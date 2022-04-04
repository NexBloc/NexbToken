//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./customERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NexB is customERC20, ReentrancyGuard {
   
   event burned(address account,uint tokenAmount);
   event paused();
   event unpaused();
   
   address public admin;

    constructor(
        string memory name,
        string memory symbol,
        uint256 supply,
        address governance_
    ) customERC20(name, symbol, governance_) {
       _mint(msg.sender, supply);
       admin = msg.sender;
    }

function userBurn(address account, uint tokenAmount) pausable blacklisted external {
    require(msg.sender != admin,'Admin not allowed.');
    require(msg.sender != governance,'Admin not allowed.');

    require(account == msg.sender,"Access denied.");
    _burn(account,tokenAmount);
    emit burned(account,tokenAmount);

}

function adminBurn(address account, uint tokenAmount) onlyGovernance pausable external {
    require(msg.sender == governance, "Only Admin's allowed.");
    require(account == admin,"Access denied.");
    _burn(account,tokenAmount);
    emit burned(account,tokenAmount);

}

function pauseContract(uint val) onlyGovernance external {
    
    require(val==0 || val==1,'wrong input.');
    
    if(pause ==0){
        require(val==1,'Contract is already unpaused.');
         pause = val;
         emit paused();
    }
    else if(pause == 1){
        require(val==0,'Contract is already paused.');
         pause = val;
         emit unpaused();
    }

}

function addBlacklist(address[] memory blacklistedAddress, uint val) onlyGovernance external  {
    
    if(val== 1){
    for(uint i=0;i<blacklistedAddress.length;i++){
        blacklist[blacklistedAddress[i]] = true;
    } 
    }
    else{
        removeBlacklist(blacklistedAddress);
    }
}

function removeBlacklist(address[] memory blacklistedAddress) onlyGovernance public  {
    for(uint i=0;i<blacklistedAddress.length;i++){
        blacklist[blacklistedAddress[i]] = false;
    } 



}

function modifyGovernance(address governance_) onlyGovernance external {
      governance = governance_;
    } 


}




