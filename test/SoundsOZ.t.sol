// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
import "forge-std/console.sol";


import "./TestSetUp.sol";


contract ERC721Test is Test, TestSetUp {


    function invariantMetadata() public {
        assertEq(sounds.name(), "Sounds");
        assertEq(sounds.symbol(), "SNDS");
        assertEq(sounds.frontEnd(), "front end goes here.");

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

        sounds.setFrontEnd("new frontend");
        assertEq(sounds.frontEnd(), "new frontend");

        // non owner
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xBEEF));
        sounds.setFrontEnd("new frontend");


    }

    function testOwnerCreateSound() public {
        keyboardOZ.setSounds(address(sounds));
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
        string[] memory installedNames = keyboardOZ.getSoundNames();
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
        assertEq(sounds.getSoundData(1).arweaveHash, "pvB8EG3mjVWf0cdarTtJOv37s-24L_9oREPCatbCEzU");
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

        vm.expectRevert(NonExistentSound.selector);
        sounds.mint{value: .01 ether}(0);

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

        // test mint with too many. max number of mints is 20.
        amounts[2] = 21;
        ids[2] = 3;

        total = 0;
        for(uint i=0; i<ids.length; i++) {
            total += (sounds.getSoundData(ids[i]).price * amounts[i]);
        }
        vm.expectRevert(TooManyMints.selector);
        sounds.mintBatch {value: total}(ids, amounts);

    }

    function testWithdraw() public {
        uint[] memory ids = new uint[](3);
        ids[0] = 1; ids[1] = 2; ids[2] = 3;


        uint[] memory amounts = new uint[](3);
        amounts[0] = 2; amounts[1] = 2; amounts[2] = 2;

        uint total;
        for(uint i=0; i<ids.length; i++) {
            total += (sounds.getSoundData(ids[i]).price * amounts[i]);
        }   

        sounds.mintBatch {value: total}(ids, amounts);

        assertEq(address(sounds).balance, total);

        // set this address balance to zero
        hoax(address(this), 0 ether);
        sounds.withdrawFunds();

        // check is ether is transferred correctly
        assertEq(address(keyboardOZ).balance, 0);
        assertEq(address(this).balance, total);



    }
    function testWithdrawERC20() public {
        assertEq(erc20Mock.balanceOf(address(this)), 1000 ether);
        erc20Mock.transfer(address(keyboardOZ), 500 ether);

        assertEq(erc20Mock.balanceOf(address(this)), 500 ether);
        assertEq(erc20Mock.balanceOf(address(keyboardOZ)), 500 ether);

        keyboardOZ.withdrawERC20(address(erc20Mock));

        assertEq(erc20Mock.balanceOf(address(this)), 1000 ether);
        assertEq(erc20Mock.balanceOf(address(keyboardOZ)), 0);


    }


}
