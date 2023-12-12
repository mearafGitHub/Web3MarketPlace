// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; 
// "optimizer: enabled; runs: 200";
// "revertStrings: disabled";

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";


contract MarketPlace is Initializable, AccessControlUpgradeable, UUPSUpgradeable, ERC721Upgradeable {

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 _nextTokenId;

    struct NFTData {
        uint256 id;
        string name;
        address owner;
        uint256 price;
        bool forAuction;
        uint auctionEndTime;
        bool auctionStarted;
        bool auctionEnded;
        uint256 highestBid;
        address payable highestBidder; 
    }
    NFTData public nftData;
    NFTData[] public _nftsForAuctionList;
    NFTData[] public _nftsFixedPriceList;

    struct CollateralData {
        uint256 collateralAmount;
        uint256 nftId;
        address payable bidder;
    }

    mapping (uint256 => uint256) _highestBid; 
    mapping (uint256 => NFTData) _auctionNFT;
    mapping (uint256 => address payable) _highestBidder; 
    mapping (uint256 => NFTData) _fixedPriceNFT;
    mapping (uint256 => NFTData) public _allNFTs;
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
    }

    // Aucton NFTs
    function getAllAuctionNFTs() public view returns (NFTData[] memory){
        return _nftsForAuctionList;
    }

    function getPriceNFT(uint256 nftId) public view returns (uint256){
        return _fixedPriceNFT[nftId].price;
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

    function checkBidder( address bidder, uint256 nftId) public view returns (bool){
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
    
    function holdCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private returns(bool){
        bool hold;
        // Create new collateral data
        CollateralData memory collateralData;
        collateralData.nftId = _nftId;
        collateralData.bidder = _bidder;
        collateralData.collateralAmount += newBidOffer;
        
        // Hold collateral -- would deduct ETH from wallet in real implememntaton
        _biddersCollaterals[_nftId].push(collateralData);
        hold = true;

        return hold;
    }

    function updateCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private view returns(bool){
        bool flag = false;
        CollateralData[] memory collaterals = _biddersCollaterals[_nftId];
        
        if (collaterals.length > 0){
            // Find precious collateral
            for (uint256 i=0; i<collaterals.length; i++){
                uint256 collateralNftId = collaterals[i].nftId;
                address bidderAddress = collaterals[i].bidder;

                if (collateralNftId == _nftId && bidderAddress == _bidder){
                    // Delete previous
                    delete collaterals[i];
                    // Add new
                    collaterals[i].collateralAmount = newBidOffer;
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
            for (uint256 i=0; i<collaterals.length; i++){
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

        uint256 newTokenId = _nextTokenId++; 
        _mint(msg.sender, newTokenId);
        uint256 newNftID = newTokenId;
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
            _auctionNFT[newNftID] = nftData;
        }else{
            _nftsForAuctionList.push(nftData);
            _fixedPriceNFT[newNftID] = nftData;
        }
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 

        address payable _owner = payable(_auctionNFT[nftId].owner);
        require(msg.sender != _owner, "Unauthorised!");

        require(_allNFTs[nftId].id != 0, "NFT not found or Invalid");
        require(msg.sender != _owner, "Unauthorised!");
        require(_allNFTs[nftId].auctionStarted, "Auction has already started!");

        NFTData memory _nftData = _allNFTs[nftId];
        _nftData.forAuction = true;
        _nftData.auctionStarted = true;
        _nftData.highestBidder = payable(msg.sender);
        _nftData.highestBid = initialPrice;
        _nftData.auctionEndTime = auctionEndsAt;

        // Insert to trackers
        _nftsForAuctionList.push(_nftData);
        _auctionNFT[nftId] = _nftData;

        // add Bidder to list
        _nftBiddersList[nftId].push(msg.sender);
        
        emit AuctionStarted(nftId);  
    }

    function endAuction(uint256 nftId) external{
        address payable _owner = payable(_auctionNFT[nftId].owner);

        require(msg.sender != _owner, "Unauthorised!");
        require(getAuctionNFTData(nftId).auctionEnded, "Auction already ended.");
        require(block.timestamp >= getAuctionNFTData(nftId).auctionEndTime, "It's not ending time yet.");

        address theHighestBidder = _highestBidder[nftId];
        uint256 theHighestBid = _highestBid[nftId];
        // Sell to winner
        if(theHighestBidder != address(0)){
            (bool sent, bytes memory txData) = _owner.call{value: theHighestBid}(
                abi.encodeWithSignature("")
            ); 
            transferFrom(address(this), theHighestBidder, nftId);
            require(sent, "Payment failed!");

            emit WinnerAnnounced(nftId, payable(theHighestBidder), theHighestBid, txData);
        } else{
            // Transfer nft back to owner
            transferFrom(address(this), _owner, nftId);
        }

        _allNFTs[nftId].auctionEnded = true;

        // Remove from list and map
        delete _nftsForAuctionList[nftId];
        _nftsForAuctionList.pop();
        
        emit AuctionEnded( nftId, theHighestBidder, theHighestBid);
    }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        // Check if started, ended, and price increase
        require(getAuctionNFTData(nftId).auctionStarted, "Auction has NOT started yet!");
        require(getAuctionNFTData(nftId).auctionEnded, "Auction has ended!");
        require( offeredPrice > _highestBid[nftId], "Price offer must be greater than the most recent bid!");

        address payable theHighestBidder = payable(_highestBidder[nftId]);
        bool flag;
        // If any bidder found
        if (theHighestBidder != address(0)){
            // Check for new bidder to this NFT
            bool exists = checkBidder(msg.sender, nftId);
            if(!exists){
                flag = holdCollateral(nftId, theHighestBidder, offeredPrice);
                require(flag, "Holding Colateral Failed!");

            }else{
                flag = updateCollateral(nftId, theHighestBidder, offeredPrice);
                require(flag, "Holding Colateral Failed!");
            }
        } 
        _highestBidder[nftId] = theHighestBidder;

        // Insert to traking map
        _highestBid[nftId] = offeredPrice;
        _highestBidder[nftId] = theHighestBidder;

        emit NewBid(theHighestBidder, _highestBid[nftId], nftId); 
    }

    function withdraw(uint256 nftId) external{
        uint256 payBackAmount = calculatePayBackAmount(nftId, payable(msg.sender));
        require(payBackAmount > 0, "No balance!");
        (bool sent, bytes memory txData) = payable(msg.sender).call{value: payBackAmount}(
            abi.encodeWithSignature(" ")
        );
        require(sent, "Withdraw transaction failed!");
        emit Withdraw(msg.sender, payBackAmount, txData);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC721Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
