pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


pragma solidity ^0.6.2;


contract PinToken is ERC20, Ownable {
    using SafeMath for uint256;
    uint256 public totalBurn;
    uint256 private _cap;
    uint256 private _newamount;
    uint8 public divisor;
    //@dev pinmaster is the contract deployer
    address public pinMaster;

    constructor() ERC20("Pin", "PinExp") public {
        pinMaster = msg.sender;
        _mint(pinMaster, 1800000000000000000000); //mint 1800 pin to deployer
        //@dev cap is immutable,
        _cap = 9000000000000000000000; //9000
        divisor = 100;

    }

    // mints new  pintokens, can only be called by BubbleToken */
    // contract during burns, no users or dev can call this
    function mint(address _to, uint256 _amount) public onlyOwner {
        require(totalSupply().add(_amount) <= _cap, "Pin: cap exceeded");
        _mint(_to, _amount);
    }
    /**
    * @dev Returns the cap on the token's total supply.
    */

    function cap() public view returns (uint256) {
        return _cap;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        // pin amount is 1%
        uint256 burnAmount = amount.div(divisor);
        //@dev burn amount cap to 6000
        if (totalBurn + burnAmount <= 6000000000000000000000) {
           // sender loses the 1% of the pins
            _burn(msg.sender, burnAmount);
            totalBurn += burnAmount;
            _newamount = amount.sub(burnAmount);
        }else {
            _newamount = amount;
        }
        // sender transfers 99% of the pins if burn cap is not 6000
        return super.transfer(recipient, _newamount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        // burn amount is 1%
        uint256 burnAmount = amount.div(divisor);
        if (totalBurn + burnAmount <= 6000000000000000000000) {
            _burn(sender, burnAmount);
            totalBurn += burnAmount;
            _newamount = amount.sub(burnAmount);
        }else {
            _newamount = amount;
        }
        // sender transfers 99% of the pins if burn cap is not 6000
        return super.transferFrom(sender, recipient, _newamount);
    }
}
