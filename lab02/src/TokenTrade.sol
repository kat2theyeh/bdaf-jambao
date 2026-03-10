// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract TokenTrade {

    using SafeERC20 for IERC20;

    struct Trade {
        address seller;
        address inputToken;
        uint256 inputAmount;
        uint256 outputAsk;
        uint256 expiry;
        bool settled;
        bool cancelled;
    }

    address public immutable OWNER;
    address public immutable TOKEN_A;
    address public immutable TOKEN_B;

    uint256 public nextTradeId;

    mapping(uint256 => Trade) public trades;
    mapping(address => uint256) public accumulatedFees;

    constructor(address _tokenA, address _tokenB) {
        OWNER = msg.sender;
        TOKEN_A = _tokenA;
        TOKEN_B = _tokenB;
    }

    function setupTrade(
        address inputToken,
        uint256 inputAmount,
        uint256 outputAsk,
        uint256 expiry
    ) external {

        require(
            inputToken == TOKEN_A || inputToken == TOKEN_B,
            "invalid token"
        );

        require(inputAmount > 0, "invalid amount");
        require(outputAsk > 0, "invalid ask");
        require(expiry > block.timestamp, "invalid expiry");

        IERC20(inputToken).safeTransferFrom(msg.sender, address(this), inputAmount);

        trades[nextTradeId] = Trade({
            seller: msg.sender,
            inputToken: inputToken,
            inputAmount: inputAmount,
            outputAsk: outputAsk,
            expiry: expiry,
            settled: false,
            cancelled: false
        });

        nextTradeId++;
    }

    function settleTrade(uint256 tradeId) external {

        Trade storage trade = trades[tradeId];

        require(trade.seller != address(0), "trade not found");
        require(!trade.settled, "already settled");
        require(!trade.cancelled, "cancelled");
        require(block.timestamp <= trade.expiry, "expired");

        address outputToken = trade.inputToken == TOKEN_A
            ? TOKEN_B
            : TOKEN_A;

        uint256 fee = trade.outputAsk / 1000;
        uint256 sellerReceive = trade.outputAsk - fee;

        IERC20(outputToken).safeTransferFrom(msg.sender, address(this), trade.outputAsk);

        IERC20(outputToken).safeTransfer(trade.seller, sellerReceive);

        IERC20(trade.inputToken).safeTransfer(msg.sender, trade.inputAmount);

        accumulatedFees[outputToken] += fee;

        trade.settled = true;
    }

    function cancelExpiredTrade(uint256 tradeId) external {

        Trade storage trade = trades[tradeId];

        require(trade.seller == msg.sender, "not seller");
        require(!trade.settled, "already settled");
        require(!trade.cancelled, "already cancelled");
        require(block.timestamp > trade.expiry, "not expired");

        trade.cancelled = true;

        IERC20(trade.inputToken).safeTransfer(trade.seller, trade.inputAmount);
    }

    function withdrawFee() external {

        require(msg.sender == OWNER, "not owner");

        _withdraw(TOKEN_A);
        _withdraw(TOKEN_B);
    }

    function _withdraw(address token) internal {

        uint256 amount = accumulatedFees[token];

        if (amount == 0) return;

        accumulatedFees[token] = 0;

        IERC20(token).safeTransfer(OWNER, amount);
    }
}