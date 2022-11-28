// contracts/GovernanceToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// implementation of ERC20Votes as votes
contract SUCoin is ERC20 {

    // max supply
    uint256 public s_maxSupply = 10000000000000;

    // constructor: initializes once contract is deployed 
    constructor() 
    ERC20("SUCoin", "SUC")
    {
        _mint(msg.sender, s_maxSupply);
    }

    // functions below are overrides required by solidity
    function get() public view returns (uint256){
        return s_maxSupply;
    }


}