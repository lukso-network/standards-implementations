pragma solidity 0.5.10;

import "../BareDelegateReciever.sol";
import "../../../Account/SimpleKeyManager.sol";


contract RecievingDelegate is BareDelegateReciever{


    event RecievedTokenTransfer(address token, address from,address to, uint256 amount, bytes data);
    event SentTokenToWallet(address token, address wallet, uint amount);
    address tokenWallet;

    constructor(address _tkWallet) public {
        tokenWallet = _tkWallet;       
    }
  
    function toTokenData(bytes memory _bytes) internal pure returns(address _from, address _to, uint256 _amount) {
        require(_bytes.length == 72);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            _from := mload(add(add(_bytes, 0x14), 0x0))
            _to := mload(add(add(_bytes, 0x14), 0x14))
            _amount := mload(add(add(_bytes, 0x20), 0x28))
        }
    }

    function redirectToAddress(address token, address recipient, uint256 amount) internal {
        bytes memory data = abi.encodeWithSelector(0xa9059cbb, recipient, amount);
        // //Bad Naming here
        SimpleKeyManager keyManager = SimpleKeyManager(owner);
        keyManager.execute(0,token,0, data);
        emit SentTokenToWallet(token,recipient,amount);
    }
    
    function recieve(address sender, bytes32 typeId, bytes calldata data) external {
        (address from, address to, uint256 amount) = toTokenData(data);
        redirectToAddress(sender, tokenWallet ,amount);
        emit RecievedTokenTransfer(sender,from,to,amount,data);
    }
}
