// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenJBC} from "../src/TokenJBC.sol";

contract DeployTokenJBC is Script {
    function run() external returns (TokenJBC token) {
        vm.startBroadcast();
        token = new TokenJBC();
        vm.stopBroadcast();
    }
}