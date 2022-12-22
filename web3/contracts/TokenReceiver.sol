// contracts/send.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// This contract receives ERC20 tokens and has a function to transfer them to a specified address.
contract TokenReceiver {
    using SafeERC20 for ERC20; // We use the SafeERC20 contract to ensure that the transfer function can only be called on ERC20 tokens.

    ERC20 public token; // The ERC20 token that this contract will receive.

    constructor(address _token) public {
        // In the constructor, we set the token address to the address passed in as an argument.
        token = ERC20(_token);
    }

    function transfer(address _to, uint256 _value) public {
        // This function transfers the specified amount of tokens to the specified address.
        // It uses the safeTransfer function from the SafeERC20 contract to ensure that the transfer can only be made if the contract is an ERC20 token.
        token.safeTransfer(_to, _value);
    }
}
