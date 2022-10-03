// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Script.sol";
import "../src/Keyboard.sol";
import "../src/Sounds.sol";
import "forge-std/console.sol";


contract MyScript is Script {
    function run() external {
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        Keyboard keyboard = new Keyboard();
        Sounds sounds = new Sounds();
        keyboard.setSounds(address(sounds));
        uint[] memory colors = new uint[](5);
        colors[0] = 1; colors[1] = 2; colors[2] = 3; colors[3] = 4; colors[4] = 5;
        keyboard.mint{value: keyboard.price() * 5}(colors);
        string memory tokenUri = keyboard.tokenURI(5);
        console.log(tokenUri);

        vm.stopBroadcast();
    }
}
