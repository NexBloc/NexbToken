// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import './Inexb_ERC20.sol';
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";


contract NexbGovernance is Initializable{

   event PauseUnpause();  
   event burn(uint amount);
   event Approved();
   event ApprovalWithdrawn();
   event DisapprovalWithdrawn();
   event disapproved();
   event systemReset();
   
   
    modifier approval{
      require(addresses[msg.sender], 'Only approved Addresses can make request.');
      _;

    }
    
    
    address[] public approvedAddresses;
    address[] public blacklist;
    uint public pause;
    uint public val;
    address public token;
    address public burnAccount;
    address public governance;
    uint public burnAmount;
    uint public approvalCount;
    uint public disapprovalCount;
    mapping(address => bool) public approvals;
    mapping(address => bool) public disapprovals;
    mapping(address => bool) private addresses;
    
    
    
    
    function initialize(address[] memory _approvedAddresses, address token_) initializer external{
    
    
    for(uint i=0;i<_approvedAddresses.length;i++){
        approvedAddresses.push(_approvedAddresses[i]);
        addresses[_approvedAddresses[i]] = true;
    } 

    approvalCount=0;
    disapprovalCount=0;
    token=token_;
    pause = 9;
    burnAmount = 0;
    val=9;

    
    } 

    
    function makePausableRequest(uint val_) external approval{
        
        require(governance==address(0),'Governance request already exists.');
        require(pause==9,'Pause/Unpause request already exists.');
        require(burnAmount ==0 && burnAccount == address(0),'Burn request already exists.');
        require(blacklist.length == 0, 'Blacklist request already exists.');

        pause = val_;
        
    }

    function makeBurnRequest(address account, uint amount) external approval {
        
        require(governance==address(0),'Governance request already exists.');
        require(burnAmount ==0 && burnAccount == address(0),'Burn request already exists.');
        require(pause==9,'Pause/Unpause request already exists.');
        require(blacklist.length == 0, 'Blacklist request already exists.');


        burnAccount = account;
        burnAmount = amount;


    }

    function makeBlacklistRequest(address[] memory blacklist_, uint val_) external approval {
        
        require(governance==address(0),'Governance request already exists.');
        require(blacklist.length == 0, 'Blacklist request already exists.');
        require(pause==9 ,'Pause/Unpause request already exists.');
        require(burnAmount ==0 && burnAccount == address(0),'Burn request already exists.');

        for(uint i=0;i<blacklist_.length;i++){
        blacklist.push(blacklist_[i]);
    } 
        val=val_;


    }


    function makeGovernanceRequest(address governance_) external approval{
        
        require(governance==address(0),'Governance request already exists.');
        require(pause==9,'Pause/Unpause request already exists.');
        require(burnAmount ==0 && burnAccount == address(0),'Burn request already exists.');
        require(blacklist.length == 0, 'Blacklist request already exists.');

        governance = governance_;
        
    }


     

    function giveApproval() external approval{
        
        require(pause!=9 || burnAmount !=0 && burnAccount != address(0) || blacklist.length != 0 || governance!=address(0),'Request does not exists.');
        require(!approvals[msg.sender],'request already approved.');
        approvalCount++;
        approvals[msg.sender] = true;

        emit Approved();

    }

    
    function withdrawApproval() external approval{

        require(approvals[msg.sender],'Have to approve first.');
        approvalCount--;
        approvals[msg.sender] = false;

        emit ApprovalWithdrawn();
    }

    
    
    
    function sendPausableRequest() external approval{
        
        
        require(pause!=9, ' Pausable Request does not exists.');
        
        uint approvalsRequired = approvedAddresses.length/2;
        
        require(approvalCount>approvalsRequired,'Not enough approvals.');

        Inexb_ERC20(token).pauseContract(pause);
        reset();

        emit PauseUnpause();
    }



     function sendBurnRequest() external approval{

        require(burnAmount !=0 && burnAccount != address(0),'Burn request does not exists.');
        
        uint approvalsRequired = approvedAddresses.length/2;

        require(approvalCount>approvalsRequired,'Not enough approvals.');

        Inexb_ERC20(token).adminBurn(burnAccount,burnAmount);
        reset();
           
        emit burn(burnAmount);

  }

   function sendBlacklistRequest() external approval {
       
       require(blacklist.length != 0, 'Blacklist request does not exists.');

       uint approvalsRequired = approvedAddresses.length/2;

       require(approvalCount>approvalsRequired,'Not enough approvals.');

       Inexb_ERC20(token).addBlacklist(blacklist,val);
        reset();
           
        emit burn(burnAmount);
   }

   function sendGovernanceRequest() external approval {
       
       require(governance != address(0), 'Governance request does not exists.');

       uint approvalsRequired = approvedAddresses.length/2;

       require(approvalCount>approvalsRequired,'Not enough approvals.');

       Inexb_ERC20(token).modifyGovernance(governance);
        reset();
           
        emit burn(burnAmount);
   }




    
    
    function disapproval() external approval{
                
        require(pause!=9 || burnAmount !=0 && burnAccount != address(0) || blacklist.length != 0 || governance!=address(0),'Request does not exists.');
        require(!disapprovals[msg.sender],'request already disapproved.');

        uint disapprovalsRequired = approvedAddresses.length/2;

        disapprovals[msg.sender]=true;
        disapprovalCount++;

        if(disapprovalCount>disapprovalsRequired){
            reset();
        }

        emit disapproved();
    }


    function withdrawDisapproval() external approval{

        require(disapprovals[msg.sender],'Have to disapprove first.');
        disapprovalCount--;
        disapprovals[msg.sender] = false;

        emit DisapprovalWithdrawn();
    }

    
    function reset() private {
        
        approvalCount=0;
        disapprovalCount=0;
        
        for(uint i=0;i<approvedAddresses.length;i++){
            approvals[approvedAddresses[i]] = false;
            disapprovals[approvedAddresses[i]] = false;
        }
        
        pause = 9;
        burnAccount = address(0);
        burnAmount = 0;
        val=9;
        delete blacklist;
        governance = address(0);


        emit systemReset();



    }
    
    function resetGovernance() approval external{
        reset();
    }
    }

    