package.path = package.path.."../?.lua"

local LeapInterface = require("LeapInterface");
local HandyMouse = require("HandyMouse");
local UIOSimulator = require("UIOSimulator");

local leap, err = LeapInterface();

assert(leap, "Error Loading Leap Interface: ", err);

local main = function()
	local handymouse = HandyMouse(leap, UIOSimulator.ScreenWidth, UIOSimulator.ScreenHeight);
	handymouse:Start();

end

run(main);