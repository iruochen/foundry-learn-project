// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract ForkTest is Test {
    uint256 public sepoliaForkId;
    uint256 public polygonForkId;

    function setUp() public {
        // use latest available block from the RPC provider (avoid historical-state errors)
        sepoliaForkId = vm.createSelectFork(vm.rpcUrl("sepolia"));
        polygonForkId = vm.createSelectFork(vm.rpcUrl("polygon"));
    }

    function test_Sepolia() public {
        vm.selectFork(sepoliaForkId);
        assertEq(vm.activeFork(), sepoliaForkId);

        MyToken token = MyToken(0x21b4D1f6d42dc6083db848D42AA4b6895371E1e7);
        console.log("Token name:", token.name());
        console.log("Token symbol:", token.symbol());
        console.log("address balance:", token.balanceOf(0xe7a4159Be8c74c3BB38A45B31cF59889EF3F32b7));
        assertGe(token.balanceOf(0xe7a4159Be8c74c3BB38A45B31cF59889EF3F32b7), 1e18);
    }

    function test_Polygon() public {
        vm.selectFork(polygonForkId);
        assertEq(vm.activeFork(), polygonForkId);
    }
}
