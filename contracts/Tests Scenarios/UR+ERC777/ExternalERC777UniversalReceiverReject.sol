// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;


contract ExternalERC777UniversalReceiverRejectTester {
    function universalReceiverDelegate(address, bytes32, bytes memory) external pure returns(bytes32){
        require(false, "We reject everything");
        return "";
    }
}
