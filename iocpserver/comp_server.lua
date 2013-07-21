
local Computicle = require("Computicle");
local IOCompletionPort = require("IOCompletionPort");


-- create the queue that will be used 
-- to transfer new connections to workers
newConnectionQueue = IOCompletionPort();

-- Create the computicle which will do the accepting
local acceptor = Computicle:createFromFile("comp_socketacceptor.lua");

acceptor.outputQueue = newConnectionQueue;

-- create the workers which will handle the new connections
--local worker = Computicle:load("comp_newconnection")
local worker1 = Computicle:createFromFile("comp_handler.lua");
worker1.newConnectionQueue = newConnectionQueue;


acceptor:waitForFinish();
