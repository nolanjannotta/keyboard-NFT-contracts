// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.7;

// import "forge-std/Test.sol";
// import "forge-std/console.sol";

// import "./TestSetUp.sol";





// contract ERC721Test is Test, TestSetUp {
    

//     function invariantMetadata() public {
//         assertEq(keyboardA.name(), "Keyboards");
//         assertEq(keyboardA.symbol(), "KEYS");
//         assertEq(keyboardA.price(), .05 ether);
//         assertEq(keyboardA.maxSupply(), 10_000);
//         assertEq(keyboardA.defaultGateway(), "https://arweave.net/");

//     }

//     function getColors() internal pure returns(uint[] memory) {
//         uint[] memory colors = new uint[](5);
//         colors[0] = 1;
//         colors[1] = 2;
//         colors[2] = 3;
//         colors[3] = 4;
//         colors[4] = 5;
//         return colors;
//     }



//     function testOwner() public {
//         assertEq(keyboardA.owner(), address(this));
//     }

//     function testSetUserGateway() public {

//         string memory gateway = "new gateway";
//         // should fail if no tokens are owned by msg.sender
//         vm.expectRevert(NotTokenOwner.selector);
//         keyboardA.setGateway(gateway);
//         // minting
//         uint[] memory colors = getColors();
//         uint price = keyboardA.price() * colors.length;

//         keyboardA.mint{value: price}(colors);
//         // setting gateway
//         keyboardA.setGateway(gateway);
//         assertEq(keyboardA.getGateway(address(this)), gateway);

//         keyboardA.setGateway("default");
//         assertEq(keyboardA.getGateway(address(this)), keyboardA.defaultGateway());
//     }

//     function testGetUserSoundBalances() public {
//         // first mint some sounds
//         uint[] memory ids = new uint[](2);
//         ids[0] = 1; ids[1] = 2;


//         uint[] memory amounts = new uint[](2);
//         amounts[0] = 2; amounts[1] = 2;

//         uint total;
//         for(uint i=0; i<ids.length; i++) {
//             total += (sounds.getSoundData(ids[i]).price * amounts[i]);
//         }        
//         sounds.mintBatch {value: total}(ids, amounts);
//         keyboardA.setSounds(address(sounds));
//         uint[] memory installed = keyboardA.getUserSoundBalances(address(this));

//         assertEq(installed[0], 2);
//         assertEq(installed[1], 2);
//         assertEq(installed[2], 0);


//     }

//     function testkeyboardAInstallations() public {
//         // setup

//         // creating another sound
//         sounds.createSound(
//             "arweave hash",
//             true,
//             true,
//             "sound type",
//             "name",
//             5,
//             10000,
//             1000000000000000
//         );
//         assertEq(sounds.totalSounds(), 4);

//         uint[] memory ids = new uint[](3); // [1,2,3]
//         uint[] memory amounts = new uint[](3); // [2,2,2]
//         ids[0] = 1;
//         ids[1] = 2;
//         ids[2] = 3;
//         amounts[0] = 2;
//         amounts[1] = 2;
//         amounts[2] = 2;

//         uint cost;
//         for(uint i=0; i<ids.length; i++) {
//             cost += sounds.getSoundData(ids[i]).price * amounts[i];
//         }

//         sounds.mintBatch{value: cost}(ids, amounts);
//         assertEq(sounds.balanceOf(address(this),1), 2);
//         assertEq(sounds.balanceOf(address(this),2), 2);
//         assertEq(sounds.balanceOf(address(this),3), 2);
//         assertEq(sounds.balanceOf(address(this),4), 0);



//         uint[] memory mintArg = new uint[](2); // [1,2]
//         mintArg[0] = 1;
//         mintArg[1] = 2;
        
//         // minting two keyboardAs
//         keyboardA.mint{value: keyboardA.price() * 2}(mintArg);
//         assertEq(keyboardA.ownerOf(1), address(this));
//         // assertEq(keyboardA.ownerOf(2), address(this));
//         assertEq(keyboardA.balanceOf(address(this)), 2);



//         // set sounds address in keyboardA contract
//         keyboardA.setSounds(address(sounds));

//         // approve
//         sounds.setApprovalForAll(address(keyboardA), true);
//         // console.log(sounds.isApprovedForAll(address(this), address(keyboardA)));

//         // installing

//         keyboardA.install(1,1);
//         keyboardA.install(1,2);
//         keyboardA.install(1,3);


//         // make sure tokens are transferred
//         assertEq(sounds.balanceOf(address(this),1), 1);
//         assertEq(sounds.balanceOf(address(this),2), 1);
//         assertEq(sounds.balanceOf(address(this),3), 1);

//         assertEq(sounds.balanceOf(address(keyboardA),1), 1);
//         assertEq(sounds.balanceOf(address(keyboardA),2), 1);
//         assertEq(sounds.balanceOf(address(keyboardA),3), 1);

//         uint[] memory installed = new uint[](3);
//         installed[0] = 1;
//         installed[1] = 2;
//         installed[2] = 3;
//         assertEq(keyboardA.getInstalledSounds(1), installed);

//         // double install
//         vm.expectRevert(AlreadyInstalled.selector);
//         keyboardA.install(1,1);
//         vm.expectRevert(AlreadyInstalled.selector);
//         keyboardA.install(1,2);

//         // insufficient sound token balance;
//         vm.expectRevert("ERC1155: insufficient balance for transfer");
//         keyboardA.install(1,4);

//         // testing installing sound in non owned keyboardA
//         vm.expectRevert(OnlyTokenOwner.selector);
//         vm.prank(address(0xBEEF));
//         keyboardA.install(2,1);



