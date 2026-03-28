
export const Profile = () => {
  return(
    <>
      <> {/* LEFT BUTTONS */}
        <div 
            class="absolute left-0 top-0 w-[4vw] flex flex-row border-black hover:bg-amber-950 hover:mouse-pointer text-center font-bold"
          >
          <div class="bg-gray-300">PROFILE</div>
          <div class="bg-pink-300">SETTINGS</div>
        </div>
      </>
      <> {/* RIGHT BUTTONS */}
          <div 
            class="absolute right-0 top-0 w-[4vw] flex flex-row border border-black hover:bg-amber-950 hover:mouse-pointer text-center font-bold"
          >
          <div class="bg-red-300 w-[2vw]">OFF</div>
          <div class="bg-green-300 w-[2vw]">ON</div>
        </div>
      </>
    </>
  );
};