// import React from 'react'

// const CountBox = ({ title, value }) => {
//   return (
//     <div className="flex flex-col items-center w-[150px]">
//       <h4 className="font-epilogue font-bold text-[20px] text-white p-3 bg-[#1c1c24] rounded-t-[10px] w-full text-center truncate">{value}</h4>
//       <p className="font-epilogue font-normal text-[16px] text-[#F2F3F4] bg-[#c46535] px-3 py-2 w-full rouned-b-[10px] text-center">{title}</p>
//     </div>
//   )
// }

// export default CountBox

import React from 'react'

const CountBox = ({ title, value }) => {
  return (
    <div className="flex flex-col items-center w-[150px] bg-[#1c1c24] rounded-full p-4">
      <h4 className="font-epilogue font-bold text-[20px] text-white mb-1 truncate">{value}</h4>
      <p className="font-epilogue font-normal text-[16px] text-[#F2F3F4] bg-[#c46535] px-3 py-1 rounded-full text-center">{title}</p>
    </div>
  )
}

export default CountBox
