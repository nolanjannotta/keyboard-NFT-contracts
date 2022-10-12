pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// mock class using ERC20
contract ERC20Mock is ERC20 {
    constructor() payable ERC20("Mock", "MCK") {
        _mint(msg.sender, 1000 ether);
    }

}