//         // testing uninstalling
//         keyboardA.unInstall(1,2);
//         uint[] memory unInstalled = new uint[](2);
        
//         unInstalled[0] = 1;
//         unInstalled[1] = 3;


//         assertEq(sounds.balanceOf(address(this),2), 2);
//         assertEq(sounds.balanceOf(address(keyboardA),2), 0);

//         assertEq(keyboardA.getInstalledSounds(1), unInstalled);

//         // testing double uninstall
//         vm.expectRevert(NotInstalled.selector);
//         keyboardA.unInstall(1,2);


        
//     }
 

//     function testTokenIdsByOwner() public {
//         uint[] memory colors = getColors();
//         uint price = keyboardA.price() * colors.length;
//         keyboardA.mint{value:price}(colors);


//         hoax(address(0xABCBEEF), 1 ether);
//         keyboardA.mint{value:price}(colors);


//         uint[] memory owned = keyboardA.tokensOfOwner(address(this));
//         assertEq(owned[0], 1);
//         assertEq(owned[1], 2);
//         assertEq(owned[2], 3);
//         assertEq(owned[3], 4);
//         assertEq(owned[4], 5);

//         owned = keyboardA.tokensOfOwner(address(0xABCBEEF));
//         assertEq(owned[0], 6);
//         assertEq(owned[1], 7);
//         assertEq(owned[2], 8);
//         assertEq(owned[3], 9);
//         assertEq(owned[4], 10);


//         keyboardA.safeTransferFrom(address(this), address(0xBEEF), 3);
//         assertEq(keyboardA.tokensOfOwner(address(0xBEEF))[0], 3);

//         owned = keyboardA.tokensOfOwner(address(this));
//         assertEq(owned[0], 1);
//         assertEq(owned[1], 2);
//         assertEq(owned[2], 4);
//         assertEq(owned[3], 5);
//     }




//     ////////////////keyboardA mint tests///////////////////////////

//     function testMint() public {
//         uint[] memory colors = getColors();
//         uint price = keyboardA.price() * colors.length;

//         keyboardA.mint{value:price}(colors);

//         assertEq(address(keyboardA).balance, price);
//         assertEq(keyboardA.balanceOf(address(this)), 5);
//         assertEq(keyboardA.ownerOf(1), address(this));

//         // wrong price mint
//         vm.expectRevert(IncorrectMsgValue.selector);
//         keyboardA.mint{value:.02 ether}(colors);

//         vm.expectRevert(IncorrectMsgValue.selector);
//         keyboardA.mint{value:.06 ether}(colors);


//         // testing too many colors
//         uint[] memory tooManyColors = new uint[](6);
//         tooManyColors[0] = 1;
//         tooManyColors[1] = 2;
//         tooManyColors[2] = 3;
//         tooManyColors[3] = 4;
//         tooManyColors[4] = 5;
//         tooManyColors[5] = 5;

//         vm.expectRevert(TooManyMints.selector);
//         keyboardA.mint{value:.3 ether}(tooManyColors);


//         // testing invalid color mint
//         colors[4] = 6;
//         vm.expectRevert(InvalidColor.selector);
//         keyboardA.mint{value:price}(colors);

//     }

//     function testFailSendEther() public {
//         // reverts if ether is sent to contract 
//         payable(address(keyboardA)).transfer(1 ether);
//     }

//     function testWithdraw() public {
//         uint[] memory colors = getColors();
//         uint price = keyboardA.price() * colors.length;
//         keyboardA.mint{value:price}(colors);
//         assertEq(address(keyboardA).balance, price);

//         // set this address balance to zero
//         hoax(address(this), 0 ether);
//         keyboardA.withdrawFunds();

//         // check is ether is transferred correctly
//         assertEq(address(keyboardA).balance, 0);
//         assertEq(address(this).balance, price);



//     }

//     ////////////keyboardA owner functions/////////////////

//     function testOwnerSetters() public {
//         string memory testString = "this is a test string";
//         uint testPrice = .2 ether;


//         // set default sound hash
//         keyboardA.setEPianoHash(testString);
//         assertEq(keyboardA.ePianoHash(),testString);
//         // non owner
//         vm.expectRevert('Ownable: caller is not the owner');
//         vm.prank(address(0xABCDBEEF));
//         keyboardA.setEPianoHash(testString);



//         // set price
//         keyboardA.setPrice(testPrice);
//         assertEq(keyboardA.price(), testPrice);
//         // non owner
//         vm.expectRevert('Ownable: caller is not the owner');
//         vm.prank(address(0xABCDBEEF));
//         keyboardA.setPrice(testPrice);



//         // set frontend
//         keyboardA.setFrontend(testString);
//         assertEq(keyboardA.frontEnd(), testString);
//         // non owner
//         vm.expectRevert('Ownable: caller is not the owner');
//         vm.prank(address(0xABCDBEEF));
//         keyboardA.setFrontend(testString);



//         // set default gateway
//         keyboardA.setDefaultGateway(testString);
//         assertEq(keyboardA.defaultGateway(), testString);
//         // non owner
//         vm.expectRevert('Ownable: caller is not the owner');
//         vm.prank(address(0xABCDBEEF));
//         keyboardA.setDefaultGateway(testString);



//         // set sounds
//         keyboardA.setSounds(address(sounds));
//         assertEq(keyboardA.sounds(), address(sounds));
//         // test double set sounds
//         vm.expectRevert(SoundsAlreadySet.selector);
//         keyboardA.setSounds(address(0xBEEF));
//         // non owner
//         vm.prank(address(0xABCDBEEF));
//         vm.expectRevert('Ownable: caller is not the owner');        
//         keyboardA.setSounds(address(sounds));

//     }


// }
