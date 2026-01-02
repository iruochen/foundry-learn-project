// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenReceiver {
    function tokenReceived(
        address from,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract RCH is ERC20 {
    event TransferWithCallback(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data
    );

    string private constant NAME = "Ruochen";
    string private constant SYMBOL = "RCH";
    uint256 private constant MAX_TOTAL_SUPPLY = 1_000_000_000 * 10 ** 18;

    constructor(address recipient) ERC20(NAME, SYMBOL) {
        _mint(recipient, MAX_TOTAL_SUPPLY);
    }

    function transferWithCallback(
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        require(to != address(0), "Transfer to zero address");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, to, amount);

        if (_isContract(to)) {
            require(
                ITokenReceiver(to).tokenReceived(msg.sender, amount, data),
                "Token receiver callback failed"
            );
        }

        emit TransferWithCallback(msg.sender, to, amount, data);

        return true;
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
