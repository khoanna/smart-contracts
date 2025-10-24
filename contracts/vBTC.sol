// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract vBTC is ERC20 {
    constructor() ERC20("Virtual Bitcoin", "vBTC") {
        _mint(msg.sender, 21_000_000_000  * 10 ** decimals()); 
    }
}
