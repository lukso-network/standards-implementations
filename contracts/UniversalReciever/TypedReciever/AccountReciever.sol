pragma solidity 0.5.10;

import "./TypedReciever.sol";
import "../../Account/Account.sol";

contract AccountReciever is Account, TypedReciever {

    //address Responsible for recieving function
    TypedReciever public recievingDelegate;

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  TypedReciever(_newDelegate);
    }

    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        recievingDelegate.recieve(typeId, from, to, amount, data);
        emit Recieved(typeId , from,  to, amount,data);
    }

}