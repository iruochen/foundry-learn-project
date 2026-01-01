// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RCH is ERC20 {
    string private constant NAME = "Ruochen";
    string private constant SYMBOL = "RCH";
    uint256 private constant MAX_TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18;

    constructor(address recipient) ERC20(NAME, SYMBOL) {
        _mint(recipient, MAX_TOTAL_SUPPLY);
    }
}
