const governance = artifacts.require('NexbGovernance');

module.exports =  function(deployer){
      deployer.deploy(governance)
   }