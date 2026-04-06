//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MyTokenV2} from "../src/MyTokenV2.sol";

interface IStakeForNft {
    function mint() external;
}

contract UpgradeAndMint is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        // Address of the existing proxy
        address proxyAddress = vm.envAddress("PROXY_ADDR");
        // Address of the StakeForNft contract
        address stakeForNft = vm.envAddress("STAKE_FOR_NFT_ADDR");

        // Deploy the new implementation contract
        MyTokenV2 myTokenV2 = new MyTokenV2();

        // Upgrade the proxy to the new implementation
        MyTokenV2 token = MyTokenV2(proxyAddress);
        token.upgradeToAndCall(address(myTokenV2), bytes(""));

        // Call the new burn function to burn tokens from the StakeForNft contract
        token.burn(stakeForNft);

        // Call the mint function on the StakeForNft contract
        IStakeForNft(stakeForNft).mint();

        vm.stopBroadcast();
    }
}