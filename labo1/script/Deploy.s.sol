// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Script, console2} from "forge-std/Script.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";
import {DEX} from "../src/Dex.sol";

contract Deploy is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        TokenA tokenA = new TokenA();
        TokenB tokenB = new TokenB();

        uint256 rate = 2;
        DEX dex = new DEX(address(tokenA), address(tokenB), rate);

        vm.stopBroadcast();

        console2.log("TokenA:", address(tokenA));
        console2.log("TokenB:", address(tokenB));
        console2.log("DEX   :", address(dex));
    }
}