// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {console} from "forge-std/Script.sol";

import {BaseScript} from "./BaseScript.s.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenScript is BaseScript {

	MyToken public myToken;

	function run() public broadcaster {
		myToken = new MyToken("RC", "R");
		console.log("MyToken deployed at:", address(myToken));
		saveContract("MyToken", address(myToken));
	}
}