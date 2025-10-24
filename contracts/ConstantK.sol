// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CPAMM is ERC20 {
    IERC20 public immutable token0; // VNST
    IERC20 public immutable token1; // vBTC
    AggregatorV3Interface public immutable priceFeed; // BTC/USD oracle

    uint256 public fee = 3; // 0.3%

    uint256 public reserve0;
    uint256 public reserve1;

    address owner;

    constructor(address _token0, address _token1, address _priceFeed) ERC20 ("VIS", "VinaSwap") {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function getLatestBTCPrice() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price/ 1e8); 
    }

    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn != address(0), "ZERO ADDRESS");
        require(_amountIn > 0, "ZERO AMOUNT");
        require(_tokenIn == address(token0) || _tokenIn == address(token1));

        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) =
            (_tokenIn == address(token0)) ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        uint256 amountIn = (_amountIn * (1000 - fee)) / 1000;
        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);

        tokenIn.transfer(owner, _amountIn - amountIn);
        tokenOut.transfer(msg.sender, amountOut);

        (uint256 _reserve0, uint256 _reserve1) =
            (_tokenIn == address(token0)) ? (reserveIn + _amountIn, reserveOut - amountOut) : (reserveOut - amountOut, reserveIn + amountIn);
        _update(_reserve0, _reserve1);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        uint256 btcPrice = getLatestBTCPrice(); 

        uint256 expectedVNST = (_amount1 * (btcPrice/1000) );
        require(_amount0 == expectedVNST, "VNST must match BTC price");

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (totalSupply() == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalSupply()) / reserve0,
                (_amount1 * totalSupply()) / reserve1
            );
        }

        require(shares > 0, "ZERO_SHARES");
        _mint(msg.sender, shares);
        _update(reserve0 + _amount0, reserve1 + _amount1);
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        amount0 = (_shares * reserve0) / totalSupply();
        amount1 = (_shares * reserve1) / totalSupply();
        require(amount0 > 0 && amount1 > 0, "ZERO AMOUNT");
        _burn(msg.sender, _shares);
        _update(reserve0 - amount0, reserve1 - amount1);
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }
}
