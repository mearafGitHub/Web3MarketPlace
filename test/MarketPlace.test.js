const {time, loadFixture,} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue, anyUint } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const hre = require("hardhat");

describe("MarketPlace", async function () {

  // ...deploy the contract as before...
  const { ethers, upgrades } = require("hardhat");
  require('dotenv').config();

  async function main() { 

    // Deploy MarketPlace contract  -> UUPS proxy
    const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
    console.log("\nDeploying MarketPlace Contract..."); 
    // Deploy the implementation contract via UUPS proxy 
    const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, 
      [process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE], 
      { initializer: 'initialize' }
    ); 
    console.log("\nProxyMarketPlaceContract contract deployed. Details:\n", proxyMarketPlaceContract);
  } 
    
  main() .then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 
  
  const price = anyUint(10);
  const nftName = "name";
  const isForAuction = false;
  const auctionEndTime = anyUint(2);

  describe("Create NFT", async function (){
    it("Must get input data from user", async function createNFT() {
  
    });

    it("Must create NFT", async function createNFT() {
  
    });

    it("Should revert with the right error if called with wrong role.", async function () {
      await expect(proxyMarketPlaceContract.createNFT(
        price,
        nftName,
        isForAuction,
        auctionEndTime
        )).to.be.revertedWith("You don't have MINTER_ROLE!");
    });
  });

  describe("Start Auction", async function (){
    it("Must start an auction", async function startAuction() {
  
    });
  });
  
  describe("Get Bidders of NFT", async function (){
    it("Must get list od bidders to a given NFT id", async function getBiddersOf() {
  
    });
  });

  describe("Get All Auction Based NFTs", async function (){
    it("Must get all auctioned NFTs", async function getAllAuctionNFTs() {
    
    });
  });

  describe("Get All Fixed Priced NFTs", async function (){
    it("Must get all fixed price NFTs", async function getAllFixedPriceNFT() {
  
    });
  });

  describe("Get Auction End Time", async function (){
    it("Must get end time of auction for a given auctioned NFT", async function getAuctionEndTime() {
  
    });
  });

});
  

    
  
