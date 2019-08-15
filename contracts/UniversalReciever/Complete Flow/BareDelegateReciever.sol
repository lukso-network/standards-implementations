pragma solidity 0.5.10;

import "../BareReciever/BareReciever.sol";
import "../../Account/SimpleKeyManager.sol";
import "../../Account/Account.sol";

contract BareDelegateReciever is Account, BareReciever {
    
    address public recievingDelegate;
    bool performDelegate;

    function changePerformDelegate(bool perform) onlyOwner external {
        performDelegate = perform;
    }

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  _newDelegate;
    }

    function recieve(address sender,bytes32 typeId ,bytes calldata data) external{
        bool succ;
        bytes memory ret;
        if(performDelegate){
            (succ, ret) = recievingDelegate.delegatecall(abi.encodeWithSignature("recieve(address,bytes32,bytes)", sender,typeId,data));
        } else {
            (succ, ret) = recievingDelegate.call(abi.encodeWithSignature("recieve(address,bytes32,bytes)", sender,typeId,data));
        }
        require(succ);
        emit Received(sender, typeId,data);
    }


}