--[[--------------------------
   LUA script for configuring an ESP8266 to connect to a Wi-Fi network
   Author : Seventh Dwarf
   Modules: bit, i2c, gpio, net, node, rtctime, sntp, tmr, wifi
   Version: 1.01
--------------------------]]--
-- require "MWC_inc_config"
require "MWC_inc_german"
package.loaded["module_ht16k33"] = nil
ht = require("module_ht16k33")

---------WiFi Config----------
SSID       = "Jules_Welt"           -- "ESP8266"
PASSWORD   = "JulesWelt"            -- "1234sakul"
TIMEOUT    = 15000000 -- 15s
MAIN       = "main.lua"

-------- Station modes -------
STAMODE = {
    STATION_IDLE             = 0,
    STATION_CONNECTING       = 1,
    STATION_WRONG_PASSWORD   = 2,
    STATION_NO_AP_FOUND      = 3,
    STATION_CONNECT_FAIL     = 4,
    STATION_GOT_IP           = 5
}

-------- Boot Reasons -------
RESETCAUSE = {
    REASON_DEFAULT_RST       = 0,    -- normal startup by power on
    REASON_WDT_RST           = 1,    -- hardware watch dog reset
    REASON_EXCEPTION_RST     = 2,    -- exception reset, GPIO status won’t change
    REASON_SOFT_WDT_RST      = 3,    -- software watch dog reset, GPIO status won’t change
    REASON_SOFT_RESTART      = 4,    -- software restart ,system_restart , GPIO status won’t change
    REASON_DEEP_SLEEP_AWAKE  = 5,    -- wake up from deep-sleep
    REASON_EXT_SYS_RST       = 6     -- external system reset
}

-------- WiFi Status-------
WIFISTATUS = {
    UNCONNECTED              = 0,
    CONNECTED                = 1,
    TIMEOUT                  = 2
}

-------- Station config -------
cfg = {
    ip      = "192.168.179.23",
    netmask = "255.255.255.0",
    gateway = "192.168.179.1"
}

-------- ntp time config -------
ntp = {
    timezone    = 2,
    ip          = "130.149.17.21",  -- IP address of NTP-server at TU-Berlin
    port        = 123,
    ntpstamp    = 0,
    unixstamp   = 0,
    secondsofday= 0
}

-------- system config -------
sys = {
    voltage    = 0,     -- VDD33
    systime    = 0
}

-------- Constants -------
pinSDA = 2
pinSCL = 1
HT16K33_ADDRESS = 0x70
-------- GPIO pins -------
pinGPIO15 = 8
pinGPIO14 = 5
pinGPIO13 = 7
pinGPIO2  = 4
pinGPIO1  = 10
pinGPIO0  = 3
local LED    = pinGPIO13
local ABORT  = pinGPIO14

local LED_ON  = gpio.LOW
local LED_OFF = gpio.HIGH
  
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


function setup()
    led_status = false
--[[  This is the standard way
      However, it does not work as "rtctime.dsleep" does not set
      the bootreason correctly ]--
    _, reset_cause = node.bootreason()
    if reset_cause == RESETCAUSE.REASON_DEEP_SLEEP_AWAKE then
        print("Wake-up from Deep Sleep")
        do_transmission = false
    else
        print("Reset cause : " .. reset_cause)
        do_transmission = true
    end
]]--

--[[  Alternative solution
      If using rtctime.dlseep, checking the seconds of rtctime.gettime()
      will provide some information if this is a cold reset 
      or deep sleep wake-up ]]--
    ht.init(pinSDA, pinSCL, HT16K33_ADDRESS)
    ht.setBrightness(15)

    sec, usec = rtctime.get()
    if ( sec == 0 ) then            -- cold reset, 
        rtctime.set(1473497760, 0)  -- set time to default value
        print("Reset cause probably hardware reset or power-up")
        ht.writeDisplay(testdisp, true)         -- Shortly show test pattern
        do_transmission = true      -- allow connection to ntp server
    else
        print("Wake-up from Deep Sleep")
        do_transmission = false
    end
    updateTime()
  
    wifi_status = WIFISTATUS.UNCONNECTED
    gpio.mode(LED, gpio.OUTPUT)
    gpio.write(LED, led_status and LED_ON or LED_OFF);  -- equiv to  led_status ? gpio.HIGH : gpio.LOW
    gpio.mode(ABORT, gpio.INPUT, gpio.PULLUP)
    if adc.force_init_mode(adc.INIT_VDD33) then
        node.restart()
        return -- don't bother continuing, the restart is scheduled
    end
    sys.voltage      = adc.readvdd33()
    sys.systime,usec = rtctime.get()
end
 
