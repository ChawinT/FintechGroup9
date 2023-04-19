pragma solidity ^0.8.9;

contract Crowdfunding {
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline;
        uint256 amountCollected;
        // to change
        // uint256[] donations;
        address[] donators;
        mapping(address => uint256) donations;
        uint256 expectedInterestRate;
        mapping(uint => Voting) votes;
        uint256 status;
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
        campaign.expectedInterestRate = _expectedInterestRate;
        campaign.status = 0;

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
        (bool sent, ) = payable(campaign.owner).call{value: amount}("");
        if (sent) {
            campaign.amountCollected += amount;
        }
    }

    function withdrawFunds(uint256 _id, uint256 _amount) public payable {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.owner, "Only the owner of the campaign can withdraw funds.");
        require(campaign.amountCollected >= _amount, "Cannot withdraw more than the amount collected.");

        (bool sent, ) = payable(campaign.owner).call{value: _amount}("");

        require(sent, "Failed to send Ether.");

        campaign.amountCollected -= _amount;
    }

    function releaseFunds(uint256 _id) public payable {
        Campaign storage campaign = campaigns[_id];

        require(campaign.amountCollected >= campaign.target, "Target amount not reached.");
        require(block.timestamp >= campaign.deadline + 30 days, "Funds can only be released one month after the deadline.");

        for (uint256 i = 0; i < campaign.donators.length; i++) {
            address donator = campaign.donators[i];
            uint256 donation = campaign.donations[donator];

            uint256 payout = donation + donation * campaign.expectedInterestRate / 100;
            (bool sent, ) = payable(donator).call{value: payout}("");

            require(sent, "Failed to send Ether.");
        }

        require(campaign.amountCollected == 0, "Something Wrong");
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
    // struct CampaignDetails {
    //     address owner;
    //     string title;
    //     string description;
    //     uint256 target;
    //     uint256 deadline;
    //     uint256 amountCollected;
    //     address[] donators;
    //     uint256 expectedInterestRate;
    //     uint256 status;
    // }

    // function getCampaigns() public view returns (CampaignDetails[] memory) {
    //     CampaignDetails[] memory allCampaigns = new CampaignDetails[](numberOfCampaigns);

    //     for (uint256 i = 0; i < numberOfCampaigns; i++) {
    //         Campaign storage item = campaigns[i];

    //         allCampaigns[i] = CampaignDetails({
    //             owner: item.owner,
    //             title: item.title,
    //             description: item.description,
    //             target: item.target,
    //             deadline: item.deadline,
    //             amountCollected: item.amountCollected,
    //             donators: item.donators,
    //             expectedInterestRate: item.expectedInterestRate,
    //             status: item.status
    //         });
    //     }

    //     return allCampaigns;
    // }
    // function getCampaigns() public view returns (
    //     address[] memory, 
    //     string[] memory, 
    //     string[] memory, 
    //     uint256[] memory, 
    //     uint256[] memory, 
    //     uint256[] memory
    // ) {
    //     address[] memory owners = new address[](numberOfCampaigns);
    //     string[] memory titles = new string[](numberOfCampaigns);
    //     string[] memory descriptions = new string[](numberOfCampaigns);
    //     uint256[] memory targets = new uint256[](numberOfCampaigns);
    //     uint256[] memory deadlines = new uint256[](numberOfCampaigns);
    //     uint256[] memory amountCollecteds = new uint256[](numberOfCampaigns);

    //     for (uint256 i = 0; i < numberOfCampaigns; i++) {
    //         Campaign storage item = campaigns[i];

    //         owners[i] = item.owner;
    //         titles[i] = item.title;
    //         descriptions[i] = item.description;
    //         targets[i] = item.target;
    //         deadlines[i] = item.deadline;
    //         amountCollecteds[i] = item.amountCollected;
    //     }

    //     return (owners, titles, descriptions, targets, deadlines, amountCollecteds);
    // }

}