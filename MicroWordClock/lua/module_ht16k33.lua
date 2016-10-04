-- ******************************************************
-- Module for ESP8266 with nodeMCU
--
-- Written by Max Headroom <max.headroom@smart.ms>
--
-- GNU LGPL, see https://www.gnu.org/copyleft/lesser.html
-- ******************************************************

-- Module Bits
local moduleName = ...
local M = {}
-- _G[moduleName] = M

-- Default I2C ID
local id = 0

--Commands
local HT16K33_CMD_BLINK    = 0x80
local BLINK_DISPLAYON      = 0x1
local BLINK_OFF            = 0x0
local BLINK_2HZ            = 0x1
local BLINK_1HZ            = 0x2
local BLINK_HALF_HZ        = 0x3
local HT16K33_CMD_BRIGHTNESS =   0xE0
local HT16K33_CMD_SYSTEM   = 0x20
local SYSTEM_OSC_ON        = 0x1
local SYSTEM_OSC_OFF       = 0x0
local HT16K33_CMD_ADDR     = 0x00

-- Local constants
local MAX_BRIGHTNESS = 15
local MIN_BRIGHTNESS = 0
local LED_ON  = 1
local LED_OFF = 0

-- Local vars
local _sda
local _scl
local _addr
local _brightness = 7
local init = false
local _buffer = { 0x01, 0x00, 0x02, 0x00, 0x04, 0x00, 0x08, 0x00, 0x10, 0x00, 0x20, 0x00, 0x40, 0x00, 0x80, 0x00 }
local _squares = {1, 4, 9, 16, 25, 36, 49, 64, 81}



-- 16-bit  two's complement
-- value: 16-bit integer
local function twoCompl(value)
 if value > 32767 then value = -(65535 - value + 1)
 end
 return value
end

-- read data from device
-- Parameter:
-- 		addr	: slave address
-- 		command	: Command of device
-- 		length	: bytes to read
--
-- Returns:
--		string with data
local function readData(addr, command, length)
  i2c.start(id)
  i2c.address(id, addr, i2c.TRANSMITTER)
  i2c.write(id, command)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, addr,i2c.RECEIVER)
  c = i2c.read(id, length)
  i2c.stop(id)
  return c
end

-- read register from device
-- Parameter:
-- 		addr	: slave address
-- 		register: register address of device
--
-- Returns:
--		register value
local function readReg(addr, register)
     i2c.start(id)
     i2c.address(id, addr,i2c.TRANSMITTER)
     i2c.write(id,register)
     i2c.stop(id)
     i2c.start(id)
     i2c.address(id, addr,i2c.RECEIVER)
     c=i2c.read(id,1)
     i2c.stop(id)
     return c
end

-- write register of device
-- Parameter:
-- 		addr	: slave address
-- 		register: register address of device
--
-- Returns:
--		nothing
local function writeReg(addr, reg_addr, ...)
     i2c.start(id)
     i2c.address(id, addr, i2c.TRANSMITTER)
     i2c.write(id, reg_addr)
     i2c.write(id, ...)
     i2c.stop(id)
end

-- Send command to device
-- Parameter:
-- 		addr	: slave address
-- 		command : register address of device
--
-- Returns:
--		nothing
local function writeCmd(addr, command)
     i2c.start(id)
     i2c.address(id, addr, i2c.TRANSMITTER)
     i2c.write(id, command)
     i2c.stop(id)
end


-- Initialize I2C
-- Parameter:
-- 		scl		: scl pin
--		sda		: sda pin
-- 		addr	: address of device
--
-- Returns:
--		nothing
function M.init(d, c, a)
	if (d ~= nil) and (d >= 0) and (d <= 11) and (c ~= nil) and (c >= 0) and ( c <= 11) and (d ~= l) and (a ~= nil)  then
		_sda  = d
		_scl  = c 
		_addr = a
		i2c.setup(id,_sda,_scl,i2c.SLOW)
		i2c.start(id)
		res = i2c.address(id, _addr, i2c.TRANSMITTER) --verify that the address is valid
		i2c.stop(id)
		if (res == false) then
			print("device not found")
			return nil
		end
        writeCmd(_addr, HT16K33_CMD_SYSTEM + SYSTEM_OSC_ON  )
        writeCmd(_addr, HT16K33_CMD_BLINK + BLINK_DISPLAYON + BLINK_OFF )
		init = true
	else 
        print("i2c configuration failed") 
		return nil
    end
