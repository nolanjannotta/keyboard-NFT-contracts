// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
// import "forge-std/console.sol";

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
    // uint[] tooManyColors = [1,2,3,4,5,5];
    // uint[] invalidColors = [1,2,3,4,6];

    // uint[] soundMintBatchIds = [1,2,3];
    // uint[] soundMintBatchAmounts = [2,3,4];

    // uint[] soundMintBatchIdsInvalid = [1,2,4];
    // uint[] soundMintBatchAmountsTooMany = [1,1,2,2,3,3];

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

    function invariantMetadata() public {
        assertEq(keyboard.name(), "Keyboards");
        assertEq(keyboard.symbol(), "KEYS");
        assertEq(keyboard.price(), .1 ether);
    }

    function getColors() internal pure returns(uint[] memory) {
        uint[] memory colors = new uint[](3);
        colors[0] = 1;
        colors[1] = 2;
        colors[2] = 3;
        return colors;
    }

    function testSetUserGateway() public {
        string memory gateway = "new gateway";
        keyboard.setGateway(gateway);
        assertEq(keyboard.getGateway(address(this)), gateway);

        keyboard.setGateway("default");
        assertEq(keyboard.getGateway(address(this)), keyboard.defaultGateway());
    }

    function testInstallations() public {
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
        keyboard.mint{value:.3 ether}(colors);

        assertEq(keyboard.balanceOf(address(this)), 3);
        assertEq(keyboard.ownerOf(1), address(this));
    }

    

    function testTooManyMints() public {
        uint[] memory tooManyColors = new uint[](6);
        tooManyColors[0] = 1;
        tooManyColors[1] = 1;
        tooManyColors[2] = 1;
        tooManyColors[3] = 1;
        tooManyColors[4] = 1;
        tooManyColors[5] = 1;

        uint price = keyboard.price() * tooManyColors.length;

        vm.expectRevert(TooManyMints.selector);
        keyboard.mint{value:price}(tooManyColors);

    }

    function testWrongPriceMint() public {
        uint[] memory colors = getColors();
        uint total = keyboard.price() * colors.length;

        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:total-1234}(colors);

        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:total+1234}(colors);
    }


    function testInvalidColorMint() public {
        uint[] memory invalidColors = new uint[](5);
        invalidColors[0] = 1;
        invalidColors[1] = 2;
        invalidColors[2] = 3;
        invalidColors[3] = 4;
        invalidColors[4] = 6;


        uint total = keyboard.price() * invalidColors.length;
        vm.expectRevert(InvalidColor.selector);

        keyboard.mint{value:total}(invalidColors);
    }

    // function testFailExceedMaxMint() public {

    // }

    function testSetSounds() public {
        keyboard.setSounds(address(sounds));
        assertEq(keyboard.sounds(), address(sounds));
    }

    function testDoubleSetSounds() public {
        keyboard.setSounds(address(sounds));
        vm.expectRevert(SoundsAlreadySet.selector);
        keyboard.setSounds(address(0xBEEF));
    }

    function testNonOwnerSetSounds() public {
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');        
        keyboard.setSounds(address(sounds));
    }



    function testOwnerSetters() public {

        string memory testString = "this is a test string";
        keyboard.setEPianoHash(testString);
        assertEq(keyboard.ePianoHash(),testString);

        uint price = .2 ether;
        keyboard.setPrice(price);
        assertEq(keyboard.price(), price);

        keyboard.setFrontend(testString);
        assertEq(keyboard.frontEnd(), testString);

        keyboard.setDefaultGateway(testString);
        assertEq(keyboard.defaultGateway(), testString);
    }

    function testOwnerSettersFail() public {
        string memory testString = "this is a test string";

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setEPianoHash(testString);

        uint price = .2 ether;
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setPrice(price);

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setFrontend(testString);

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboard.setDefaultGateway(testString);
    }

    function testNonOwnerSetEpiano() public {

        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');
        keyboard.setEPianoHash("this is a string");
    }

    function testNonOwnerSetPrice() public {
        vm.prank(address(0xABCDBEEF));

        vm.expectRevert('Ownable: caller is not the owner');
        keyboard.setPrice(1e18);
    }

    function testNonOwnerSetFrontend() public {
        vm.prank(address(0xABCDBEEF));

        vm.expectRevert('Ownable: caller is not the owner');
        keyboard.setFrontend("this is the frontend");
    }

    function testNonOwnerSetGateway() public {
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');
        keyboard.setDefaultGateway("this is the default gateway");

    }







    //////////////////////////Sounds////////////////////////////////

    function testSoundOwnerFunctions() public {
        sounds.updateUri("new uri",1);
        assertEq(sounds.getSoundData(1).arweaveHash, "new uri");
    }
    function testOwnerSetPrice() public {
        sounds.setPrice(1,.1 ether);
        assertEq(sounds.getSoundData(1).price, .1 ether);
    }
    function testOwnerSetFrontend() public {
        sounds.setFrontend("new frontend");
        assertEq(sounds.frontEnd(), "new frontend");
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

        string[] memory installedNames = keyboard.getSoundNames();
        assertEq(installedNames[0], "Grand Piano");
        assertEq(installedNames[1], "Juno");
        assertEq(installedNames[2], "Rhodes");
        assertEq(installedNames[3], "name");


    }
    function testMaxAmount() public {
        assertEq(sounds.getSoundData(1).maxAmount, 10000);
        assertEq(sounds.getSoundData(2).maxAmount, 10000);
        assertEq(sounds.getSoundData(3).maxAmount, 10000);

    }

    function testSoundMint()public {

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
    function testTotalSounds() public {
        uint total = sounds.totalSounds();
        assertEq(total, 3);
    }

    function testSoundBatchMint() public {
        uint[] memory ids = new uint[](3);
        ids[0] = 1; ids[1] = 2; ids[2] = 3;


        uint[] memory amounts = new uint[](3);
        amounts[0] = 2; amounts[1] = 2; amounts[2] = 2;


        // uint[] soundMintBatchAmountsTooMany = [1,1,2,2,3,3];


        uint total;
        for(uint i=0; i<ids.length; i++) {
            total += (sounds.getSoundData(ids[i]).price * amounts[i]);
        }

        // console.log(sounds.totalSounds());
        
        sounds.mintBatch {value: total}(ids, amounts);

        uint[] memory invalidIds =  new uint[](4);
        invalidIds[0] = 1; invalidIds[1] = 2; invalidIds[2] = 3; invalidIds[3] = 4;

        uint[] memory invalidIdsAmounts = new uint[](4);
        invalidIdsAmounts[0] = 1; invalidIdsAmounts[1] = 1; invalidIdsAmounts[2] = 1; invalidIdsAmounts[3] = 1;

        total = 0;
        for(uint i=0; i<invalidIds.length; i++) {
            total += (sounds.getSoundData(invalidIds[i]).price * invalidIdsAmounts[i]);
        }
        vm.expectRevert(NonExistentSound.selector);
        sounds.mintBatch {value: total}(invalidIds, invalidIdsAmounts);

    }


}
