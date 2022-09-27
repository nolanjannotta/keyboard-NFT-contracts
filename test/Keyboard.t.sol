// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "forge-std/Test.sol";
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


contract ERC721Test is Test {
    Keyboard token;
    Sounds sounds;
    // uint[] tooManyColors = [1,2,3,4,5,5];
    // uint[] invalidColors = [1,2,3,4,6];

    uint[] soundMintBatchIds = [1,2,3];
    uint[] soundMintBatchAmounts = [2,3,4];

    uint[] soundMintBatchIdsInvalid = [1,2,4];
    uint[] soundMintBatchAmountsTooMany = [1,1,2,2,3,3];

    function setUp() public {
        token = new Keyboard();
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
        assertEq(token.name(), "Keyboards");
        assertEq(token.symbol(), "KEYS");
        assertEq(token.price(), .1 ether);
    }

    function getColors() internal pure returns(uint[] memory) {
        uint[] memory colors = new uint[](3);
        colors[0] = 1;
        colors[1] = 2;
        colors[2] = 3;
        return colors;
    }


    ////////////////keyboard mint tests///////////////////////////

    function testMint() public {

        uint[] memory colors = getColors();
        token.mint{value:.3 ether}(colors);

        assertEq(token.balanceOf(address(this)), 3);
        assertEq(token.ownerOf(1), address(this));
    }

    

    function testTooManyMints() public {
        uint[] memory tooManyColors = new uint[](6);
        tooManyColors[0] = 1;
        tooManyColors[1] = 1;
        tooManyColors[2] = 1;
        tooManyColors[3] = 1;
        tooManyColors[4] = 1;
        tooManyColors[5] = 1;

        uint price = token.price() * tooManyColors.length;

        vm.expectRevert(TooManyMints.selector);
        token.mint{value:price}(tooManyColors);

    }

    function testUnderPriceMint() public {
        uint[] memory colors = getColors();


        uint total = token.price() * colors.length;
        vm.expectRevert(IncorrectMsgValue.selector);

        token.mint{value:total-1234}(colors);
    }

    function testHigherPriceMint() public {
        uint[] memory colors = getColors();


        uint total = token.price() * colors.length;
        vm.expectRevert(IncorrectMsgValue.selector);

        token.mint{value:total+1234}(colors);
    }

    function testInvalidColorMint() public {
        uint[] memory invalidColors = new uint[](5);
        invalidColors[0] = 1;
        invalidColors[1] = 2;
        invalidColors[2] = 3;
        invalidColors[3] = 4;
        invalidColors[4] = 6;


        uint total = token.price() * invalidColors.length;
        vm.expectRevert(InvalidColor.selector);

        token.mint{value:total}(invalidColors);
    }

    // function testFailExceedMaxMint() public {

    // }

    function testSetSounds() public {
        token.setSounds(address(sounds));
        assertEq(token.sounds(), address(sounds));
    }

    function testDoubleSetSounds() public {
        token.setSounds(address(sounds));
        vm.expectRevert(SoundsAlreadySet.selector);
        token.setSounds(address(0xBEEF));
    }

    function testNonOwnerSetSounds() public {
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');        
        token.setSounds(address(sounds));
    }



    function testOwnerSetters() public {

        string memory testString = "this is a test string";
        token.setEPianoHash(testString);
        assertEq(token.ePianoHash(),testString);

        uint price = .2 ether;
        token.setPrice(price);
        assertEq(token.price(), price);

        token.setFrontend(testString);
        assertEq(token.frontEnd(), testString);

        token.setDefaultGateway(testString);
        assertEq(token.defaultGateway(), testString);
    }

    function testOwnerSettersFail() public {
        string memory testString = "this is a test string";

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        token.setEPianoHash(testString);

        uint price = .2 ether;
        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        token.setPrice(price);

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        token.setFrontend(testString);

        vm.expectRevert('Ownable: caller is not the owner');
        vm.prank(address(0xABCDBEEF));
        token.setDefaultGateway(testString);
    }

    function testNonOwnerSetEpiano() public {

        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');
        token.setEPianoHash("this is a string");
    }

    function testNonOwnerSetPrice() public {
        vm.prank(address(0xABCDBEEF));

        vm.expectRevert('Ownable: caller is not the owner');
        token.setPrice(1e18);
    }

    function testNonOwnerSetFrontend() public {
        vm.prank(address(0xABCDBEEF));

        vm.expectRevert('Ownable: caller is not the owner');
        token.setFrontend("this is the frontend");
    }

    function testNonOwnerSetGateway() public {
        vm.prank(address(0xABCDBEEF));
        vm.expectRevert('Ownable: caller is not the owner');
        token.setDefaultGateway("this is the default gateway");

    }







    //////////////////////////Sounds////////////////////////////////

    function testSoundOwnerFunctions() public {
        sounds.updateUri("new uri",1);
        assertEq(sounds.getSoundData(1).arweaveHash, "new uri");
    }
    function testOwnerSetPrice() public {
        sounds.setPrice(1,1000000000000000);
        assertEq(sounds.getSoundData(1).price, 1000000000000000);
    }
    function testOwnerSetFrontend() public {
        sounds.setFrontend("new frontend");
        assertEq(sounds.frontEnd(), "new frontend");
    }
    function testOwnerCreateSound() public {
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
    }
    function testMaxAmount() public {
        assertEq(sounds.getSoundData(1).maxAmount, 10000);
        assertEq(sounds.getSoundData(2).maxAmount, 10000);
        assertEq(sounds.getSoundData(3).maxAmount, 10000);

    }

    function testSoundMint()public {
        uint total = sounds.getSoundData(1).price;
        sounds.mint{value: total}(1);
        assertEq(sounds.balanceOf(address(this), 1),1);
        assertEq(sounds.totalSupply(1), 1);
        
    }
    function testTotalSounds() public {
        uint total = sounds.totalSounds();
        assertEq(total, 3);
    }

    function testSoundBatchMint() public {
        uint total;
        for(uint i=0; i<soundMintBatchIds.length; i++) {
            total += (sounds.getSoundData(soundMintBatchIds[i]).price * soundMintBatchAmounts[i]);
        }
        
        sounds.mintBatch {value: total}(soundMintBatchIds, soundMintBatchAmounts);
    }


    function testInvalidSoundMint() public {
        vm.expectRevert(NonExistentSound.selector);
        sounds.mint{value: .01 ether}(6);
        // assertEq(sounds.balanceOf(address(this),6), 1);
    }

    // function testFailSoundBatchMint() public {


    // }




    // function testBurn() public {
    //     token.mint(address(0xBEEF), 1337);
    //     token.burn(1337);

    //     assertEq(token.balanceOf(address(0xBEEF)), 0);

    //     hevm.expectRevert("NOT_MINTED");
    //     token.ownerOf(1337);
    // }

    // function testApprove() public {
    //     token.mint(address(this), 1337);

    //     token.approve(address(0xBEEF), 1337);

    //     assertEq(token.getApproved(1337), address(0xBEEF));
    // }

    // function testApproveBurn() public {
    //     token.mint(address(this), 1337);

    //     token.approve(address(0xBEEF), 1337);

    //     token.burn(1337);

    //     assertEq(token.balanceOf(address(this)), 0);
    //     assertEq(token.getApproved(1337), address(0));

    //     hevm.expectRevert("NOT_MINTED");
    //     token.ownerOf(1337);
    // }

    // function testApproveAll() public {
    //     token.setApprovalForAll(address(0xBEEF), true);

    //     assertTrue(token.isApprovedForAll(address(this), address(0xBEEF)));
    // }

    // function testTransferFrom() public {
    //     address from = address(0xABCD);

    //     token.mint(from, 1337);

    //     hevm.prank(from);
    //     token.approve(address(this), 1337);

    //     token.transferFrom(from, address(0xBEEF), 1337);

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(0xBEEF));
    //     assertEq(token.balanceOf(address(0xBEEF)), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testTransferFromSelf() public {
    //     token.mint(address(this), 1337);

    //     token.transferFrom(address(this), address(0xBEEF), 1337);

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(0xBEEF));
    //     assertEq(token.balanceOf(address(0xBEEF)), 1);
    //     assertEq(token.balanceOf(address(this)), 0);
    // }

    // function testTransferFromApproveAll() public {
    //     address from = address(0xABCD);

    //     token.mint(from, 1337);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.transferFrom(from, address(0xBEEF), 1337);

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(0xBEEF));
    //     assertEq(token.balanceOf(address(0xBEEF)), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testSafeTransferFromToEOA() public {
    //     address from = address(0xABCD);

    //     token.mint(from, 1337);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, address(0xBEEF), 1337);

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(0xBEEF));
    //     assertEq(token.balanceOf(address(0xBEEF)), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testSafeTransferFromToERC721Recipient() public {
    //     address from = address(0xABCD);
    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.mint(from, 1337);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, address(recipient), 1337);

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);
    //     assertEq(token.balanceOf(from), 0);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), from);
    //     assertEq(recipient.id(), 1337);
    //     assertBytesEq(recipient.data(), "");
    // }

    // function testSafeTransferFromToERC721RecipientWithData() public {
    //     address from = address(0xABCD);
    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.mint(from, 1337);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, address(recipient), 1337, "testing 123");

    //     assertEq(token.getApproved(1337), address(0));
    //     assertEq(token.ownerOf(1337), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);
    //     assertEq(token.balanceOf(from), 0);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), from);
    //     assertEq(recipient.id(), 1337);
    //     assertBytesEq(recipient.data(), "testing 123");
    // }

    // function testSafeMintToEOA() public {
    //     token.safeMint(address(0xBEEF), 1337);

    //     assertEq(token.ownerOf(1337), address(address(0xBEEF)));
    //     assertEq(token.balanceOf(address(address(0xBEEF))), 1);
    // }

    // function testSafeMintToERC721Recipient() public {
    //     ERC721Recipient to = new ERC721Recipient();

    //     token.safeMint(address(to), 1337);

    //     assertEq(token.ownerOf(1337), address(to));
    //     assertEq(token.balanceOf(address(to)), 1);

    //     assertEq(to.operator(), address(this));
    //     assertEq(to.from(), address(0));
    //     assertEq(to.id(), 1337);
    //     assertBytesEq(to.data(), "");
    // }

    // function testSafeMintToERC721RecipientWithData() public {
    //     ERC721Recipient to = new ERC721Recipient();

    //     token.safeMint(address(to), 1337, "testing 123");

    //     assertEq(token.ownerOf(1337), address(to));
    //     assertEq(token.balanceOf(address(to)), 1);

    //     assertEq(to.operator(), address(this));
    //     assertEq(to.from(), address(0));
    //     assertEq(to.id(), 1337);
    //     assertBytesEq(to.data(), "testing 123");
    // }

    // function testFailMintToZero() public {
    //     token.mint(address(0), 1337);
    // }

    // function testFailDoubleMint() public {
    //     token.mint(address(0xBEEF), 1337);
    //     token.mint(address(0xBEEF), 1337);
    // }

    // function testFailBurnUnMinted() public {
    //     token.burn(1337);
    // }

    // function testFailDoubleBurn() public {
    //     token.mint(address(0xBEEF), 1337);

    //     token.burn(1337);
    //     token.burn(1337);
    // }

    // function testFailApproveUnMinted() public {
    //     token.approve(address(0xBEEF), 1337);
    // }

    // function testFailApproveUnAuthorized() public {
    //     token.mint(address(0xCAFE), 1337);

    //     token.approve(address(0xBEEF), 1337);
    // }

    // function testFailTransferFromUnOwned() public {
    //     token.transferFrom(address(0xFEED), address(0xBEEF), 1337);
    // }

    // function testFailTransferFromWrongFrom() public {
    //     token.mint(address(0xCAFE), 1337);

    //     token.transferFrom(address(0xFEED), address(0xBEEF), 1337);
    // }

    // function testFailTransferFromToZero() public {
    //     token.mint(address(this), 1337);

    //     token.transferFrom(address(this), address(0), 1337);
    // }

    // function testFailTransferFromNotOwner() public {
    //     token.mint(address(0xFEED), 1337);

    //     token.transferFrom(address(0xFEED), address(0xBEEF), 1337);
    // }

    // function testFailSafeTransferFromToNonERC721Recipient() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new NonERC721Recipient()), 1337);
    // }

    // function testFailSafeTransferFromToNonERC721RecipientWithData() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new NonERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailSafeTransferFromToRevertingERC721Recipient() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), 1337);
    // }

    // function testFailSafeTransferFromToRevertingERC721RecipientWithData() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailSafeTransferFromToERC721RecipientWithWrongReturnData() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new WrongReturnDataERC721Recipient()), 1337);
    // }

    // function testFailSafeTransferFromToERC721RecipientWithWrongReturnDataWithData() public {
    //     token.mint(address(this), 1337);

    //     token.safeTransferFrom(address(this), address(new WrongReturnDataERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailSafeMintToNonERC721Recipient() public {
    //     token.safeMint(address(new NonERC721Recipient()), 1337);
    // }

    // function testFailSafeMintToNonERC721RecipientWithData() public {
    //     token.safeMint(address(new NonERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailSafeMintToRevertingERC721Recipient() public {
    //     token.safeMint(address(new RevertingERC721Recipient()), 1337);
    // }

    // function testFailSafeMintToRevertingERC721RecipientWithData() public {
    //     token.safeMint(address(new RevertingERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailSafeMintToERC721RecipientWithWrongReturnData() public {
    //     token.safeMint(address(new WrongReturnDataERC721Recipient()), 1337);
    // }

    // function testFailSafeMintToERC721RecipientWithWrongReturnDataWithData() public {
    //     token.safeMint(address(new WrongReturnDataERC721Recipient()), 1337, "testing 123");
    // }

    // function testFailBalanceOfZeroAddress() public view {
    //     token.balanceOf(address(0));
    // }

    // function testFailOwnerOfUnminted() public view {
    //     token.ownerOf(1337);
    // }

    // function testMetadata(string memory name, string memory symbol) public {
    //     MockERC721 tkn = new MockERC721(name, symbol);

    //     assertEq(tkn.name(), name);
    //     assertEq(tkn.symbol(), symbol);
    // }

    // function testMint(address to, uint256 id) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     token.mint(to, id);

    //     assertEq(token.balanceOf(to), 1);
    //     assertEq(token.ownerOf(id), to);
    // }

    // function testBurn(address to, uint256 id) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     token.mint(to, id);
    //     token.burn(id);

    //     assertEq(token.balanceOf(to), 0);

    //     hevm.expectRevert("NOT_MINTED");
    //     token.ownerOf(id);
    // }

    // function testApprove(address to, uint256 id) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     token.mint(address(this), id);

    //     token.approve(to, id);

    //     assertEq(token.getApproved(id), to);
    // }

    // function testApproveBurn(address to, uint256 id) public {
    //     token.mint(address(this), id);

    //     token.approve(address(to), id);

    //     token.burn(id);

    //     assertEq(token.balanceOf(address(this)), 0);
    //     assertEq(token.getApproved(id), address(0));

    //     hevm.expectRevert("NOT_MINTED");
    //     token.ownerOf(id);
    // }

    // function testApproveAll(address to, bool approved) public {
    //     token.setApprovalForAll(to, approved);

    //     assertBoolEq(token.isApprovedForAll(address(this), to), approved);
    // }

    // function testTransferFrom(uint256 id, address to) public {
    //     address from = address(0xABCD);

    //     if (to == address(0) || to == from) to = address(0xBEEF);

    //     token.mint(from, id);

    //     hevm.prank(from);
    //     token.approve(address(this), id);

    //     token.transferFrom(from, to, id);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), to);
    //     assertEq(token.balanceOf(to), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testTransferFromSelf(uint256 id, address to) public {
    //     if (to == address(0) || to == address(this)) to = address(0xBEEF);

    //     token.mint(address(this), id);

    //     token.transferFrom(address(this), to, id);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), to);
    //     assertEq(token.balanceOf(to), 1);
    //     assertEq(token.balanceOf(address(this)), 0);
    // }

    // function testTransferFromApproveAll(uint256 id, address to) public {
    //     address from = address(0xABCD);

    //     if (to == address(0) || to == from) to = address(0xBEEF);

    //     token.mint(from, id);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.transferFrom(from, to, id);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), to);
    //     assertEq(token.balanceOf(to), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testSafeTransferFromToEOA(uint256 id, address to) public {
    //     address from = address(0xABCD);

    //     if (to == address(0) || to == from) to = address(0xBEEF);

    //     if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

    //     token.mint(from, id);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, to, id);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), to);
    //     assertEq(token.balanceOf(to), 1);
    //     assertEq(token.balanceOf(from), 0);
    // }

    // function testSafeTransferFromToERC721Recipient(uint256 id) public {
    //     address from = address(0xABCD);

    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.mint(from, id);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, address(recipient), id);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);
    //     assertEq(token.balanceOf(from), 0);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), from);
    //     assertEq(recipient.id(), id);
    //     assertBytesEq(recipient.data(), "");
    // }

    // function testSafeTransferFromToERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     address from = address(0xABCD);
    //     ERC721Recipient recipient = new ERC721Recipient();

    //     token.mint(from, id);

    //     hevm.prank(from);
    //     token.setApprovalForAll(address(this), true);

    //     token.safeTransferFrom(from, address(recipient), id, data);

    //     assertEq(token.getApproved(id), address(0));
    //     assertEq(token.ownerOf(id), address(recipient));
    //     assertEq(token.balanceOf(address(recipient)), 1);
    //     assertEq(token.balanceOf(from), 0);

    //     assertEq(recipient.operator(), address(this));
    //     assertEq(recipient.from(), from);
    //     assertEq(recipient.id(), id);
    //     assertBytesEq(recipient.data(), data);
    // }

    // function testSafeMintToEOA(uint256 id, address to) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     if (uint256(uint160(to)) <= 18 || to.code.length > 0) return;

    //     token.safeMint(to, id);

    //     assertEq(token.ownerOf(id), address(to));
    //     assertEq(token.balanceOf(address(to)), 1);
    // }

    // function testSafeMintToERC721Recipient(uint256 id) public {
    //     ERC721Recipient to = new ERC721Recipient();

    //     token.safeMint(address(to), id);

    //     assertEq(token.ownerOf(id), address(to));
    //     assertEq(token.balanceOf(address(to)), 1);

    //     assertEq(to.operator(), address(this));
    //     assertEq(to.from(), address(0));
    //     assertEq(to.id(), id);
    //     assertBytesEq(to.data(), "");
    // }

    // function testSafeMintToERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     ERC721Recipient to = new ERC721Recipient();

    //     token.safeMint(address(to), id, data);

    //     assertEq(token.ownerOf(id), address(to));
    //     assertEq(token.balanceOf(address(to)), 1);

    //     assertEq(to.operator(), address(this));
    //     assertEq(to.from(), address(0));
    //     assertEq(to.id(), id);
    //     assertBytesEq(to.data(), data);
    // }

    // function testFailMintToZero(uint256 id) public {
    //     token.mint(address(0), id);
    // }

    // function testFailDoubleMint(uint256 id, address to) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     token.mint(to, id);
    //     token.mint(to, id);
    // }

    // function testFailBurnUnMinted(uint256 id) public {
    //     token.burn(id);
    // }

    // function testFailDoubleBurn(uint256 id, address to) public {
    //     if (to == address(0)) to = address(0xBEEF);

    //     token.mint(to, id);

    //     token.burn(id);
    //     token.burn(id);
    // }

    // function testFailApproveUnMinted(uint256 id, address to) public {
    //     token.approve(to, id);
    // }

    // function testFailApproveUnAuthorized(
    //     address owner,
    //     uint256 id,
    //     address to
    // ) public {
    //     if (owner == address(0) || owner == address(this)) owner = address(0xBEEF);

    //     token.mint(owner, id);

    //     token.approve(to, id);
    // }

    // function testFailTransferFromUnOwned(
    //     address from,
    //     address to,
    //     uint256 id
    // ) public {
    //     token.transferFrom(from, to, id);
    // }

    // function testFailTransferFromWrongFrom(
    //     address owner,
    //     address from,
    //     address to,
    //     uint256 id
    // ) public {
    //     if (owner == address(0)) to = address(0xBEEF);
    //     if (from == owner) revert();

    //     token.mint(owner, id);

    //     token.transferFrom(from, to, id);
    // }

    // function testFailTransferFromToZero(uint256 id) public {
    //     token.mint(address(this), id);

    //     token.transferFrom(address(this), address(0), id);
    // }

    // function testFailTransferFromNotOwner(
    //     address from,
    //     address to,
    //     uint256 id
    // ) public {
    //     if (from == address(this)) from = address(0xBEEF);

    //     token.mint(from, id);

    //     token.transferFrom(from, to, id);
    // }

    // function testFailSafeTransferFromToNonERC721Recipient(uint256 id) public {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new NonERC721Recipient()), id);
    // }

    // function testFailSafeTransferFromToNonERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new NonERC721Recipient()), id, data);
    // }

    // function testFailSafeTransferFromToRevertingERC721Recipient(uint256 id) public {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), id);
    // }

    // function testFailSafeTransferFromToRevertingERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new RevertingERC721Recipient()), id, data);
    // }

    // function testFailSafeTransferFromToERC721RecipientWithWrongReturnData(uint256 id) public {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new WrongReturnDataERC721Recipient()), id);
    // }

    // function testFailSafeTransferFromToERC721RecipientWithWrongReturnDataWithData(uint256 id, bytes calldata data)
    //     public
    // {
    //     token.mint(address(this), id);

    //     token.safeTransferFrom(address(this), address(new WrongReturnDataERC721Recipient()), id, data);
    // }

    // function testFailSafeMintToNonERC721Recipient(uint256 id) public {
    //     token.safeMint(address(new NonERC721Recipient()), id);
    // }

    // function testFailSafeMintToNonERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     token.safeMint(address(new NonERC721Recipient()), id, data);
    // }

    // function testFailSafeMintToRevertingERC721Recipient(uint256 id) public {
    //     token.safeMint(address(new RevertingERC721Recipient()), id);
    // }

    // function testFailSafeMintToRevertingERC721RecipientWithData(uint256 id, bytes calldata data) public {
    //     token.safeMint(address(new RevertingERC721Recipient()), id, data);
    // }

    // function testFailSafeMintToERC721RecipientWithWrongReturnData(uint256 id) public {
    //     token.safeMint(address(new WrongReturnDataERC721Recipient()), id);
    // }

    // function testFailSafeMintToERC721RecipientWithWrongReturnDataWithData(uint256 id, bytes calldata data) public {
    //     token.safeMint(address(new WrongReturnDataERC721Recipient()), id, data);
    // }

    // function testFailOwnerOfUnminted(uint256 id) public view {
    //     token.ownerOf(id);
    // }
}
