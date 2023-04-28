pragma solidity ^0.8.9;

import "./crowdfunding.sol";

contract Vote is Crowdfunding {
    function isFundsEnough(uint256 id)public view returns (bool){
        // check time before the deadline
        require(block.timestamp >= campaigns[id].deadline,"not reach the money raising deadline");
        return campaigns[id].target <= campaigns[id].amountCollected;
    }

// project status
// 0-create 
// 1-raising money   2-fail(because funds not enough)
// 3-enough money and voting     4-fail(vote to end)
// 5-finish and give money back with interest
// 6-campaign done

    function moveNextStage(uint256 project_id) public {

        uint256 stage = campaigns[project_id].current_stage;

        if((stage ==0)&& (campaigns[project_id].status==1)){
            campaigns[project_id].amountleft = campaigns[project_id].amountCollected;

            if (isFundsEnough(project_id)){                    // fund is enough
                // start the project
                campaigns[project_id].status = 3;
                // withdraw first stage amount of funds
                withdrawFunds(project_id, stage);       //
                // start voting 
                // record the start time
                campaigns[project_id].start_timestamp = block.timestamp;
            }else{
                // project fail at raising money
                campaigns[project_id].status = 2;
                // release all the funds collected
                releaseFunds(project_id,stage);
            }
            
        }else if((stage < 3)&& (campaigns[project_id].status==3)){  // stage 0,1,2 voting
            uint256 time = campaigns[project_id].start_timestamp;
            for (uint256 i = 0;i<=stage;i++){
                time += campaigns[project_id].timer[i]* 1 seconds;     //TODO: change minutes to days
            }
            require(block.timestamp > time,"voting has not reached the deadline");
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


    function stage_vote(uint256 project_id) public {
        uint256 stage = campaigns[project_id].current_stage;

        require(!campaigns[project_id].votes[stage].voterAddrs[msg.sender], "Address has already voted.");
        //check donators address
        require(isDonator(project_id, msg.sender), "The sender is not a donator.");
        //check time

        // require(campaigns[project_id].status == 4, "Invalid project status.");
        // require(stage == campaigns[project_id].currentstage);

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

    // function writeComment(uint256 id, string memory cmt) public {
    //     Campaign storage campaign = campaigns[id];
    //     require(msg.sender==campaign.owner,"only owner can write comment in voting process");
    //     // add comment in certain stage
    //     campaign.votes[campaign.current_stage].comment = cmt;
    // }
}
