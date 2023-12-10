// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");

async function main() { 
  const defaultAdmin = "0x3612cA87A30df105E53F6bb7673BeF1DEae1ff33";
  // const minter = "0xFbB28e9380B6657b4134329B47D9588aCfb8E33B"
  const minter = "0x3612cA87A30df105E53F6bb7673BeF1DEae1ff33"

  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  const Auction = await ethers.getContractFactory("Auction"); 


  console.log("\nDeploying IBLOXXToken..."); 
  // Deploy the implementation contract via UUPS proxy 
  const proxyIBLOXXTokenContract = await upgrades.deployProxy(IBLOXXToken, [defaultAdmin, minter, defaultAdmin], { initializer: 'initialize' }); 

  // await proxyIBLOXXToken.deployed(); 
  console.log("\nIBLOXXToken deployed to proxyIBLOXXTokenContract:", proxyIBLOXXTokenContract.target); 
  console.log("\nDetail of proxyIBLOXXTokenContract:\n", proxyIBLOXXTokenContract); 

  const mintTx = await proxyIBLOXXTokenContract.safeMint(defaultAdmin, "https://app.infura.io/");  // sample uri, TODO: change later
  const resultNFT = await mintTx.wait(); 
  console.log("\nResult of minting NFT:\n", resultNFT)
  console.log(`\nNFT minted to address "${resultNFT.to}".`); 


  // deploy Auction contract
  console.log("\nDeploying Auction Contract..."); 
  // Deploy the implementation contract via UUPS proxy 
  const proxyAuctionContract = await upgrades.deployProxy(Auction, [defaultAdmin, defaultAdmin], { initializer: 'initialize' }); 

  console.log("\nProxyAuctionContract contract deployed. Content:\n", proxyAuctionContract);

  // const resultAuction = await proxyAuctionContract.deployed(); 
  // console.log("Result of de NFT:\n", resultAuction) 

  // const startAuction = await proxyAuction.start_auction( _nft_id, IERC721 _nft, uint _end_date, uint _initial_price);  // sample uri, TODO: change later

  // console.log(`\nNFT minted to address ${defaultAdmin}. NFT Contract address: ${proxyIBLOXXToken.address()}`); 

} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy.js --network goerli  
