// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";


contract IBLOXXToken is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    uint256 private _nextTokenId;
    struct TokenData {
        uint256 id;
        string name;
        address payable owner;
        uint256 price;
    }

    TokenData _tokenData;

    mapping (uint256 => TokenData) _tokens;
    mapping (uint256 => uint256) private _tokenPrices;


    function initialize(address defaultAdmin, address minter, address upgrader)
        initializer public
    {
        __ERC721_init("IBLOXXToken", "IBX");
        __ERC721Enumerable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(UPGRADER_ROLE, upgrader);
    }

    function getTokenPrice(uint256 tokenId) external view returns (uint256) { 
        return _tokenPrices[tokenId];
    } 

    function setTokenPrice(uint256 tokenId, uint256 price) private { 
        _tokenPrices[tokenId] = price; 
    } 

    function getTokenData(uint256 tokenId) external view returns (TokenData memory) { 
        return _tokens[tokenId];
    } 

    function setTokenData(uint256 tokenId, TokenData memory info) private { 
        _tokens[tokenId] = info; 
    } 

    function safeMint(address payable to) external onlyRole(MINTER_ROLE) 
    returns (uint256){
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function mintNFT(uint256 price, string memory tokenName, address payable tokenOwner) external onlyRole(MINTER_ROLE) returns (uint256){ 
        // TODO: Think of a require condition 

        uint256 newTokenId = _nextTokenId++; 
        // TokenData newTokenData - TODO: Think of the pros and cons
        _tokenData.id = newTokenId;
        _tokenData.name = tokenName;
        _tokenData.owner = tokenOwner;
        
        _mint(tokenOwner, newTokenId);
        setTokenData(newTokenId, _tokenData);           
        setTokenPrice(newTokenId, price); 

        return newTokenId;
    } 

    function adminMint(uint256 quantity) external payable onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(msg.sender, quantity);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE){} 

    // Override required by Solidity for UUPS function
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
