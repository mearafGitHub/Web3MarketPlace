// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");

async function main() { 
  const defaultAdmin = "0x3612cA87A30df105E53F6bb7673BeF1DEae1ff33";
  const minter = "0xFbB28e9380B6657b4134329B47D9588aCfb8E33B"

  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  console.log("Deploying IBLOXXToken..."); 
  const proxyIBLOXXToken = await upgrades.deployProxy(IBLOXXToken, [defaultAdmin, minter, defaultAdmin], { initializer: 'initialize' }); 

  await proxyIBLOXXToken.deployed; 
  console.log("IBLOXXToken deployed to:", proxyIBLOXXToken.address); 

  const mintTx = await proxyIBLOXXToken.safeMint(initialOwner, "moke_uri"); 
  await mintTx.wait(); 
  console.log(`NFT minted to address ${initialOwner}`); 
} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// npx hardhat run scripts/deploy.js --network goerli  
