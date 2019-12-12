pragma solidity 0.5.10;

interface UniversalReceiver {
    event Received(bytes32 typeId, bytes data);

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32);
}