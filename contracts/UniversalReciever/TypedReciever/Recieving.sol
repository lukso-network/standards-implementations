pragma solidity 0.5.10;

import "./TypedReciever.sol";

contract Recieving is TypedReciever{

    event RecievedCustom(bytes32 typeId , address from, address to, uint256 amount, bytes data);

    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        to;
        emit RecievedCustom(typeId,from,address(this),amount,data);
    }

}