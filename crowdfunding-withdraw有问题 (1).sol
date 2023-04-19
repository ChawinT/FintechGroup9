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
        //string image;
        address[] donators;
        uint256[] donations;
        uint256 expectedInterestRate;
    }

    mapping(uint256 => Campaign) public campaigns;

    uint256 public numberOfCampaigns = 0;

    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        //string memory _image,
        uint256 _expectedInterestRate
    ) public returns (uint256) {

        //uint256 day = 1 days; 
        uint256 minute = 1 minutes;

        Campaign storage campaign = campaigns[numberOfCampaigns];

        //require(_deadline > block.timestamp, "The deadline should be a date in the future.");
        require((_deadline * minute) + block.timestamp > block.timestamp, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = (_deadline * minute) + block.timestamp;
        campaign.amountCollected = 0;
        //campaign.image = _image;
        campaign.expectedInterestRate = _expectedInterestRate;

        numberOfCampaigns++;

        return numberOfCampaigns - 1;
    }

    function donateToCampaign(uint256 _id)public payable {
        uint256 amount = msg.value;


        Campaign storage campaign = campaigns[_id];

        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);

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
        payable(msg.sender).transfer(_amount);
    }

    function releaseFunds(uint256 _id) public payable {
        Campaign storage campaign = campaigns[_id];
        
        require(campaign.amountCollected >= campaign.target, "Target amount not reached.");
        require(block.timestamp >= campaign.deadline + 30 days, "Funds can only be released one month after the deadline.");
        
        //uint256 totalFunds = campaign.amountCollected;
        //uint256 interest = totalFunds * campaign.expectedInterestRate / 100;
        
        for (uint256 i = 0; i < campaign.donators.length; i++) {
            address donator = campaign.donators[i];
            uint256 donation = campaign.donations[i];
            
            uint256 payout = donation + donation * campaign.expectedInterestRate / 100 ;
            (bool sent, ) = payable(donator).call{value: payout}("");
            
            require(sent, "Failed to send Ether.");
        }
        
        //(bool sent, ) = payable(campaign.owner).call{value: interest}("");
        
        //require(sent, "Failed to send Ether.");
        
        //campaign.amountCollected = 0; // may be check the amount of money is equal to 0 or not after we pay all the money to donator //

        require(campaign.amountCollected == 0, "Something Wrong");
    }
    function getDonators(uint256 _id)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint256 i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
}