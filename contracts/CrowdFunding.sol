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

        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(_deadline>0, "The deadline should be a date in the future.");

        campaign.owner = msg.sender;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
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

            user_campaign_lists[msg.sender].push(_id);

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
            uint256 interestRate = campaign.expectedInterestRate;
            uint256 total_payout = 0;
            for (uint256 i = 0; i < campaign.donators.length; i++) {
                address donator = campaign.donators[i];
                uint256 donation = campaign.donations[donator];
                uint256 payout =  ((interestRate+100)/100) * donation;
                (bool sent, ) =payable(donator).call{value: payout}("");
                require(sent, "Failed to send Ether.");
                total_payout += payout;
            }

            // check if all the funds are released
            // check to prevent failing to send money halfway in loop
            // This require is not necessary, just in case
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

    function getCampaignsDetailsImage() public view returns(
        string[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory

    ){
        string[] memory imgs = new string[](numberOfCampaigns);
        uint256[] memory interests = new uint256[](numberOfCampaigns);
        uint256[] memory stage0time = new uint256[](numberOfCampaigns);
        uint256[] memory stage1time = new uint256[](numberOfCampaigns);
        uint256[] memory stage2time = new uint256[](numberOfCampaigns);
        uint256[] memory stage3time = new uint256[](numberOfCampaigns);
        uint256[] memory amountLefts = new uint256[](numberOfCampaigns);
        uint256[] memory profits = new uint256[](numberOfCampaigns);


        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            imgs[i] = item.img;
            interests[i] = item.expectedInterestRate;
            stage0time[i] = item.timer[0];
            stage1time[i] = item.timer[1];
            stage2time[i] = item.timer[2];
            stage3time[i] = item.timer[3];
            amountLefts[i] = item.amountleft;
            profits[i] = item.profit;

        }
        return (
            imgs,
            interests,
            stage0time,
            stage1time,
            stage2time,
            stage3time,
            amountLefts,
            profits
        );
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
        // string[] memory
    ) {
        address[] memory owners = new address[](numberOfCampaigns);
        string[] memory titles = new string[](numberOfCampaigns);
        string[] memory descriptions = new string[](numberOfCampaigns);
        uint256[] memory targets = new uint256[](numberOfCampaigns);
        uint256[] memory deadlines = new uint256[](numberOfCampaigns);
        uint256[] memory amountCollecteds = new uint256[](numberOfCampaigns);
        uint256[] memory statuses = new uint256[](numberOfCampaigns);
        uint256[] memory stages = new uint256[](numberOfCampaigns);
        // string[] memory images = new string[](numberOfCampaigns);

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
            // images[i] = item.img;
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
            // images
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
    

    mapping(address => uint256[]) user_campaign_lists;


    // return the campaign that the donator can vote 
    function getUserCampaign(address useraddr) public view returns(uint256 [] memory){
        return user_campaign_lists[useraddr];
    }

    function getDonateCampaignDetail(address userAdd) public view returns(
        string[] memory,
        string[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ){
        uint256[] memory projectList = getUserCampaign(userAdd);

        string[] memory titles = new string[](numberOfCampaigns);
        string[] memory descriptions = new string[](numberOfCampaigns);
        uint256[] memory targets = new uint256[](numberOfCampaigns);
        uint256[] memory deadlines = new uint256[](numberOfCampaigns);
        uint256[] memory amountCollecteds = new uint256[](numberOfCampaigns);
        uint256[] memory statuses = new uint256[](numberOfCampaigns);
        uint256[] memory stages = new uint256[](numberOfCampaigns);

        for (uint256 i = 0; i < projectList.length; i++) {
            Campaign storage item = campaigns[i];

            titles[i] = item.title;
            descriptions[i] = item.description;
            targets[i] = item.target;
            deadlines[i] = item.deadline;
            amountCollecteds[i] = item.amountCollected;
            statuses[i] = item.status;
            stages[i] = item.current_stage;
        }

         return (
            titles,
            descriptions,
            targets,
            deadlines,
            amountCollecteds,
            statuses,
            stages
            // images
        );
    }


    function isFundsEnough(uint256 id)public view returns (bool){
        // check time before the deadline
        // require(block.timestamp >= campaigns[id].deadline,"not reach the money raising deadline");
        return campaigns[id].target <= campaigns[id].amountCollected;
    }

    function moveNextStage(uint256 project_id) public {

        uint256 stage = campaigns[project_id].current_stage;

        if((stage ==0)&& (campaigns[project_id].status==1)){
            campaigns[project_id].amountleft = campaigns[project_id].amountCollected;
            if(block.timestamp >= campaigns[project_id].deadline){
                if (isFundsEnough(project_id)){                    // fund is enough
                    // start the project
                    campaigns[project_id].status = 3;
                    // withdraw first stage amount of funds
                    withdrawFunds(project_id, stage);       //
                    // start voting 
                    // record the start time
                    // campaigns[project_id].start_timestamp = block.timestamp;
                }else{
                    // project fail at raising money
                    campaigns[project_id].status = 2;
                    // release all the funds collected
                    releaseFunds(project_id,stage);
                }
            }   
        }else if((stage < 3)&& (campaigns[project_id].status==3)){  // stage 0,1,2 voting
            // uint256 time = campaigns[project_id].start_timestamp;
            // for (uint256 i = 0;i<=stage;i++){
            //     time += campaigns[project_id].timer[i]* 1 seconds;     //TODO: change minutes to days
            // }
            uint256 i = campaigns[project_id].current_stage;
            require(block.timestamp > campaigns[project_id].timer[i],"voting has not reached the deadline");
            if(getVotingResult(project_id, stage)){
                // project contine and withdraw the part of funds to project owner
                campaigns[project_id].current_stage += 1;
                stage = campaigns[project_id].current_stage;
                withdrawFunds(project_id, stage);
            }else{
                // vote to end the project and release the rest of funds
                campaigns[project_id].status = 4;
                releaseFunds(project_id,stage);
            }
        }else if((stage == 3)&&(campaigns[project_id].status==3)){   // last stage, no votings
            require(block.timestamp>=campaigns[project_id].deadline,"stage 3 has not reached the deadline");
            campaigns[project_id].status = 5;

        }else if((stage == 3)&&campaigns[project_id].status==5){     // release funds after project finish and with interest rate

            // require after owner add the profit to campaign
            uint256 expect = campaigns[project_id].target*(campaigns[project_id].expectedInterestRate/100)+campaigns[project_id].target;
            if(campaigns[project_id].profit < expect){    // if profit is less than owner promised
                // add owner to blacklist
                punish(campaigns[project_id].owner);
            }
            // then release the fund 
            releaseFunds(project_id, stage);
            campaigns[project_id].status = 6;
        }
    }

    function loopMoveNextStage() public {
        for (uint256 i=0; i < numberOfCampaigns; i++){
            moveNextStage(i);
        }
    }

    function stage_vote(uint256 project_id) public {
        uint256 stage = campaigns[project_id].current_stage;

        require(!campaigns[project_id].votes[stage].voterAddrs[msg.sender], "Address has already voted.");
        //check donators address
        require(isDonator(project_id, msg.sender), "The sender is not a donator.");

        campaigns[project_id].votes[stage].count += campaigns[project_id].donations[msg.sender];
        campaigns[project_id].votes[stage].voterAddrs[msg.sender] = true;
    }

    function writeComment(uint256 id, string memory cmt)public {
        require(msg.sender == campaigns[id].owner,"only owner can set the comment");
        campaigns[id].votes[campaigns[id].current_stage].comment = cmt;
    }

    function getComment(uint256 id,uint256 stage) public view returns (string memory){
        return campaigns[id].votes[stage].comment;
    }


    function isDonator(uint256 project_id, address user) public view returns (bool) {
        Campaign storage campaign = campaigns[project_id];
        for (uint256 i = 0; i < campaign.donators.length; i++) {
            if (campaign.donators[i] == user) {
                return true;
            }
        }
        return false;
    }

    function getVotingResult(uint256 project_id, uint256 stage) public view returns (bool) {
        // require donators to view the voting results
        // require(isDonator(project_id, msg.sender), "The sender is not a donator.");
        // require(msg.sender == campaigns[project_id].owner, "Only the owner of the campaign can public the project.");
        bool vote_result = (campaigns[project_id].votes[stage].count > campaigns[project_id].target / 2);
        return vote_result;
    }

}