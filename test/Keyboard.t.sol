// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/Keyboard.sol";
import "../src/Sounds.sol";


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


contract ERC721Test is Test {
    Keyboard keyboard;
    Sounds sounds;

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

    receive() payable external {}

    function invariantMetadata() public {
        assertEq(keyboard.name(), "Keyboards");
        assertEq(keyboard.symbol(), "KEYS");
        assertEq(keyboard.price(), .1 ether);
        assertEq(keyboard.maxSupply(), 10_000);
        assertEq(keyboard.defaultGateway(), "https://arweave.net/");

    }

    function getColors() internal pure returns(uint[] memory) {
        uint[] memory colors = new uint[](5);
        colors[0] = 1;
        colors[1] = 2;
        colors[2] = 3;
        colors[3] = 4;
        colors[4] = 5;
        return colors;
    }



    function testOwner() public {
        assertEq(keyboard.owner(), address(this));
    }

    function testSetUserGateway() public {
        string memory gateway = "new gateway";
        keyboard.setGateway(gateway);
        assertEq(keyboard.getGateway(address(this)), gateway);

        keyboard.setGateway("default");
        assertEq(keyboard.getGateway(address(this)), keyboard.defaultGateway());
    }

    function testGetUserSoundBalances() public {
        // first mint some sounds
        uint[] memory ids = new uint[](2);
        ids[0] = 1; ids[1] = 2;


        uint[] memory amounts = new uint[](2);
        amounts[0] = 2; amounts[1] = 2;

        uint total;
        for(uint i=0; i<ids.length; i++) {
            total += (sounds.getSoundData(ids[i]).price * amounts[i]);
        }        
        sounds.mintBatch {value: total}(ids, amounts);
        keyboard.setSounds(address(sounds));
        uint[] memory installed = keyboard.getUserSoundBalances(address(this));

        assertEq(installed[0], 2);
        assertEq(installed[1], 2);
        assertEq(installed[2], 0);


    }

    function testKeyboardInstallations() public {
        // setup

        // creating another sound
        sounds.createSound(
            "arweave hash",
            true,
            true,
            "sound type",
            "name",
            5,
            10000,
            1000000000000000
        );
        assertEq(sounds.totalSounds(), 4);

        uint[] memory ids = new uint[](3); // [1,2,3]
        uint[] memory amounts = new uint[](3); // [2,2,2]
        ids[0] = 1;
        ids[1] = 2;
        ids[2] = 3;
        amounts[0] = 2;
        amounts[1] = 2;
        amounts[2] = 2;

        uint cost;
        for(uint i=0; i<ids.length; i++) {
            cost += sounds.getSoundData(ids[i]).price * amounts[i];
        }

        sounds.mintBatch{value: cost}(ids, amounts);
        assertEq(sounds.balanceOf(address(this),1), 2);
        assertEq(sounds.balanceOf(address(this),2), 2);
        assertEq(sounds.balanceOf(address(this),3), 2);
        assertEq(sounds.balanceOf(address(this),4), 0);



        uint[] memory mintArg = new uint[](2); // [1,2]
        mintArg[0] = 1;
        mintArg[1] = 2;
        
        // minting two keyboards
        keyboard.mint{value: keyboard.price() * 2}(mintArg);
        assertEq(keyboard.ownerOf(1), address(this));
        assertEq(keyboard.ownerOf(2), address(this));
        assertEq(keyboard.balanceOf(address(this)), 2);



        // set sounds address in keyboard contract
        keyboard.setSounds(address(sounds));

        // approve
        sounds.setApprovalForAll(address(keyboard), true);
        // console.log(sounds.isApprovedForAll(address(this), address(keyboard)));

        // installing

        keyboard.install(1,1);
        keyboard.install(1,2);
        keyboard.install(1,3);


        // make sure tokens are transferred
        assertEq(sounds.balanceOf(address(this),1), 1);
        assertEq(sounds.balanceOf(address(this),2), 1);
        assertEq(sounds.balanceOf(address(this),3), 1);

        assertEq(sounds.balanceOf(address(keyboard),1), 1);
        assertEq(sounds.balanceOf(address(keyboard),2), 1);
        assertEq(sounds.balanceOf(address(keyboard),3), 1);

        uint[] memory installed = new uint[](3);
        installed[0] = 1;
        installed[1] = 2;
        installed[2] = 3;
        assertEq(keyboard.getInstalledSounds(1), installed);

        // double install
        vm.expectRevert(AlreadyInstalled.selector);
        keyboard.install(1,1);
        vm.expectRevert(AlreadyInstalled.selector);
        keyboard.install(1,2);

        // insufficient sound token balance;
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        keyboard.install(1,4);

        // testing installing sound in non owned keyboard
        vm.expectRevert(OnlyTokenOwner.selector);
        vm.prank(address(0xBEEF));
        keyboard.install(2,1);



        // testing uninstalling
        keyboard.unInstall(1,2);
        uint[] memory unInstalled = new uint[](2);
        
        unInstalled[0] = 1;
        unInstalled[1] = 3;


        assertEq(sounds.balanceOf(address(this),2), 2);
        assertEq(sounds.balanceOf(address(keyboard),2), 0);

        assertEq(keyboard.getInstalledSounds(1), unInstalled);

        // testing double uninstall
        vm.expectRevert(NotInstalled.selector);
        keyboard.unInstall(1,2);


        
    }
 




    ////////////////keyboard mint tests///////////////////////////

    function testMint() public {

        uint[] memory colors = getColors();
        keyboard.mint{value:.5 ether}(colors);

        assertEq(address(keyboard).balance, .5 ether);
        assertEq(keyboard.balanceOf(address(this)), 5);
        assertEq(keyboard.ownerOf(1), address(this));

        // wrong price mint
        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:.2 ether}(colors);

        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:.6 ether}(colors);


        // testing too many colors
        uint[] memory tooManyColors = new uint[](6);
        tooManyColors[0] = 1;
        tooManyColors[1] = 2;
        tooManyColors[2] = 3;
        tooManyColors[3] = 4;
        tooManyColors[4] = 5;
        tooManyColors[5] = 5;

        uint price = keyboard.price() * tooManyColors.length;

        vm.expectRevert(TooManyMints.selector);
        keyboard.mint{value:price}(tooManyColors);


        // testing invalid color mint
        colors[4] = 6;
        vm.expectRevert(InvalidColor.selector);
        keyboard.mint{value:.5 ether}(colors);

    }

    function testFailSendEther() public {
        // reverts if ether is sent to contract 
        payable(address(keyboard)).transfer(1 ether);
    }

    function testWithdraw() public {
        uint[] memory colors = getColors();
        keyboard.mint{value:.5 ether}(colors);
        assertEq(address(keyboard).balance, .5 ether);

        // set this address balance to zero
        hoax(address(this), 0 ether);
        keyboard.withdrawFunds();

        // check is ether is transferred correctly
        assertEq(address(keyboard).balance, 0);
        assertEq(address(this).balance, .5 ether);



    }

    ////////////keyboard owner functions/////////////////

    function testOwnerSetters() public {
        string memory testString = "this is a test string";
        uint testPrice = .2 ether;


        // set default sound hash
        keyboard.setEPianoHash(testString);
        assertEq(keyboard.ePianoHash(),testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setEPianoHash(testString);



        // set price
        keyboard.setPrice(testPrice);
        assertEq(keyboard.price(), testPrice);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setPrice(testPrice);



        // set frontend
        keyboard.setFrontend(testString);
        assertEq(keyboard.frontEnd(), testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setFrontend(testString);



        // set default gateway
        keyboard.setDefaultGateway(testString);
        assertEq(keyboard.defaultGateway(), testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setDefaultGateway(testString);



        // set sounds
        keyboard.setSounds(address(sounds));
        assertEq(keyboard.sounds(), address(sounds));
        // test double set sounds
        vm.expectRevert(SoundsAlreadySet.selector);
        keyboard.setSounds(address(0xBEEF));
        // non owner
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');        
        keyboard.setSounds(address(sounds));

    }

    //////////////////////////Sounds//////////////////////////

    function testTotalSounds() public {
        uint total = sounds.totalSounds();
        assertEq(total, 3);
    }

    function testSoundOwnerFunctions() public {
        // update uri for sound number 1
        sounds.updateUri("new arweave hash",1);
        assertEq(sounds.getSoundData(1).arweaveHash, "new arweave hash");

        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xBEEF));
        sounds.updateUri("new arweave hash",1);


        sounds.setPrice(1, .1 ether);
        assertEq(sounds.getSoundData(1).price, .1 ether);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xBEEF));
        sounds.setPrice(1,.1 ether);

        sounds.setFrontend("new frontend");
        assertEq(sounds.frontEnd(), "new frontend");

        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xBEEF));
        sounds.setFrontend("new frontend");


    }

    function testOwnerCreateSound() public {
        keyboard.setSounds(address(sounds));
        sounds.createSound(
            "arweave hash",
            true,
            true,
            "sound type",
            "name",
            5,
            10000,
            1000000000000000
        );
        assertEq(sounds.totalSounds(), 4);


        // test for getSoundNames()
        string[] memory installedNames = keyboard.getSoundNames();
        assertEq(installedNames[0], "Grand Piano");
        assertEq(installedNames[1], "Juno");
        assertEq(installedNames[2], "Rhodes");
        assertEq(installedNames[3], "name");

        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xBEEF));
        sounds.createSound(
            "arweave hash",
            true,
            true,
            "sound type",
            "name",
            5,
            10000,
            1000000000000000
        );



    }

    function testGetSoundData() public {
        sounds.createSound(
            "arweave hash",
            true,
            true,
            "sound type",
            "name",
            5,
            10000,
            .001 ether
        );
        

        // check sound that is created on deployment
        assertEq(sounds.getSoundData(1).arweaveHash, "2sDFrNK4ftL4hoqH00XX4y3n-kg_9v3UViBQit9fAs8");
        assertEq(sounds.getSoundData(1).name, "Grand Piano");
        assertEq(sounds.getSoundData(1).soundType, "Piano/Epiano");
        assertEq(sounds.getSoundData(1).oneShot, false);
        assertEq(sounds.getSoundData(1).polyphonic, true);
        assertEq(sounds.getSoundData(1).octaves, 5);
        assertEq(sounds.getSoundData(1).price, .01 ether);
        assertEq(sounds.getSoundData(1).maxAmount, 10000);

        // check newly created sound 
        assertEq(sounds.getSoundData(4).name, "name");
        assertEq(sounds.getSoundData(4).arweaveHash, "arweave hash");
        assertEq(sounds.getSoundData(4).soundType, "sound type");
        assertEq(sounds.getSoundData(4).oneShot, true);
        assertEq(sounds.getSoundData(4).polyphonic, true);
        assertEq(sounds.getSoundData(4).octaves, 5);
        assertEq(sounds.getSoundData(4).price, .001 ether);
        assertEq(sounds.getSoundData(4).maxAmount, 10000);




    }


    /////////////////////mint functions testing//////////////////////

    function testSoundMint() public {

        // test mint
        uint price = sounds.getSoundData(1).price;
        sounds.mint{value: price}(1);
        assertEq(sounds.balanceOf(address(this), 1),1);
        assertEq(sounds.totalSupply(1), 1);

        // test wrong price
        vm.expectRevert(IncorrectMsgValue.selector);
        sounds.mint{value: .0001 ether}(1);
        vm.expectRevert(IncorrectMsgValue.selector);
        sounds.mint{value: 1 ether}(1);


        // test invalid sound
        vm.expectRevert(NonExistentSound.selector);
        sounds.mint{value: .01 ether}(6);

        sounds.createSound(
            "arweave hash",
            true,
            true,
            "sound type",
            "name",
            5,
            1, // max amount is 1 for testing
            .01 ether
        );
        assertEq(sounds.totalSounds(), 4); 
        sounds.mint{value: .01 ether}(4);

        bytes4 selector = bytes4(keccak256("MaxAmountExceeded(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 4));
        sounds.mint{value: .01 ether}(4);

        
    }


    function testSoundBatchMint() public {
        uint[] memory ids = new uint[](3);
        ids[0] = 1; ids[1] = 2; ids[2] = 3;


        uint[] memory amounts = new uint[](3);
        amounts[0] = 2; amounts[1] = 2; amounts[2] = 2;

        uint total;
        for(uint i=0; i<ids.length; i++) {
            total += (sounds.getSoundData(ids[i]).price * amounts[i]);
        }        
        sounds.mintBatch {value: total}(ids, amounts);


        // test mint with invalid sound id. id #4 doesnt exist
        ids[2] = 4;
        vm.expectRevert(NonExistentSound.selector);
        sounds.mintBatch {value: total}(ids, amounts);

        // test mint with too many. max number of mints is 5.
        amounts[2] = 6;
        ids[2] = 3;
        vm.expectRevert(TooManyMints.selector);
        sounds.mintBatch {value: total}(ids, amounts);

    }


}
