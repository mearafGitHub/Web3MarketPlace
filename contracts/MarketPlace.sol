// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; 
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
    // event AuctionEnded(uint256 auctionedNFTId, address highestBidderAddress, uint highestBidAmount); 
    // event NewBid(address indexed bidder, uint256 offerAmount, uint256 bidTime); 
    // event WinnerAnnounced(uint256 auctionedNFT, address payable winnerAddress, uint winnerBidAmount, bytes transactionData); 
    // event Withdraw(address bidderAddress, uint256 auctionedNFTId, bytes transactionData);


    // Intialize contract with Upgradability and Role management 
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

    function  getAllFixedPriceNFT() public view returns (NFTData[] memory){
        return _nftsFixedPriceList;
    }

    function  getBiddersOf(uint256 nftId) public view returns ( address[] memory){
        return _nftBiddersList[nftId];
    }

    function  getAuctionEndTime(uint256 nftId) public view returns (uint256){
        return _nftsForAuctionList[nftId].auctionEndTime;
    }
  
    function createNFT(uint256 price, string memory nftName, bool isForAuction, uint256 auctonEndTime) external onlyRole(MINTER_ROLE) {

        uint256 newTokenId = _nextTokenId++; 
        _mint(msg.sender, newTokenId);
        
        // Create new nft data
        NFTData memory _nftData;

        _nftData.price = price;
        _nftData.name = nftName;
        _nftData.owner = payable(msg.sender);
        _nftData.id = newTokenId;
        _nftData.forAuction = isForAuction;
        _nftData.auctionEndTime = auctonEndTime;
        _allNFTs[newTokenId] = nftData;

        if (isForAuction){
            _nftsForAuctionList.push(nftData);
            _auctionNFT[newTokenId] = nftData;
        }else{
            _nftsFixedPriceList.push(nftData); 
            _fixedPriceNFT[newTokenId] = nftData;
        }
    }

    function startAuction (uint256 nftId, uint auctionEndsAt, uint256 initialPrice) external { 

        address payable _owner = payable(_auctionNFT[nftId].owner);
        require(msg.sender != _owner); // "Unauthorised!"
        require(_allNFTs[nftId].id != 0); // "Invalid nftId"
        require(_allNFTs[nftId].auctionStarted); // "Already started!"

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

    // function endAuction(uint256 nftId) external{
    //     address payable _owner = payable(_auctionNFT[nftId].owner);
        
    //     require(msg.sender != _owner); // "Unauthorised!"
    //     require(_auctionNFT[nftId].auctionEnded); // "Auction already ended."
    //     require(block.timestamp >= _auctionNFT[nftId].auctionEndTime); // "It's not ending time yet."

    //     address theHighestBidder = _highestBidder[nftId];
    //     uint256 theHighestBid = _highestBid[nftId];
    //     // Sell to winner
    //     if(theHighestBidder != address(0)){
    //         (bool sent, bytes memory txData) = _owner.call{value: theHighestBid}(
    //             abi.encodeWithSignature("")
    //         ); 
    //         transferFrom(address(this), theHighestBidder, nftId);
    //         require(sent, string(txData));

    //         // emit WinnerAnnounced(nftId, payable(theHighestBidder), theHighestBid, txData);
    //     } else{
    //         // Transfer nft back to owner
    //         transferFrom(address(this), _owner, nftId);
    //     }
    //     _allNFTs[nftId].auctionEnded = true;

    //     // Remove from list and map
    //     delete _nftsForAuctionList[nftId];
    //     _nftsForAuctionList.pop();
        
    //     // emit AuctionEnded( nftId, theHighestBidder, theHighestBid);
    // }

    function bid(uint256 nftId, uint256 offeredPrice) payable external{
        // Check if started, ended, and price increase
        require(_auctionNFT[nftId].auctionStarted); // "Auction has NOT started yet!"
        require(_auctionNFT[nftId].auctionEnded);  // "Auction has ended!"
        require( offeredPrice > _highestBid[nftId]);  // "Price offer must be greater than the most recent bid!"

        address payable theHighestBidder = payable(_highestBidder[nftId]);

        // Insert to traking map
        _highestBidder[nftId] = theHighestBidder;
        _highestBid[nftId] = offeredPrice;

        // emit NewBid(theHighestBidder, _highestBid[nftId], nftId); 
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
