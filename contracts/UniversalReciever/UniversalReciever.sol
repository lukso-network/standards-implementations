pragma solidity 0.5.10;

interface UniversalReciever {
    event Received(address sender, bytes32 typeId , bytes data);
    function recieve(address sender,bytes32 typeId,bytes calldata data) external;
}