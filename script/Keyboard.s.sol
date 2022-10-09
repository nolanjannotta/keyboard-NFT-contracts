// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Script.sol";
import "../src/KeyboardA.sol";
import "../src/KeyboardOZ.sol";
import "../src/Sounds.sol";
import "forge-std/console.sol";


contract MyScript is Script {
    function run() external {
        vm.startBroadcast();

        // KeyboardA keyboardA = KeyboardA();
        KeyboardOZ keyboardOZ = new KeyboardOZ();

        Sounds sounds = new Sounds();
        keyboardOZ.setSounds(address(sounds));
        uint[] memory colors = new uint[](5);
        colors[0] = 1; colors[1] = 2; colors[2] = 3; colors[3] = 4; colors[4] = 5;
        keyboardOZ.mint{value: keyboardOZ.price() * 5}(colors);
        string memory tokenUri = keyboardOZ.tokenURI(5);
        console.log(tokenUri);
        keyboardOZ.withdrawFunds();
        console.log(address(sounds));
        console.log(address(keyboardOZ));

        vm.stopBroadcast();
    }
}
