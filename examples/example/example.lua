-- Meccano IOT - NodeMCU / Lua Library - Minimum Program
--
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

---
--- Sample code
---

-- Include meccano module
local meccano = require("meccano")

-- Contact the Meccano Network
meccano.setup("ssid", "ssid_password", "meccano-gateway-host", 80, function()
  -- Your main program
  print("My hook...")
  tmr.alarm(1, 100, 1,
    function()
      -- Your program here
      -- read gpio, adc port and so on

      -- If you need to create and send a fact
      fact = meccano.fact_create("feedback", 1, 100)
      meccano.fact_send(fact, function()
        print("Data successfuly sent!")
      end)
  end)
end)
