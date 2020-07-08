// SPDX-License-Identifier: CC0-1.0
pragma solidity >=0.5.0 <0.7.0;

interface ILSP1 {
    event UniversalReceiver(address indexed from, bytes32 indexed typeId, bytes32 indexed returnedValue, bytes receivedData);

    function universalReceiver(bytes32 typeId, bytes memory data) external returns (bytes32);
}
