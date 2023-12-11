// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


interface IERC721 {
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
}


contract MarketPlace is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address payable owner;
    address payable highest_bidder;
    address payable auction_initiator;

    bool public is_started;
    bool public is_ended;
    uint public end_at;
    uint public highest_bid;

    mapping (address => uint) all_bids;

    event AuctionStarted(); 
    event AuctionEnded(address highest_bidder, uint highest_bid); 
    event NewBid(address indexed sender, uint amount, uint time); 
    event WinnerAnnounced(address payable winner, uint winner_bid_amount, bytes tx_data); 
    event Withdraw(address bidder, uint, bytes);

    IERC721 nft;
    uint256 nft_id;
    address payable nftContractCddress;

    // ether scan link for my quick reference: 
    // https://goerli.etherscan.io/nft/0x90509fdb1523f0ae75f2f0e5f47781ea90d1744b/10

    // TODO: Access Token Data

    
    // TODO: Track bidders by tokenID  -- use map, and update map at bid function
    // TODO: Track auction ending time by tokenID 
    // TODO: Track bidders by tokenID and retun full data - use map and struct
    // TODO: Track auction based tokens and retun full data - use mapp and struct and update minting time
    // TODO: Test cases for each of the functioins 
    // TODO: Create NodeJs API to interact with this funtions


    function initialize(address defaultAdmin, address upgrader)
        initializer public
    {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(UPGRADER_ROLE, upgrader);
        nftContractCddress = "0x90509fdB1523f0aE75F2f0e5f47781Ea90d1744b";
        nft = IERC721Metadata(nftContractCddress); 
    }

    function getTokenMetadata(uint256 tokenId) public view returns (string memory) { 

        return nft.tokenURI(tokenId); 

    } 

    function startAuction ( uint256 _nft_id, IERC721 _nft, uint _end_date, uint _initial_price) external { 
        require(msg.sender == owner, "Unauthorised request!");
        require(!is_started, "Auction has already started!");
        auction_initiator = payable(msg.sender);
        highest_bid = _initial_price; 

        nft_id = _nft_id;
        nft = _nft;
        // take ownership of token from the auctioner 
        nft.transferFrom(msg.sender, address(this), _nft_id);
        end_at = _end_date; // block.timestamp + 5 days; 
        
        is_started = true;
        emit AuctionStarted();  
        }


    function endAuction() external{
        require(msg.sender == owner, "Unauthorised Operation");
        require(is_ended, "Auction already ended.");
        require(block.timestamp >= end_at, "It's not ending time yet.");

        // default value for address(0) is a zero filled address hance it's the auction initiator
        if(highest_bidder != address(0)){
            
            // transfer nft to winner 
            nft.transferFrom(address(this), highest_bidder, nft_id);
            
            // pay to auction initiator 
            (bool sent, bytes memory tx_data) = auction_initiator.call{value: highest_bid}(
                abi.encodeWithSignature("")
            ); 
            require(sent, "Payment to auction owner transaction has failed!");
            
            emit WinnerAnnounced(highest_bidder, highest_bid, tx_data);
            
        } 
        else{
            nft.transfer(auction_initiator, nft_id);
        }
    
        is_ended = true;
        emit AuctionEnded(highest_bidder, highest_bid);
    }

    function bid(uint256 offered_price) payable external{
        
        require(is_started, "Auction has NOT started yet!");
        require(!is_ended, "Auction has ended!");
        require( offered_price > highest_bid, "Auction has ended!");
        highest_bid = offered_price;  
        highest_bidder = payable(msg.sender);

        // zero filled address check
        if (highest_bidder != address(0)){
            // keep the sum of each the bid money of this bidder 
            all_bids[highest_bidder] += highest_bid;
        }

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
