
local Runtime = require("Runtime");
local LeapScape = require ("Leap.LeapScape");
local GestureHandler = require("Leap.GestureHandler");


local printDict = function(dict)
	for k,v in pairs(dict) do
		print(k,v)
	end
end


local OnSwipeBegin = function(gesture)
	local p = gesture.position;
	print("============")
	print("SWIPE BEGIN: ", p[1], p[2], p[3])
end

local OnSwipeEnd = function(gesture)
	local p = gesture.position;
	local d = gesture.direction;

	print("SWIPE END: ", p[1], p[2], p[3]);
	print("Direction: ", d[1], d[2], d[3]);
	print("Speed: ", gesture.speed);
end


local OnCircleBegin = function(gesture)
	local p = gesture.position;
	print("============")
	print("CIRCLE BEGIN: ")
end

local OnCircling = function(gesture)
	local n = gesture.normal;
	local direction = "ccw";
	if n[1] <0 and n[3] < 0 then
		direction = "cw"
	end

	print(string.format("CIRCLING: %f %s", gesture.progress, direction));
	--printDict(gesture);
end

local OnCircleEnd = function(gesture)
	local c = gesture.center;

	print(string.format("CIRCLE END: %f [%f, %f, %f]", gesture.radius, c[1], c[2], c[3]));
	--print(string.format("Direction: [%f, %f, %f]", d[1], d[2], d[3]));
	printDict(gesture);
end



local OnScreenTap = function(gesture)
	local p = gesture.position;
	print("SCREEN TAP: ", p[1], p[2], p[3]);	
end

local OnKeyTap = function(gesture)
	local p = gesture.position;
	print("KEY TAP: ", p[1], p[2], p[3]);	
end



local main = function()
	local scape = LeapScape();
	local ghandler = GestureHandler();
	
	-- Swipes
	--ghandler.OnSwipeEnd = OnSwipeEnd;
	--ghandler.OnSwipeBegin = OnSwipeBegin;

	-- Circles
	ghandler.OnCircleBegin = OnCircleBegin;
	ghandler.OnCircling = OnCircling;
	ghandler.OnCircleEnd = OnCircleEnd;

	-- Taps
	--ghandler.OnKeyTap = OnKeyTap;
	--ghandler.OnScreenTap = OnScreenTap;


	scape.GestureHandler = ghandler;

	spawn(scape.Start, scape)
end

run(main);
