package.path = package.path.."../../?.lua"

local LeapScape = require ("LeapScape");
local FrameObserver = require("FrameObserver");
local UIOSimulator = require("UIOSimulator");


local scape, err = LeapScape();

if not scape then 
	print("No LeapScape: ", err)
	return false
end

--[=[
	"hands":[{
		"id":4,
		"direction":[-0.0793992,0.899586,-0.427785],
		"palmNormal":[-0.16208,-0.432144,-0.886711],
		"palmPosition":[27.138,227.235,80.2504],
		"palmVelocity":[-136.716,-134.926,-359.534],
		"sphereCenter":[9.15823,202.468,9.29922],
		"sphereRadius":106.122,
		"r":[[0.989305,-0.132062,-0.0619254],[0.117032,0.97208,-0.203384],[0.0870557,0.193962,0.977139]],
		"s":1.45151,
		"t":[-18.2708,21.6366,-106.687]
	}],
--]=]

local OnHand = function(param, hand)
	local c = hand.sphereCenter;
	print(string.format("OnHand: %d  %03.2f [%03.2f, %03.2f, %03.2f]", hand.id, hand.sphereRadius, c[1], c[2], c[3]));

	--UIOSimulator.MouseMove(x, y);
end

local fo = FrameObserver(scape);
fo:AddHandObserver(OnHand, nil);


scape:Start();


run();
