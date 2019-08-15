pragma solidity 0.5.10;

import "./TypedReciever.sol";
import "../../Account/Account.sol";

contract ExternalReciever is Account, TypedReciever {

    //address Responsible for recieving function
    TypedReciever public externalReciever;

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        externalReciever =  TypedReciever(_newDelegate);
    }

    function recieve(address sender, bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        externalReciever.recieve(sender, typeId, from, to, amount, data);
        emit Recieved(sender, typeId , from,  to, amount,data);
    }

}