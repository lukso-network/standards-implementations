pragma solidity 0.5.10;

import "./TypedReciever.sol";
import "../../Account/Account.sol";

contract BasicTypedReciever is Account, TypedReciever {
    event TokenRecieved(address from, address to, uint256 amount);
    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        emit TokenRecieved(from,  to, amount);
        emit Recieved(typeId , from,  to, amount,data);
    }
}