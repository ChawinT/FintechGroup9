
// export const useStateContext = () => useContext(StateContext);

import React, { useContext, createContext } from 'react';
// useContext allows the user to use the values from the context //
// createContext allow the user to create a new context //

import { useAddress, useContract, useMetamask, useContractWrite } from '@thirdweb-dev/react';
// useAddress provide the user ethereum address //
// useContract provide the interface for interacting with a smart contract //
// useMetamask allow user to connect to the Metamask wallet //
// useContractWrite allow the users to write a smart contract //

import { ethers } from 'ethers';
// ethers allows uset to interact with Ethereum //

import { EditionMetadataWithOwnerOutputSchema } from '@thirdweb-dev/sdk';
// EditionMetadataWithOwnerOutputSchema is a schema provided bt

const StateContext = createContext();
// Create a new React context

export const StateContextProvider = ({ children }) => {
    // const StateContextProvider = ({ children }) => allow the children components to access to the state data and functions defined in the context.

    //const { contract } = useContract('0xa0E66fc7c6855B0FCc5f07304A575843F9624fab'); // Change to your contract //
    const { contract } = useContract('0xF55Dd308A675a8a1Dd87B1614E9F2Fc77089a532');
    // useContract allow to retrieve the smart contract interface for the contract with the given address.

    const { mutateAsync: createCampaign } = useContractWrite(contract, 'createCampaign');
    const { mutateAsync: stage_vote } = useContractWrite(contract, 'stage_vote');
    // const { mutateAsync: donateToCampaign } = useContractWrite(contract, 'donateToCampaign');
    const { mutateAsync: ownerAddToCampaign } = useContractWrite(contract, 'ownerAddToCampaign');
    const { mutateAsync: loopMoveNextStage } = useContractWrite(contract, 'loopMoveNextStage');
    // By using object destructuring syntax, this line of code extracts the mutateAsync function from the object and assigns it to the createCampaign variable //
    // This allows the createCampaign variable to be used as a standalone function that can be called to interact with the createCampaign function on the blockchain. //
    // In other words, createCampaign is a function that is used to call the createCampaign function on the smart contract associated with the contract variable. //
    // The mutateAsync function that it is extracting is a function provided by useContractWrite that allows you to asynchronously update the smart contract data on the blockchain. //

    const address = useAddress();
    const connect = useMetamask();
    // useAddress allow user to retreive the user's ethereum address //
    // useMetamask allow user to connect to their Metamask wallet //

    const publishCampaign = async (form) => { // async with await
        //console.log(address)
        console.log(form.title)
        console.log(form.description)
        console.log(form.target)
        console.log(form.deadline)
        console.log(form.expectedInterestRate)
        console.log(form.stage0time)
        console.log(form.stage1time)
        console.log(form.stage2time)
        console.log(form.stage3time)
        console.log(form.image)
        // console.log statements are used to log various properties of the form object and the address variable to the console. //

        // console.log(form.expectedInterestRate)
        // console.log(form.stage0time)
        // console.log(form.stage1time)
        // console.log(form.stage2time)
        // console.log(form.stage3time)


        try {
            const data = await createCampaign({
                args: [
                    //address, // owner
                    form.title, // title
                    form.description, // description
                    form.target,
                    new Date(form.deadline).getTime()/1000, // deadline // .getTime convert the time to Unix timestamp
                    form.expectedInterestRate,
                    new Date(form.stage0time).getTime()/1000, // 
                    new Date(form.stage1time).getTime()/1000, // 
                    new Date(form.stage2time).getTime()/1000, // 
                    new Date(form.stage3time).getTime()/1000, // 
                    form.image

                ]
            })

            console.log("contract call success", data)
        } catch (error) {
            console.log("contract call failure", error)
        }
    }

    const getAllCampaigns = async () => {

        const [
            imgs,
            interests,
            stage0time,
            stage1time,
            stage2time,
            stage3time,
            amountLefts,
            profits
        ]
            = await contract.call('getCampaignsDetailsImage');
        console.log(imgs)

        const [
            owners,
            titles,
            descriptions,
            targets,
            deadlines,
            amountCollecteds,
            statuses,
            stages,
        ] = await contract.call('getCampaignsDetails');

    
        const parsedCampaigns = owners.map((owner, i) => ({
            owner,
            title: titles[i],
            description: descriptions[i],
            target: ethers.utils.formatEther(targets[i].toString()),
            deadline: deadlines[i].toNumber(),
            amountCollected: ethers.utils.formatEther(amountCollecteds[i].toString()),
            status: statuses[i].toNumber(),
            currentStage: stages[i].toNumber(),
            pId: i,
            image: imgs[i],
            interest: interests[i].toNumber(),
            stage0time: stage0time[i].toNumber(),
            stage1time: stage1time[i].toNumber(),
            stage2time: stage2time[i].toNumber(),
            stage3time: stage3time[i].toNumber()
        }));
        //const move = await loopMoveNextStages();
        console.log("asdfasdfasdfasdfasdf")
        return parsedCampaigns;
    }

    const getCampaigns = async () => {

        const [
            imgs,
            interests,
            stage0time,
            stage1time,
            stage2time,
            stage3time,
            amountLefts,
            profits
        ]
            = await contract.call('getCampaignsDetailsImage');
        console.log(imgs)

        const [
            owners,
            titles,
            descriptions,
            targets,
            deadlines,
            amountCollecteds,
            statuses,
            stages,
        ] = await contract.call('getCampaignsDetails');

        console.log('status', statuses)
        console.log('stage', stages)
        console.log('aaa', interests)
        const parsedCampaigns = owners.map((owner, i) => ({
            owner,
            title: titles[i],
            description: descriptions[i],
            target: ethers.utils.formatEther(targets[i].toString()),
            deadline: deadlines[i].toNumber(),
            amountCollected: ethers.utils.formatEther(amountCollecteds[i].toString()),
            status: statuses[i].toNumber(),
            currentStage: stages[i].toNumber(),
            pId: i,
            image: imgs[i],
            interest: interests[i].toNumber(),
            stage0time: stage0time[i].toNumber(),
            stage1time: stage1time[i].toNumber(),
            stage2time: stage2time[i].toNumber(),
            stage3time: stage3time[i].toNumber()
        }));
        //const move = await loopMoveNextStages();
        console.log("asdfasdfasdfasdfasdf")
        const filteredCampaigns = parsedCampaigns.filter((campaign) => (campaign.currentStage === 0 && campaign.status === 1));
        return filteredCampaigns;
    }

    const getUserCampaigns = async () => {
        const allCampaigns = await getAllCampaigns();
        

        const filteredCampaigns = allCampaigns.filter((campaign) => campaign.owner === address);

        return filteredCampaigns;
    }

    const getUserCampaignsReturn = async () => {
        const allCampaigns = await getAllCampaigns();

        const filteredCampaigns = allCampaigns.filter((campaign) => (campaign.owner === address && campaign.currentStage === 3 && campaign.status === 5));

        return filteredCampaigns;
    }

    const getUserCampaignsVote = async () => {
        const allCampaigns = await getAllCampaigns();
        const CampaignsDonated = [];

        const ListparsedDonations = [];
        for (let i = 0; i < allCampaigns.length; i++) {
            const pId = allCampaigns[i].pId;
            console.log('pId:', pId);
            console.log(address)
            const donations = await contract.call('getDonators', [pId]);
            const per = await getVoterPercentage([pId])
            console.log("Percentage",per)
            //console.log(per)
            const numberOfDonations = donations[0].length;
            const parsedDonations = [];
            console.log(donations[0]);
            if (donations[0].includes(address)) {
                console.log('In');
                console.log(allCampaigns[i])
                allCampaigns[i].votePercentage = per;
                CampaignsDonated.push(allCampaigns[i]);
            }

            else { console.log('Out') }
        }

        for (let i = 0; i < ListparsedDonations.length; i++) {
            const list = ListparsedDonations[i];
            console.log('List: ', list);
        }
        const filteredCampaigns = CampaignsDonated.filter((campaign) => (((campaign.currentStage === 0) ||(campaign.currentStage === 1) || (campaign.currentStage === 2)) && campaign.status === 3));
       // const filteredCampaigns = allCampaigns.filter((campaign) => campaign.owner === address);
        return filteredCampaigns;
    }

    // Link with Solidity Function donateToCampaing //
    const donate = async (pId, amount) => {
        console.log(pId)
        console.log(amount)
        //const data = await contract.call('donateToCampaign', pId, { value: ethers.utils.parseEther(amount)});
        const data = await contract.call('donateToCampaign', [pId], { value: ethers.utils.parseEther(amount) });

        return data;
    }

    const getDonations = async (pId) => {
        console.log(pId)
        const donations = await contract.call('getDonators', [pId]);
        const numberOfDonations = donations[0].length;

        const parsedDonations = [];

        for (let i = 0; i < numberOfDonations; i++) {
            parsedDonations.push({
                donator: donations[0][i],
                donation: ethers.utils.formatEther(donations[1][i].toString())
            })
        }

        return parsedDonations;
    }

    // Return Status of the project //
    const getStatus = async (pId) => {
        console.log(pId)
        const status = await contract.call("getStatus", [pId]);

        return status
    }

    // Withdraw the money to the owner of the project //
    const withdraw = async (pId, stage) => {
        console.log(pId)
        console.log(stage)

        const withdrawFund = await contract.call("withdrawFunds", [pId, stage]);

        return withdrawFund;
    }

    // Donate the rest of the money //
    const donateRestMoney = async (pId, amount) => {
        console.log(pId)
        console.log(amount)

        const restMoney = await contract.call("donateRestMoney", [pId], { value: ethers.utils.parseEther(amount) });

        return restMoney;
    }

    // Release Fund back to the donators //
    const releaseFund = async (pId, stage) => {
        console.log(pId)
        console.log(stage)

        const releaseMoney = await contract.call("releaseFunds", [pId, stage]);

        return releaseMoney;
    }

    const stageVote = async (pId) => { // async with await
        try {
            const data = await stage_vote({
                args: [pId]
            })
            console.log("contract call success", data)
        } catch (error) {
            console.log("contract call failure", error)
        }
    }


    const ownerAddToCampaignCall = async (pId, amount) => {
        console.log(pId)
        console.log("Hererere")
        console.log(amount)
        //const data = await contract.call('donateToCampaign', pId, { value: ethers.utils.parseEther(amount)});
        const data = await contract.call('ownerAddToCampaign', [pId], { value: ethers.utils.parseEther(amount.toString()) });

        return data;
    }

    // const ownerAddToCampaign = async (pId,value) => { // async with await
    //     try {
    //         const data = 
            
    //         await ownerAddToCampaign({
    //             args: [pId,{ value: ethers.utils.parseEther(value) }]
    //         })
    //         console.log("contract call success", data)
    //     } catch (error) {
    //         console.log("contract call failure", error)
    //     }
    // }

    const getVoterPercentage = async (pId) => {

        console.log(pId)

        // const current_stage = await contract.call('getCurrentStage', [pId]);
        const voter_amount = await contract.call('getVoterAmount', [pId]);
        const target = await contract.call('getTarget', [pId]);
        const percentage = voter_amount * 100 / target;
        console.log("in get vote", percentage)
        // const stage_vote_percentage = "stage " + current_stage + " vote for " + percentage + "%";
        return percentage;
    }

    const getStageDeadline = async (pId) => {
        console.log(pId)

        const deadline_list = await contract.call('getDeadline', [pId]);
        const stage_deadline_list = {};

        for (let i = 0; i < 4; i++) {
            stage_deadline_list[i] = "stage " + i + " deadline " + new Date(deadline_list[i] * 1000);
        }

        return stage_deadline_list;
    }

    const loopMoveNextStages = async () => { // async with await
        try {
            const data = await loopMoveNextStage();
            console.log("contract call success", data)
        } catch (error) {
            console.log("contract call failure", error)
        }
    }

    return (
        <StateContext.Provider
            value={{
                address,
                contract,
                connect,
                createCampaign: publishCampaign, // Return the value from 
                getCampaigns,
                getAllCampaigns,
                getUserCampaigns,
                getUserCampaignsReturn,
                getUserCampaignsVote,
                donate, // Pass Donate Function to contract //
                donateRestMoney, // Donate the rest of money //
                getDonations,
                getStatus, // Get the stutus of the project //
                withdraw, // Withdraw fund to the project owner //
                releaseFund, // Release the fund back to the donator //
                stageVote,
                ownerAddToCampaignCall,
                getVoterPercentage,
                getStageDeadline,
                loopMoveNextStages
            }}
        >
            {children}
        </StateContext.Provider>
    )
}

export const useStateContext = () => useContext(StateContext);