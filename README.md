# nodemcu-lua-library
Meccano Client Library for NodeMCU (lua)

# About Meccano IoT Project

Meccano project is a multi-purpose IoT (Internet of Things) board and software platform created by Luciano Kadoya, Rogério Biondi, Diego Osse and Talita Paschoini. Its development started in early 2014 as a closed R&D project in the Software Architecture Division, with the aim of creating a board which is robust, based on a modern microprocessor (ESP8266), cheap, easy to implement and deploy through the 750 retail stores to perform several functions, such as:

- Count the number of visitors in each store to calculate the sales/visits ratio;
- Get the vote/feedback of users regarding the services;
- Voice marketing;
- Energy saving initiatives;
- Beacons and interaction of the customer in the physical store;
- Several other undisclosed applications;

Different from other ESP8266 projects, Meccano board has been heavily tested in retail stores and adjusted to be safe against RF (radio frequency) interferences. The physical store is an inhospitable environment since there are several hundreds of electronic products, such as TVs, computers, sound and home theaters as well as electronic home appliances.

The project is still in its early stages and will evolve in the future. Magazine Luiza will plan the backlog and sponsor the project. It has been open-sourced because it´s the first initiative to create a board based on ESP8266 in Brazil and we are really excited with the possibilities. Magazine Luiza has a passion for innovations and contribution to the development of technology. So you are invited to join us because your support/collaboration is welcome!


# NodeMCU-Lua-Library

Meccano nodemcu-lua-library is a client library for NodeMCU Using the Lua Firmware.

## Features:

 - Simple to use
 - Integration to Meccano Gateway    
    - Create and send facts
    - Check and execute messages from gateway

## Limitations:

- Due to the asynchronous nature of Lua in NodeMCU, the local persistence of data when connection is not available is not implemented yet.

- There is not enough memory, so if you want to have more room for creating your Lua program, we strongly recommend you build a custom firmware for NodeMCU. Minimum modules you should include: adc, file, gpio, net, node, tmr, wifi and the modules your program will use. In this site you may create it: http://nodemcu-build.com/

- No buzz and led functions yet (low memory).


## requirements

In order to use nodemcu-lua-library you should prepare and reflash your NodeMCU to use the latest version or use a custom firmware with just the modules you'll need (see the limitations above). More information about NodeMCU platform may be found on:

http://www.nodemcu.com


## Installation

1. Download the zip from GIT Hub to a local directory (e. g. Dowloads)
2. Rename file Downloads/node-lua-library-master.zip > node-lua-library
2. Open your IDE (we use the ESPlorer IDE - http://esp8266.ru/ )
3. Click the Upload Button and select the file node-lua-library/meccano.lua
4. Open the node-lua-library/example.lua, change it according your needs and Save/Run


### Mininum Meccano Program

You need to include the meccano library in your code:

```
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
```


### Functions

#### Setup functions ####

##### void setup(ssid, ssid_password, server, port, userfn) #####

The setup() will do the following functions:

1. Setup and get the device id (mac-address);
2. Setup the wifi connection to the access point (AP). You must provide your AP credentials (ssid and password);
3. Setup the connection to gateway. You must pass the host (or IP) and port where the meccano gateway is running;
4. It will register the device in the Meccano Network;
5. It will get the clock information.

```
meccano.setup("ssid", "passwd", "meccano.server.iot", 80, function()
  print("Connected to meccano network!")
  -- My program here
end)
```


#### Fact functions ####

Facts are the representation of a physical event. They are data captured by the sensors of Meccano Mini Board. It can be a temperature sensor, a line infrared or PIR sensor or others. The data of a fact is represented by a numeric value. Examples: for a temperature sensor it should be a number between -100 and 100 representing the celsius measure, or if you create a button it can be the number of times which it has been pressed by the user.


##### fact_create(channel, sensor, value) #####

When you create a fact, you must specify a channel. The channel is a class that identify which kind of information you want to send to the meccano gateway. Besides the channel, each fact must specify the sensor. You must define a number for each sensor connected to your meccano mini board. Let's consider, for example, that you have a PIR sensor connected in one port and a temperature sensor in other port. for identification, you should consider the PIR as sensor 1 and temperature as sensor 2. If you have several identical appliances which the same configuration, you must keep the same configuration of sensor for all devices. The value of the sensor is the data captured of them. This can be a value of temperature, a voltage or whatever you need to collect.


##### fact_send(String fact, userfn) #####

Send a fact to the meccano gateway.

```
fact = meccano.fact_create("my_channel", 1, 100)
meccano.fact_send(fact, function()
  print("Data sent to meccano network!")
end)
```

***
NOTE: There is no persistence for the facts in this first version, which means that the client operates only in on-line mode
***
