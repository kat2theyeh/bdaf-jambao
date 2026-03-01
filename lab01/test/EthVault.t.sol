// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {EthVault} from "../src/EthVault.sol";

contract EthVaultTest is Test {
    EthVault vault;

    address owner = address(0xA11CE);
    address alice = address(0xB0B);
    address bob   = address(0xCAFE);

    function setUp() public {
        vault = new EthVault(owner);

        // Give test accounts some ETH
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
    }

    // ---------- Group A: Deposits ----------

    function test_SingleDeposit_EmitsEventAndIncreasesBalance() public {
        uint256 amount = 1 ether;
        uint256 vaultBefore = address(vault).balance;
        
        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, amount);
        
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: amount}("");
        assertTrue(ok);
        assertEq(address(vault).balance,vaultBefore + amount);
    }

    function test_MultipleDeposits_SingleSenders() public {
        uint256 amountA = 1 ether;
        uint256 amountB = 2 ether;
        uint256 vaultBefore = address(vault).balance;

        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, amountA);
        vm.prank(alice);
        (bool ok1, ) = address(vault).call{value: amountA}("");
        assertTrue(ok1);
        
        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(bob, amountB);
        vm.prank(bob);
        (bool ok2, ) = address(vault).call{value: amountB}("");
        assertTrue(ok2);

        assertEq(address(vault).balance, vaultBefore + amountA + amountB);
    }

    // ---------- Group B: Owner Withdrawal ----------

    function test_OwnerWithdraw_Partial() public {
        // deposit 10 ether from Alice

        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, 10 ether);
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: 10 ether}("");
        assertTrue(ok);

        uint256 vaultBefore = address(vault).balance;
        uint256 ownerBefore = owner.balance;


        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit EthVault.Withdraw(owner, 2 ether);

        vault.withdraw(2 ether);

        assertEq(address(vault).balance,vaultBefore - 2 ether );
        assertEq(owner.balance, ownerBefore + 2 ether);
    }

    function test_OwnerWithdraw_FullBalance() public {
        // deposit 4 ether from Alice

        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, 4 ether);
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: 4 ether}("");
        assertTrue(ok);

        uint256 vaultBefore = address(vault).balance;
        uint256 ownerBefore = owner.balance;

        vm.prank(owner);
        vault.withdraw(4 ether);

        assertEq(address(vault).balance, vaultBefore - 4 ether );
        assertEq(owner.balance, ownerBefore + 4 ether);
    }

    // ---------- Group C: Unauthorized Withdrawal ----------

    function test_NonOwnerWithdraw_DoesNotRevert_EmitsUnauthorizedEvent_AndNoBalanceChange() public {
        // deposit 3 ether from Alice

        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, 3 ether);    
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: 3 ether}("");
        assertTrue(ok);

        uint256 balBefore = address(vault).balance;
        uint256 ownerBefore = owner.balance;

        vm.prank(bob);
        vm.expectEmit(true, false, false, true);
        emit EthVault.UnauthorizedWithdrawAttempt(bob, 1 ether);

        // Must NOT revert
        vault.withdraw(1 ether);

        assertEq(address(vault).balance, balBefore);
        assertEq(owner.balance, ownerBefore);
    }

    // ---------- Group D: Edge Cases ----------

    function test_WithdrawMoreThanBalance_RevertsForOwner() public {

        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, 1 ether);    
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: 1 ether}("");
        assertTrue(ok);

        vm.prank(owner);
        vm.expectRevert(bytes("insufficient balance"));
        vault.withdraw(2 ether);
    }

    function test_WithdrawZero_OwnerAllowed_EmitsWithdraw() public {
        vm.expectEmit(true, false, false, true);
        emit EthVault.Deposit(alice, 1 ether); 
        vm.prank(alice);
        (bool ok, ) = address(vault).call{value: 1 ether}("");
        assertTrue(ok);

        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit EthVault.Withdraw(owner, 0);

        vault.withdraw(0);

        assertEq(address(vault).balance, 1 ether);
    }

    function test_MultipleDeposits_ThenWithdraw() public {
        vm.prank(alice);
        (bool ok1, ) = address(vault).call{value: 2 ether}("");
        assertTrue(ok1);

        vm.prank(bob);
        (bool ok2, ) = address(vault).call{value: 5 ether}("");
        assertTrue(ok2);

        
        vm.prank(owner);
        vm.expectEmit(true, false, false, true);
        emit EthVault.Withdraw(owner, 3 ether);
        vault.withdraw(3 ether);
   

        assertEq(address(vault).balance, 4 ether);
    }

}
