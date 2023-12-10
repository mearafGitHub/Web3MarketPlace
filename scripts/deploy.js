// scripts/deploy-my-collectible.js
const { ethers, upgrades } = require("hardhat");

async function main() { 
  const initialOwner = '0x3612cA87A30df105E53F6bb7673BeF1DEae1ff33';

  const IBLOXXToken = await ethers.getContractFactory("IBLOXXToken"); 
  console.log("Deploying IBLOXXToken..."); 
  const proxyIBLOXXToken = await upgrades.deployProxy(IBLOXXToken, [initialOwner], { initializer: 'initialize' }); 

  await proxyIBLOXXToken.deployed; 
  console.log("IBLOXXToken deployed to:", proxyIBLOXXToken.address); 

  const mintTx = await proxyIBLOXXToken.safeMint(initialOwner, "moke_uri"); 
  await mintTx.wait(); 
  console.log(`NFT minted to address ${initialOwner}`); 
} 
  
main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

// ToDo: to deploy run:  npx hardhat run scripts/deploy.js --network goerli  
