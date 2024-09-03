// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    address public funder;
    address public beneficiary;

    function setUp() public {
        funder = address(1);
        beneficiary = address(2);
        vm.prank(funder);
        escrow = new Escrow();
    }

    function testFund() public {
        vm.prank(funder);
        vm.deal(funder, 1 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        assertEq(escrow.funder(), funder);
        assertEq(escrow.beneficiary(), beneficiary);
        assertEq(escrow.amount(), 1 ether);
        assertTrue(escrow.isFunded());
        assertFalse(escrow.isReleased());
        assertEq(address(escrow).balance, 1 ether);
    }

    function testRelease() public {
        vm.prank(funder);
        vm.deal(funder, 1 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        vm.prank(funder);
        escrow.release();

        assertTrue(escrow.isReleased());
        assertEq(beneficiary.balance, 1 ether);
        assertEq(address(escrow).balance, 0);
    }

    function testCannotFundTwice() public {
        vm.prank(funder);
        vm.deal(funder, 2 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        vm.expectRevert("Contract is already funded");
        escrow.fund{ value: 1 ether }(beneficiary);
    }

    function testCannotReleaseWithoutFunding() public {
        vm.prank(funder);
        vm.expectRevert("Contract is not funded");
        escrow.release();
    }

    function testCannotReleaseIfNotFunder() public {
        vm.prank(funder);
        vm.deal(funder, 1 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        vm.prank(beneficiary);
        vm.expectRevert("Only the funder can release funds");
        escrow.release();
    }

    function testCannotReleaseTwice() public {
        vm.prank(funder);
        vm.deal(funder, 1 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        vm.prank(funder);
        escrow.release();

        vm.prank(funder);
        vm.expectRevert("Funds have already been released");
        escrow.release();
    }

    function testGetBalance() public {
        vm.prank(funder);
        vm.deal(funder, 1 ether);
        escrow.fund{ value: 1 ether }(beneficiary);

        assertEq(escrow.getBalance(), 1 ether);

        vm.prank(funder);
        escrow.release();

        assertEq(escrow.getBalance(), 0);
    }
}
