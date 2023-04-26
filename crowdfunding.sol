// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

contract Crowdfunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        // record the duration of each stage
        uint256[] timer;
        uint256 amountleft;
        // to change
        // uint256[] donations;
        address[] donators;
        mapping(address => uint256) donations;
        uint256 expectedInterestRate;
        mapping(uint => Voting) votes;
        uint256 status;
        uint256 current_stage;
        uint256 start_timestamp;
        uint256 profit; // profit in the end
    }
    

    struct Voting {
        uint256 stage;
        uint256 count;
        mapping(address => bool) voterAddrs;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        uint256 _expectedInterestRate
    ) public returns (uint256) {

        uint256 minute = 1 minutes;

        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline>0, "The deadline should be a date in the future.");

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = (_deadline * minute) + block.timestamp;
        campaign.amountCollected = 0;
        //campaign.amountleft = 0;
        campaign.expectedInterestRate = _expectedInterestRate;
        campaign.status = 0;
        campaign.current_stage = 0;
        campaign.timer = [20,30,30,30];
        campaign.profit = 0;

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
        require(campaigns[_id].target >= campaigns[_id].amountCollected +msg.value,"amount is out of range" );
        //rest money

        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        
        if (campaign.donations[msg.sender] == 0) {
            campaign.donators.push(msg.sender);
        }

        campaign.donations[msg.sender] += amount;
        (bool sent, ) = payable(address(this)).call{value: amount}("");
        campaign.amountCollected += amount;
        // if (sent) {
        //     campaign.amountCollected += amount;
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

    // function withdrawFunds(uint256 _id, uint256 _stage) public payable {

    //     // uint256 currentStage = _stage;

    //     Campaign storage campaign = campaigns[_id];

    //     //uint _amountWei = _amount * 1 ether;
    //     address ownerAdd = campaign.owner;
    //     uint withdrawMoney = campaign.amountCollected * 15/100;

    //     //require(msg.sender == campaign.owner, "Only the owener of the campaign can withdraw funds");
    //     require(address(this).balance > withdrawMoney, "Don't have enpugh money on this contract");
    //     require(campaign.amountCollected >= withdrawMoney, "The money in this project is not enough"); 

    //     if(_stage <= 3) {
    //          (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
    //          campaign.amountCollected -= withdrawMoney;
    //     }

    //  }

    function releaseFunds(uint256 _id, uint256 _stage) public payable {
        // uint256 currentStage = _stage;
        Campaign storage campaign = campaigns[_id];

        if (_stage == 0) { // If the campaign cannot start, return the funds donated by the donor to the donor
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                (bool sent, ) =payable(donator).call{value: donation}("");
                require(sent, "Failed to send Ether.");
            }
            campaign.amountCollected = 0;
        } else if (_stage == 1) { // If the campaign can be completed in the end, the original funds and expected interest will be returned to the donor within 30 days after the end of the project
            require(campaign.amountCollected >= campaign.target, "Target amount not reached.");
            require(block.timestamp >= campaign.deadline + 30 days, "Funds can only be released one month after the deadline.");
            uint256 totalPayout;
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                uint256 payout = donation + donation * campaign.expectedInterestRate / 100;
                (bool sent, ) =payable(donator).call{value: payout}("");
                require(sent, "Failed to send Ether.");
                totalPayout += payout;
            }
            campaign.amountCollected = 0;
        } else if (_stage == 2) { // If the campaign is interrupted, the remaining funds will be returned to the donor in proportion to the donation
            uint256 totalDonations;
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address payable donator = payable(campaign.donators[i]);
                uint256 donation = campaign.donations[donator];
                totalDonations += donation;
            }
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address payable donator = payable(campaign.donators[i]);
                uint256 donation = campaign.donations[donator];
                uint256 payout = campaign.amountCollected * donation / totalDonations;
                (bool sent, ) = donator.call{value: payout}("");
                require(sent, "Failed to send Ether.");
            }
            campaign.amountCollected = 0;
        } else {
            revert("Invalid stage");
        }
    }

    function donateRestMoney(uint256 id) public payable {
        Campaign storage camp = campaigns[id];
        require(msg.value > 0, "Donation amount must be greater than zero.");
        require(campaigns[id].status == 1,"Project is not at raising money status");

        uint256 amount_need = camp.target - camp.amountCollected;
        
        if (camp.donations[msg.sender] == 0) {
            camp.donators.push(msg.sender);
        }

        camp.donations[msg.sender] += amount_need;
        (bool sent, ) = payable(address(this)).call{value: amount_need}("");
        camp.amountCollected += amount_need;
    }

    // owner add their profit to campaign
    function ownerAddToCampaign(uint256 id)public payable {
        Campaign storage camp = campaigns[id];
        require(msg.sender == camp.owner,"You are not the campaign owner.");
        require(msg.value>0,"Please enter a value over 0");
        require(camp.status>=3,"Please use this function after raising enough money");
        //target


        (bool sent, ) = payable(address(this)).call{value: msg.value}("");

        // owner can add their profit in every stages
        // camp.profit[camp.current_stage] += msg.value;
        camp.profit += msg.value;
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