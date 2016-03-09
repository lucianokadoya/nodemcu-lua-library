---
--- Sample code
---

-- Include meccano module
local meccano = require("meccano")

-- Contact the Meccano Network
res = meccano.setup("ssid", "ssid_password", "meccano-gateway-host", 80)

-- Your main program
print("My hook...")
tmr.alarm(1, 100, 1,
  function()
    -- Your program here
    -- read gpio, adc port and so on

    -- If you need to create and send a fact
    fact = meccano.fact_create("feedback", 1, 100)
    meccano.fact_send(fact)
end)
