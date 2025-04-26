// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;
    uint256 public fee = 3; //0.3%

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 amount) private  {
        balanceOf[_to] += amount;
        totalSupply += amount;
    }

    function _burn(address _from, uint256 amount) private  {
        balanceOf[_from] -= amount;
        totalSupply -= amount;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) private  {
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

    function _min(uint256 x, uint256 y) private pure returns (uint256 z)  {
        return x <= y ? x : y;
    }
    
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn != address(0), "ZERO ADDRESS");
        require(_amountIn > 0,"ZERO AMOUNT");
        require(_tokenIn == address(token0) || _tokenIn == address(token1));
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = (_tokenIn == address(token0)) ? (token0, token1, reserve0, reserve1): (token1, token0, reserve1, reserve0);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        uint256 amountIn = (_amountIn*(1000 - fee))/1000;
        amountOut = (reserveIn * amountIn) / (reserveOut + amountIn);
        tokenOut.transfer(msg.sender, amountOut);

        (uint256 _reserve0, uint256 _reserve1) = (_tokenIn == address(token0)) ? (reserveIn + _amountIn, reserveOut - amountOut) : (reserveOut - amountOut, reserveIn + amountIn);
        _update(_reserve0, _reserve1);
    }

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns (uint256 shares) {
        if (reserve0 > 0 && reserve1 > 0 ) {
            require(_amount0 * reserve1 == _amount1 * reserve0 );
        }

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount0);
        } else {
            shares = _min( 
                (_amount0*totalSupply/reserve0),
                (_amount1*totalSupply/reserve1)
            );
        }

        require(shares > 0);
        _mint(msg.sender, shares);
        _update(reserve0 + _amount0, reserve1 + _amount1);
    }

    function removeLiquidity(uint256 _shares) external returns (uint256 amount0, uint256 amount1) {
        amount0 = _shares * reserve0 / totalSupply;
        amount1 = _shares * reserve1 / totalSupply;
        require(amount0 > 0 && amount1 > 0);
        _burn(msg.sender, _shares);
        _update((reserve0 - amount0), (reserve1 - amount1));    
    }

}