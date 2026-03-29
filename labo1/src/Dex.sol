// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DEX {
    using SafeERC20 for IERC20;

    address public immutable TOKEN_A;
    address public immutable TOKEN_B;
    uint256 public rate;

    constructor(address _tokenA, address _tokenB, uint256 _rate) {
        TOKEN_A = _tokenA;
        TOKEN_B = _tokenB;
        rate = _rate;
    }
    
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        IERC20(TOKEN_A).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(TOKEN_B).safeTransferFrom(msg.sender, address(this), amountB);
    }

    // x + r * y = k
    function swap(address tokenIn, uint256 amountIn) external {
        if (tokenIn == TOKEN_A) {
            uint256 amountOut = amountIn / rate;
            if (amountOut <= IERC20(TOKEN_B).balanceOf(address(this))) {
                IERC20(TOKEN_A).safeTransferFrom(msg.sender, address(this), amountIn);
                IERC20(TOKEN_B).safeTransfer(msg.sender, amountOut);
            } else revert("Insufficient Luquidity of TOKEN_B");
        } else if (tokenIn == TOKEN_B) {
            uint256 amountOut = amountIn * rate;
            if (amountOut <= IERC20(TOKEN_A).balanceOf(address(this))) {
                IERC20(TOKEN_B).safeTransferFrom(msg.sender, address(this), amountIn);
                IERC20(TOKEN_A).safeTransfer(msg.sender, amountOut);
            } else revert("Insufficient Luquidity of TOKEN_A");
        } else revert("Invalid Token");
    }

    function getReserves() external view returns (uint256 reserveA, uint256 reserveB) {
        reserveA = IERC20(TOKEN_A).balanceOf(address(this));
        reserveB = IERC20(TOKEN_B).balanceOf(address(this));
    }

    function feeRecipient() external pure returns (address) {
        return address(0);
    }

    function withdrawFee() external {}
}