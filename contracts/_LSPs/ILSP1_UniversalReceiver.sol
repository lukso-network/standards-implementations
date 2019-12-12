pragma solidity 0.5.10;

interface IUniversalReceiver {
    event Received(bytes32 typeId, bytes data);

    function universalReceiver(bytes32 typeId, bytes calldata data) external returns (bytes32);
}