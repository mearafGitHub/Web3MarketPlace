// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// new contract addr: 0xf26262e62ef703aa09876a9d705914d6170233c6

interface IERC721 {
    // bring TokenData here
    struct TokenData {
       uint256 id;
       string name;
       address owner;
       uint256 price;
   }
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function getTokenData(uint256) external returns (uint256);
    function getTokenOwner(uint256) external returns (address);
    function mintNFT(uint256, string memory, address payable) external returns (uint256);
}


contract MarketPlace is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    IERC721 public iBloxxNftContract;
    address public iBloxxNftContractAddress;
    IERC721.TokenData public _iBloxxTokenData;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct NFTData {
        uint256 id;
        string name;
        address owner;
        uint256 price;
        bool forAuction;
        uint256 auctionEndTime;
        bool auctionStarted;
        bool auctionEnded;
        uint256 highestBid;
        address payable highestBidder; 
    }
    NFTData public nftData;

    struct CollateralData {
        uint256 collateralAmount;
        uint256 nftId;
        address payable bidder;
    }

    NFTData[] public _nftsForAuctionList;
    NFTData[] public _nftsFixedPriceList;

    mapping (uint256 => NFTData) public _allNFTs;

    mapping (uint256 => uint256) private _tokenPrices;

    mapping (uint256 => uint256) _highestBid; 
    mapping (uint256 => address) _highestBidder; 

    mapping (address => uint256) _bidderAuctionedNFTs; 
    mapping (address => uint256[]) _ownerFixedPriceNFTs; 

    mapping (uint256 => NFTData) _nftsFixedPrice;
    mapping (uint256 => NFTData) _nftsAuction;

    mapping (uint256 => address[]) private _nftBiddersList;

    mapping (uint256 => CollateralData[]) public _biddersCollaterals;

    event AuctionStarted(uint256 nftId); 
    event AuctionEnded(uint256 auctionedNFTId, address highestBidderAddress, uint highestBidAmount); 
    event NewBid(address indexed bidder, uint256 offerAmount, uint256 bidTime); 
    event WinnerAnnounced(uint256 auctionedNFT, address payable winnerAddress, uint winnerBidAmount, bytes transactionData); 
    event Withdraw(address bidderAddress, uint256 auctionedNFTId, bytes transactionData);


    function initialize(address defaultAdmin, address minter, address upgrader)
        initializer public
    {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);

        bytes memory nftContractBytes = hex"4493E79599a23D6644AEe0a2f47117D18980a645";
        address contractAddress = payable(address(abi.decode(nftContractBytes, (address))));
        iBloxxNftContract = IERC721(contractAddress);
    }

    // Aucton NFTs
    function getAllAuctionNFTs() public view returns (NFTData[] memory){
        return _nftsForAuctionList;
    }

    function getPriceNFT(uint256 nftId) public view returns (uint256){
        return _nftsFixedPrice[nftId].price;
    }
    
    // Get one auctioned NFT
    function getAuctionNFTData(uint256 nftId) public view returns (NFTData memory){
        NFTData memory tempNftData;
        if (_nftsForAuctionList.length > 0){
            for (uint256 i=0; i<=_nftsForAuctionList.length; i++){
                if (_nftsForAuctionList[i].id == nftId ){
                    tempNftData = _nftsForAuctionList[i];
                }
            }
        }
        return tempNftData;
    }

    function checkBidder( address payable bidder, uint256 nftId) public view returns (bool){
        bool found;
        address[] memory biddersList = _nftBiddersList[nftId];
        if (biddersList.length > 0){
            for (uint i=0; i<=biddersList.length; i++){
            address _bidder = biddersList[i];
                if(_bidder != bidder){
                   found = true;
                }
            }
        }
        return found;
    } 
    
    function holdCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private {
            CollateralData memory collateralData;
            collateralData.nftId = _nftId;
            collateralData.bidder = _bidder;
            collateralData.collateralAmount += newBidOffer;
            _biddersCollaterals[_nftId].push(collateralData);
    }

    function updateCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private view returns (bool){
        bool flag = false;
        CollateralData[] memory collaterals = _biddersCollaterals[_nftId];
        if (collaterals.length > 0){
            for (uint i=0; i<=collaterals.length; i++){
                uint256 collateralNftId = collaterals[i].nftId;
                address bidderAddress = collaterals[i].bidder;
                if (collateralNftId == _nftId && bidderAddress == _bidder){
                    collaterals[i].collateralAmount += newBidOffer;
                    flag = true;
                }
            }
       }
        return flag;
    }

    function calculatePayBackAmount(uint256 nftId, address payable bidder) public view returns (uint256){
        uint256 payBackAmount = 0;
        CollateralData[] memory collaterals = _biddersCollaterals[nftId];
        if (collaterals.length > 0){
            for (uint i=0; i<=collaterals.length; i++){
                uint256 collateralNftId = collaterals[i].nftId;
                address bidderAddress = collaterals[i].bidder;
                if (collateralNftId == nftId && bidderAddress == bidder){
                     payBackAmount = collaterals[i].collateralAmount;
                }
            }
        }
        return payBackAmount;
    }

    function createNFT(uint256 price, string memory nftName, bool isForAuction, uint256 auctonEndTime) external onlyRole(MINTER_ROLE) {
        uint256 newNftID = iBloxxNftContract.mintNFT(price, nftName, payable(msg.sender));
        NFTData memory _nftData;
        _nftData.price = price;
        _nftData.name = nftName;
        _nftData.owner = payable(msg.sender);
        _nftData.id = newNftID;
        _nftData.forAuction = isForAuction;
        _nftData.auctionEndTime = auctonEndTime;
        _allNFTs[newNftID] = nftData;
        if (isForAuction){
            _nftsForAuctionList.push(nftData);
            _nftsAuction[newNftID] = nftData;
        }else{
            _nftsForAuctionList.push(nftData);
            _nftsFixedPrice[newNftID] = nftData;
        }
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 
        require(_allNFTs[nftId].id != 0, "NFT not found or Invalid");
        require(msg.sender == _iBloxxTokenData.owner, "Unauthorised request!");
        require(_allNFTs[nftId].auctionStarted, "Auction has already started!");
        NFTData memory _nftData = _allNFTs[nftId];
        _nftData.forAuction = true;
        _nftData.auctionStarted = true;
        _nftData.highestBidder = payable(msg.sender);
        _nftData.highestBid = initialPrice;
        _nftData.auctionEndTime = auctionEndsAt;
        _nftsForAuctionList.push(_nftData);
        iBloxxNftContract.transferFrom(payable(msg.sender), address(this), nftId);
        emit AuctionStarted(nftId);  
    }

    function endAuction(uint256 nftId) external{
        address payable _owner = payable (iBloxxNftContract.getTokenOwner(nftId));
        require(msg.sender == _owner, "Unauthorised Operation");
        require(getAuctionNFTData(nftId).auctionEnded, "Auction already ended.");
        require(block.timestamp >= getAuctionNFTData(nftId).auctionEndTime, "It's not ending time yet.");
        address theHighestBidder = _highestBidder[nftId];
        uint256 theHighestBid = _highestBid[nftId];
        if(theHighestBidder != address(0)){
            iBloxxNftContract.transferFrom(address(this), theHighestBidder, nftId);
            (bool sent, bytes memory txData) = _owner.call{value: theHighestBid}(
                abi.encodeWithSignature("")
            ); 
            require(sent, "Payment to auction owner transaction has failed!");
            emit WinnerAnnounced(nftId, payable(theHighestBidder), theHighestBid, txData);
        } 
        else{
            iBloxxNftContract.transferFrom(address(this), _owner, nftId);
        }
         _allNFTs[nftId].auctionEnded = true;
        delete _nftsForAuctionList[nftId];
        emit AuctionEnded( nftId, theHighestBidder, theHighestBid);
    }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        require(getAuctionNFTData(nftId).auctionStarted, "Auction has NOT started yet!");
        require(getAuctionNFTData(nftId).auctionEnded, "Auction has ended!");
        require( offeredPrice > _highestBid[nftId], "Your offered price is must be greater than the most recent bid!");
        _highestBid[nftId] = offeredPrice;
        address payable theHighestBidder = payable ( _highestBidder[nftId]);
        if (theHighestBidder != address(0)){
            bool exists = checkBidder(payable(msg.sender), nftId);
            if(!exists){
                holdCollateral(nftId, theHighestBidder, offeredPrice);
            }else{
                updateCollateral(nftId, theHighestBidder, offeredPrice);
            }
        } 
        _highestBidder[nftId] = theHighestBidder;
        emit NewBid(theHighestBidder, _highestBid[nftId], nftId); 
    }

    function withdraw(uint256 nftId) external{
        uint256 payBackAmount = calculatePayBackAmount(nftId, payable(msg.sender));
        require(payBackAmount > 0, "You have no balance!");
        (bool sent, bytes memory tx_data) = payable(msg.sender).call{value: payBackAmount}(
            abi.encodeWithSignature(" ")
        );
        require(sent, "Withdraw transaction failed!");
        emit Withdraw(msg.sender, payBackAmount, tx_data);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
