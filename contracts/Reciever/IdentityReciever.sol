pragma solidity 0.5.10;

import "./Reciever.sol";
import "../Identity/Identity.sol";

contract IdentityReciever is Identity, Reciever {

    //address Responsible for recieving function
    Reciever public recievingDelegate;

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  Reciever(_newDelegate);
    }

    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        recievingDelegate.recieve(typeId, from, to, amount, data);
        emit Received(typeId , from,  to, amount,data);
    }

}