
import React, { useState, useEffect } from 'react'

import { DisplayCampaignsReturn } from '../components';
import { useStateContext } from '../context'

const ReturnMoney = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [campaigns, setCampaigns] = useState([]);

  const { address, contract, getUserCampaignsReturn } = useStateContext();

  const fetchCampaigns = async () => {
    setIsLoading(true);
    const data = await getUserCampaignsReturn();
    setCampaigns(data);
    setIsLoading(false);
  }

  useEffect(() => {
    if(contract) fetchCampaigns();
  }, [address, contract]);

  return (
    <DisplayCampaignsReturn
      title="Campaign that you need to Return (Money + Interest Rate)"
      isLoading={isLoading}
      campaigns={campaigns}
    />
  )
}

export default ReturnMoney