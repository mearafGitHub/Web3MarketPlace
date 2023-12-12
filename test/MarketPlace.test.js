const {time, loadFixture,} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue, anyUint } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { ethers, upgrades } = require("hardhat");
const { expect } = require("chai");
const hre = require("hardhat");
require('dotenv').config();

describe("MarketPlace", async function () {

  const nftName = "name";
  const nftId = anyUint(1);
  const price = anyUint(10);
  const isForAuction = false;
  const auctionEndTime = anyUint(2);
  

  describe("Create NFT", async function (){

    it("Should revert with the right error if called with wrong role.", async function () {
      // ...deploy the contract 
      async function main() { 
        const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
        const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, [
          process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE
        ], {
          initializer: 'initialize'
        });
        main().then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

        await expect(proxyMarketPlaceContract.createNFT(
          price,
          nftName,
          isForAuction,
          auctionEndTime
          )).to.be.revertedWith("You don't have MINTER_ROLE!");
      } 
    });

  });

  describe("Start Auction", async function (){
    it("Must start an auction", async function startAuction() {
  
    });
  });
  
  describe("Get Bidders of NFT", async function (){
    it("Must get list of bidders to a given NFT id", async function getBiddersOf() {
      // ...deploy the contract 
      async function main() { 
        const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
        const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, [
          process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE
        ], {
          initializer: 'initialize'
        });
        main().then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

        await expect(proxyMarketPlaceContract.getBiddersOf(nftId) 
        ).to.be.equal([]);

      } 
    });
  });

  describe("Get All Auction Based NFTs", async function (){
    it("Must get all auctioned NFTs", async function getAllAuctionNFTs() {
      // ...deploy the contract 
      async function main() { 
        const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
        const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, [
          process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE
        ], {
          initializer: 'initialize'
        });

        await expect(proxyMarketPlaceContract.getAllAuctionNFTs() 
        ).to.be.equal([]);

      } 
    });

  });

  describe("Get All Fixed Priced NFTs", async function (){
    it("Must get all fixed price NFTs", async function getAllFixedPriceNFT()  {
      // ...deploy the contract 
      async function main() { 
        const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
        const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, [
          process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE
        ], {
          initializer: 'initialize'
        });
        main().then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

        await expect(proxyMarketPlaceContract.getAllFixedPriceNFT() 
        ).to.be.equal([]);

      } 
    });
  });

  describe("Get Auction End Time", async function (){
    it("Must get end time of auction for a given auctioned NFT", async function getAuctionEndTime() {
      // ...deploy the contract 
      async function main() { 
        const MarketPlace = await ethers.getContractFactory("MarketPlace"); 
        const proxyMarketPlaceContract = await upgrades.deployProxy(MarketPlace, [
          process.env.DEFAULT_ADMIN, process.env.MINTER_ROLE, process.env.UPGRADER_ROLE
        ], {
          initializer: 'initialize'
        });
        main().then(() => process.exit(0)) .catch((error) => { console.error(error); process.exit(1); }); 

        await expect(proxyMarketPlaceContract.getAuctionEndTime(nftId) 
        ).to.be.equal(0);

      } 
    });
  });

});
  

    
  
