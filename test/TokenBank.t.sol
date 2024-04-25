// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract CounterTest is Test {
    TokenBank public tokenbank;
    MyERC20 public myERC20;
    uint256 depositETH;
    address alice;
    function setUp() public {
        tokenbank = new TokenBank();
        myERC20 = new MyERC20();
        alice = makeAddr("alice");
        depositETH  = 2 ether;
        vm.deal(alice, depositETH);    
        }

    function test_mint() public{
        vm.prank(alice);
        myERC20._mint(alice, depositETH);
        assertEq(myERC20.balances(alice), depositETH);

    }

    function test_approve() public{
        test_mint();
        address spender = address(tokenbank);
        vm.prank(alice);
        myERC20.approve(spender, depositETH);
        assertEq(myERC20.allowances(alice, spender), depositETH);
        
    }
    
    function test_transferFrom() public {
        test_approve();
        address Bob = makeAddr("Bob");
        address spender = address(tokenbank);
        uint256 aliceInitialBalance = myERC20.balances(alice);
        uint256 expectedAliceBalanceAfterTransfer = aliceInitialBalance - depositETH;
        assertEq(myERC20.balances(Bob), 0);
        vm.prank(spender);
        myERC20.transferFrom(alice, Bob, depositETH);
        assertEq(myERC20.allowances(alice, spender), 0, "allowances wrong");
        assertEq(myERC20.balances(alice), expectedAliceBalanceAfterTransfer, "alice balances wrong");
        assertEq(myERC20.balances(Bob), depositETH, "bob balances wrong");                    
    }

    function test_deposit() public {
        test_approve();
        vm.prank(alice);
        tokenbank.deposit(address(myERC20), depositETH);
        assertEq(tokenbank.balances(address(myERC20),alice), depositETH);
        
    }

    function test_withdraw()public {
        test_deposit();
        vm.prank(address(this));
        tokenbank.withdraw(address(myERC20),alice, depositETH);
        assertEq(tokenbank.balances(address(myERC20),alice), 0);
    }


}
