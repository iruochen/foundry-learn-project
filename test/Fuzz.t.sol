// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {MyToken} from "../src/MyToken.sol";

contract FuzzTest is Test {
    Counter public counter;
    MyToken public token;

    function setUp() public {
        counter = new Counter();
        token = new MyToken("RC", "R");
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }

    function testFuzz_ERC20Transfer(address to, uint256 amount) public {
        // set constraints on fuzzed inputs
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        amount = bound(amount, 0, 10000 * 10 ** 18);
        token.transfer(to, amount);
        assertEq(token.balanceOf(to), amount);
    }
}
