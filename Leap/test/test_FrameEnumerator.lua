package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local FrameEnumerator = require("FrameEnumerator");
local EventEnumerator = require("EventEnumerator");
local StopWatch = require("StopWatch");


local leap, err = LeapInterface();
local sw = StopWatch.new();

assert(leap, "Error Loading Leap Interface: ", err);


printDict = function(dict)
	for k,v in pairs(dict) do
		print(k,v);
	end
end

local pointerfilter = function(param, event)
	if event.tipPosition then
		return event 
	end

	return nil;
end

local main = function()
	local frameCount = 0;

	for frame in EventEnumerator(FrameEnumerator(leap), pointerfilter) do
		frameCount = frameCount+1;
		print("fps: ", frameCount/sw:Seconds());

		--print("==================");
		--printDict(frame);
		--print(frame.s);
	end	
end


run(main);
