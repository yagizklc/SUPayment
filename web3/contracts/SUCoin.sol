// contracts/SUCoin.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import the ERC20 contract from the OpenZeppelin Contracts library
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SUCoin is ERC20 {
    constructor() ERC20("SUCoin", "SUC") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}