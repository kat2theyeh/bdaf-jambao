// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script} from "forge-std/Script.sol";
import {jambaosocute_a} from "../src/jambaosocute_a.sol";
import {jambaosocute_b} from "../src/jambaosocute_b.sol";
import {TokenTrade} from "../src/TokenTrade.sol";

contract Deploy is Script {

    function run() external {

        vm.startBroadcast();

        jambaosocute_a tokenA = new jambaosocute_a();
        jambaosocute_b tokenB = new jambaosocute_b();

        TokenTrade trade = new TokenTrade(
            address(tokenA),
            address(tokenB)
        );

        vm.stopBroadcast();
    }
}