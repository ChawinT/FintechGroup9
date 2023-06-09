import React, { useState, useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom';
import { ethers } from 'ethers';

import { useStateContext } from '../context';
import { CountBox, CustomButton, Loader } from '../components';
import { calculateBarPercentage, daysLeft } from '../utils';
import { thirdweb } from '../assets';

const CampaignDetails = () => {
  const { state } = useLocation();
  const navigate = useNavigate();
  const { donate, getDonations, contract, address } = useStateContext();

  const [isLoading, setIsLoading] = useState(false);
  const [amount, setAmount] = useState('');
  const [donators, setDonators] = useState([]);

  const remainingDays = daysLeft(state.deadline*1000);
  const unixTimestamp = state.stage3time;
  const milliseconds = unixTimestamp*1000; 
  const dateObject = new Date(milliseconds);
  console.log(dateObject)

  const fetchDonators = async () => {
    const data = await getDonations(state.pId);

    setDonators(data);
  }

  useEffect(() => {
    if(contract) fetchDonators();
  }, [contract, address])

  const handleDonate = async () => {
    setIsLoading(true);

    await donate(state.pId, amount); 

    navigate('/')
    setIsLoading(false);
  }

  return (
    <div>
      {isLoading && <Loader />}

      
      <div className="w-full flex md:flex-row flex-col mt-10 gap-[30px]">
        

        <div className="flex md:w-[150px]  flex-wrap justify-between gap-[10px]">
          <CountBox title="Days Left" value={remainingDays} />
          <CountBox title={`Raised of ${state.target}`} value={state.amountCollected} />
          <CountBox title="Total Backers" value={donators.length} />
          <CountBox title="Money will return" value={dateObject.toLocaleDateString("en-US")} />
        </div> 
        <div className="flex-1 flex-col">
          <img src={state.image} alt="campaign" className="w-full h-[410px] object-cover rounded-xl"/>
         
        </div>
       
      </div>

      



      

<div className="mt-[20px] flex flex-col p-4 bg-[#1c1c24] rounded-[60px]">
      <div className="mt-[60px] flex lg:flex-row flex-col gap-5">
        <div className="flex-[2] flex flex-col gap-[40px]">
          <div>
            <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">   Campaign Creator</h4>

            <div className="mt-[20px] flex flex-row items-center flex-wrap gap-[14px]">
              {/* <div className="w-[52px] h-[52px] flex items-center justify-center rounded-full bg-[#2c2f32] cursor-pointer">
                <img src={thirdweb} alt="user" className="w-[60%] h-[60%] object-contain"/>
              </div> */}
              <div>
                <h4 className="font-epilogue font-semibold text-[14px] text-white break-all">{state.owner}</h4>
              </div>
            </div>
          </div>

          <div>
            <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">Story</h4>

              <div className="mt-[20px]">
                <p className="font-epilogue font-normal text-[16px] text-[#808191] leading-[26px] text-justify">{state.description}</p>
              </div>
          </div>

          <div>
            <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">Donators</h4>

              <div className="mt-[20px] flex flex-col gap-4">
                {donators.length > 0 ? donators.map((item, index) => (
                  <div key={`${item.donator}-${index}`} className="flex justify-between items-center gap-4">
                    <p className="font-epilogue font-normal text-[16px] text-[#b2b3bd] leading-[26px] break-ll">{index + 1}. {item.donator}</p>
                    <p className="font-epilogue font-normal text-[16px] text-[#808191] leading-[26px] break-ll">{item.donation}</p>
                  </div>
                )) : (
                  <p className="font-epilogue font-normal text-[16px] text-[#808191] leading-[26px] text-justify">No donators yet. Be the first one!</p>
                )}
              </div>
          </div>
        </div>
</div>
        

        <div className="flex-1">
        <div className="mt-[20px] flex flex-col p-4 bg-[#873702] rounded-[60px]">
          <p className="font-epilogue fount-medium text-[20px] leading-[30px] text-center text-[#FFFFFF]">
            Fund the campaign
          </p>
          <div className="mt-[30px] ">
            <input 
              type="number"
              placeholder="ETH 0.1"
              step="0.01"
              className="w-full py-[10px] sm:px-[20px] px-[15px] outline-none border-[1px] border-[#FFFFFF] bg-transparent font-epilogue  text-[20px] leading-[30px] placeholder:text-[#FFFFFF] rounded-[30px]"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />

            <div>_</div>
            <CustomButton 
              btnType="button"
              title="Fund Campaign"
              styles="w-full bg-[#c46535] rounded-[30px]"
              handleClick={handleDonate}
            />
          </div>
        </div>
        </div>
      </div>
    </div>
  )
}

export default CampaignDetails