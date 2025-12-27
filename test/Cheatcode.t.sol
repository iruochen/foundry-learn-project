// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {Owner} from "../src/Owner.sol";
import {MyToken} from "../src/MyToken.sol";

contract CheatcodeTest is Test {
    Counter public counter;
    address public alice;
    address public bob;

    function setUp() public {
        counter = new Counter();
        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function test_Roll() public {
        counter.increment();
        assertEq(counter.number(), 1);

        uint256 newBlockNumber = 100;
        vm.roll(newBlockNumber);
        console.log("Block number after roll:", block.number);

        assertEq(block.number, newBlockNumber + 1);
        assertEq(counter.number(), 1); // State should remain unchanged
    }

    function test_Warp() public {
        uint256 newTimeStamp = 1753207525;
        vm.warp(newTimeStamp);
        console.log("Timestamp after warp:", block.timestamp);
        assertEq(block.timestamp, newTimeStamp);

        skip(1000);
        console.log("Timestamp after skip:", block.timestamp);
        assertEq(block.timestamp, newTimeStamp + 1000);
    }

    function test_Prank() public {
        console.log("current contract address:", address(this));
        console.log("test_Prank counter address:", address(counter));

        Owner o = new Owner();
        console.log("owner address: ", address(o.owner()));
        assertEq(o.owner(), address(this));

        console.log("alice address:", alice);
        vm.prank(alice);
        Owner o2 = new Owner();
        assertEq(o2.owner(), alice);
    }

    function test_startPrank() public {
        console.log("current contract address:", address(this));
        console.log("test_startPrank counter address:", address(counter));

        Owner o = new Owner();
        console.log("owner address: ", address(o.owner()));
        assertEq(o.owner(), address(this));

        console.log("bob address:", bob);
        vm.startPrank(bob);
        Owner o2 = new Owner();
        assertEq(o2.owner(), bob);
        Owner o4 = new Owner();
        assertEq(o4.owner(), bob);
        vm.stopPrank();

        Owner o3 = new Owner();
        assertEq(o3.owner(), address(this));
    }

    function test_Deal() public {
        console.log("alice balance before deal:", alice.balance);
        vm.deal(alice, 10 ether);
        console.log("alice balance after deal:", alice.balance);
        assertEq(alice.balance, 10 ether);

        vm.deal(alice, 1 ether);
        console.log("alice balance after second deal:", alice.balance);
        assertEq(alice.balance, 1 ether);
    }

    function test_Deal_ERC20() public {
        MyToken token = new MyToken("RC", "R");
        console.log("token address: ", address(token));

        console.log("alice address:", alice);
        deal(address(token), alice, 100 ether);
        uint256 aliceBalance = token.balanceOf(alice);
        assertEq(aliceBalance, 100 ether);
    }

    function test_Revert_IFNOT_Owner() public {
        vm.startPrank(alice);
        Owner o = new Owner();
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("Not the owner");
        o.changeOwner(bob);
        vm.stopPrank();
    }

    function test_Revert_IFNOT_Owner2() public {
        vm.startPrank(alice);
        Owner o = new Owner();
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(Owner.NotOwner.selector, bob));
        o.changeOwner2(bob);
        vm.stopPrank();
    }

    event ChangeOwner(address indexed caller, address indexed newOwner);

    function test_Emit() public {
        Owner o = new Owner();

        vm.expectEmit(true, true, false, false);
        emit ChangeOwner(address(this), bob);
        o.changeOwner(bob);
    }
}
