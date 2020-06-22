pragma solidity ^0.6.0;

interface IUniversalReceiver {
    event Received(bytes32 indexed typeId, bytes data);

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32);
}
