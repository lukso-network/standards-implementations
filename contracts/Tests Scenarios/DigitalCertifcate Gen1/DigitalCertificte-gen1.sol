pragma solidity 0.5.10;

import "https://github.com/lukso-network/standards-scenarios/blob/digital-certificates/contracts/DigitialCertificate/DigitalCertificate-fungible.sol";
//import "../../DigitialCertificate/DigitalCertificate-fungible.sol";

contract DCGen1 is DigitalCertificate {

    bytes32 public itemId = 0xdab14dd162839a7a989c99832802afa21dc91e29a88dd57d24c6160a7f9ee688; // DigitalCertificate.getData(0x1234567890);

    mapping(bytes32 => bool) private _claimables;


    constructor(string memory name, string memory symbol, address[] memory defaultOperators)
    DigitalCertificate()
    ERC777(name, symbol, defaultOperators)
    public
    {
        DigitalCertificate.owner = msg.sender;
    }

    /**
    * @dev Allows the issuer to add claimable items
    */
    function addClaimable(bytes32 _claimable)
    public
    onlyOwner
    {
        _claimables[_claimable] = true;
    }


    // certificate should not be able to receive ETH/LYX
    function() external {}


    /**
    * @dev Claims an item based on the itemId and certificateCode, which is hashed and compared to the stored hash
    */
    function claim(bytes4 _itemId, bytes4 _certificateCode)
    public
    {

        // compare given item ID, to current itemId
        require(keccak256(abi.encodePacked(_itemId)) == itemId, "Wrong item ID given.");


        // hash itemId with unique certificate ID
        bytes32 hashed = keccak256(abi.encodePacked(_itemId, _certificateCode));

        // see if hash is claimable
        require(_claimables[hashed] == true, "Given certificate ID is not existing.");

        address account = msg.sender;

        // remove claimable item
        delete _claimables[hashed];

        ERC777._totalSupply = ERC777._totalSupply.add(1);
        ERC777._balances[account] = ERC777._balances[account].add(1);

        ERC777._callTokensReceived(address(0), address(0), account, 1, "", "", false); // Allow transfer to any address

        emit Minted(account, account, 1, "", "");
        emit Transfer(address(0), account, 1);
    }


    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     *
     * See `IERC777Sender` and `IERC777Recipient`.
     *
     * Emits `Minted` and `Transfer` events.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - if `account` is a contract, it must implement the `tokensReceived`
     * interface.
     */
    function mint(
        address account,
        uint256 amount
    )
    public
    onlyOwner
    {
        require(account != address(0), "ERC777: mint to the zero address");

        // Update state variables
        ERC777._totalSupply = ERC777._totalSupply.add(amount);
        ERC777._balances[account] = ERC777._balances[account].add(amount);

        ERC777._callTokensReceived(address(0), address(0), account, amount, "", "", false); // Allow transfer to any address

        emit Minted(account, account, amount, "", "");
        emit Transfer(address(0), account, amount);
    }

}