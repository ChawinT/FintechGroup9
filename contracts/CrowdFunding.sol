// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Crowdfunding {
    struct Campaign {
        address owner; // An address of the owner of the project 
        string title; // A title of the project 
        string description; // A description of the project 
        uint256 target; // A target for fund raising 
        uint256 deadline; // A deadline for raising fund 
        uint256 amountCollected; // An amount of fund that has been raised
        uint256 amountleft; // An amount of fund left after withdraw to the project owener 
        address[] donators; // An address of donator 
        mapping(address => uint256) donations; // A mapping of an address to an amount of donation 
        uint256 expectedInterestRate; // An expected interest rate of a project
        mapping(uint => Voting) votes; // 
        uint256 status; // A status of a project 
        uint256 current_stage; // A stage of the project
    }
    
    struct Voting {
        uint256 stage; // A stage of voting
        uint256 count; // A number of voting
        mapping(address => bool) voterAddrs; // A map that link address to the vote
    }

    mapping(uint256 => Campaign) public campaigns; // A mapping that link the project id to campaign

    uint256 public numberOfCampaigns = 0; // A number of campaign

    // A function that use to create a campaign //
    // It needs 5 inputs which are 1.Title of the project 2.Description of the project 3.Targeted amount 4.Deadline for fundraising 5.Expected Interest Rate
    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        uint256 _expectedInterestRate
    ) public returns (uint256) {

        uint256 minute = 1 minutes;
        // uint256 day = 1 days;

        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline>0, "The deadline should be a date in the future.");

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target * 1 ether;
        campaign.deadline = (_deadline * minute) + block.timestamp;
        campaign.amountCollected = 0;
        campaign.amountleft = 0;
        campaign.expectedInterestRate = _expectedInterestRate;
        campaign.status = 0;
        campaign.current_stage = 0;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function publicCampaign(uint256 projectid) public {
        require(msg.sender == campaigns[projectid].owner, "Only the owner of the campaign can public the project.");
        campaigns[projectid].status = 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(msg.value > 0, "Donation amount must be greater than zero.");
        require(campaigns[_id].status == 1,"Project is not at raising money status");

        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        
        if (campaign.donations[msg.sender] == 0) {
            campaign.donators.push(msg.sender);
        }

        campaign.donations[msg.sender] += amount;
        (bool sent, ) = payable(address(this)).call{value: amount}("");
        campaign.amountCollected += amount; 
        campaign.amountleft += amount;
        
        // if (sent == true) {
        //     campaign.amountCollected += amount;
        //     campaign.amountleft += amount;
        // }
    }

    function withdrawFunds(uint256 _id, uint256 _stage) public payable {

        uint256 currentStage = _stage;

        Campaign storage campaign = campaigns[_id];

        address ownerAdd = campaign.owner;
        uint projectFund = campaign.target;
        uint withdrawMoney;

        //require(msg.sender == campaign.owner, "Only the owener of the campaign can withdraw funds");
        require(address(this).balance >= campaign.amountleft, "Don't have enough money on this contract");

        if(currentStage == 0) {
            withdrawMoney = projectFund * 15/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } else
        if(currentStage == 1) {
            withdrawMoney = projectFund * 40/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } else
        if(currentStage == 2) {
            withdrawMoney = projectFund * 35/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } else
        if(currentStage == 3) {
            withdrawMoney = projectFund * 10/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } 
        // else
        // if(currentStage == 4) {
        //     require(campaign.amountleft == 0, "Something Wrong");
        // }

     }

    function releaseFunds(uint256 _id) public payable {
        Campaign storage campaign = campaigns[_id];
        // require(campaign.amountCollected >= campaign.target, "Target amount not reached.");
        // require(block.timestamp >= campaign.deadline + 30 days, "Funds can only be released one month after the deadline.");

            for (uint256 i = 0; i < campaign.donators.length; i++) {
             address donator = campaign.donators[i];
             uint donation = campaign.donations[donator];

             //uint256 payout = donation + donation * campaign.expectedInterestRate / 100;
             (bool sent, ) = payable(donator).call{value: donation}("");
             campaign.amountleft -= donation;
             require(sent, "Failed to send Ether.");
         }

         require(campaign.amountleft == 0, "Something Wrong");
    }

    function getDonators(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        return (campaigns[_id].donators);
    }
    
    function getCampaignsDetails() public view returns (
        address[] memory,
        string[] memory,
        string[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) {
        address[] memory owners = new address[](numberOfCampaigns);
        string[] memory titles = new string[](numberOfCampaigns);
        string[] memory descriptions = new string[](numberOfCampaigns);
        uint256[] memory targets = new uint256[](numberOfCampaigns);
        uint256[] memory deadlines = new uint256[](numberOfCampaigns);
        uint256[] memory amountCollecteds = new uint256[](numberOfCampaigns);
        uint256[] memory statuses = new uint256[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            owners[i] = item.owner;
            titles[i] = item.title;
            descriptions[i] = item.description;
            targets[i] = item.target;
            deadlines[i] = item.deadline;
            amountCollecteds[i] = item.amountCollected;
            statuses[i] = item.status;
        }

        return (
            owners,
            titles,
            descriptions,
            targets,
            deadlines,
            amountCollecteds,
            statuses
        );
    }
    
}