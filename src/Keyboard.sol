// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

import "./keyBoardLib.sol";
import "./ISounds.sol";




contract Keyboard is ERC721Enumerable,ERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint public maxSupply = 10_000;


    ISounds private soundsContract;
    uint96 internal royaltyPercentage = 300; // 3%

    string public defaultGateway = "https://arweave.net/";

    uint public price;

    string public ePianoHash;

    string[] internal colorNames = ["Red", "Blue","Purple", "Green", "Pink"];
    mapping(uint => keyBoardLib.ColorScheme) private colorSchemes;
    mapping(uint => uint) internal idToColorScheme;

    string public frontEnd;
    mapping(uint => uint[]) private tokenIdtoInstalledSounds;

    

    mapping(address => string) internal addressToGateway;

    modifier onlyTokenOwner(uint id) {
        if (ownerOf(id) != msg.sender) revert OnlyTokenOwner();
        _;
    }

    event Install(uint keyboardId, uint soundId);
    event UnInstall(uint keyboardId, uint soundId);
    event KeyboardMint(address minter);
    event GatewayUpdated(string newGateway);

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



    constructor() ERC721("Keyboards", "KEYS") { 
        setFrontend("frontend goes here");
        setEPianoHash("tN6qM5U8UE9n_gSMQ0LJYJ4sgrVYe6OEKDcvgVYvXU4");
        setPrice(.01 ether);
        _setDefaultRoyalty(owner(), royaltyPercentage);


        // setting up the colors mapping 
        colorSchemes[1] = keyBoardLib.ColorScheme(
            "00afb9",
            "f07167"
        );
        
        colorSchemes[2] = keyBoardLib.ColorScheme(
            "83c5be",
            "0081a7"
        );
        colorSchemes[3] = keyBoardLib.ColorScheme(
            "a7ece6",
            "AC4EBF"
        );
        colorSchemes[4] = keyBoardLib.ColorScheme(
            "51C2DD",
            "2a994a"
        );
        colorSchemes[5] = keyBoardLib.ColorScheme(
            "b892ff",
            "ff5d8f"
        );

    }

    ///////////////////////////////OWNER FUNCTIONS///////////////////////////////


    function setSounds(address soundsAddr) public onlyOwner {
        //can only set the sounds contract once
        if (address(soundsContract) != address(0))  revert SoundsAlreadySet();
        soundsContract = ISounds(soundsAddr);
    }
    function setEPianoHash(string memory url) public onlyOwner {
        // set arweave hash for default electric piano sound;
        ePianoHash = url;
    }
    function setPrice(uint newPrice) public onlyOwner {
        price = newPrice;
    }

    function setFrontend(string memory url) public onlyOwner {
        //  users can always get the most update frontend. users can also verify a url is not a scammer.
        frontEnd = url;
    }

    function withdrawFunds() public {
        uint amount = address(this).balance;
        Address.sendValue(payable(owner()), amount);
    }

    function setDefaultGateway(string memory newGateway) public onlyOwner {
        // default arweave gateway
        defaultGateway = newGateway;
    }

    ///////////////////////////////////////////////////////////////////////

    function sounds() public view returns(address) {
        // address of sounds contract
        return address(soundsContract);
    }

    function mint(uint[] memory _colorSchemes) public payable {
        // length is also the number of mints
        uint length = _colorSchemes.length;
        // total price
        uint total = length * price;

        // safety checks
        if (msg.value != total) revert IncorrectMsgValue();
        if (length > 5) revert TooManyMints();
        if(_tokenIdCounter.current() + length > maxSupply) revert MaxSupplyExceeded();
        
        
        for (uint i=0; i<length; i++) {
            // makes sure the color exists
            if(_colorSchemes[i] > 5) revert InvalidColor();
            // increment id, get a copy of it
            _tokenIdCounter.increment();
            uint id = _tokenIdCounter.current();
            // records colorid, mints
            idToColorScheme[id] = _colorSchemes[i];
            _safeMint(msg.sender, id);   

        }
        

        emit KeyboardMint(msg.sender);

    }

    function totalSounds() internal view returns(uint) {
        return soundsContract.totalSounds();
    }
    // allows this contract to received erc1155 tokens. Used in install()
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



    function isInstalled(uint[] memory installed, uint sound) private pure returns(bool) {
        // checks whether "sound" exists in "installed"
        for (uint i=0; i<installed.length; i++) {
            if(installed[i]==sound) return true;
        }
        return false;
    }

    // gets index of "element" in "installed." reverts if not found
    function indexOf(uint[] memory installed, uint element) private pure returns(uint) {
        for (uint i=0; i<installed.length; i++) {
            if(installed[i]==element) return i;
        }
        revert NotFound();
    }
    // removes element at "index" of installed array in storage
    function _unInstall(uint keyboardId, uint index) private {
        
        uint[] storage installed = tokenIdtoInstalledSounds[keyboardId];
        for (uint i=index; i<installed.length-1; i++) {
            installed[i] = installed[i+1];

        }
        installed.pop();
    }



    function install(uint KeyboardId, uint soundIndex) public onlyTokenOwner(KeyboardId) {
        // get copy of installed list
        uint[] memory installed = tokenIdtoInstalledSounds[KeyboardId];
        // revert if "soundIndex" is already in the installed list
        if (isInstalled(installed,soundIndex)) revert AlreadyInstalled();
        // adds soundsIndex to list
        tokenIdtoInstalledSounds[KeyboardId].push(soundIndex);
        // transers sound token from "msg.sender"(owner of "keyboardId") to this contract
        soundsContract.safeTransferFrom(msg.sender, address(this), soundIndex, 1, "");
        emit Install(KeyboardId,soundIndex);
    }

    function unInstall(uint KeyboardId, uint soundIndex) public onlyTokenOwner(KeyboardId) {
        // get copy of installed list
        uint[] memory installed = tokenIdtoInstalledSounds[KeyboardId];
        // reverts if soundIndex is NOT in the installed list
        if (!isInstalled(installed,soundIndex)) revert NotInstalled();
        // get index of "soundIndex" in the installed list
        uint index = indexOf(installed, soundIndex);
        // removes "soundId" at "index"
        _unInstall(KeyboardId, index);

        // transfers sound token from this contract to "msg.sender" (owner of "keyboardId") 
        soundsContract.safeTransferFrom(address(this), msg.sender, soundIndex, 1, "");
        emit UnInstall(KeyboardId,soundIndex);

    }

    function setGateway(string memory newString) public {
        // reverts if msg.sender does not own a keyboard
        if(balanceOf(msg.sender) == 0) revert NotTokenOwner();
        // sets custom arweave gateway for all tokens owned by msg.sender
        addressToGateway[msg.sender] = newString;
        emit GatewayUpdated(newString);

    }

    function getGateway(address user) public view returns(string memory) {
        // gets bytes of current gateway for "user"
        bytes memory gatewayBytes = bytes(addressToGateway[user]);
        // if "users" gatesway is zero or set to "default", it uses the contracts default gateway
        // otherwise uses the custom gateway 
        return keccak256(gatewayBytes) == keccak256(bytes("default")) || gatewayBytes.length == 0
        ? defaultGateway
        : addressToGateway[user];        
    }

    // returns array of all sound names
    function getSoundNames() public view returns(string[] memory) {
        uint total = totalSounds();
        // create a memory array with a length the size of totalSounds
        string[] memory soundNames = new string[](total);
        for(uint i=1; i<=total; i++) {
        ISounds.Sound memory sound = soundsContract.getSoundData(i);
            // get each sound name, add to array 
            soundNames[i-1] = sound.name;
        }
        return soundNames;
    }

    // returns array of balances of each sound owned by "user"
    // in this case, balances[0] corresponds to sound id #1
    function getUserSoundBalances(address user) public view returns(uint[] memory) {
        uint total = totalSounds();
        // create a memory array with a length the size of totalSounds
        uint[] memory balances = new uint[](total);
        for(uint i=1; i<=total; i++) {
            // get each balance, add to array
            balances[i-1] = soundsContract.balanceOf(user,i);
        }
        return balances;

    }
    
    
    // returns a list of sound ids that are install in `id`, if the sound id is not install, it is a `0`
    function getInstalledSounds(uint id) public view returns(uint[] memory) {
        return tokenIdtoInstalledSounds[id];
        
    }

    // returns a string for all sound data needed for the keyboard javascript script
    // returns attribute data for keyboard metadata
    function getSoundsAndAttributes(uint id, uint colorId) internal view returns(string memory, string memory) {
        string memory arweaveUrl;
        string memory gateway = getGateway(ownerOf(id));
        // get the start of all the strings as bytes that we need for the keyboards script
        bytes memory _octaves = 'let octaves = [4';
        bytes memory _urls = abi.encodePacked('let soundUris = [','"', gateway, ePianoHash, '"');
        bytes memory _names = 'let names = ["Electric Piano"';
        bytes memory _oneShots = 'let oneShots = [false';
        bytes memory _polyphonic = 'let polyphonic = [true';

        bytes memory _attributes = abi.encodePacked('{"trait_type": "Color", "value": "', colorNames[colorId-1], '"},{"trait_type": "Sound", "value": "Electric Piano"}');

        // gets array of installed sounds for "id"
        uint[] memory installed = tokenIdtoInstalledSounds[id];
        uint length = installed.length;
        if(length > 0) {
            // loop through installed array, concat the bytes we created above to the data for each installed sound
            for(uint i=0; i<length; i++) {                
                // get sound object
                ISounds.Sound memory sound = soundsContract.getSoundData(installed[i]);
                arweaveUrl = string(abi.encodePacked(gateway,sound.arweaveHash));

                _octaves =      abi.encodePacked(_octaves, ',', Strings.toString(sound.octaves));
                _oneShots =     abi.encodePacked(_oneShots, ',',sound.oneShot ? 'true' : 'false');
                _polyphonic =   abi.encodePacked(_polyphonic, ',',sound.polyphonic ? 'true' : 'false');
                _names =        abi.encodePacked(_names, ',"', sound.name, '"');
                _urls =         abi.encodePacked(_urls, ',"', arweaveUrl, '"');
                _attributes =   abi.encodePacked(_attributes, ', {"trait_type": "Sound", "value": "', sound.name,'"}');
            
            }
        }
        return (
            string(abi.encodePacked(_names, "];", _urls, "];", _octaves, "];", _oneShots, "];", _polyphonic, "];")), 
            string(abi.encodePacked("[", _attributes, "]"))
        );
    }


    function tokenURI(uint id) public view override returns(string memory) {
        address owner = ownerOf(id);
        uint color = idToColorScheme[id];
        keyBoardLib.ColorScheme memory colors = colorSchemes[color];
        (string memory soundArr, string memory attributes) = getSoundsAndAttributes(id,color);
        // create param onject to the pass to generateTokenUri()
        keyBoardLib.URIParams memory params = keyBoardLib.URIParams(
            address(soundsContract),
            soundArr,
            attributes,
            frontEnd,
            owner,
            id,
            colors,
            color
        );
        return keyBoardLib.generateTokenURI(params);
    }

    function tokenIdsByOwner(address owner) public view returns(uint[] memory) {
        uint arrLength = balanceOf(owner);
        uint[] memory arr = new uint[](arrLength);
        for (uint i=0;i<arrLength; i++) {
            arr[i] = tokenOfOwnerByIndex(owner, i);
        }
        return arr;

    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable,ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }





}