--[[ Function connectWiFi: ------
      connects to a predefined access point
      params:
         timeout int    : timeout in us
--------------------------]]--
function connectWiFi(timeout)
   local time = tmr.now()
   wifi.sta.connect()
   print("1")

   -- Wait for IP address; check each 300ms; timeout
   tmr.alarm(1, 300, tmr.ALARM_AUTO,
      function()
--   print("2")
         if wifi.sta.status() == STAMODE.STATION_GOT_IP then
               tmr.unregister(1)
               print("Station: connected! IP: " .. wifi.sta.getip() .. " in " ..((tmr.now() - time)/1000000).. " seconds.")
               gpio.write(LED, LED_ON);  
               wifi_status = WIFISTATUS.CONNECTED
                 -- dofile(MAIN)
         else
                   if tmr.now() - time > timeout then
                        print("Timeout!")
                        led_status = false
                        gpio.write(LED, (led_status and LED_ON or LED_OFF));  
                        if wifi.sta.status() == STAMODE.STATION_IDLE          then print("Station: idling") end
                        if wifi.sta.status() == STAMODE.STATION_CONNECTING       then print("Station: connecting") end
                        if wifi.sta.status() == STAMODE.STATION_WRONG_PASSWORD    then print("Station: wrong password") end
                        if wifi.sta.status() == STAMODE.STATION_NO_AP_FOUND    then print("Station: AP not found") end
                        if wifi.sta.status() == STAMODE.STATION_CONNECT_FAIL    then print("Station: connection failed") end
                        wifi_status = WIFISTATUS.TIMEOUT
                        tmr.unregister(1)
                  else
                        gpio.write(LED, (led_status and LED_ON or LED_OFF));  -- equiv to  led_status ? gpio.HIGH : gpio.LOW
                        led_status = not led_status
                        -- print("LED Status :" .. (led_status and gpio.HIGH or gpio.LOW))
                  end
         end
      end
   )
   print("3")

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

 wifi_led = {
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x08
}

 
function updateDisplay()
    blinknow = not blinknow;
    for r=1, 8 do
        disp[r]=0x00;
        disp[r] = bit.bor(disp[r], minutes[disp_min+1][r])
        disp[r] = bit.bor(disp[r], hours[disp_hrs+1][r])
        if( blink_enable and blinknow) then
            disp[r] = bit.bor(disp[r], blinky[r])
        end
        if( led_status ) then
            disp[r] = bit.bor(disp[r], wifi_led[r])
        end
        disp[r] = transp(disp[r])
    end
    ht.writeDisplay(disp, true)
end

--  Main Code
print("HEAP:" .. node.heap())
setup()
print("System Voltage    : " .. sys.voltage)
print("Current Wi-Fi mode: " .. wifi.getmode())
print("WiFi LED Status   : " .. (led_status and "TRUE" or "FALSE"))
--tm = rtctime.epoch2cal(rtctime.get())
--print(string.format("RTC-Time : %02d.%02d.%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"], tm["sec"]))


do_not_abort = (gpio.read(ABORT) == 1)
do_transmission = true

--	Init wifi
if do_not_abort then

    print("RTC-Time: " .. (rtctime.get() % 300))
    if ((rtctime.get() % 300) >293) then
	do_transmission = true
    end

    sync_done = false

if do_transmission then
    print("Setting up Wi-Fi connection..")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, PASSWORD)
    -- wifi.sta.setip(cfg) 
    connectWiFi(TIMEOUT)
    print("4")
    tmr.alarm(2, 100, tmr.ALARM_AUTO, function()
--        print("tmr2")
        if wifi_status == WIFISTATUS.CONNECTED then
            tmr.unregister(2)
                -- Sync time with server and print the result, or that it failed
                sntp.sync(ntp.ip,
                  function(sec,usec,server)
                    print(string.format('Sync: %14d, %10d, %s', sec, usec, server))
                    new_sec  = sec + (ntp.timezone*3600)
                    new_usec = usec
                    rtctime.set(new_sec, new_usec)
--                    tm = rtctime.epoch2cal(new_sec)
--                    print(string.format("Sync-Time: %02d.%02d.%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"], tm["sec"]))
                    sync_done = true

                  end,
                  function()
                   print('failed!')
                    sync_done = true
                  end)
        end
        if wifi_status == WIFISTATUS.TIMEOUT then
             sync_done = true
	end
    end)
    print("5")
    do_transmission = false
else
    sync_done = true
 
end  -- if do_transmission
 

tmr.alarm(5,5*60*10,tmr.ALARM_AUTO,function()
	updateTime()
end)

tmr.alarm(6,1*500,tmr.ALARM_AUTO,function()
--    ht.clear()
    updateDisplay()
end)

local b = 15
tmr.alarm(0, 500, tmr.ALARM_AUTO, function()
--    print("tmr0")
        if ( sync_done ) then
--    updateTime()
--    updateDisplay()
            ht.setBrightness(b)
            b = b-1
            led_status = false
            if ( (b <= 0) and ( not blinknow ) ) then
                tmr.unregister(0)
                print("tmr0 unregister")
                wifi.setmode(wifi.NULLMODE)
--                rtctime.dsleep(5000000, 4)
                rtctime.dsleep_aligned(2*60*1000000, 10*1000000, 4)
--              node.dsleep(5000000, 4)
            end
        end
end)
else
    print("Aborted operation")
end

 


