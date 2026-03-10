// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract jambaosocute_b is ERC20 {

    constructor() ERC20("TokenB", "TKB") {

        _mint(msg.sender, 1_000_000 ether);
    }
}