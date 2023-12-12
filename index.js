const ethers = require('ethers');
const express = require('express');
const app = express();

app.use(express.json());
require('dotenv').config();

const QUICK_NODE_URL = process.env.QUICK_NODE_URL;
const TEST_ACC_PRIVATE_KEY = process.env.TEST_ACC_PRIVATE_KEY;

const contractAddressIIBLOXXToken = process.env.MARKET_PLACE_CONTRACT_ADDRESS;
const contractAddressMarektPlace = process.env.IBLOXX_CONTRACT_ADDRESS;

const provider = new ethers.providers.JsonRpcProvider(QUICK_NODE_URL);
const signer = new ethers.Wallet(TEST_ACC_PRIVATE_KEY, provider);

// MarektPlace contract
const {abiMarektPlace} = require("./artifacts/contracts/MarektPlace.sol/MarektPlace.json");
const contractInstanceMarektPlace = new ethers.Contract(contractAddress, abi, signer);

// IBLOXXToken contract
const {abiIBLOXXToken} = require("./artifacts/contracts/IBLOXXToken.sol/IBLOXXToken.json");
const contractInstanceIBLOXXToken = new ethers.Contract(contractAddress, abi, signer);

const port = process.env.PORT;
app.listen(
    port,
    () => console.log(`Server running on http://localhost:${port}`)
)

app.get("/auctionNfts", function (request, result) {
    const sample = {}
    result.status(200).send(sample);
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