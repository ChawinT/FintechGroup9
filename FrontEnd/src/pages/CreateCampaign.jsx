import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom';
import { ethers } from 'ethers';

import { useStateContext } from '../context';
import { money } from '../assets';
import { CustomButton, FormField, Loader } from '../components';
import { checkIfImage } from '../utils';

const CreateCampaign = () => {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const { createCampaign } = useStateContext();
  const [form, setForm] = useState({
    name: '',
    title: '',
    description: '',
    target: '',
    deadline: '',
    expectedInterestRate: '',
    stage0time: '',
    stage1time: '',
    stage2time: '',
    stage3time: '',
    image: ''
  });

  const handleFormFieldChange = (fieldName, e) => {
    setForm({ ...form, [fieldName]: e.target.value })
  }

  const handleSubmit = async (e) => {
    e.preventDefault();

    checkIfImage(form.image, async (exists) => {
      if (exists) {
        setIsLoading(true)
        await createCampaign({ ...form, target: ethers.utils.parseUnits(form.target, 18)})
        setIsLoading(false);
        navigate('/');
      } else {
        alert('Provide valid image URL')
        setForm({ ...form, image: '' });
      }
    })
  }

  return (
    <div className="bg-[#1c1c24] flex justify-center items-center flex-col rounded-[10px] sm:p-10 p-4">
      {isLoading && <Loader />}
      <div className="flex justify-center items-center p-[16px] sm:min-w-[380px] bg-[#3a3a43] rounded-[10px]">
        <h1 className="font-epilogue font-bold sm:text-[25px] text-[18px] leading-[38px] text-white">Start a Campaign</h1>
      </div>

      <form onSubmit={handleSubmit} className="w-full mt-[65px] flex flex-col gap-[30px]">
        <div className="flex flex-wrap gap-[40px]">
          <FormField
            labelName="Your Name *"
            placeholder="Name"
            inputType="text"
            value={form.name}
            handleChange={(e) => handleFormFieldChange('name', e)}
          />
          <FormField
            labelName="Campaign Title *"
            placeholder="Title"
            inputType="text"
            value={form.title}
            handleChange={(e) => handleFormFieldChange('title', e)}
          />
        </div>

        <FormField
          labelName="Story *"
          placeholder="Write a story of your project" 
          isTextArea
          value={form.description}
          handleChange={(e) => handleFormFieldChange('description', e)}
        />



        <div className="flex flex-wrap gap-[40px]">
          <FormField
            labelName="Goal *"
            placeholder="ETH 0.50"
            inputType="text"
            value={form.target}
            handleChange={(e) => handleFormFieldChange('target', e)}
          />
          <FormField
            labelName="Interest Rate"
            placeholder="20(%)"
            inputType="number"
            value={form.expectedInterestRate}
            handleChange={(e) => handleFormFieldChange('expectedInterestRate', e)}
          />
          <FormField
            labelName="End Date of Crowd Funding (30% of Money will be released after enough funding)*"
            placeholder="End Date"
            inputType="date"
            value={form.deadline}
            handleChange={(e) => handleFormFieldChange('deadline', e)}
          />
        </div>

        <FormField
          labelName="Campaign Image *"
          placeholder="Place image URL of your campaign"
          inputType="url"
          value={form.image}
          handleChange={(e) => handleFormFieldChange('image', e)}
        />

        <div className="flex flex-wrap gap-[40px]">
          <FormField
            labelName="Deadine of First Vote (30% Money)"
            placeholder="End Date"
            inputType="date"
            value={form.stage0time}
            handleChange={(e) => handleFormFieldChange('stage0time', e)}
          />
          <FormField
            labelName="Deadine of Second Vote (30% Money)"
            placeholder="End Date"
            inputType="date"
            value={form.stage1time}
            handleChange={(e) => handleFormFieldChange('stage1time', e)}
          />
        </div>
        <div className="flex flex-wrap gap-[40px]">
          <FormField
            labelName="Deadine of Third Vote (10% Money)"
            placeholder="End Date"
            inputType="date"
            value={form.stage2time}
            handleChange={(e) => handleFormFieldChange('stage2time', e)}
          />
          <FormField
            labelName="Deadline of Return Money + Interest Rate"
            placeholder="End Date"
            inputType="date"
            value={form.stage3time}
            handleChange={(e) => handleFormFieldChange('stage3time', e)}
          />
        </div>

        <div className="flex justify-center items-center mt-[40px]">
          <CustomButton
            btnType="submit"
            title="Submit new campaign"
            styles="bg-[#1dc071]"
          />
        </div>
      </form>
    </div>
  )
}

export default CreateCampaign