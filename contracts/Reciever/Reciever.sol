pragma solidity 0.5.10;

interface Reciever {
    event Received(bytes32 typeId , address from, address to, uint256 amount, bytes data);
    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external;
}