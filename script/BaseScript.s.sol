// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

abstract contract BaseScript is Script {

	address internal deployer;
	address internal user;
	string internal mnemonic;
	uint256 internal deployerPrivateKey;

	function setUp() public virtual { 
		// mnemonic = vm.envString("MNEMONIC");
		// (deployer, )= vm.deriveKeyAndAddress(mnemonic, 0);
		// console.log("Deployer address:", deployer);

		deployerPrivateKey = vm.envUint("PRIVATE_KEY");
		// user = vm.addr(deployerPrivateKey);
		// console.log("Deployer address:", user);
	}

	function saveContract(string memory name, address addr) internal {
		string memory chainId = vm.toString(block.chainid);

		string memory json1 = "key";
		string memory finalJson = vm.serializeAddress(json1, "address", addr);
		string memory dirPath = string.concat(string.concat("deployments/", name), "_");
		vm.writeJson(finalJson, string.concat(dirPath, string.concat(chainId, ".json"))); 
	}	

	modifier broadcaster() {
		vm.startBroadcast(deployerPrivateKey);
		_;
		vm.stopBroadcast();
	}
}
