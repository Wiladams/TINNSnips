local ffi = require("ffi");
local LeapInterface = require("LeapInterface");
--local WebSocketStream = require("WebSocketStream");
local Scheduler = require("EventScheduler");

local sched = Scheduler();
Runtime={}
Runtime.Scheduler = sched;

local leap, err = LeapInterface();

print(leap, err);

if not leap then
	return false, err
end

-- Print a dictionary
local printDict = function(tbl)
	if not tbl then 
		return 
	end

	for k,v in pairs(tbl) do
		print(k,v);
	end
end


local readRawFrames = function(leap)
	for frame in leap:RawFrames() do
		--print("==== FRAME ====")
		--print("FIN: ", frame.FIN);
		--print("Op Code: ", frame.opcode);
		--print("MASK: ", frame.MASK);
		--print("PayloadLen: ", frame.PayloadLen);
		print(ffi.string(frame.Data, frame.DataLength));
	end
end



local readFrames = function(leap)
	for frame in leap:Frames() do
		print("==== FRAME ====")
		printDict(frame);
		printDict(frame.t);
	end
end

sched:Spawn(readRawFrames, leap);
--sched:Spawn(readFrames, leap);
sched:Start();
