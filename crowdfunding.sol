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
        // uint256 start_timestamp;
        uint256 profit; // profit in the end
        string img;
    }
    

    struct Voting {
        uint256 stage;
        uint256 count;
        mapping(address => bool) voterAddrs;
        string comment;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        uint256 _expectedInterestRate,
        uint256 _stage0time,
        uint256 _stage1time,
        uint256 _stage2time,
        uint256 _stage3time,
        string memory _img
    ) public returns (uint256) {

        //uint256 minute = 1 minutes;

        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline>0, "The deadline should be a date in the future.");

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target * 1 ether;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        //campaign.amountleft = 0;
        campaign.expectedInterestRate = _expectedInterestRate;
        campaign.status = 1;
        campaign.current_stage = 0;
        // int256[] memory timer = new uint256[](numberOfCampaigns);
        campaign.timer = [_stage0time,_stage1time,_stage2time,_stage3time];
        campaign.profit = 0;
        campaign.img = _img;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function publicCampaign(uint256 projectid) public {
        require(msg.sender == campaigns[projectid].owner, "Only the owner of the campaign can public the project.");
        campaigns[projectid].status = 1;
    }

    function donateToCampaign(uint256 _id) public payable {
        require(campaigns[_id].owner != msg.sender,"Owner of project should not donate.");
        require(msg.value > 0, "Donation amount must be greater than zero.");
        require(campaigns[_id].status == 1,"Project is not at raising money status");
        if(campaigns[_id].target >= campaigns[_id].amountCollected +msg.value){

            uint256 amount = msg.value;
            Campaign storage campaign = campaigns[_id];
            
            if (campaign.donations[msg.sender] == 0) {
                campaign.donators.push(msg.sender);
            }

            campaign.donations[msg.sender] += amount;
            (bool sent, ) = payable(address(this)).call{value: amount}("");
            campaign.amountCollected += amount;
        }else{
            donateRestMoney(_id);
        }

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
            withdrawMoney = projectFund * 30/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } else
        if(currentStage == 1) {
            withdrawMoney = projectFund * 30/100;
            require(campaign.amountleft >= withdrawMoney, "The money in this project is not enough");
            (bool sent, ) = payable(ownerAdd).call{value : withdrawMoney}("");
            campaign.amountleft -= withdrawMoney;
        } else
        if(currentStage == 2) {
            withdrawMoney = projectFund * 30/100;
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

    function releaseFunds(uint256 _id, uint256 _stage) public payable {

        Campaign storage campaign = campaigns[_id];

        if ((_stage == 0)&&(campaign.status == 2)) {                                                      // release the rest amount of money. call this 4 times at most: 1 before voting and 3 voting stages
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                (bool sent, ) = payable(donator).call{value: donation}("");
                require(sent, "Failed to send Ether.");
            }
        }else if ((_stage < 3)) {                                                      // release the rest amount of money. call this 4 times at most: 1 before voting and 3 voting stages
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                uint256 payout = campaign.amountleft * donation / campaign.target;    // donation / campaign.target means the portion of each donators
                (bool sent, ) = payable(donator).call{value: payout}("");
                require(sent, "Failed to send Ether.");
            }
        }else if (_stage==3){                                                  //release all the profits. call this only one time
            uint256 profit = campaign.profit;
            uint256 total_payout = 0;
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                uint256 payout =  profit * donation / campaign.target;
                (bool sent, ) =payable(donator).call{value: payout}("");
                require(sent, "Failed to send Ether.");
                total_payout += payout;
            }

            // check if all the funds are released
            // check to prevent failing to send money halfway in loop
            // This require is not necessary, just in case
            require(profit == total_payout, "Not all funds are released");
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
        (bool st, ) = payable(msg.sender).call{value : msg.value-amount_need}("");
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

    // add owner to blacklist if not return enough profit
    address[] blacklist;
    function punish(address owner) public {
        // require(msg.sender==address(this),"This function can only be called by contract.");
        blacklist.push(owner);
    }

    function calculateProfit(uint256 id) public view returns (uint256) {
        // to calculate how much money the owner need to add to campaign
        return campaigns[id].target*campaigns[id].expectedInterestRate/100 + campaigns[id].target;
    }


    function getDonators(uint256 _id)
        public
        view
        returns (address[] memory,uint256[] memory)
    {
        uint256 numberOfDonators = campaigns[_id].donators.length;
        uint256 [] memory amount = new uint256[](numberOfDonators);
        for (uint256 i = 0; i < numberOfDonators; i++) {
            amount[i] = campaigns[_id].donations[campaigns[_id].donators[i]];
        }
        return (campaigns[_id].donators,amount);  // TODO
    }
    
    function getCampaignsDetails() public view returns (
        address[] memory,
        string[] memory,
        string[] memory,
        uint256[] memory,
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
        uint256[] memory stages = new uint256[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            owners[i] = item.owner;
            titles[i] = item.title;
            descriptions[i] = item.description;
            targets[i] = item.target;
            deadlines[i] = item.deadline;
            amountCollecteds[i] = item.amountCollected;
            statuses[i] = item.status;
            stages[i] = item.current_stage;
        }

        return (
            owners,
            titles,
            descriptions,
            targets,
            deadlines,
            amountCollecteds,
            statuses,
            stages
        );
    }

    function getStatus(uint256 id)public view returns (string memory){

        if(campaigns[id].status == 1){return("Raising Fund");}
        else if(campaigns[id].status == 2){return("Fail: Fund Not Enough");}
        else if(campaigns[id].status == 3){return("Enough Fund and Voting");}
        else if(campaigns[id].status == 4){return("Fail: Vote to End");}
        else if(campaigns[id].status == 5){return("Campaign Finish, Owner Add Profit");}
        else if(campaigns[id].status == 6){return("Give Fund Back to Donators");}
        else{return("Status is not in the range");}
    }
//     If (status == 1 ) public returns{
// string _status = “raising fund”;
// return _status;
}

