
local NUM_LEDS = 7
local TYPE_LED = 4  -- 4: RGBW, 3: RGB

ws2812.init()
local i = 0
local buffer = ws2812.newBuffer(NUM_LEDS, TYPE_LED)
buffer:fill(0, 0, 0, 0)
tmr.alarm(0, 50, 1, function()
        i=i+1
        buffer:fade(2,ws2812.FADE_OUT)
        buffer:set(i%buffer:size()+1, 25, 25, 25, 25)
        ws2812.write(buffer)
end)