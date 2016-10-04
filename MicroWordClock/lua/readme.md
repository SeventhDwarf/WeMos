##Required files

- init.lua                        -- required to start the main code after reset/wake-up
- wifi_config.lua                 -- configuration data like SSID and password
- MicroWordClock.lua              -- the main file, no WiFi, no NTP update
- MicroWordClock_WiFi_short.lua   -- the main file, with WiFi and NTP update
- module_ht16k33.lua              -- driver for the I²C to LED matrix driver
- MWC_inc_german.lua              -- include file with the German definitions.

If you get RAM memory problems you can compile the files and use the ".lc" files.
