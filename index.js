const ethers = require('ethers');
const express = require('express');
const app = express();

app.use(express.json());
require('dotenv').config();

const TEST_ACC_PRIVATE_KEY = process.env.TEST_ACC_PRIVATE_KEY;

// Create provider
const network = "goerli";
const provider = new ethers.InfuraProvider(network, process.env.INFURA_API_KEY);
const signer = new ethers.Wallet(TEST_ACC_PRIVATE_KEY, provider);

// MarketPlace contract
const ContractAddressMarketPlace = process.env.MARKET_PLACE_CONTRACT_ADDRESS;
const { abi } = require("./artifacts/contracts/MarketPlace.sol/MarketPlace.json"); 
const contractInstanceMarketPlace = new ethers.Contract(ContractAddressMarketPlace, abi, signer);

// // IBLOXXToken contract
// const ContractAddressIIBLOXXToken = process.env.IBLOXX_CONTRACT_ADDRESS;
// const {abi} = require("./artifacts/contracts/IBLOXXToken.sol/IBLOXXToken.json");
// const contractInstanceIBLOXXToken = new ethers.Contract(ContractAddressIIBLOXXToken, abi, signer);


const port = process.env.PORT;
app.listen(
    port,
    () => console.log(`Server running on http://localhost:${port}`)
)

app.get("/auctionNfts", async function (request, result) {
    try {
        const nfts = await contractInstanceMarketPlace.getAllAuctionNFTs();
        result.status(200).send(nfts);
    } catch (error) {
        result.console.error(error);
        result.status(500).send(error.message);
    }
});

app.get('/fixedPriceNfts', async function(request, result) {
    try {
        const nfts = await contractInstanceMarketPlace.getAllFixedPriceNFT();
        result.status(200).send(nfts);
    } catch (error) {
        console.error("\nFound Error:\n",error);
        result.status(500).send(error.message);
    }
});

app.post("/createNFT", async function (request, result) { 
    try {
        // Take parameters in request body
        const {price, nftName, isForAuction, auctionEndTime} = request.body;
        const creatNFTTransaction = await contractInstanceMarketPlace.createNFT(price, nftName, isForAuction, auctionEndTime);

        result.status(201).send(creatNFTTransaction);
    } catch (error) {
        console.error("\n createNFT Found Error:\n",error);
        result.status(500).send(error.message);
    }
});


app.get('/getAuctionEndTime/:nftId', async function(request, result){

    try {
        const nftId = request.params.nftId;
        const nfts = await contractInstanceMarketPlace.getAuctionEndTime(nftId);
        result.status(200).send(Object(nfts));
    } catch (error) {
        console.error("\n getAuctionEndTime Found Error:\n",error);
        result.status(500).send(error.message);
    }
});

app.get('/getBiddersOf/:nftID', async function(request, result){
    try {
        const _nftID = request.params.nftID;
        console.log("Got id: ", _nftID);
        const bidders = await contractInstanceMarketPlace.getBiddersOf(_nftID);
        result.status(200).send(bidders);
    } catch (error) {
        console.error("\ngetBiddersOf Found Error:\n",error);
        result.status(500).send(error.message);
    }
});

app.post('/startAuction', async function(request, result){
    try {
        const {nftId, auctionEndsAt, initialPrice} = request.body;
        const nfts = await contractInstanceMarketPlace.startAuction ( nftId, auctionEndsAt, initialPrice);
        result.status(200).send(nfts);
    } catch (error) {
        console.error("\nendAuctionFound Error:\n",error);
        result.status(500).send(error.message);
    }
});

app.post('/endAuction', async function(request, result){
    try {
        const {nftId} = request.body;
        const nfts = await contractInstanceMarketPlace.endAuction(nftId);
        result.status(200).send(nfts);
    } catch (error) {
        console.error("\nendAuctionFound Error:\n",error);
        result.status(500).send(error.message);
    }
});


app.get('/withdrawCollateral', async function(request, result){
    try {
        const {nftId, bidderAddress} = request.body;
        const nfts = await contractInstanceMarketPlace.withdraw(nftId, bidderAddress);
        result.status(200).send(nfts);
    } catch (error) {
        console.error("\nwithdrawCollateral Found Error:\n",error);
    }
});