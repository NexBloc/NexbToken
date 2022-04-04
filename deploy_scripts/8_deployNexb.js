//const customERC721 = artifacts.require('CustomERC721');
const nexb = artifacts.require('NexB');


    module.exports =  function(deployer){
      deployer.deploy(nexb,'NexB','NEXB','550000000000000000000000000','enter governance address');
   }