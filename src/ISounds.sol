pragma solidity 0.8.7;


interface ISounds {

    struct Sound {
        string arweaveHash;
        string name;
        string soundType; //types: Piano/Epiano, Synth, Drums/Perc, Bass etc
        uint maxAmount;
        bool oneShot;
        bool polyphonic;
        uint octaves;
        uint price;
    }

    function name() external view returns (string memory);
    function url(uint soundId) external view returns (string memory);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function balanceOf(address account, uint id) external view returns (uint);
    function mint(address to, uint id) external payable;
    function displayImage() external view returns(string memory);
    function totalSounds() external view returns(uint);
    function mintGrandPiano(address to) external;
    function createSound(string memory _arWeaveUrl, string memory _name, uint _maxAmount) external returns (uint);
    function getSoundData(uint id) external view returns (Sound memory);

    function name(uint id) external view returns (string memory);
    function octaves(uint id) external view returns (uint);
    function setKeyboard(address _keyboard) external;
    function mintBatch(address to,uint[] memory soundIds, uint[] memory amounts) external payable;
}