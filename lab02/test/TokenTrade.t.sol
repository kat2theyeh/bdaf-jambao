// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {Test} from "forge-std/Test.sol";
import {TokenTrade} from "../src/TokenTrade.sol";
import {jambaosocute_a} from "../src/jambaosocute_a.sol";
import {jambaosocute_b} from "../src/jambaosocute_b.sol";

contract TokenTradeTest is Test {

    jambaosocute_a tokenA;
    jambaosocute_b tokenB;
    TokenTrade trade;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {

        tokenA = new jambaosocute_a();
        tokenB = new jambaosocute_b();

        trade = new TokenTrade(address(tokenA), address(tokenB));

        tokenA.transfer(alice, 1000 ether);
        tokenB.transfer(bob, 1000 ether);
    }

    function testSetupTrade() public {

        vm.startPrank(alice);

        tokenA.approve(address(trade), 100 ether);

        trade.setupTrade(
            address(tokenA),
            100 ether,
            50 ether,
            block.timestamp + 1 days
        );

        vm.stopPrank();

        assertEq(trade.nextTradeId(), 1);
    }

    function testSettleTrade() public {

        vm.startPrank(alice);

        tokenA.approve(address(trade), 100 ether);

        trade.setupTrade(
            address(tokenA),
            100 ether,
            50 ether,
            block.timestamp + 1 days
        );

        vm.stopPrank();

        vm.startPrank(bob);

        tokenB.approve(address(trade), 50 ether);

        trade.settleTrade(0);

        vm.stopPrank();

        assertEq(tokenA.balanceOf(bob), 100 ether);
    }

    function testExpiredTrade() public {

        vm.startPrank(alice);

        tokenA.approve(address(trade), 100 ether);

        trade.setupTrade(
            address(tokenA),
            100 ether,
            50 ether,
            block.timestamp + 1 days
        );

        vm.stopPrank();

        vm.warp(block.timestamp + 2 days);

        vm.startPrank(bob);

        tokenB.approve(address(trade), 50 ether);

        vm.expectRevert();

        trade.settleTrade(0);

        vm.stopPrank();
    }
}