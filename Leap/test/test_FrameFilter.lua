package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local FrameEnumerator = require("FrameEnumerator");
local EventEnumerator = require("EventEnumerator");

local leap, err = LeapInterface();

assert(leap, "Error Loading Leap Interface: ", err);



local printHand = function(hand)
	local c = hand.sphereCenter;
	local r = hand.sphereRadius;
	local n = hand.palmNormal;
	print(string.format("HAND: %3.2f  [%3.2f %3.2f %3.2f]", r, c[1], c[3], c[3]));
end

-- Only allow the hand events to come through
local handfilter = function(event)
	return event.palmNormal ~= nil
end

local main = function()
	for event in EventEnumerator(FrameEnumerator(leap), handfilter) do
		printHand(event);
	end	
end

run(main);
