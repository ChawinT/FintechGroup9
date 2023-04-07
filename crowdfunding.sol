// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.15;

//contract to record all crowdfunding projects
contract CrowdFactory {
    address[] public publishedProjs;

    event Projectcreated(
        string projTitle,
        uint256 goalAmount,
        address indexed ownerWallet,
        address projAddress,
        uint256 indexed timestamp
        
    );

    function totalPublishedProjs() public view returns (uint256) {
        return publishedProjs.length;
    }

    function createProject(
        string memory projectTitle,
        uint256 projgoalAmount,
        string memory projDescript,
        address ownerWallet,
        uint256 projectDeadline,
        uint256 interestRate
    ) public {
        //initializing CrowdfundingProject contract
        CrowdfundingProject newproj = new CrowdfundingProject(
            //passing arguments from constructor function
            projectTitle,
            projgoalAmount,
            projDescript,
            ownerWallet,
            projectDeadline,
            interestRate
        );

        //pushing project address
        publishedProjs.push(address(newproj));

        //calling Projectcreated (event above)
        emit Projectcreated(
            projectTitle,
            projgoalAmount,
            msg.sender,
            address(newproj),
            block.timestamp
        );
    }
}

contract CrowdfundingProject {
    //defining state variables
    string public projTitle;
    string public projDescription;
    uint256 public goalAmount;
    uint256 public raisedAmount;
    address ownerWallet; //address where amount to be transferred
    uint256 public projectDeadline; // Unix timestamp
    uint256 public interestRate;

    event Funded(
        address indexed donar,
        uint256 indexed amount,
        uint256 indexed timestamp
    );

    constructor(
        string memory projectTitle,
        uint256 projgoalAmount,
        string memory projDescript,
        address ownerWallet_,
        uint256 projectDeadline_,
        uint256 interestRate_
    ) {
        //mapping values
        projTitle = projectTitle;
        goalAmount = projgoalAmount;
        projDescription = projDescript;
        ownerWallet = ownerWallet_;
        projectDeadline = projectDeadline_;
        interestRate = interestRate_;
    }

    //donation function
    function makeDonation() public payable {
        //if goal amount is achieved, close the proj
        require(goalAmount > raisedAmount, "GOAL ACHIEVED");

        //record walletaddress of donor
        (bool success, ) = payable(ownerWallet).call{value: msg.value}("");
        require(success, "VALUE NOT TRANSFERRED");

        //calculate total amount raised
        raisedAmount += msg.value;

        emit Funded(msg.sender, msg.value, block.timestamp);
    }

    function projectExpired() public view returns(bool) {
        return block.timestamp >= projectDeadline;
    }

    function repayInvestors() public {
        require(projectExpired(), "Project has not expired yet");

        // Calculate the interest amount to be paid
        uint256 interestAmount = ((raisedAmount * interestRate) / 100);

        // Calculate the total amount to be repaid
        uint256 totalAmount = raisedAmount + interestAmount;

        // Transfer the total amount to the investors
        (bool success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(success, "VALUE NOT TRANSFERRED");
    }
    
}