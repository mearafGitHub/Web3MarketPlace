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

    mapping (uint256 => NFTData) public _allNFTs;

    mapping (uint256 => uint256) private _tokenPrices;

    mapping (uint256 => uint256) _highestBid; 
    mapping (uint256 => address) _highestBidder; 

    mapping (address => uint256) _bidderAuctionedNFTs; 
    mapping (address => uint256[]) _ownerFixedPriceNFTs; 

    mapping (uint256 => address[]) private _nftBiddersList;

    mapping (uint256 => CollateralData[]) public _biddersCollaterals;

    event AuctionStarted(uint256 nftId); 
    event AuctionEnded(uint256 auctionedNFTId, address highestBidderAddress, uint highestBidAmount); 
    event NewBid(address indexed bidder, uint256 offerAmount, uint256 bidTime); 
    event WinnerAnnounced(uint256 auctionedNFT, address payable winnerAddress, uint winnerBidAmount, bytes transactionData); 
    event Withdraw(address bidderAddress, uint256 auctionedNFTId, bytes transactionData);


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

    // Aucton NFTs
    function getAllAuctionNFTs() public view returns (NFTData[] memory){
        return _nftsForAuctionList;
    }

    // Fixed-Price NFTs
    function setFixedPriceNFTs(NFTData memory nft) private{
        //_nftsForFixedPrice[nftId] = nft;
        _nftsForAuctionList.push(nft);
    }

    // Set and Get NFT price
    function setPriceNFT(uint256 nftId, uint256 price) public {
        _allNFTs[nftId].price = price;
    }

    function getPriceNFT(uint256 nftId) public returns (uint256){}

    function updatePriceNFT(uint256 nftId) private returns (bool){}

    // Get and Set highest bid and bidder
    function setHighestBid(uint256 nftId, uint256 highestBid) private {
        _highestBid[nftId] = highestBid;
    }

    function setHighestBidder(uint256 nftId, address theHighestBidder) public {
        _highestBidder[nftId] = theHighestBidder;
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

    function deleteNFTfromAuctionList(uint256 nftId) private{
        for (uint256 i=0; i<=_nftsForAuctionList.length; i++){
            if (_nftsForAuctionList[i].id == nftId ){
                //tempNftData = _nftsForAuctionList[i];
                delete _nftsForAuctionList[i];
            }
        }
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

    function checkBidder( address payable bidder, uint256 nftId) public view returns (bool){
        bool found;
        address[] memory biddersList = _nftBiddersList[nftId];

        for (uint i=0; i<biddersList.length; i++){
            address _bidder = biddersList[i];
            // toggle flag
            if(_bidder != bidder){
                found = true;
            } 
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
            _biddersCollaterals[_nftId].push(collateralData);
    }

    function updateCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private view returns (bool){
        bool flag = false;

        // get lsit of collaterals
        CollateralData[] memory collaterals = _biddersCollaterals[_nftId];

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
        CollateralData[] memory collaterals = _biddersCollaterals[nftId];

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
        NFTData memory _nftData;
        _nftData.price = price;
        _nftData.name = nftName;
        _nftData.owner = payable(msg.sender);
        _nftData.id = newNftID;
        _nftData.forAuction = isForAuction;
        _nftData.auctionEndTime = auctonEndTime;

        // add to nft list
        _allNFTs[newNftID] = nftData;
        
        if (isForAuction){
            _nftsForAuctionList.push(nftData);
        }else{
            _nftsForAuctionList.push(nftData);
        }
        
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 

        // check for owner 
        require(msg.sender == _iBloxxTokenData.owner, "Unauthorised request!");
        require(checkAuctionStartedSatus(nftId), "Auction has already started!");

        // Get the nft from map
        NFTData memory _nftData = _allNFTs[nftId];

        // Set NFT for Auction
        _nftData.forAuction = true;
        _nftData.auctionStarted = true;
        _nftData.highestBidder = payable(msg.sender);
        _nftData.highestBid = initialPrice;
        _nftData.auctionEndTime = auctionEndsAt;

        //set NFT for auction
        _nftsForAuctionList.push(_nftData);

        // take ownership of token from the auctioner for swift management 
        iBloxxNftContract.transferFrom(payable(msg.sender), address(this), nftId);
        
        emit AuctionStarted(nftId);  
        }


    function endAuction(uint256 nftId) external{
        address payable _owner = payable (iBloxxNftContract.getTokenOwner(nftId));
        require(msg.sender == _owner, "Unauthorised Operation");

        require(checkAuctionEndSatus(nftId), "Auction already ended.");
        require(block.timestamp >= getAuctoinEndDateTime(nftId), "It's not ending time yet.");

        address theHighestBidder = _highestBidder[nftId];
        uint256 theHighestBid = _highestBid[nftId];

        // sell NFT for highest bidder
        // see if any one bid on this auction
        // default value for address(0) is a zero filled address. Indicates no bid.
        if(theHighestBidder != address(0)){
            
            // transfer nft to winner 
            iBloxxNftContract.transferFrom(address(this), theHighestBidder, nftId);

            // pay to auction initiator 
            (bool sent, bytes memory txData) = _owner.call{value: theHighestBid}(
                abi.encodeWithSignature("")
            ); 
            require(sent, "Payment to auction owner transaction has failed!");
            emit WinnerAnnounced(nftId, payable(theHighestBidder), theHighestBid, txData);
            
        } 
        else{
            // Send back the NFT bact to the owner
            iBloxxNftContract.transferFrom(address(this), _owner, nftId);
        }
        // toggle indicator value
         _allNFTs[nftId].auctionEnded = true;

        // delete item  
        delete _nftsForAuctionList[nftId];
       
        emit AuctionEnded( nftId, theHighestBidder, theHighestBid);
    }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        
        require(checkAuctionStartedSatus(nftId), "Auction has NOT started yet!");
        require(checkAuctionEndSatus(nftId), "Auction has ended!");
        require( offeredPrice > _highestBid[nftId], "Your offered price is must be greater than the most recent bid!");

        // Set highestBidder to current bid
        setHighestBid(nftId, offeredPrice);  

        // check if any one has bid for this auction
        address payable theHighestBidder = payable ( _highestBidder[nftId]);
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

        emit NewBid(theHighestBidder, _highestBid[nftId], nftId); 
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
