package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local FrameEnumerator = require("FrameEnumerator");
local EventEnumerator = require("EventEnumerator");

local leap, err = LeapInterface();

assert(leap, "Error Loading Leap Interface: ", err);

local printTool = function(event)
	local p = event.tipPosition;
	print(string.format("Tool: [%3.2f %3.2f %3.2f]", p[1], p[2], p[3]));
end

-- Only allow the hand events to come through
local toolfilter = function(param, event)
	if event.tool ~= nil and event.tool == true then
		return event
	end

	return nil
end

local main = function()
	for event in EventEnumerator(FrameEnumerator(leap), toolfilter) do
		printTool(event);
	end	
end

run(main);