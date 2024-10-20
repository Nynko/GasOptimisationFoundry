// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0; 

import "./Ownable.sol";
import {GasCustomErrors} from "./Interfaces/CustomErrors.sol";


// Current deployemnt gas cost is: 1015633 gas
contract GasContract is Ownable, GasCustomErrors {
    uint256 immutable private totalSupply; // cannot be updated
    uint256 private constant tradePercent = 12;
    uint256 public paymentCounter = 0;
    address public contractOwner;
    //mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public administrators;
    //mapping(address => uint256) public whiteListStruct;
    
    struct Payment { // TODO: move the elements to optimize
        // PaymentType paymentType;
        uint256 paymentID;
        uint256 amount;
        address recipient;
        address admin; // administrators address
        string recipientName; // max 8 characters --> TODO: certainly optimizable
        bool adminUpdated;
    }

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    modifier onlyAdminOrOwner() {
        //address senderOfTx = msg.sender;
        
        if (!checkForAdmin(msg.sender) && msg.sender != contractOwner) { 
            revert Gas_OnlyOwnerOrAdmin();
        } 
        _;    
        
    }

    modifier checkIfWhiteListed() {
        uint256 usersTier = whitelist[msg.sender];
        if (usersTier <= 0) {
            revert Gas_UserIsNotWhitelisted();
        }
        if (usersTier > 3) {
            revert Gas_UserTierIsIncorrect();
        }
        _;
    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;

        for (uint256 ii = 0; ii < 5; ii++) {
            administrators[ii] = _admins[ii];
            balances[_admins[ii]] = 0;
            }
            balances[contractOwner] = _totalSupply;
        
    }
    

    function checkForAdmin(address _user) public view returns (bool admin) { // remove for loop, and set up mapping instead
        //bool isAdmin = false;

        for (uint i = 0;  i < 5; i++) {
            if (administrators[i] == _user) {
                return true;
                break;
                }
        }
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }
    
    function transfer(address _recipient, uint256 _amount, string calldata _name) public  { //returns (bool status_)
        
        
        require(balances[msg.sender] >= _amount); //CUSTOM ERROR: Gas Contract - Transfer function
        //require(bytes(_name).length < 9);

        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;

        //payments[msg.sender].push(Payment({ //pushes payment onto already initalised structure for the address, instead of making a brand new one each time
        //admin: address(0),
        //adminUpdated: false,
        //recipient: _recipient,
        //amount: _amount,
        //recipientName: _name,
        //paymentID: ++paymentCounter
        //removed status as it wasnt used
    //}));
    
    //return true;
}

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner {
        
        require(_tier < 255);
        
        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier; //if the tier is above three then it as 3, else use their tier number to assign
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public checkIfWhiteListed() {
        //address senderOfTx = msg.sender;
        whitelist[msg.sender] = _amount;
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        balances[msg.sender] += whitelist[msg.sender];
        balances[_recipient] -= whitelist[msg.sender];
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whitelist[sender]);
    }

}