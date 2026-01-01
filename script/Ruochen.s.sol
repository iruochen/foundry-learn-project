// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {console} from "forge-std/Script.sol";

import {BaseScript} from "./BaseScript.s.sol";
import {Ruochen} from "../src/Ruochen.sol";

contract RuochenScript is BaseScript {
    Ruochen public ruochen;

    function run() public broadcaster {
        ruochen = new Ruochen();
        console.log("Ruochen deployed at:", address(ruochen));
        saveContract("Ruochen", address(ruochen));
    }
}
