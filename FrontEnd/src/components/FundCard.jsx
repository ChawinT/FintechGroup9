import React from 'react';

import { tagType, thirdweb } from '../assets';
import { daysLeft } from '../utils';

const FundCard = ({ owner, title, description, target, deadline, amountCollected, image, handleClick,stage3time }) => {
  const remainingDays = daysLeft(deadline*1000);
  const unixTimestamp = stage3time;
  const milliseconds = unixTimestamp*1000; 
  const dateObject = new Date(milliseconds);
  console.log(dateObject)
  
  return (
    <div className="sm:w-[288px] w-full rounded-[15px] bg-[#000000] cursor-pointer" onClick={handleClick}>
      <img src={image} alt="fund" className="w-full h-[158px] object-cover rounded-[15px]"/>

      <div className="flex flex-col p-4">
      

        <div className="block">
          <h3 className="font-epilogue font-semibold text-[#c46535] text-[16px] text-white text-left leading-[26px] truncate">{title}</h3>
          <p className="mt-[5px] font-epilogue font-normal text-[#808191] text-left leading-[18px] truncate">{description}</p>
        </div>

        <div className="flex justify-between flex-wrap mt-[15px] gap-2">
          <div className="flex flex-col">
            <h4 className="font-epilogue font-semibold text-[14px] text-[#b2b3bd] leading-[22px]">{amountCollected}</h4>
            <p className="mt-[3px] font-epilogue font-normal text-[12px] leading-[18px] text-[#808191] sm:max-w-[120px] truncate">Raised of {target}</p>
          </div>
          <div className="flex flex-col">
            <h4 className="font-epilogue font-semibold text-[14px] text-[#b2b3bd] leading-[22px]">{remainingDays}</h4>
            <p className="mt-[3px] font-epilogue font-normal text-[12px] leading-[18px] text-[#808191] sm:max-w-[120px] truncate">Days Left to raise fund</p>
          </div>
          <div className="flex flex-col">
            <h4 className="font-epilogue font-semibold text-[14px] text-[#b2b3bd] leading-[22px]">{dateObject.toDateString()}</h4>
            <p className="mt-[3px] font-epilogue font-normal text-[12px] leading-[18px] text-[#808191] sm:max-w-[120px] truncate">Date expected money return: </p>
          </div>
        </div>

        <div className="flex items-center mt-[20px] gap-[12px]">
     
          <p className="flex-1 font-epilogue font-normal text-[12px] text-[#808191] truncate">Campaign owner: <span className="text-[#b2b3bd]">{owner}</span></p>
        </div>
      </div>
    </div>
  )
}

export default FundCard