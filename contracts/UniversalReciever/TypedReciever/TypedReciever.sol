pragma solidity 0.5.10;

interface TypedReciever {
    event Recieved(bytes32 typeId , address from, address to, uint256 amount, bytes data);
    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external;
}