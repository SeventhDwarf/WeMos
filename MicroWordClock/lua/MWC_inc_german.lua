--[[

V1
 FÜNFZEHN
 VORNACH*
 HALBACHT
 EINSECHS
 SIEZWÖLF
 BENDREIÜ
 *ZEHNEUN
 VIER*ELF

V2
 FÜNFZEHN
 VORNACH*
 HALBVIER
 EINSECHS
 SIEZWÖLF
 BENDREIÜ
 ÄZEHNEUN
 ACHT*ELF

]]--

min_offset=4	-- 12:00 + 5*4 min = zehn vor halb EINS

minutes = {
  { -- punkt
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  , { -- fünf nach
    0xF0,
    0x1E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  , { -- zehn nach
    0x0F,
    0x1E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- fünfzehn nach
    0xFF,
    0x1E,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- zehn vor halb
    0x0F,
    0xE0,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- fünf vor halb
    0xF0,
    0xE0,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- halb
    0x00,
    0x00,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- fünf nach halb
    0xF0,
    0x1E,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- zehn nach halb
    0x0F,
    0x1E,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- fünfzehn vor
    0xFF,
    0xE0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- zehn vor
    0x0F,
    0xE0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- fünf vor
    0xF0,
    0xE0,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00
  }
};

hours = {
  { -- zwoelf
    0x00,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x00,
    0x00,
    0x00
  }
  ,{ -- eins
    0x00,
    0x00,
    0x00,
    0xF0,
    0x00,
    0x00,
    0x00,
    0x00
  }
  ,{ -- zwei
    0x00,
    0x00,
    0x00,
    0x00,
    0x18,
    0x06,
    0x00,
    0x00,
  }
  ,{ -- drei
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x1E,
    0x00,
    0x00,
  }
  ,{ -- vier
    0x00,
    0x00,
    0x0F,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  }
  ,{ -- fuenf
    0x00,
    0x00,
    0x00,
    0x00,
    0x01,
    0x01,
    0x01,
    0x01,
  }
  ,{ -- sechs
    0x00,
    0x00,
    0x00,
    0x1F,
    0x00,
    0x00,
    0x00,
    0x00,
  }
  ,{ -- sieben
    0x00,
    0x00,
    0x00,
    0x00,
    0xE0,
    0xE0,
    0x00,
    0x00,
  }
  ,{ -- acht
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0xF0,
  }
  ,{ -- neun
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x0F,
    0x00,
  }
  ,{ -- zehn
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x78,
    0x00,
  }
  ,{ -- elf
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x07,
  }
}

blinky = {
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00
}
