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
    const sample = {}
    try {
        const nfts = await contractInstanceMarketPlace.getAllAuctionNFTs();
        result.status(200).send(nfts);
    } catch (error) {
        result.console.error(error);
    }
});

app.get('/fixedPriceNfts', async function(request, result, next){
    const sample = {}
    result.send(sample);
});

app.post("/creatNFT", function (request, result) {
    
    const sample = {}
    result.status(201).send(sample);
});

app.post('/createAuction', async function(request, result, next){
    const sample = {}
    result.status(201).send(sample);
});

app.get('/getAuctionEndTime', async function(request, result, next){
    const sample = {}
    result.status(200).send(sample);
});

app.get('/bidders', async function(request, result,  next){
    const sample = {}
    result.status(200).send(sample);
});

app.post('/startAuction', async function(request, result, next){
    const sample = {}
    result.status(201).send(sample);
});

app.post('/endAuction', async function(request, result, next){
    const sample = {}
    result.status(201).send(sample);
});

app.get('/withdrawCollateral', async function(request, result, next){
    const sample = {}
    result.status(201).send(sample);
});