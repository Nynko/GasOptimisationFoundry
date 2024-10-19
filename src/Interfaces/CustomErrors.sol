// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface GasCustomErrors {
    error Gas_OnlyOwnerOrAdmin();
    error Gas_UserIsNotWhitelisted();
    error Gas_UserTierIsIncorrect();
}



