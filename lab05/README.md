# BDaF 2026 Lab05 — Proxy Patterns & Upgradeable Contracts

In this lab, I created an upgradeable ERC20 token on Ethereum Sepolia using the UUPS proxy pattern. I first wrote `MyTokenV1` with `ERC20Upgradeable`, `OwnableUpgradeable`, and `UUPSUpgradeable`, and then deployed it through an `ERC1967Proxy`.

After deploying the token, I approved the `StakeForNFT` contract to use my token, and then I called the `stake()` function with my proxy token address and student ID.

Next, I tried calling `unstake()`. However, I did not get my tokens back as I expected.

To solve Part 4, I upgraded my token from V1 to V2. In `MyTokenV2`, I added a `burn(address target)` function, which lets the owner burn all tokens held by a specific address.

I used this function to burn the tokens held by the `StakeForNFT` contract. Once its token balance became zero, I was able to call `mint()` successfully and receive the NFT.

Through this lab, I learned that proxy contracts can keep the same address while changing their logic through upgrades. I also learned that I should not trust a contract only because its function name looks normal. Even if a function is called `unstake()`, the real behavior on-chain may still be different from what I expect.