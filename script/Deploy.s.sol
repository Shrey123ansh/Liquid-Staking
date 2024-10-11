//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import {DeployYourContract} from "./DeployYourContract.s.sol";
import "../contracts/BLSToken.sol"; // Adjust path based on your file structure
import "../contracts/BlumeLiquidStaking.sol"; // Adjust path based on your file structure;
import "../contracts/SmartWallet.sol"; // Adjust path based on your file structure;


contract DeployScript is ScaffoldETHDeploy {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        uint256 owner = vm.envUint("OWNER_ADDRESS");
        address admin = vm.addr(deployerPrivateKey);
        // Start the broadcast (send transactions)
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        if (owner == 0) {
            revert InvalidOwnerAddress();
        }
        vm.startBroadcast(deployerPrivateKey);
        address setter = vm.addr(deployerPrivateKey);

        // Deploy BLSToken
        BLSToken blsToken = new BLSToken();

        // Deploy BlumeLiquidStaking
        BlumeLiquidStaking stakingToken = new BlumeLiquidStaking(blsToken);

        SmartWallet smartWallet = new SmartWallet();

        // Stop broadcasting
        vm.stopBroadcast();

        // Print the addresses of the deployed contracts
        console.log("BLSToken deployed to:", address(blsToken));
        console.log("BlumeLiquidStaking deployed to:", address(stakingToken));;
        console.log("SmartWallet deployed to:", address(smartWallet));;
    }
}
