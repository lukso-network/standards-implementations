pragma solidity 0.5.10;

import "./TypedReciever.sol";
import "../../Account/Account.sol";

contract DelegateReciever is Account, TypedReciever {

    //address Responsible for recieving function
    address public recievingDelegate;

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  _newDelegate;
    }

    function recieve(address sender, bytes32 typeId , address from, address to, uint256 amount, bytes calldata data) external {
        (bool succ, bytes memory _) = 
        recievingDelegate.delegatecall(abi.encodeWithSignature("recieve(address,bytes32,address,address,uint256,bytes)", sender,typeId, from, to, amount, data));
        require(succ);
        _;
        emit Recieved(sender, typeId , from,  to, amount,data);
    }

}