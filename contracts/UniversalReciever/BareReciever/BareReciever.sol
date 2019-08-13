pragma solidity 0.5.10;

interface BareReciever {
    event Received(bytes32 typeId , bytes data);
    function recieve(bytes32 typeId ,bytes calldata data) external;
}