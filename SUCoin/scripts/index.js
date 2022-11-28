// scripts/index.js

module.exports = async function main (callback) {
    try {
        // Our code will go here

        // Retrieve accounts from the local node
        const accounts = await web3.eth.getAccounts();
        console.log(accounts)

        // Set up a Truffle contract, representing our deployed Box instance 
        const SUCoin = artifacts.require('SUCoin');
        const coin = await SUCoin.deployed();

        // gov get func
        console.log((await coin.get()).toString());

        
        callback(0);
    } catch (error) {
        console.error(error);
        callback(1);
    }
};

