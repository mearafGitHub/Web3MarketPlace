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
    function getTokenPrice(uint256) external returns (uint256);
    function setTokenPrice(uint256) external returns (uint256);
    function getTokenData(uint256) external returns (uint256);
    function getTokenOwner(uint256) external returns (address);
    function mintNFT(uint256, string memory, address payable) external returns (uint256);
}


contract MarketPlace is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    IERC721 public iBloxxNftContract;
    address public iBloxxNftContractAddress;
    IERC721.TokenData public _iBloxxTokenData;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

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

    mapping (uint256 => NFTData) _nfts;
    mapping (uint256 => uint256) private _tokenPrices;
    mapping (uint256 => address[]) private _nftBiddersList;
    mapping (address => uint256) allBidsOfBidder; 
    mapping (uint256 => uint256) _highestBid; 
    mapping (uint256 => address) _highestBidder; 
    mapping (uint256 => NFTData[]) _auctionNFTs; 
    mapping (uint256 => NFTData[]) _ficedPriceNFTs; 
    mapping (uint256 => CollateralData[]) biddersCollaterals;
    mapping (address => uint256[]) biddersOfNftListByAddress;

    event AuctionStarted(); 
    event AuctionEnded(address highest_bidder, uint highest_bid); 
    event NewBid(address indexed sender, uint amount, uint time); 
    event WinnerAnnounced(address payable winner, uint winner_bid_amount, bytes transaction_data); 
    event Withdraw(address bidder, uint, bytes);


    function initialize(address defaultAdmin, address upgrader)
        initializer public
    {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, upgrader);

        bytes memory nftContractBytes = hex"4ff75e8620c6699b9177337ac2eac2e24111d5aa";
        address contractAddress = payable(address(abi.decode(nftContractBytes, (address))));
        iBloxxNftContract = IERC721(contractAddress);
    }

    // single Aucton NFT
    function setAuctionNFTs(NFTData memory nft) public{
        _nftsForAuctionList.push(nft);
    }
    
    function updateAuctionNFT(uint256 nftId) private returns (bool){}

    // Aucton NFTs
    function getAllAuctionNFTs() public view returns (NFTData[] memory){
        return _nftsForAuctionList;
    }

    function removeNftFromAucton(uint256) private returns (bool){}

    // Fixed-Price NFTs
    function setFixedPriceNFTs(NFTData memory nft) private{
        //_nftsForFixedPrice[nftId] = nft;
        _nftsForAuctionList.push(nft);
    }

    // Set and Get NFT price
    function setPriceNFT(uint256 nftId, uint256 price) public {
        _nfts[nftId].price = price;
    }

    function getPriceNFT(uint256 nftId) public returns (uint256){}

    function updatePriceNFT(uint256 nftId) private returns (bool){}

    // Get and Set highest bid and bidder
    function setHighestBid(uint256 nftId, uint256 highestBid) private {
        _highestBid[nftId] = highestBid;
    }

    function getHighestBid(uint256 nftId) public view returns(uint256){
        return _highestBid[nftId];
    }

    function setHighestBidder(uint256 nftId, address theHighestBidder) public {
        _highestBidder[nftId] = theHighestBidder;
    }

    function getHighestBidder(uint256 nftId) public view returns (address){
        return _highestBidder[nftId];
    }

    // get one auction NFT
    function getAuctionNFTData(uint256 nftId) public view returns (NFTData memory){
        NFTData memory tempNftData;
        for (uint256 i=0; i<=_nftsForAuctionList.length; i++){
            if (_nftsForAuctionList[i].id == nftId ){
                tempNftData = _nftsForAuctionList[i];
            }
        }
        return tempNftData;
    }

    // Auction status for an NFT
    function checkAuctionStartedSatus(uint256 nftId) view public returns (bool){
        // get nft 
        return getAuctionNFTData(nftId).auctionStarted;
    }

    function checkAuctionEndSatus(uint256 nftId) public view returns (bool){
        return getAuctionNFTData(nftId).auctionEnded;
    }

    // Auction End date
    function setAuctoinEndDate(uint256 nftId, uint256 endsAt) private view {
        getAuctionNFTData(nftId).auctionEndTime = endsAt;
    }

    function getAuctoinEndDateTime(uint256 nftId) public view returns(uint256){
        return getAuctionNFTData(nftId).auctionEndTime;
    }

    // Toggle auction ended variable
    function setEndAuction(uint256 nftId) private view {
        getAuctionNFTData(nftId).auctionEnded = true;
    }

    // Set / Get bidders for an NFT
    function setBid(uint256 nftId, address payable bidder) private{
        // TODO: impliment
    }

    function setBidder(uint256 nftId, address payable bidder) private{
        _nftBiddersList[nftId].push(bidder);
    }

    function getBidders(uint256 nftId) public view returns (address[] memory){
        return _nftBiddersList[nftId];
    }

    function checkBidder( address payable _bidder, uint256 nftId) public returns (bool){
        bool found;
        address[] memory biddersList = _nftBiddersList[nftId];

        // Invert mapping for searching
        // map returns default value if key doesn't exist

        for (uint i=0; i<biddersList.length; i++){
            address bidder = biddersList[i];
            biddersOfNftListByAddress[bidder].push(nftId);
        }
        uint size = biddersOfNftListByAddress[_bidder].length;

        // toggle flag
        if(size != 0){
            found = true;
        }
        return found;

    } 

    // Hold colateral of bidders
    function holdCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private {

            // Declare CollateralData type instance
            CollateralData memory collateralData;
            collateralData.nftId = _nftId;
            collateralData.bidder = _bidder;
            collateralData.collateralAmount += newBidOffer;
            // Add to collaterals record
            biddersCollaterals[_nftId].push(collateralData);
    }

    function updateCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private view returns (bool){
        bool flag = false;

        // get lsit of collaterals
        CollateralData[] memory collaterals = biddersCollaterals[_nftId];

        // Linear search of the collateral data of the given NFT and bidder address
        for (uint i=0; i<collaterals.length; i++){
            uint256 collateralNftId = collaterals[i].nftId;
            address bidderAddress = collaterals[i].bidder;

            // check token-owner match
            if (collateralNftId == _nftId && bidderAddress == _bidder){
                // Update the collateral record
                collaterals[i].collateralAmount += newBidOffer;
                flag = true;
            }
        }
        return flag;
    }

    function calculatePayBackAmount(uint256 nftId, address payable bidder) public view returns (uint256){
        uint256 payBackAmount = 0;

        // get lsit of collaterals
        CollateralData[] memory collaterals = biddersCollaterals[nftId];

        // Linear search of the collateral data of the given NFT and bidder address
        for (uint i=0; i<collaterals.length; i++){
            uint256 collateralNftId = collaterals[i].nftId;
            address bidderAddress = collaterals[i].bidder;
            
            // check token-owner match
            if (collateralNftId == nftId && bidderAddress == bidder){
                // Update the collateral record
                payBackAmount = collaterals[i].collateralAmount;
            }
        }

        return payBackAmount;

    }

    // Creat NFT with user input data  
    function createNFT(uint256 price, string memory nftName, bool isForAuction, uint256 auctonEndTime) external{
        
        uint256 newNftID = iBloxxNftContract.mintNFT(price, nftName, payable(msg.sender));

        nftData.price = price;
        nftData.name = nftName;
        nftData.owner = payable(msg.sender);
        nftData.id = newNftID;
        nftData.forAuction = isForAuction;
        nftData.auctionEndTime = auctonEndTime;
        
        if (isForAuction){
            setAuctionNFTs(nftData);
        }else{
            setFixedPriceNFTs(nftData);
        }
        
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 

        // check for owner 
        // IERC721.TokenData memory _tokenData = BloxxNftContract.getTokenData(nftId) ;
        // address owner = iBloxxNftContract.getTokenOwner(nftId);

        require(msg.sender == _iBloxxTokenData.owner, "Unauthorised request!");
        require(checkAuctionStartedSatus(nftId), "Auction has already started!");

        // get nft from map
        NFTData memory _nftData = _nfts[nftId];

        // Set NFT for Auction
        _nftData.forAuction = true;
        _nftData.auctionStarted = true;
        _nftData.highestBidder = payable(msg.sender);
        _nftData.highestBid = initialPrice;
        _nftData.auctionEndTime = auctionEndsAt;

        setAuctionNFTs(_nftData);

        // take ownership of token from the auctioner for swift management 
        iBloxxNftContract.transferFrom(payable(msg.sender), address(this), nftId);
        
        emit AuctionStarted();  
        }


    function endAuction(uint256 nftId) external{
        address payable _owner = payable (iBloxxNftContract.getTokenOwner(nftId));
        require(msg.sender == _owner, "Unauthorised Operation");

        require(checkAuctionEndSatus(nftId), "Auction already ended.");
        require(block.timestamp >= getAuctoinEndDateTime(nftId), "It's not ending time yet.");

        address theHighestBidder = getHighestBidder(nftId);
        // default value for address(0) is a zero filled address hance it's the auction initiator
        if(theHighestBidder != address(0)){
            
            // transfer nft to winner 
            iBloxxNftContract.transferFrom(address(this), theHighestBidder, nftId);

            uint256 theHighestBid = getHighestBid(nftId);
            // pay to auction initiator 
            (bool sent, bytes memory txData) = _owner.call{value: theHighestBid}(
                abi.encodeWithSignature("")
            ); 
            require(sent, "Payment to auction owner transaction has failed!");
            
            emit WinnerAnnounced(payable(theHighestBidder), theHighestBid, txData);
            
        } 
        else{
            // Send back the NFT bact to the owner
            iBloxxNftContract.transferFrom(address(this), _owner, nftId);
        }

        setEndAuction(nftId);

        emit AuctionEnded(getAuctionNFTData(nftId).highestBidder, getAuctionNFTData(nftId).highestBid);
    }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        
        require(checkAuctionStartedSatus(nftId), "Auction has NOT started yet!");
        require(checkAuctionEndSatus(nftId), "Auction has ended!");
        require( offeredPrice > getHighestBid(nftId), "Auction has ended!");

        // Set highestBidder to current bid
        setHighestBid(nftId, offeredPrice);  

        // if any one bid for this auction
        // zero filled address check indicates that.
        address payable theHighestBidder = payable (getHighestBidder(nftId));
        if (theHighestBidder != address(0)){

            // 1. Take collateral

            // Check bidder already made bids to this auction
            bool exists = checkBidder(payable(msg.sender), nftId);

            if(!exists){
                // record collateral
                holdCollateral(nftId, theHighestBidder, offeredPrice);

            }else{
                // keep the sum of each the bid money of this bidder 
                updateCollateral(nftId, theHighestBidder, offeredPrice);
            }
        }

        // 2. Make the bid  
        setHighestBidder(nftId, payable(msg.sender));

        emit NewBid(theHighestBidder, getHighestBid(nftId), nftId); 
    }

    function withdraw(uint256 nftId) external{

        uint256 payBackAmount = calculatePayBackAmount(nftId, payable(msg.sender));
        require(payBackAmount > 0, "You have no balance!");

        // send the due payment
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
