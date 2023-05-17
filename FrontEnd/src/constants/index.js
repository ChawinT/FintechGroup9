import { createCampaign, dashboard, logout, payment, profile, withdraw } from '../assets';

export const navlinks = [
  {
    name: 'All Campaigns',
    imgUrl: dashboard,
    link: '/',
  },
  
  {
    name: 'My Campaigns',
    imgUrl: profile,
    link: '/profile',
  },


  {
    name: 'Return Money to Donator (My Campagins)',
    imgUrl: profile,
    link: '/ReturnMoney',
  },

  {
    name: 'Vote to Campaign that I Doante',
    imgUrl: profile,
    link: '/Vote',
  },


];
