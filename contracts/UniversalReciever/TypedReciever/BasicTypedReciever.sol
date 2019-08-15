pragma solidity 0.5.10;

import "./TypedReciever.sol";
import "../../Account/Account.sol";

contract BasicTypedReciever is Account, TypedReciever {
    event TokenRecieved(address token, address from, address to, uint256 amount);
    function recieve(address sender, bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        emit TokenRecieved(sender, from,  to, amount);
        emit Recieved(sender, typeId , from,  to, amount,data);
    }
}