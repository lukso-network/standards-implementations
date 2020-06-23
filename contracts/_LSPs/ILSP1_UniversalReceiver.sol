// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.6.0;

interface IUniversalReceiver {
    event Received(bytes32 indexed typeId, bytes data);

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32);
}
