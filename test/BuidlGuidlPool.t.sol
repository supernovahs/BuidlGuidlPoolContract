// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BuidlGuidlPool.sol";
contract BuidlGuidlTestPool is Test {
    

    BuidlGuidlPool public pool;
    address public BuidlGuidlAdmin = makeAddr("buidlguidl");
    function setUp() public {
        pool = new BuidlGuidlPool(BuidlGuidlAdmin);
    }


    function testSweep() public {
        vm.deal(address(pool),10 ether);
        vm.prank(BuidlGuidlAdmin);
        pool.Sweep();
        assertEq(address(pool).balance,0);
        assertEq(address(BuidlGuidlAdmin).balance,10 ether);
    }


    // function testCreateNewStream() public {
    //     vm.warp(1679677904);
    //     vm.prank(BuidlGuidlAdmin);
    //     pool.StreamBuilder(BuidlGuidlPool.Type.DamageDealer,makeAddr("John"),true,2419200);
    //     vm.warp(1679677904 + 1296000);

    //     (uint cap ,uint fre,uint last) = pool.stream_map(makeAddr("John"));
    //     assertEq(last,1679677904 - 2419200);

    //     uint RequiredStreamBalance = 1.5 ether;
    //     assertEq(pool.streamBalance(makeAddr("John")),RequiredStreamBalance);

    //     vm.deal(address(pool),2 ether);
        
    // }

}
