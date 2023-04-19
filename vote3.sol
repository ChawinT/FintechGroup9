pragma solidity ^0.8.9;

import "./crowdfunding2.sol";


contract Vote is Crowdfunding {
    // ...

    function tmpMove2Voting(uint256 project_id) public {
        require(campaigns[project_id].status < 4, "Invalid project status.");
        require(msg.sender == campaigns[project_id].owner, "Only the owner of the campaign can move the status of project.");

        campaigns[project_id].status = 4;
        campaigns[project_id].votes[1].stage = 1;
    }

    // ...

    function moveNextStage(uint256 project_id) public {
        require(campaigns[project_id].status != 4, "Invalid project status.");

        uint256 stage = campaigns[project_id].votes[1].stage;
        if (stage == 4) {
            campaigns[project_id].status = 6; // 6 means the project reach the end with money and interest back.
        }

        // ...

        if (campaigns[project_id].votes[1].count >= campaigns[project_id].amountCollected / 2) {
            if (stage < 4) {
                campaigns[project_id].status = campaigns[project_id].status + 1;
            }
        } else {
            if (stage < 4) {
                campaigns[project_id].status = 5; // 5 means the project ends in half and return the rest money back.
            }
        }
    }

    // ...

    function stage_vote(uint256 project_id, uint256 stage) public {
        // require(!campaigns[project_id].votes[stage].voterAddrs[msg.sender], "Address has already voted.");
        // require(campaigns[project_id].status == 4, "Invalid project status.");

        campaigns[project_id].votes[stage].count += campaigns[project_id].donations[msg.sender];
        campaigns[project_id].votes[stage].voterAddrs[msg.sender] = true;
    }

    // ...

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
        require(isDonator(project_id, msg.sender), "The sender is not a donator.");
        // require(msg.sender == campaigns[project_id].owner, "Only the owner of the campaign can public the project.");

        bool vote_result = (campaigns[project_id].votes[stage].count > campaigns[project_id].amountCollected / 2);
        return vote_result;
    }

    function finishVoting(uint256 project_id, uint256 stage) public {
        // require time 
        bool result = getVotingResult(project_id, stage);
        if (result) {
            moveNextStage(project_id);
        } else {
            endProject(project_id);
        }
    }

    function endProject(uint256 project_id) private {
        campaigns[project_id].status = 5;
    }
}
