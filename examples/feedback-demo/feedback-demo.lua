-- Meccano IOT - NodeMCU / Lua Library - Feedback Demo
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

local meccano = require("meccano")

BUZZ, LED = 0, 1
PRESSED = nil
gpio.mode(BUZZ, gpio.OUTPUT)
gpio.mode(LED, gpio.OUTPUT)
gpio.write(BUZZ, gpio.LOW)
gpio.write(LED, gpio.LOW)
net.dns.setdnsserver("8.8.8.8")

function buzz()
    gpio.write(BUZZ, gpio.HIGH)
    gpio.write(LED, gpio.HIGH)
    tmr.delay(500000)
    gpio.write(BUZZ, gpio.LOW)
    gpio.write(LED, gpio.LOW)
    tmr.delay(500000)
end

-- Contact the Meccano Network
meccano.setup("*****", "*****",
              "meccano.server", 80, function()
    -- Read the ADC port
    print("Hook for buttons...")
    tmr.alarm(1, 100, 1,
      function()
        val = adc.read(0)
        if PRESSED then
            return
        end
        if val > 1010 then
        -- Nothing
        elseif val > 990 then
            PRESSED = 1
            tmr.delay(1000)
            fact = meccano.fact_create("feedback", 1, 100)
            meccano.fact_send(fact, function()
                print("+++ POSITIVE FEEDBACK")
                buzz()
                tmr.delay(5000)
                PRESSED = nil
            end)
        elseif val > 900 then
            PRESSED = 1
            fact = meccano.fact_create("feedback", 1, 50)
            meccano.fact_send(fact, function()
                print("ooo NEUTRAL FEEDBACK")
                buzz()
                tmr.delay(5000)
                PRESSED = nil
            end)
        else
            PRESSED = 1
            meccano.fact = fact_create("feedback", 1, -100)
            meccano.fact_send(fact, function()
                print("--- NEGATIVE FEEDBACK")
                buzz()
                tmr.delay(5000)
                PRESSED = nil
            end)
        end
    end)
end)