end

-- Set brightness
-- Parameter:
-- 		bright	: brightness level 0 ... 15
--
-- Returns:
--		nothing
function M.setBrightness(b)
	if (not init) then
        print("init() must be called before read.")
		return nil
	end
	if (b ~= nil) and (b >= 0) and (b <= 15) then
		writeCmd(_addr, HT16K33_CMD_BRIGHTNESS + b);
		_brightness = b
	end
end

-- Increase brightness
-- Parameter:
-- 		none
--
-- Returns:
--		nothing
function M.incBrightness()
	if (not init) then
        print("init() must be called before read.")
		return nil
	end
	if ( _brightness < MAX_BRIGHTNESS ) then
		_brightness = _brightness +1
		M.setBrightness( _brightness )
	end
end

-- Decrease brightness
-- Parameter:
-- 		none
--
-- Returns:
--		nothing
function M.decBrightness()
	if (not init) then
        print("init() must be called before read.")
		return nil
	end
	if ( _brightness > MIN_BRIGHTNESS ) then
		_brightness = _brightness - 1
		M.setBrightness( _brightness )
	end
end


-- Set blink rate
-- Parameter:
-- 		blink	: blink rate 0: Off, 1: 2Hz, 2: 1Hz , 3: half Hz
--
-- Returns:
--		nothing
function M.setBlinkRate(b)
	if (not init) then
        print("init() must be called before read.")
		return nil
	end
	if (b ~= nil) and (b >= 0) and (b <= 3) then
		writeCmd(_addr, HT16K33_CMD_BLINK + BLINK_DISPLAYON + b*2);
	end
end

-- Draw pixel of color at position x, y
-- Parameter:
-- 		x, y	: horizontal and veritcal position
--		c		: color, either 0 ( black ) or 1 ( white )
--		u		: optional, update display if true
-- Returns:
--		nothing
function M.drawPixel(x, y, c, u)
	if (not init) then
        print("init() must be called before read.")
		return nil
	end
	u = u or false
	if (x ~= nil) and (x >= 0) and (x <= 7) and (y ~= nil) and (y >= 0) and ( y <= 7) and (c ~= nil)  then
		-- wrap around the x
		x = x + 7
		x = x % 8
        _val = _buffer[y*2+1]
		if ( c == 1 ) then
            _msk = 1 * 2 ^ x
		else
            _msk = -( 1 * 2 ^ x )
		end
        _buffer[y*2+1] = _val + _msk
        
--        print("Buffer: " .. #_buffer )
        if ( u ) then M.update(_buffer) end
	end
end


-- Write Display with pattern, e.g. font
-- Parameter:
--      b       : buffer of 8 Bytes
--      u       : optional, update display if true
-- Returns:
--      nothing
function M.writeDisplay(b, u)
    if (not init) then
        print("init() must be called before read.")
        return nil
    end
    u = u or false
    if (b ~= nil) then
        for i=0, 7 do
            _buffer[i*2+1] = b[i+1]
--            writeReg( _addr, HT16K33_CMD_ADDR + i*2, b[i+1])
        end
        if ( u ) then M.update(_buffer) end
    end
end
 
-- Update display
-- Parameter:
--      b       : buffer
-- Returns:
--      nothing
function M.update(b)
    if (not init) then
        print("init() must be called before read.")
        return nil
    end
    writeReg( _addr, HT16K33_CMD_ADDR + 0, b)
end

-- Clear display and buffer
-- Parameter:
--      none
--      u       : optional, update display if true
-- Returns:
--      nothing
function M.clear(u)
    if (not init) then
        print("init() must be called before read.")
        return nil
    end
    u = u or false
    for i=1, 16 do
      _buffer[i] = 0x00
    end
    if ( u ) then M.update(_buffer) end
end


function M.dummy()
	if (not init) then
        print("init() must be called before read.")
		return nil
	end

  -- DO something useful

end

--  void writeDisplay(void);
M.BLINK_OFF = BLINK_OFF
M.BLINK_2HZ = BLINK_2HZ
M.BLINK_1HZ = BLINK_1HZ

return M



