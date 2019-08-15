pragma solidity 0.5.10;

import "./TypedReciever.sol";

contract Recieving is TypedReciever{

    event RecievedCustom(address self, address msgSender, address from, uint256 amount, bytes data);

    function recieve(address sender, bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        to;
        emit RecievedCustom(address(this),msg.sender,from,amount,data);
    }

}