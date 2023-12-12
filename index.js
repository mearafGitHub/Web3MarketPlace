const ethers = require('ethers');
require('dotenv').config();

const express = require('express');
const app = express();
app.use(express.json());

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