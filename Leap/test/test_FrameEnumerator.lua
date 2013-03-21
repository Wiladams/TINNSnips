package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local FrameEnumerator = require("FrameEnumerator");

local leap, err = LeapInterface();

assert(leap, "Error Loading Leap Interface: ", err);


printDict = function(dict)
	for k,v in pairs(dict) do
		print(k,v);
	end
end


local main = function()
	for frame in FrameEnumerator(leap) do
		print("==================");
		printDict(frame);
	end	
end


run(main);
