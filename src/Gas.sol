// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 
import {GasCustomErrors} from "./Interfaces/CustomErrors.sol";


// Current deployemnt gas cost is: 593049 gas
contract GasContract is GasCustomErrors {
    address immutable public contractOwner;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public administrators;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    modifier onlyAdminOrOwner() {
        
        if (!checkForAdmin(msg.sender) && msg.sender != contractOwner) { 
            revert Gas_OnlyOwnerOrAdmin();
        } 
        _;    
        
    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        unchecked {
            for (uint256 ii = 0; ii < 5; ii++) {
                administrators[ii] = _admins[ii];
            }
        }
        balances[msg.sender] = _totalSupply;
        
    }
    

    function checkForAdmin(address _user) public view returns (bool admin) { // remove for loop, and set up mapping instead
        for (uint i = 0;  i < 5; i++) {
            if (administrators[i] == _user) {
                return true;
                }
        }
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }
    
    function transfer(address _recipient, uint256 _amount, string calldata _name) public  {
        require(balances[msg.sender] >= _amount); 

        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner {
        
        require(_tier < 255);
        
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier; //if the tier is above three then it as 3, else use their tier number to assign
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {
        whitelist[msg.sender] = _amount;
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whitelist[sender]);
    }

}