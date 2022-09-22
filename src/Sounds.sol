// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";








contract Sounds is ERC1155Supply, Ownable {
    

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
    uint internal currentSoundId;
    // uint defaultPrice = 1 ether; //matic
    string public frontEnd;
    
    string internal svgStart = '<svg viewBox="0 0 400 200" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"> <rect fill="#a8dadc" x="0" y="0" width="400" height="200"/> <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" font-size="40px" font-family="Helvetica">';
    string internal svgEnd = '</text> </svg>';
    string public name;
    string public symbol;
    mapping(uint => Sound) internal soundIdToSound;

    event TokenMint(address minter);
    

    constructor() ERC1155("") {
        setFrontend("front end goes here.");
        // setDefaultPrice(.1 ether);
        createSound(
            "2sDFrNK4ftL4hoqH00XX4y3n-kg_9v3UViBQit9fAs8", 
            false,
            true,
            "Piano/Epiano", 
            "Grand Piano", 
            5,
            10000,
            10**16
        );
        createSound(
            "NiGTqdulx6I2pp4PZLnCzAOUkQAXO50QIL8efl9nxRM", 
            false,
            true,
            "Synth", 
            "Juno", 
            4,
            10000,
            10**16
        );
        
        createSound(
            "zwK_0m2oN9XeI2F0ojLcLm22Yf_fpeJ7xirvIVJBK_k", 
            false,
            true,
            "Keyboard", 
            "Rhodes", 
            4,
            10000,
            10**16
        );
        

        name = "Sounds";
        symbol = "SNDS";
        }


    function updateUri(string memory newHash, uint soundId) public onlyOwner {
        soundIdToSound[soundId].arweaveHash = newHash;
    }

    function withdrawFunds() public onlyOwner {
        uint amount = address(this).balance;
        Address.sendValue(payable(owner()), amount);
    }

    function setPrice(uint id, uint newPrice) public onlyOwner {
        soundIdToSound[id].price = newPrice;
    }
    // function setDefaultPrice(uint newPrice) public onlyOwner {
    //     defaultPrice = newPrice;
    // }
    function setFrontend(string memory newUrl) public onlyOwner {
        frontEnd = newUrl;
    }


    function totalSounds() public view returns(uint) {
        return currentSoundId;
    }
    

    function getSoundData(uint soundId) public view returns(Sound memory sound){
        sound = soundIdToSound[soundId];


    }

    function createSound(
        string memory _arweaveHash, 
        bool _oneShot, bool _polyphonic, 
        string memory _soundType, 
        string memory _name, 
        uint _octaves, 
        uint _maxAmount,
        uint _price
        ) public onlyOwner {
        Sound memory newSound = Sound({
            arweaveHash: _arweaveHash, 
            maxAmount: _maxAmount, 
            name: _name,
            oneShot: _oneShot,
            polyphonic: _polyphonic,
            soundType: _soundType,
            octaves: _octaves,
            price: _price
            });
        
        currentSoundId ++;
        soundIdToSound[currentSoundId]= newSound;
    }




    

    function uri(uint soundId) public view override returns(string memory) {
        Sound memory sound = soundIdToSound[soundId];
        string memory base64 =  Base64.encode(abi.encodePacked(svgStart, sound.name, svgEnd));
        bytes memory json = abi.encodePacked(
            '{"image":"',
            "data:image/svg+xml;base64,",
            base64,
            '", "description":"',
            'Sound plug-in for Keyboard NFT. To learn more, visit the [Official Website](',
            frontEnd,
            ')","samples_hash":"',
            sound.arweaveHash,
            '","name":"'
            );
        json = abi.encodePacked(
            json, 
            sound.name,
            '", "attributes":',
            '[{ "trait_type": "sound_type", "value": "',
            sound.soundType,
            '"}, {"trait_type": "one_shot", "value": "',
            sound.oneShot ? 'true' : 'false',
            '"}, {"trait_type": "polyphonic", "value": "',
            sound.polyphonic ? 'true' : 'false',
            '"}, {"trait_type": "octaves", "value": "',
            Strings.toString(sound.octaves),
            '"}]}'
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(json)));
        
    }
    
    function mint(uint256 soundId) payable public { 
        require(soundId >= 1 && soundId <= totalSounds(), "sound doesnt exist");
        require(msg.value == soundIdToSound[soundId].price);
        require(totalSupply(soundId) < soundIdToSound[soundId].maxAmount, "max amount reached");
        _mint(msg.sender, soundId, 1, "");
        emit TokenMint(msg.sender);

    }

    function mintBatch(address to, uint[] memory soundIds, uint[] memory amounts) payable public{
        uint totalCost = 0;
        for(uint i=0; i<soundIds.length; i++) {
            uint soundId = soundIds[i];
            uint amount = amounts[i];
            require(soundId >= 1 && soundId <= totalSounds(), "sound doesnt exist");
            require(totalSupply(soundId) + amount <= soundIdToSound[soundId].maxAmount, "max amount exceeded");
            require(amount <= 5, "max amount is 5");
            totalCost += (amount * soundIdToSound[soundId].price);
        }
        require(msg.value == totalCost, "incorrect amount sent");
        _mintBatch(to, soundIds, amounts, "");
        emit TokenMint(msg.sender);

    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }




}