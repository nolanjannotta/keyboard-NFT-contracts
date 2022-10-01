// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./TestSetUp.sol";





contract ERC721Test is Test, TestSetUp {
    

    function invariantMetadata() public {
        assertEq(keyboard.name(), "Keyboards");
        assertEq(keyboard.symbol(), "KEYS");
        assertEq(keyboard.price(), .01 ether);
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
        // should fail if no tokens are owned by msg.sender
        vm.expectRevert(NotTokenOwner.selector);
        keyboard.setGateway(gateway);
        // minting
        uint[] memory colors = getColors();
        uint price = keyboard.price() * colors.length;

        keyboard.mint{value: price}(colors);
        // setting gateway
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
 

    function testTokenIdsByOwner() public {
        uint[] memory colors = getColors();
        uint price = keyboard.price() * colors.length;
        keyboard.mint{value:price}(colors);

        uint[] memory owned = keyboard.tokenIdsByOwner(address(this));
        assertEq(owned[0], 1);
        assertEq(owned[1], 2);
        assertEq(owned[2], 3);
        assertEq(owned[3], 4);
        assertEq(owned[4], 5);


        keyboard.safeTransferFrom(address(this), address(0xBEEF), 3);
        assertEq(keyboard.tokenIdsByOwner(address(0xBEEF))[0], 3);

        owned = keyboard.tokenIdsByOwner(address(this));
        assertEq(owned[0], 1);
        assertEq(owned[1], 2);
        assertEq(owned[2], 5);
        assertEq(owned[3], 4);
    }




    ////////////////keyboard mint tests///////////////////////////

    function testMint() public {
        uint[] memory colors = getColors();
        uint price = keyboard.price() * colors.length;

        keyboard.mint{value:price}(colors);

        assertEq(address(keyboard).balance, price);
        assertEq(keyboard.balanceOf(address(this)), 5);
        assertEq(keyboard.ownerOf(1), address(this));

        // wrong price mint
        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:.02 ether}(colors);

        vm.expectRevert(IncorrectMsgValue.selector);
        keyboard.mint{value:.06 ether}(colors);


        // testing too many colors
        uint[] memory tooManyColors = new uint[](6);
        tooManyColors[0] = 1;
        tooManyColors[1] = 2;
        tooManyColors[2] = 3;
        tooManyColors[3] = 4;
        tooManyColors[4] = 5;
        tooManyColors[5] = 5;

        vm.expectRevert(TooManyMints.selector);
        keyboard.mint{value:.06 ether}(tooManyColors);


        // testing invalid color mint
        colors[4] = 6;
        vm.expectRevert(InvalidColor.selector);
        keyboard.mint{value:price}(colors);

    }

    function testFailSendEther() public {
        // reverts if ether is sent to contract 
        payable(address(keyboard)).transfer(1 ether);
    }

    function testWithdraw() public {
        uint[] memory colors = getColors();
        uint price = keyboard.price() * colors.length;
        keyboard.mint{value:price}(colors);
        assertEq(address(keyboard).balance, price);

        // set this address balance to zero
        hoax(address(this), 0 ether);
        keyboard.withdrawFunds();

        // check is ether is transferred correctly
        assertEq(address(keyboard).balance, 0);
        assertEq(address(this).balance, price);



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


}
