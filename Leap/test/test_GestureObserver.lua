package.path = package.path.."../?.lua"

local LeapScape = require ("LeapScape");
local GestureObserver = require("GestureObserver");

local scape, err = LeapScape();

if not scape then
	print("Error: ", err)
	return false
end


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


local go = GestureObserver(scape);

local main = function()
	scape:Start();
	
	go.OnSwipeBegin = OnSwipeBegin;
	go.OnSwipeEnd = OnSwipeEnd;

	-- Circles	
	go.OnCircleBegin = OnCircleBegin;
	go.OnCircling = OnCircling;
	go.OnCircleEnd = OnCircleEnd;

	-- Taps
	--go.OnKeyTap = OnKeyTap;
	--go.OnScreenTap = OnScreenTap;
end


run(main)
