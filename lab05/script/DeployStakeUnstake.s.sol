//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {MyTokenV1} from "../src/MyTokenV1.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

interface IStakeForNFT {
    function stake(address token, uint256 amount, string calldata studentId) external;
    function unstake() external;
}

contract DeployStakeUnstake is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyTokenV1 myTokenV1 = new MyTokenV1();
        // Deploy proxy with initialization
        bytes memory data = abi.encodeCall(
            MyTokenV1.initialize,
            ("MyToken", "MTK", 1000000 * 1e18)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(myTokenV1), data);

        // Interact via proxy address
        MyTokenV1 token = MyTokenV1(address(proxy));

        // Stake tokens for NFT
        address stakeForNft = vm.envAddress("STAKE_FOR_NFT_ADDR");
        string memory studentId = vm.envString("STUDENT_ID");
        uint256 amount = 100 * 1e18;
        token.approve(stakeForNft, amount);
        IStakeForNFT(stakeForNft).stake(address(token), amount, studentId);

        // Unstake tokens
        IStakeForNFT(stakeForNft).unstake();

        vm.stopBroadcast();
    }
}