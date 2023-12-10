// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");
require('dotenv').config()

async function main() { 

  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  const Auction = await ethers.getContractFactory("Auction"); 
  

  // Deploy IBLOXXTokenContrac contract  -> UUPS proxy 
  console.log("\nDeploying IBLOXXToken..."); 
  const proxyIBLOXXTokenContract = await upgrades.deployProxy(
    IBLOXXToken, 
    [process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.DEFAULT_ADMIN], 
    { initializer: 'initialize' }
    ); 
 
  console.log("\nIBLOXXToken deployed:", proxyIBLOXXTokenContract);

  const mintTx = await proxyIBLOXXTokenContract.safeMint(process.env.MINTER_ROLE, "https://app.infura.io/"); 
  const resultNFT = await mintTx.wait(); 
  console.log("\nSafe mint NFT:\n", resultNFT)
  console.log(`\nNFT minted to address "${resultNFT.to}".`); 
  
  const nft = await proxyIBLOXXTokenContract.mint(10); 
  const NFT = await nft.wait(); 
  console.log("\nMint NFT:\n", NFT)
  console.log(`\n10 NFTs minted to address "${NFT.to}".`); 

  // Verify nIBLOXXToken Contract:
  const contract_address = proxyIBLOXXTokenContract.target; 


  // Deploy Auction contract  -> UUPS proxy
  // console.log("\nDeploying Auction Contract..."); 
  // // Deploy the implementation contract via UUPS proxy 
  // const proxyAuctionContract = await upgrades.deployProxy(Auction, 
  //   [process.env.DEFAULT_ADMIN, process.env.UPGRADER_ROLE], 
  //   { initializer: 'initialize' }
  //   ); 

  // console.log("\nProxyAuctionContract contract deployed. Details:\n", proxyAuctionContract);

  // const resultAuction = await proxyAuctionContract.deployed(); 
  // console.log("Result of de NFT:\n", resultAuction) 

  // const startAuction = await proxyAuction.start_auction( _nft_id, IERC721 _nft, uint _end_date, uint _initial_price);  
  // console.log(`\nNFT minted to address ${defaultAdmin}. NFT Contract address: ${proxyIBLOXXToken.address()}`); 

} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy.js --network goerli  
