// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


interface IERC721 {
    // bring TokenData here
    struct TokenData {
        uint256 id;
        string name;
        address payable owner;
        uint256 price;
    }

    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function getTokenData(uint256) external returns (string memory);
    function getTokenPrice(uint256) external returns (uint256);
    function setTokenPrice(uint256) external returns (uint256);
    function getToken(uint256) external returns (TokenData);
    function mintNFT(uint256, string memory, address payable) external returns (uint256);
}


contract MarketPlace is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    IERC721 iBloxxNftContractInterface;
    address payable nftContractAddress;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct TokenData {
        uint256 id;
        string name;
        address payable owner;
        uint256 price;
    }
    TokenData public tokenData;

    struct NFTData {
        TokenData nftTokenData;

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

    mapping (uint256 => NFTData) _nfts;
    mapping (uint256 => uint256) private _tokenPrices;
    mapping (uint256 => NFTData) private _nftsForAuction;
    mapping (uint256 => NFTData) private _nftsForFixedPrice;
    mapping (uint256 => address[]) private _nftBiddersList;
    mapping (address => uint256) allBidsOfBidder; 
    mapping (address => CollateralData) biddersCollaterals;

    event AuctionStarted(); 
    event AuctionEnded(address highest_bidder, uint highest_bid); 
    event NewBid(address indexed sender, uint amount, uint time); 
    event WinnerAnnounced(address payable winner, uint winner_bid_amount, bytes tx_data); 
    event Withdraw(address bidder, uint, bytes);


    // ether scan link for my quick reference: 
    // https://goerli.etherscan.io/nft/0x90509fdb1523f0ae75f2f0e5f47781ea90d1744b/10

    // TODO: Access Token Data
    // TODO: Track bidders by tokenID  -- use map and struct, and update map at bid function
    // TODO: Track auction ending time by tokenID 
    // TODO: Track auction based tokens and retun full data - use mapp and struct and update minting time
    // TODO: Test cases for each of the functioins 
    // TODO: Create NodeJs API to interact with these funtions


    function initialize(address defaultAdmin, address upgrader)
        initializer public
    {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, upgrader);

        bytes memory nftContractBytes = hex"4ff75e8620c6699b9177337ac2eac2e24111d5aa";
        nftContractAddress = payable(address(abi.decode(nftContractBytes, (address))));
        iBloxxNftContractInterface = IERC721(nftContractAddress);

        IERC721.TokenData _iBloxxTokenData;
    }

    function getTokenMetadata(uint256 tokenId) public returns (string memory) { 
        return iBloxxNftContractInterface.getTokenData(tokenId); 
    } 

    function getNFTOwner(uint256 nftId) private returns (address payable){
        iBloxxNftContractInterface.getTokenData[nftId].owner;
    }

    // single Aucton NFT
    function setAuctionNFTs(uint256 nftId, NFTData memory nft) private returns (bool){
        _nftsForAuction[nftId] = NFTData;
    }
    
    function updateAuctionNFT(uint256 nftId) private returns (bool){}

    // Aucton NFTs
    function getAllAuctionNFTs() public returns (NFTData memory){}

    function removeNftFromAucton(uint256) private returns (bool){}

    // Fixed-Price NFTs
    function setFixedPriceNFTs(uint256) private returns (bool){}

    function getFixedPriceNFTs()public returns (NFTData memory){}

    function updateFixedPriceNFT(uint256) private returns (bool){}

    // Get and Set highest bid and bidder
    function setHighestBid(uint256 nftId, uint256 _highestBid) private {
        _nftsForAuction[nftId].highestBid = _highestBid;
    }

    function getHighestBid(uint256 nftId) public returns(uint256){
        return _nftsForAuction[nftId].highestBid;
    }

    function setHighestBidder(uint256 nftId, address payable _highestBidder) public {
        _nftsForAuction[nftId].highestBidder = _highestBidder;
    }

    function getHighestBidder(uint256 nftId) public returns (address payable){
        return _nftsForAuction[nftId].highestBidder;
    }

    // Auction status for an NFT
    function checkAuctionStartedSatus(uint256 nftId) public returns (bool){
        return _nftsForAuction[nftId].auctionStarted;
    }

    function checkAuctionEndSatus(uint256 nftId) public returns (bool){
        return _nftsForAuction[nftId].auctionEnded;
    }

    // Auction End date
    function setAuctoinEndDate(uint256 nftId, uint256 endsAt) public {
        return _nftsForAuction[nftId].auctionEndsAt = endsAt;
    }

    function getAuctoinEndDateTime(uint256 nftId) public returns(uint256){
        return _nftsForAuction[nftId].auctionEndsAt;
    }

    // Toggle auction ended variable
    function endAuction(uint256 nftId) public {
        _nftsForAuction[nftId].auctionEnded = true;
    }

    function setBid(uint256 nftId, address payable bidder) private{

    }

    // Set / Get bidders for an NFT
    function setBidder(uint256 nftId, address payable bidder) private{
        _nftBiddersList[nftId].push(bidder);
    }

    function getBidders(uint256 nftId) public returns (address payable){
        return _nftBiddersList[nftId];
    }

    // Hold colateral of bidders
    function holdCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private {

            // Declare CollateralData type instance
            CollateralData collateralData;
            collateralData.nftId = _nftId;
            collateralData.bidder = _bidder;
            collateralData.collateralAmount += newBidOffer;
            // Add to collaterals record
            biddersCollaterals[_bidder] = collateralData;
    }

    function updateCollateral(uint256 _nftId, address payable _bidder, uint256 newBidOffer) private returns (bool){
        bool flag = false;
        // check token match
        if (_nftId == biddersCollaterals[_bidder].nftId){

            // Update the collateral record
            biddersCollaterals[_bidder].collateralAmount += newBidOffer;
            flag = true;
        }
        return flag;
    }
 
    // Creat NFT with user input data
    function createNFT(uint256 price, string memory nftName, bool isForAuction, uint256 auctonEndTime) external{
        
        uint256 newNftID = iBloxxNftContractInterface.mintNFT(price, nftName, payable(msg.sender));

        nftData.id = newNftID;
        nftData.price = price;
        nftData.name = nftName;
        nftData.forAuction = isForAuction;
        nftData.owner = payable(msg.sender);
        nftData.auctionEndTime = auctonEndTime;
        
        // work here
        if (isForAuction){
            setAuctionNFTs(newNftID);
        }else{
            setFixedPriceNFTs(newNftID);
        }
        
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 

        // check for owner 
        tokenData = iBloxxNftContractInterface.getTokenData(nftId);

        require(msg.sender == tokenData.owner, "Unauthorised request!");

        require(checkAuctionStartedSatus(nftId), "Auction has already started!");

        // Set NFT for Auction
        nftData.nftTokenData = tokenData;
        nftData.isForAuction = true;
        nftData.auctionStarted = true;
        nftData.highestBidder = payable(msg.sender);
        nftData.highestBid = initialPrice;
        nftData.auctionEndsAt = auctionEndsAt;

        setAuctionNFTs(nftData);

        // take ownership of token from the auctioner for swift management 
        iBloxxNftContractInterface.transferFrom(msg.sender, address(this), nftId);
        
        emit AuctionStarted();  
        }


    function endAuction(uint256 nftId) external{
        address payable _owner = getNFTOwner(nftId);
        require(msg.sender == _owner, "Unauthorised Operation");

        require(checkAuctionEndSatus(nftId), "Auction already ended.");
        require(block.timestamp >= getAuctoinEndDateTime(nftId), "It's not ending time yet.");

        // default value for address(0) is a zero filled address hance it's the auction initiator
        if(getHighestBidder(nftId) != address(0)){
            
            // transfer nft to winner 
            iBloxxNftContractInterface.transferFrom(address(this), getHighestBidder(nftId), nftId);
            
            // pay to auction initiator 
            (bool sent, bytes memory tx_data) = _owner.call{value: getHighestBid(nftId)}(
                abi.encodeWithSignature("")
            ); 
            require(sent, "Payment to auction owner transaction has failed!");
            
            emit WinnerAnnounced(getHighestBidder(nftId), getHighestBid(nftId), tx_data);
            
        } 
        else{
            iBloxxNftContractInterface.transferFrom(address(this), _owner, nftId);
        }

        // highestBid determins the winner
        // call winnerAnnouced function somewhere around here
    
        endAuction(nftId);
        emit AuctionEnded(_nftsForAuction[nftId].highestBidder, _nftsForAuction[nftId].highestBid);
    }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        
        require(checkAuctionStartedSatus(nftId), "Auction has NOT started yet!");
        require(checkAuctionEndSatus(nftId), "Auction has ended!");
        require( offeredPrice > getHighestBid(nftId), "Auction has ended!");

        // Set highestBidder to current bid
        setHighestBid(nftId, offeredPrice);  

        // if any one bid for this auction
        // zero filled address check indicates that.
        address payable _highestBidder = getHighestBidder(nftId);
        if (_highestBidder != address(0)){

            // 1. Take collateral

            // Check bidder already made bids to this auction
            bool exists = checkBidder(payable(msg.sender), nftId);

            if(!exists){

                holdCollateral(nftId, _highestBidder, offeredPrice);

            }else{
                // keep the sum of each the bid money of this bidder 
                updateCollateral(nftId, _highestBidder, offeredPrice);
            }
        }

        // 2. Make the bid  
        setHighestBidder(payable(msg.sender));

        emit NewBid(highest_bidder, highest_bid, block.timestamp); 
    }

    function withdraw() payable external{
        uint256 pay_back = all_bids[msg.sender];
        require(pay_back > 0, "You have no balance!");
        // TODO: give it some idle time to avoid a breach
        
        // Reset due payback balance amount to zero
        all_bids[msg.sender] = 0;

        // send the due payment
        (bool sent, bytes memory tx_data) = payable(msg.sender).call{value: pay_back}(
            abi.encodeWithSignature(" ")
        );
        require(sent, "Withdraw transaction failed!");

        emit Withdraw(msg.sender, pay_back, tx_data);
    }


    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
