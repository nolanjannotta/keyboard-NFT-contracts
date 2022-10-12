pragma solidity 0.8.7;


import "../src/KeyboardA.sol";
import "../src/Sounds.sol";
import "../src/KeyboardOZ.sol";
import "./ERC20Mock.sol";


abstract contract TestSetUp {
    // KeyboardA keyboardA;
    ERC20Mock erc20Mock;
    KeyboardOZ keyboardOZ;
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
    error ScriptLocked();

    function setUp() public {
        // keyboardA = new KeyboardA();
        sounds = new Sounds();
        keyboardOZ = new KeyboardOZ();
        erc20Mock = new ERC20Mock();
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