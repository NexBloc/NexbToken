// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Inexb_ERC20 {
    function adminBurn(address account, uint tokenAmount) external ;
    function userBurn(address account, uint tokenAmount) external ;
    function pauseContract(uint val) external ;
    function addBlacklist(address[] memory blacklistedAddress, uint val) external ;
    function modifyGovernance(address governance_) external ;

    
}


