package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local FrameEnumerator = require("FrameEnumerator");
local EventEnumerator = require("EventEnumerator");

local leap, err = LeapInterface();

assert(leap, "Error Loading Leap Interface: ", err);



local printevent = function(event)
	print(string.format("GESTURE: %s  %s", event.type, event.state));
end

-- Only allow the hand events to come through
local gesturefilter = function(param, event)
	if event.type ~= nil then
		event.kind = "gesture";
		return event
	end

	return nil
end

local main = function()
	for event in EventEnumerator(FrameEnumerator(leap), gesturefilter) do
		printevent(event);
	end	
end

run(main);