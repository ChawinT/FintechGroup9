import React, { useState, useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom';
import { ethers } from 'ethers';

import { useStateContext } from '../context';
import { CountBox, CustomButton, Loader } from '../components';
import { calculateBarPercentage, daysLeft } from '../utils';
import { thirdweb } from '../assets';

const CampaignDetailsReturn = () => {
  const { state } = useLocation();
  const navigate = useNavigate();
  const { getDonations, contract, address,ownerAddToCampaignCall } = useStateContext();

  const [isLoading, setIsLoading] = useState(false);
  const [amount, setAmount] = useState('');
  const [donators, setDonators] = useState([]);

  const remainingDays = daysLeft(state.deadline);

  const fetchDonators = async () => {
    const data = await getDonations(state.pId);

    setDonators(data);
  }

  useEffect(() => {
    if(contract) fetchDonators();
  }, [contract, address])

  const handleownerAddToCampaign = async () => {
  
    console.log('amount')
    const amount = (1+(state.interest/100))*state.target;
  
    console.log(amount)
    setIsLoading(true);
    
    await ownerAddToCampaignCall(state.pId, amount); 
    navigate('/')
    setIsLoading(false);
  }

  return (
    <div>
      {isLoading && <Loader />}

      <div className="w-full flex md:flex-row flex-col mt-10 gap-[30px]">
        <div className="flex-1 flex-col">
          <img src={state.image} alt="campaign" className="w-full h-[410px] object-cover rounded-xl"/>
          <div className="relative w-full h-[5px] bg-[#3a3a43] mt-2">
            <div className="absolute h-full bg-[#4acd8d]" style={{ width: `${calculateBarPercentage(state.target, state.amountCollected)}%`, maxWidth: '100%'}}>
            </div>
          </div>
        </div>

        
      </div>

      <div className="mt-[60px] flex lg:flex-row flex-col gap-5">
        <div className="flex-[2] flex flex-col gap-[40px]">
          <div>
            <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">Campaign Creator</h4>

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
            <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">Return Money Stage</h4>

        
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

        <div className="flex-1">
          <h4 className="font-epilogue font-semibold text-[18px] text-white uppercase">  Money that you need to return </h4>   

          <div className="mt-[20px] flex flex-col p-4 bg-[#1c1c24] rounded-[10px]">
            <p className="font-epilogue fount-medium text-[20px] leading-[30px] text-center text-[#808191]">
            {/* {state.target} + Interest(10%) + {state.interest} =  */}
            {state.target} + Interest rate {state.interest}% = {Math.round((1+(state.interest/100))*state.target*1000)/1000}
            
            </p>
            <div className="mt-[30px]">
              

              {/* <div className="my-[20px] p-4 bg-[#13131a] rounded-[10px]">
                <h4 className="font-epilogue font-semibold text-[14px] leading-[22px] text-white">Back it because you believe in it.</h4>
                <p className="mt-[20px] font-epilogue font-normal leading-[22px] text-[#808191]">Support the project for no reward, just because it speaks to you.</p>
              </div> */}
              <div>_</div>
              <CustomButton 
                btnType="button"
                title="Return Money to Donators"
                styles="w-full bg-[#c46535]"
                handleClick={handleownerAddToCampaign}
              />
            </div>
          </div>
        </div>

       
      </div>
    </div>
  )
}

export default CampaignDetailsReturn