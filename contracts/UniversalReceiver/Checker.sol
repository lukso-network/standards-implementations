// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

import "./UniReceiver.sol";
import "../../node_modules/solidity-bytes-utils/contracts/BytesLib.sol";
import "../../node_modules/solidity-bytes-utils/contracts/AssertBytes.sol";

contract Checker {
    function callImplementationAndReturn(address target, bytes32 typeId) external returns (bytes32) {
        return UniReceiver(target).universalReceiver(typeId, "");
    }

    function checkImplementation(address target, bytes32 typeId) external returns (bool) {
        bytes32 ret = UniReceiver(target).universalReceiver(typeId, "");
        return ret == typeId;
    }

    function checkImplementationBytes(address target, bytes32 typeId) external returns (bool) {
        bytes memory ret = UniReceiver(target).universalReceiverBytes(typeId, "");
        return AssertBytes.equal(ret, abi.encodePacked(typeId), "");
    }

    function lowLevelCheckImplementation(address target, bytes32 typeId) external returns (bool) {
        (bool succ, bytes memory ret) = target.call(abi.encodeWithSignature("universalReceiver(bytes32,bytes)", typeId, ""));
        bytes32 response = BytesLib.toBytes32(ret, 0);
        return succ && response == typeId;
    }

    function lowLevelCheckImplementationBytes(address target, bytes32 typeId) external returns (bool) {
        (bool succ, bytes memory ret) = target.call(abi.encodeWithSignature("universalReceiverBytes(bytes32,bytes)", typeId, ""));
        return succ && AssertBytes.equal(ret, abi.encodePacked(typeId), "");
    }

}
