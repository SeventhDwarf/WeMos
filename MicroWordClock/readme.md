#MicroWordClock for WeMos

**Credits go to Daniel Rojas** and his great idea.
Please find his original design [here](https://github.com/formatc1702/Micro-Word-Clock/tree/master/v2).

##Description
Based on the work from Daniel this implemenation has the following major differences and changes:
- Uses the Wemos D1 mini.
- There is an implementation of a driver for HT16K33.
- Does not need any settings as it connects to a NTP server every hour.
- It is written completely in lua.

##Directory structure
- **lua** contains the lua source code and the ht16k33 driver.
- **graphics** contains the design for the transparency sheet to place over the LED matrix to form the words.

##Bill of Materials
- [WeMos D1 mini](https://www.wemos.cc/product/d1-mini.html) or [WeMos D1 mini pro](https://www.wemos.cc/product/d1-mini-pro.html)
- [WeMos Mini ProtoBoard](https://www.wemos.cc/product/protoboard.html)
- [Adafruit Mini 8x8 LED matrix with I²C backpack](https://www.adafruit.com/products/872)
- [WeMos Mini battery shield](https://www.wemos.cc/product/battery-shield.html)

##License
This project (both software and hardware) is published under a [Creative Commons BY-SA 3.0 License](http://creativecommons.org/licenses/by-sa/3.0/).
