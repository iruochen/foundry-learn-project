// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract StorageVars {
	uint x;
	uint y;
	uint z;

	function foo() public {
		y = 2;
		z = 3;
	}

	function bar() external view returns (uint) {
		return y;
	}
}

contract StorageStruct {
	uint8 z;

	struct Point {
		uint8 x;
		uint8 y;
		uint8 z;
	}
	Point p;
	mapping(address => Point) public points;

	function foo() public view returns (uint8) {
		uint8 sum = p.x + p.y + p.z;
		return sum;
	}
}
