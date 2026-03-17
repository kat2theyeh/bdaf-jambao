// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

interface ITokenJBC {
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external;
    function allowance(address owner, address spender) external view returns (uint256);
}

contract SignPermit is Script {
    using MessageHashUtils for bytes32;

    function run() external {
        uint256 alicePk = vm.envUint("ALICE_PRIVATE_KEY");
        uint256 bobPk = vm.envUint("BOB_PRIVATE_KEY");

        address token = vm.envAddress("TOKEN_JBC_ADDRESS");
        address owner = vm.addr(alicePk);
        address spender = vm.envAddress("BOB_ADDRESS");

        uint256 value = 50 ether;
        uint256 nonce = ITokenJBC(token).nonces(owner);
        uint256 deadline = block.timestamp + 1 hours;

        bytes32 hash = keccak256(
            abi.encodePacked(owner, spender, value, nonce, deadline, token)
        );

        bytes32 message = hash.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, message);
        bytes memory signature = abi.encodePacked(r, s, v);

        console.log("owner:", owner);
        console.log("spender:", spender);
        console.log("value:", value);
        console.log("nonce:", nonce);
        console.log("deadline:", deadline);
        console.logBytes32(hash);
        console.logBytes32(message);
        console.logBytes(signature);

        vm.startBroadcast(bobPk);
        ITokenJBC(token).permit(owner, spender, value, nonce, deadline, signature);
        vm.stopBroadcast();

        console.log("allowance after permit:", ITokenJBC(token).allowance(owner, spender));
    }
}