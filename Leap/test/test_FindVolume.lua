--package.path = package.path.."../../?.lua"
package.path = package.path.."../?.lua"

local LeapScape = require ("LeapScape");
local FrameObserver = require("FrameObserver");


local scape, err = LeapScape();

if not scape then 
	print("No LeapScape: ", err)
	return false
end

--[[
	Find the volume range the controller can detect

	min = -348.65, 22.92, -237.88
	max = 473.92, 709.31, 281.50
--]]

local sensemax = {-math.huge, -math.huge, -math.huge}
local sensemin = {math.huge, math.huge, math.huge}

local findvolume = function(param, event)
	local newvalue = false

	tp = event.tipPosition;

	sensemin[1] = math.min(tp[1], sensemin[1])
	sensemin[2] = math.min(tp[2], sensemin[2])
	sensemin[3] = math.min(tp[3], sensemin[3])

	sensemax[1] = math.max(tp[1], sensemax[1])
	sensemax[2] = math.max(tp[2], sensemax[2])
	sensemax[3] = math.max(tp[3], sensemax[3])



	print("================")
	print(string.format("x: %3.2f == %3.2f", sensemin[1], sensemax[1]));
	print(string.format("y: %3.2f == %3.2f", sensemin[2], sensemax[2]));
	print(string.format("z: %3.2f == %3.2f", sensemin[3], sensemax[3]));

	return sensemin, sensemax
end


local fo = FrameObserver(scape);

local main = function()
	fo:AddPointerObserver(findvolume, nil)

	scape:Start();

	print("AFTER START");
end

run(main);

