-- Required modules in custom build
--  bit, i2c, net, node, rtctime, sntp, tmr, wifi
--
-- require "MWC_inc_config"
require "MWC_inc_german"
package.loaded["module_ht16k33"] = nil
ht = require("module_ht16k33")

-- Constants
pinSDA = 2
pinSCL = 1
HT16K33_ADDRESS = 0x70
  
-- Customizable options
local blink_enable = true
local blinknow     = false

local disp = { 0, 0, 0, 0, 0, 0, 0, 0 }
local testdisp = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }

local disp_sec
local disp_min
local disp_hrs
local updatenow = false


function rev(MSB)
local LSB = 0
    for i=0, 7 do
        LSB= bit.lshift(LSB, 1)
        if( bit.isset(MSB, 0)  ) then
            LSB = bit.set(LSB, 0)
        end
        MSB = bit.rshift(MSB, 1)
    end
    return LSB;
end

function transp(MSB)
local LSB = 0
    for i=0, 6 do
        LSB= bit.lshift(LSB, 1)
        if( bit.isset(MSB, 0)  ) then
            LSB = bit.set(LSB, 0)
        end
        MSB = bit.rshift(MSB, 1)
    end
    if( bit.isset(MSB, 0)  ) then
        LSB = bit.set(LSB, 7)
    end
    return LSB;
end

function updateTime() 
--print("Update Time")
-- Adjust 2.5 minutes = 150 seconds forward
-- So at 12:03 it already reads "five past 12"
--[[
  DateTime now = rtc.now().unixtime() + 150;
]]--
    tm = rtctime.epoch2cal(rtctime.get()+150)
    disp_sec = tm["sec"]
    disp_min = tm["min"]
    disp_hrs = tm["hour"]
--    print(string.format("%02d.%02d.%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"], tm["sec"]))

    disp_min = math.floor(disp_min / 5)

    if (disp_min >= min_offset ) then
        disp_hrs = ( disp_hrs+1 ) % 12
    else
        disp_hrs = disp_hrs % 12
    end
end
 
 
function updateDisplay()
    blinknow = not blinknow;
    for r=1, 8 do
        disp[r]=0x00;
        disp[r] = bit.bor(disp[r], minutes[disp_min+1][r])
        disp[r] = bit.bor(disp[r], hours[disp_hrs+1][r])
        if( blink_enable and blinknow) then
            disp[r] = bit.bor(disp[r], blinky[r])
        end
        disp[r] = transp(disp[r])
    end
    ht.writeDisplay(disp, true)
end

--  Main Code
    ht.init(pinSDA, pinSCL, HT16K33_ADDRESS)
    ht.setBrightness(4)

--  Init_rtc
    sec, usec = rtctime.get()
    if ( sec == 0 ) then 
--        rtctime.set(1473497760, 0) -- 10.09.2016 - 10:56:00
        rtctime.set(1451606400, 0) -- 01.01.2016 - 00:00:00
    end
    updateTime()

--  Start timer
    ht.writeDisplay(testdisp, true)         -- Shortly show test pattern
    tmr.alarm(0,400,tmr.ALARM_SINGLE,function()
        tmr.alarm(1,100,tmr.ALARM_AUTO,function()
            updateTime()
        end)

        tmr.alarm(2,1*200,tmr.ALARM_AUTO,function()
--          ht.clear()
            updateDisplay()
        end)

        tmr.alarm(6,1*300,tmr.ALARM_AUTO,function()
            rtctime.set(rtctime.get()+100, 0) 
        end)
    end)

