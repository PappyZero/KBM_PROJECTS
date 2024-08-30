// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MyToken.sol";


contract Bank_Token 
{

    struct UserProfile {
        string name;          
        address userAddress;  
        uint256 balance;     
    }

    enum TransactionState { Failed, Successful }

    TransactionState public transactionState;

    mapping(address => UserProfile) public userProfiles;

    ERC20 public token;
    // IERC20 public token;

    uint256 public constant MIN_DEPOSIT = 10 * (10 ** 18);

    uint256 public constant MAX_WITHDRAWAL = 500 * (10 ** 18);

    modifier updateTransactionState(bool success) 
    {
        transactionState = success ? TransactionState.Successful : TransactionState.Failed;
        _;
    }

    constructor(address tokenAddress) 
    {
        token = ERC20(tokenAddress);
        // token = IERC20(tokenAddress);
    }

    function setUserProfile(string memory _name, address _addr) public 
    {
        userProfiles[_addr].name = _name;
        userProfiles[_addr].userAddress = _addr;
    }

    function deposit(address _addr, uint256 amount) public updateTransactionState(amount >= MIN_DEPOSIT) 
    {

        require(amount >= MIN_DEPOSIT, "Deposit amount is too small.");

        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed.");

        userProfiles[_addr].balance += amount;
    }

    function withdraw(address _addr, uint256 _amount) public updateTransactionState(_amount <= MAX_WITHDRAWAL && userProfiles[_addr].balance >= _amount) 
    {

        require(_amount <= MAX_WITHDRAWAL, "Withdrawal amount exceeds the maximum limit.");
                
        require(userProfiles[_addr].balance >= _amount, "Insufficient balance.");

        userProfiles[_addr].balance -= _amount;

        require(token.transfer(_addr, _amount), "Token transfer failed.");
    }




    function getUserProfile(address _user) public view returns (string memory, address, uint256) 
    {
        UserProfile memory user = userProfiles[_user];
        return (user.name, user.userAddress, user.balance);
    }
}
