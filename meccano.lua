DEBUG = nil
SSID_ID = ""
SSID_PW = ""
HOST = ""
PORT = 80
CONNECTION_TIMEOUT=60
DEVICE_ID = ""
DEVICE_GROUP = "0"
TOKEN = ""

---
---  Setup of the device
---
function setup(ssid, password, server, port)
    print("")
    print("Meccano IoT")
    print("(c) 2016 - Lua Micro Client")
    print("")
    -- Connect to the access point
    print ("Starting wifi...")
    SSID_ID = ssid
    SSID_PW = password
    timeout = CONNECTION_TIMEOUT
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID_ID, SSID_PW)
    -- Configure the device
    DEVICE_ID = wifi.sta.getmac()
    print("Device Id: ", DEVICE_ID)
    -- Configure server
    HOST = server
    PORT = port
    -- Register device
    register()
    --
    print("Installing handler for messages...")
    tmr.alarm(0, 30000, 1, function() messages_process() end)
    print("Ready in a few seconds...")
    return 1
end

---
--- Register the device
---
function register()
    print("Registering device...")
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if DEBUG then print(payloadout) end
        for word in payloadout:gmatch("%S+") do
            DEVICE_GROUP = TOKEN
            TOKEN = word
        end
        print ("Device Group:", DEVICE_GROUP)
        print ("Security Token:", TOKEN)
        if (string.find(payloadout, "403 Forbidden") ~= nil) then
            print("Device not authorized to the Meccano Network.")
            print("Rebooting...")
            node.reboot()
        end
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
        clock_setup()
    end)
    connout:on("connection", function(connout, payloadout)
        envelope = "PUT /api/gateway/"
            .. DEVICE_ID
            .. " HTTP/1.1\r\n"
            .. "Host: meccano-iot.cyclops.zone\r\n"
            .. "Connection: close\r\n"
            .. "Accept: text/plain\r\n"
            .. "User-Agent: Meccano (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
            .. "Authorization: "
            .. TOKEN
            .. "\r\n"
            .. "\r\n"
            .. "{ 'type' : 'nodemcu'}"
        if DEBUG then print(envelope) end
        connout:send(envelope)
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close()
        collectgarbage()
    end)
    connout:connect(PORT,HOST)
end

---
--- Clock Setup
---
function clock_setup()
    print("Clock setup...")
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if DEBUG then print(payloadout) end
        for word in payloadout:gmatch("%S+") do
            START_OF_OPERATION = word
        end
        print ("Start Operation: ", START_OF_OPERATION)
        if (string.find(payloadout, "403 Forbidden") ~= nil) then
            print("Device not authorized to the Meccano Network.")
            print("Rebooting...")
            node.reboot()
        end
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("OK");
        end
    end)
    connout:on("connection", function(connout, payloadout)
        envelope = "GET /api/gateway/"
            .. DEVICE_ID
            .. " HTTP/1.1\r\n"
            .. "Host: meccano-iot.cyclops.zone\r\n"
            .. "Connection: close\r\n"
            .. "Content-Type: application/json\r\n"
            .. "Accept: text/plain\r\n"
            .. "User-Agent: Meccano (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
            .. "Authorization: "
            .. TOKEN
            .. "\r\n"
            .. "\r\n"
            .. "{ 'type' : 'nodemcu'}"
        if DEBUG then print(envelope) end
        connout:send(envelope)
    end)
    connout:on("disconnection", function(connout, payloadout)
        print("Ending connection...")
        connout:close()
        collectgarbage()
    end)
    connout:connect(PORT,HOST)
end

---
--- Create fact
---
function fact_create(channel, sensor, value)
    fact = "{\"channel\":\""
        .. channel
        .. "\",\"start\":"
        .. START_OF_OPERATION
        .. ",\"delta\":"
        .. (tmr.now()/1000)
        .. ","
        .. "\"device_group\":\""
        .. DEVICE_GROUP
        .. "\",\"device\":\""
        .. DEVICE_ID
        .. "\",\"sensor\":"
        .. sensor
        .. ",\"data\":"
        .. value
        .. "}"
    return fact
end

---
--- Send fact
---
function fact_send(fact)
    print("Sending fact...")
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if DEBUG then print(payloadout) end
        if (string.find(payloadout, "200 OK") ~= nil) then
            print("Posted OK");
        else
            print("Error sending data to gateway...")
        end
    end)
    afact = "[" .. fact .. "]"
    connout:on("connection", function(connout, payloadout)
        envelope =
               "POST /api/gateway/" .. DEVICE_ID .. " HTTP/1.1\r\n"
            .. "Host: " .. HOST .. "\r\n"
            .. "Connection: close\r\n"
            .. "Content-Type: application/json\r\n"
            .. "Accept: text/plain\r\n"
            .. "Authorization: " .. TOKEN .. "\r\n"
            .. "Content-Length: " .. string.len(afact) .. "\r\n"
            .. "\r\n"
            .. afact
            .. "\r\n"
        if DEBUG then print(envelope) end
        connout:send(envelope)
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close()
        collectgarbage()
    end)
    connout:connect(PORT, HOST)
end


---
--- Processing Messages
---
function messages_process()
    if DEBUG then print("Processing messages...") end
    connout = nil
    connout = net.createConnection(net.TCP, 0)
    connout:on("receive", function(connout, payloadout)
        if DEBUG then print(payloadout) end
        for message in payloadout:gmatch("%S+") do
            if message == "REBOOT" then
              node.reboot()
            end
            if message == "FORCE_SYNC" then
                print("Command not supported.")
            end
            if message == "BLINK" then
                print("Command not supported.")
            end
            if message == "PURGE" then
                print("Removing the data file...")
                data_format()
            end
        end
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("OK");
        end
    end)
    connout:on("connection", function(connout, payloadout)
        envelope = "GET /api/gateway/"
            .. DEVICE_ID
            .. " HTTP/1.1\r\n"
            .. "Host: meccano-iot.cyclops.zone\r\n"
            .. "Connection: close\r\n"
            .. "Content-Type: application/json\r\n"
            .. "Accept: text/plain\r\n"
            .. "User-Agent: Meccano (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
            .. "Authorization: "
            .. TOKEN
            .. "\r\n"
            .. "\r\n"
            .. "{ 'type' : 'nodemcu'}"
        if DEBUG then print(envelope) end
        connout:send(envelope)
    end)
    connout:on("disconnection", function(connout, payloadout)
        connout:close()
        collectgarbage()
    end)
    connout:connect(PORT,HOST)
end

---
--- Export the Meccano Object
---
local meccano = {}
meccano.setup = setup
meccano.fact_create = fact_create
meccano.fact_send = fact_send
return meccano
