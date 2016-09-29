require "MWC_inc_config.lua"
require "MWC_inc_deutsch.lua"

-- Customizable options
local blink_enable = true
local blinknow     = false

local CM_NORMAL  = 0
local CM_SET_MIN = 1
local CM_SET_HRS = 2
local CM_END     = 3

local clockmode = CM_NORMAL

local disp = { 0, 0, 0, 0, 0, 0, 0, 0 }
local testdisp = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }

local disp_sec
local disp_min
local disp_hrs
local updatenow = false


function updateTime() {
  // Adjust 2.5 minutes = 150 seconds forward
  // So at 12:03 it already reads "five past 12"
--[[
  DateTime now = rtc.now().unixtime() + 150;

  disp_sec = now.second();
  disp_min = now.minute();
  disp_hrs = now.hour();
]]--

  disp_min = disp_min / 5;

  if (disp_min >= min_offset ) then
    disp_hrs = ( disp_hrs+1 ) % 12
  else
    disp_hrs = disp_hrs % 12
  end
}


function prepareDisplay() {
  blinknow = !blinknow;
  FOR_ALLROWS {
    disp[r]=B00000000;
    FOR_ALLCOLS {
      if((clockmode != SET_MIN || !blinknow))
        disp[r] |= minutes[disp_min][r] & (B10000000 >> c);
      if((clockmode != SET_HRS || !blinknow))
        disp[r] |= hours  [disp_hrs][r] & (B10000000 >> c);
      if(clockmode == NORMAL && blink_enable && !blinknow)
        disp[r] |= blinky[r];
    }
  }
}
