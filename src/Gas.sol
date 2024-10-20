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
    mapping(address => Payment[]) public payments;
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
        address senderOfTx = msg.sender;
        if (checkForAdmin(senderOfTx)) {
            _;
        } else if (senderOfTx == contractOwner) {
            _;
        } else {
            revert Gas_OnlyOwnerOrAdmin();
        }
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
            if (_admins[ii] != address(0)) {
                administrators[ii] = _admins[ii];
                if (_admins[ii] == contractOwner) {
                    balances[contractOwner] = _totalSupply;
                } else {
                    balances[_admins[ii]] = 0;
                }
            }
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin) { // remove for loop, and set up mapping instead
        for (uint i = 0;  i < 5; i++) {
            if (administrators[i] == _user) {
                admin = true;
            }
        }
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }
    
    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata _name
    ) public returns (bool status_) {
        // bytes8 memory b3 = bytes8(_name);
        address senderOfTx = msg.sender;
        require(
            balances[senderOfTx] >= _amount
        ); //CUSTOM ERROR: Gas Contract - Transfer function
        require(
            bytes(_name).length < 9
        );
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        Payment memory payment;
        payment.admin = address(0);
        payment.adminUpdated = false;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.recipientName = _name ;
        payment.paymentID = ++paymentCounter;
        payments[senderOfTx].push(payment);
        bool[] memory status = new bool[](tradePercent);
        for (uint256 i = 0; i < tradePercent; i++) {
            status[i] = true;
        }
        return (status[0] == true);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner {
        
        require(_tier < 255);
        
        if (_tier == 2) { // (_tier > 0 && _tier < 3) 
            whitelist[_userAddrs] = 2;
        } else if (_tier == 1) {
            whitelist[_userAddrs] = 1;
        } else { // (_tier > 3)
            whitelist[_userAddrs] = 3;
        } 
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount
    ) public checkIfWhiteListed() {
        address senderOfTx = msg.sender;
        whitelist[senderOfTx] = _amount;
        balances[senderOfTx] -= _amount;
        balances[_recipient] += _amount;
        balances[senderOfTx] += whitelist[senderOfTx];
        balances[_recipient] -= whitelist[senderOfTx];
        
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whitelist[sender]);
    }

}