// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SmartWallet {
    address public owner;

    // Data structure to store authentication methods for each user
    struct AuthMethods {
        bytes32 passcodeHash; // Hash of the user's passcode
        bool socialMediaBound; // Flag indicating if social media is bound
        bool biometricAuth; // Flag for biometric authentication
    }

    // Mapping of user addresses to their authentication methods
    mapping(address => AuthMethods) private userAuth;

    // Events
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);
    event PasscodeSet(address indexed user);
    event SocialMediaBound(address indexed user);
    event BiometricAuthEnabled(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyAuthorized() {
        require(isAuthorized(msg.sender), "User not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Deposit function to fund the wallet
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit Deposit(msg.sender, msg.value);
    }

    // Withdraw funds from the wallet
    function withdraw(uint amount) external onlyAuthorized {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // Set passcode with hashed value
    function setPasscode(bytes32 hashedPasscode) external {
        userAuth[msg.sender].passcodeHash = hashedPasscode;
        emit PasscodeSet(msg.sender);
    }

    // Bind social media ID (assuming successful OTP verification off-chain)
    function bindSocialMedia() external {
        userAuth[msg.sender].socialMediaBound = true;
        emit SocialMediaBound(msg.sender);
    }

    // Enable biometric authentication
    function enableBiometricAuth() external {
        userAuth[msg.sender].biometricAuth = true;
        emit BiometricAuthEnabled(msg.sender);
    }

    // Check if user is authorized via one of the methods
    function isAuthorized(address user) public view returns (bool) {
        AuthMethods memory auth = userAuth[user];
        return
            auth.passcodeHash != bytes32(0) ||
            auth.socialMediaBound ||
            auth.biometricAuth;
    }

    // Check if passcode is correct
    function checkPasscode(
        string memory passcode
    ) external view returns (bool) {
        return
            keccak256(abi.encodePacked(passcode)) ==
            userAuth[msg.sender].passcodeHash;
    }

    // Contract balance (for reference)
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Only the owner can withdraw all funds from the contract (emergency)
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
