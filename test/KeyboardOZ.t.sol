// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./TestSetUp.sol";





contract ERC721Test is Test, TestSetUp {
    

    function invariantMetadata() public {
        assertEq(keyboardOZ.name(), "Keyboards");
        assertEq(keyboardOZ.symbol(), "KEYS");
        assertEq(keyboardOZ.price(), .05 ether);
        assertEq(keyboardOZ.maxSupply(), 10_000);
        assertEq(keyboardOZ.defaultGateway(), "https://arweave.net/");

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
        assertEq(keyboardOZ.owner(), address(this));
    }

    function testSetUserGateway() public {

        string memory gateway = "new gateway";
        // should fail if no tokens are owned by msg.sender
        vm.expectRevert(NotTokenOwner.selector);
        keyboardOZ.setGateway(gateway);
        // minting
        uint[] memory colors = getColors();
        uint price = keyboardOZ.price() * colors.length;

        keyboardOZ.mint{value: price}(colors);
        // setting gateway
        keyboardOZ.setGateway(gateway);
        assertEq(keyboardOZ.getGateway(address(this)), gateway);

        keyboardOZ.setGateway("default");
        assertEq(keyboardOZ.getGateway(address(this)), keyboardOZ.defaultGateway());
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
        keyboardOZ.setSounds(address(sounds));
        uint[] memory installed = keyboardOZ.getUserSoundBalances(address(this));

        assertEq(installed[0], 2);
        assertEq(installed[1], 2);
        assertEq(installed[2], 0);


    }

    function testKeyboardOZInstallations() public {
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
        // sounds.createSound(
        //     "arweave hash2",
        //     true,
        //     true,
        //     "sound type2",
        //     "name2",
        //     5,
        //     10000,
        //     1000000000000000
        // );
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
        
        // minting two keyboardOZs
        keyboardOZ.mint{value: keyboardOZ.price() * 2}(mintArg);
        assertEq(keyboardOZ.ownerOf(1), address(this));
        // assertEq(keyboardOZ.ownerOf(2), address(this));
        assertEq(keyboardOZ.balanceOf(address(this)), 2);



        // set sounds address in keyboardOZ contract
        keyboardOZ.setSounds(address(sounds));

        // approve
        sounds.setApprovalForAll(address(keyboardOZ), true);
        // console.log(sounds.isApprovedForAll(address(this), address(keyboardOZ)));

        // installing

        keyboardOZ.install(1,1);
        keyboardOZ.install(1,2);
        keyboardOZ.install(1,3);


        // make sure tokens are transferred
        assertEq(sounds.balanceOf(address(this),1), 1);
        assertEq(sounds.balanceOf(address(this),2), 1);
        assertEq(sounds.balanceOf(address(this),3), 1);

        assertEq(sounds.balanceOf(address(keyboardOZ),1), 1);
        assertEq(sounds.balanceOf(address(keyboardOZ),2), 1);
        assertEq(sounds.balanceOf(address(keyboardOZ),3), 1);

        uint[] memory installed = new uint[](3);
        installed[0] = 1;
        installed[1] = 2;
        installed[2] = 3;
        assertEq(keyboardOZ.getInstalledSounds(1), installed);

        // test installing invalid sound id
        vm.expectRevert(NotFound.selector);
        keyboardOZ.install(1,5);
        
        // double install
        vm.expectRevert(AlreadyInstalled.selector);
        keyboardOZ.install(1,1);
        vm.expectRevert(AlreadyInstalled.selector);
        keyboardOZ.install(1,2);

        // insufficient sound token balance;
        vm.expectRevert("ERC1155: insufficient balance for transfer");
        keyboardOZ.install(1,4);

        // testing installing sound in non owned keyboardOZ
        vm.expectRevert(OnlyTokenOwner.selector);
        vm.prank(address(0xBEEF));
        keyboardOZ.install(2,1);

        



        // testing uninstalling
        keyboardOZ.unInstall(1,2);
        installed = new uint[](2);
        
        installed[0] = 1;
        installed[1] = 3;


        assertEq(sounds.balanceOf(address(this),2), 2);
        assertEq(sounds.balanceOf(address(keyboardOZ),2), 0);

        assertEq(keyboardOZ.getInstalledSounds(1), installed);

        // testing double uninstall
        vm.expectRevert(NotInstalled.selector);
        keyboardOZ.unInstall(1,2);


        
    }
 

    function testTokenIdsByOwner() public {
        uint[] memory colors = getColors();
        uint price = keyboardOZ.price() * colors.length;
        keyboardOZ.mint{value:price}(colors);


        hoax(address(0xABCBEEF), 1 ether);
        keyboardOZ.mint{value:price}(colors);


        uint[] memory owned = keyboardOZ.tokenIdsByOwner(address(this));
        assertEq(owned[0], 1);
        assertEq(owned[1], 2);
        assertEq(owned[2], 3);
        assertEq(owned[3], 4);
        assertEq(owned[4], 5);

        owned = keyboardOZ.tokenIdsByOwner(address(0xABCBEEF));
        assertEq(owned[0], 6);
        assertEq(owned[1], 7);
        assertEq(owned[2], 8);
        assertEq(owned[3], 9);
        assertEq(owned[4], 10);


        keyboardOZ.safeTransferFrom(address(this), address(0xBEEF), 3);
        assertEq(keyboardOZ.tokenIdsByOwner(address(0xBEEF))[0], 3);

        owned = keyboardOZ.tokenIdsByOwner(address(this));
        assertEq(owned[0], 1);
        assertEq(owned[1], 2);
        assertEq(owned[2], 5);
        assertEq(owned[3], 4);
    }




    ////////////////keyboardOZ mint tests///////////////////////////

    function testMint() public {
        uint[] memory colors = getColors();
        uint price = keyboardOZ.price() * colors.length;

        keyboardOZ.mint{value:price}(colors);

        assertEq(address(keyboardOZ).balance, price);
        assertEq(keyboardOZ.balanceOf(address(this)), 5);
        assertEq(keyboardOZ.ownerOf(1), address(this));

        // wrong price mint
        vm.expectRevert(IncorrectMsgValue.selector);
        keyboardOZ.mint{value:.02 ether}(colors);

        vm.expectRevert(IncorrectMsgValue.selector);
        keyboardOZ.mint{value:.06 ether}(colors);


        // testing too many colors
        uint[] memory tooManyColors = new uint[](6);
        tooManyColors[0] = 1;
        tooManyColors[1] = 2;
        tooManyColors[2] = 3;
        tooManyColors[3] = 4;
        tooManyColors[4] = 5;
        tooManyColors[5] = 5;

        vm.expectRevert(TooManyMints.selector);
        keyboardOZ.mint{value:.3 ether}(tooManyColors);


        // testing invalid color mint
        colors[4] = 6;
        vm.expectRevert(InvalidColor.selector);
        keyboardOZ.mint{value:price}(colors);

    }

    function testFailSendEther() public {
        // reverts if ether is sent to contract 
        payable(address(keyboardOZ)).transfer(1 ether);
    }

    function testWithdraw() public {
        uint[] memory colors = getColors();
        uint price = keyboardOZ.price() * colors.length;
        keyboardOZ.mint{value:price}(colors);
        assertEq(address(keyboardOZ).balance, price);

        // set this address balance to zero
        hoax(address(this), 0 ether);
        keyboardOZ.withdrawFunds();

        // check is ether is transferred correctly
        assertEq(address(keyboardOZ).balance, 0);
        assertEq(address(this).balance, price);



    }

    ////////////keyboardOZ owner functions/////////////////

    function testOwnerSetters() public {
        string memory testString = "this is a test string";
        uint testPrice = .2 ether;


        // set default sound hash
        keyboardOZ.setEPianoHash(testString);
        assertEq(keyboardOZ.ePianoHash(),testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboardOZ.setEPianoHash(testString);



        // set price
        keyboardOZ.setPrice(testPrice);
        assertEq(keyboardOZ.price(), testPrice);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboardOZ.setPrice(testPrice);



        // set frontend
        keyboardOZ.setFrontend(testString);
        assertEq(keyboardOZ.frontEnd(), testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboardOZ.setFrontend(testString);



        // set default gateway
        keyboardOZ.setDefaultGateway(testString);
        assertEq(keyboardOZ.defaultGateway(), testString);
        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        keyboardOZ.setDefaultGateway(testString);



        // set sounds
        keyboardOZ.setSounds(address(sounds));
        assertEq(keyboardOZ.sounds(), address(sounds));
        // test double set sounds
        vm.expectRevert(SoundsAlreadySet.selector);
        keyboardOZ.setSounds(address(0xBEEF));
        // non owner
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');        
        keyboardOZ.setSounds(address(sounds));

    }


}
