# this is just a test file

```lua
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
```
