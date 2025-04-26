# CPAMM - Constant Product Automated Market Maker

This smart contract implements a **basic Automated Market Maker (AMM)** based on the **constant product formula**, similar to Uniswap V2.

Users can **swap tokens**, **provide liquidity**, and **withdraw liquidity** while earning trading fees.

---

## 📚 Contract Overview

- **token0**, **token1**: ERC20 tokens being paired.
- **fee**: Swap fee set to `0.3%` (represented as 3 / 1000).
- **reserve0**, **reserve1**: Reserves of token0 and token1.
- **totalSupply**: Total liquidity shares issued.
- **balanceOf**: User balances of liquidity shares.

---
