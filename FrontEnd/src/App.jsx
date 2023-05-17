import React from 'react';
import { Route, Routes } from 'react-router-dom';

import { Sidebar, Navbar } from './components';
import { CampaignDetails, CreateCampaign, Home, Profile,Vote, CampaignDetailsVote,ReturnMoney,CampaignDetailsReturn } from './pages';



const App = () => {
  return (
    <div className="relative sm:-8 p-4 bg-[#3C393A] min-h-screen flex flex-row">
      <div className="flex-1 max-sm:w-full max-w-[1280px] mx-auto sm:pr-5">
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/create-campaign" element={<CreateCampaign />} />
          <Route path="/campaign-details/:id" element={<CampaignDetails />} />
          <Route path="/vote" element={<Vote />} />
          <Route path="/returnMoney" element={<ReturnMoney />} />
          <Route path="/CampaignDetailsVote/:id" element={<CampaignDetailsVote />} />
          <Route path="/CampaignDetailsReturn/:id" element={<CampaignDetailsReturn />} />
        </Routes>
      </div>
      
      {/* <div className="sm:flex hidden mr-10">

        <Sidebar />
      </div> */}

      
    </div>
  )
}

export default App