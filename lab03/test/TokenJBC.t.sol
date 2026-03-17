// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TokenJBC} from "../src/TokenJBC.sol";

contract TokenJBCTest is Test {
    TokenJBC token;

    uint256 alicePrivateKey = 0xA11CE;
    uint256 bobPrivateKey = 0xB0B;

    address alice;
    address bob;

    function setUp() public {
        token = new TokenJBC();

        alice = vm.addr(alicePrivateKey);
        bob = vm.addr(bobPrivateKey);

        // deployer 把 token 給 Alice
        assertTrue(token.transfer(alice, 1000 ether));
    }

    function getPermitMessageHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                owner,
                spender,
                value,
                nonce,
                deadline,
                address(token)
            )
        );

        // 呼應合約內 hash.toEthSignedMessageHash()
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
        );
    }

    function signPermit(
        uint256 privateKey,
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (bytes memory) {
        bytes32 message = getPermitMessageHash(
            owner,
            spender,
            value,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);
        return abi.encodePacked(r, s, v);
    }

    function testValidPermit() public {
        uint256 value = 100 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        token.permit(alice, bob, value, nonce, deadline, signature);

        assertEq(token.allowance(alice, bob), value);
    }

    function testWrongSignerFails() public {
        uint256 value = 100 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

 
        bytes memory signature = signPermit(
            bobPrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        vm.expectRevert("Invalid signature");
        token.permit(alice, bob, value, nonce, deadline, signature);
    }

    function testNonceIncreasesAfterPermit() public {
        uint256 value = 100 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        token.permit(alice, bob, value, nonce, deadline, signature);

        assertEq(token.nonces(alice), 1);
    }

    function testReusingSameSignatureFails() public {
        uint256 value = 100 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        token.permit(alice, bob, value, nonce, deadline, signature);

        vm.expectRevert("Invalid nonce");
        token.permit(alice, bob, value, nonce, deadline, signature);
    }

    function testExpiredSignatureFails() public {
        uint256 value = 100 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 hours;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        vm.warp(block.timestamp + 2 hours);

        vm.expectRevert("Signature expired");
        token.permit(alice, bob, value, nonce, deadline, signature);
    }

    function testAllowanceUpdatedAfterPermit() public {
        uint256 value = 250 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            value,
            nonce,
            deadline
        );

        token.permit(alice, bob, value, nonce, deadline, signature);

        assertEq(token.allowance(alice, bob), 250 ether);
    }

    function testTransferFromWorksAfterPermit() public {
        uint256 permitValue = 100 ether;
        uint256 transferValue = 60 ether;
        uint256 nonce = token.nonces(alice);
        uint256 deadline = block.timestamp + 1 days;

        bytes memory signature = signPermit(
            alicePrivateKey,
            alice,
            bob,
            permitValue,
            nonce,
            deadline
        );

        token.permit(alice, bob, permitValue, nonce, deadline, signature);

        vm.prank(bob);
        assertTrue(token.transferFrom(alice, bob, transferValue));

        assertEq(token.balanceOf(alice), 940 ether);
        assertEq(token.balanceOf(bob), 60 ether);
        assertEq(token.allowance(alice, bob), 40 ether);
    }

    function testTransferFromFailsWithoutPermit() public {
        vm.prank(bob);
        vm.expectRevert();
        assertFalse(token.transferFrom(alice, bob, 10 ether));
    }
}