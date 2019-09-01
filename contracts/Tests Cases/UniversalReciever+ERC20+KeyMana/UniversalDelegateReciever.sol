pragma solidity 0.5.10;

import "../../UniversalReciever/UniversalReciever.sol";
import "../../KeyManager/SimpleKeyManager.sol";
import "../../Account/Account.sol";

contract UniversalDelegateReciever is Account, UniversalReciever {
    
    address public recievingDelegate;
    bool performDelegate;

    function changePerformDelegate(bool perform) onlyOwner external {
        performDelegate = perform;
    }

    function changeRecievingDelegate(address _newDelegate) onlyOwner external {
        recievingDelegate =  _newDelegate;
    }

    function universalReciever(bytes32 typeId ,bytes calldata data) external{
        bool succ;
        bytes memory ret;
        if(performDelegate){
            (succ, ret) = recievingDelegate.delegatecall(abi.encodeWithSignature("universalReciever(address,bytes32,bytes)", msg.sender,typeId,data));
        } else {
            (succ, ret) = recievingDelegate.call(abi.encodeWithSignature("universalReciever(address,bytes32,bytes)", msg.sender,typeId,data));
        }
        require(succ);
        emit Received(typeId,data);
    }


}