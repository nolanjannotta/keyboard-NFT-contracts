pragma solidity 0.8.7;


import "../src/Keyboard.sol";
import "../src/Sounds.sol";

abstract contract TestSetUp {
    Keyboard keyboard;
    Sounds sounds;
    error NotInstalled();
    error AlreadyInstalled();
    error OnlyTokenOwner();
    error SoundsAlreadySet();
    error IncorrectMsgValue();
    error TooManyMints();
    error NotFound();
    error MaxSupplyExceeded();
    error InvalidColor();
    error NotTokenOwner();
    error NonExistentSound();
    error MaxAmountExceeded();

    function setUp() public {
        keyboard = new Keyboard();
        sounds = new Sounds();
    }

    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) public virtual returns (bytes4) {
        _operator;
        _from;
        _id;
        _data;

        return this.onERC721Received.selector;
    }
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) public pure returns (bytes4) {
        
        operator;
        from;
        id;
        value;
        data;
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory ids,
        uint256[] memory values,
        bytes calldata data
    ) public pure returns (bytes4) {
        
        operator;
        from;
        ids;
        values;
        data;
        return this.onERC1155BatchReceived.selector;
    }
    // so we can test withdrawFunds function
    receive() payable external {}
}