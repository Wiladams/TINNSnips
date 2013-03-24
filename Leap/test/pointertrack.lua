--package.path = package.path.."../../?.lua"
package.path = package.path.."../../?.lua"

local LeapScape = require ("Leap.LeapScape");
local MouseBehavior = require("Leap.MouseBehavior");
local UIOSimulator = require("UIOSimulator");


local scape, err = LeapScape();

if not scape then 
	print("No LeapScape: ", err)
	return false
end


local OnMouseMove = function(param, x, y)
	UIOSimulator.MouseMove(x, y);
end


local mousetrap = MouseBehavior(scape, UIOSimulator.ScreenWidth, UIOSimulator.ScreenHeight);
mousetrap:AddListener("mouseMove", OnMouseMove, nil);

scape:Start();


run();
