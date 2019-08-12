pragma solidity 0.5.10;

import "./Reciever.sol";
import "../../Account/Account.sol";

contract AccountReciever is Account, Reciever {

    //address Responsible for recieving function
    address public recievingDelegate;

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  _newDelegate;
    }

    function recieve(bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        (bool succ, bytes memory _) = 
        recievingDelegate.delegatecall(abi.encodeWithSignature("recieve(bytes32,address,address,uint256,bytes)", typeId, from, to, amount, data));
        require(succ);
        emit Received(typeId , from,  to, amount,data);
    }

}