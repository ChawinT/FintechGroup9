
import React, { useState, useEffect } from 'react'

import { DisplayCampaignsVote } from '../components';
import { useStateContext } from '../context'

const Vote = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [campaigns, setCampaigns] = useState([]);

  const { address, contract, getUserCampaignsVote } = useStateContext();

  const fetchCampaigns = async () => {
    setIsLoading(true);
    const data = await getUserCampaignsVote();
    setCampaigns(data);
    setIsLoading(false);
  }

  useEffect(() => {
    if(contract) fetchCampaigns();
  }, [address, contract]);

  return (
    <DisplayCampaignsVote 
      title="Campaigns To Vote"
      isLoading={isLoading}
      campaigns={campaigns}
    />
  )
}

export default Vote