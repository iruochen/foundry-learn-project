// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

contract SchoolMappingList {
	mapping(address => address) _nextStudents;
	uint public listSize;

	address constant GUARD = address(1);

	constructor() {
		_nextStudents[GUARD] = GUARD;
	}

	function addStudent(address student) external {
		require(!isStudent(student));
		_nextStudents[student] = _nextStudents[GUARD];
		_nextStudents[GUARD] = _nextStudents[student];
		listSize++;
	}

	function removeStudent(address student, address preStudent) public {
		require(isStudent(student));
		require(_nextStudents[preStudent] == student);

		_nextStudents[preStudent] = _nextStudents[student];
		_nextStudents[student] = address(0);
		listSize--;
	}

	function removeStudent2(address student) public {
		require(isStudent(student));
		address prevStudent = _getPrevStudent(student);
		_nextStudents[prevStudent] = _nextStudents[student];
		_nextStudents[student] = address(0);
		listSize--;
	}

	function _getPrevStudent(address student) internal view returns (address) {
		address currentStudent = GUARD;
		while (_nextStudents[currentStudent] != GUARD) {
			if (_nextStudents[currentStudent] == student) {
				return currentStudent;
			}
			currentStudent = _nextStudents[currentStudent];
		}
		return address(0);
	}

	function getStudents() public view returns (address[] memory) {
		address[] memory students = new address[](listSize);
		address currentAddress = _nextStudents[GUARD];
		for (uint256 i = 0; currentAddress != GUARD; ++i) {
			students[i] = currentAddress;
			currentAddress = _nextStudents[currentAddress];
		}
		return students;
	}

	function isStudent(address student) public view returns (bool) {
		return _nextStudents[student] != address(0);
	}
}
