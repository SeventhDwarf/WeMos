--load credentials
--SID and PassWord should be saved according wireless router in use
--dofile("credentials.lua")

MAIN = "MicroWordClock.lua"

function startup()
    if file.open("init.lua") == nil then
       print("init.lua deleted")
    else
        if file.open(MAIN) == nil then
            print("ERROR: Could not find " .. MAIN)
            print("init.lua stopped")
        else
            print("Running")
            file.close("init.lua")
            dofile(MAIN)
        end
    end
end

--init.lua
print("Give you 5 seconds ...")
tmr.alarm(0,5000,0,startup)
  
