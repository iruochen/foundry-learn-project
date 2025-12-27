// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

/// Top-level wrapper contract (not nested)
contract Target {
    InvariantTest parent;

    constructor(address _parent) {
        parent = InvariantTest(_parent);
    }

    function transfer(uint256 idxFrom, uint256 idxTo, uint256 amount) external {
        parent.transfer(idxFrom, idxTo, amount);
    }
}

contract InvariantTest is Test {
    MyToken public token;
    address[] public users;

    function setUp() public {
        token = new MyToken("RC", "R");
        for (uint256 i = 1; i <= 10; i++) {
            address user = address(uint160(i));
            users.push(user);
            token.transfer(user, 1000 * 10 ** 18);
        }
        users.push(address(this));
        // deploy wrapper and target only the wrapper (so only transfer is fuzzed)
        Target target = new Target(address(this));
        targetContract(address(target));
    }

    function transfer(uint256 idxFrom, uint256 idxTo, uint256 amount) public {
        idxFrom = idxFrom % users.length;
        idxTo = idxTo % users.length;

        vm.assume(idxFrom != idxTo);

        address from = users[idxFrom];
        address to = users[idxTo];

        amount = amount % (token.balanceOf(from) + 1);

        vm.prank(from);
        token.transfer(to, amount);
    }

    function invariant_TotalSupply() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 totalBalance = 0;

        console.log("users.length:", users.length);
        for (uint256 i = 0; i < users.length; i++) {
            totalBalance += token.balanceOf(users[i]);
        }

        assertEq(totalBalance, token.totalSupply(), "Total supply invariant violated");
    }
}
