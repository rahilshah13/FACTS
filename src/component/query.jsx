import { createSignal, Show } from "solid-js"

export const [query, setQuery] = createSignal("");


const QueryWords = () => {
  
};

/*
  TODO: Integrate with ./resolve.jsx
*/
export const Query = ({P : props}) => {
  // console.log("Arrange Props: ", props);
  const handleChange = (e) => setQuery(e.target.value);

  return (
    <div class="border border-blue-800 text-xs w-full py-[2vh] px-[2vw] relative place-items-center bg-blue-50">
      <span class="text-blue-800">QUERIES</span>
      <div class="flex flex-col hover:cursor-pointer">
        <input 
          class="outline-none" 
          placeholder="type a sentence fragment" 
          type="text" 
          value={query()}
          onChange={handleChange} 
        />
      </div>
    </div>
  );
};