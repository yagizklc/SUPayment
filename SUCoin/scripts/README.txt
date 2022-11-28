Scripts folder contains .js scripts 
to interact with providers, signers and contracts 
which are simply abstractions of full node, tx sender and smart contract respectively.

These scripts are executed via:
truffle exec --network development ./scripts/index.js

Note that beforehand you should setup truffle and ganache via:
truffle develop
truffle compile
truffle migrate --network development  //deploying smart contracts to local blockchain (ganache)


