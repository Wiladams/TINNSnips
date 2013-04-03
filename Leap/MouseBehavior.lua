
--[[
	An observer that turns sensor motion into mouse events.
--]]

local StopWatch = require("StopWatch");


--[[
	Map a value from one range to another
--]]
local mapit = function(x, minx, maxx, rangemin, rangemax)
	return rangemin + (((x - minx)/(maxx - minx)) * (rangemax - rangemin))
end

--[[
	Clamp a value to a range
--]]
local clampit = function(x, minx, maxx)
	if x < minx then return minx end
	if x > maxx then return maxx end

	return x
end

-- Try to load the configuration file	
local sensecfg = assert(loadfile("sensor.cfg"), "Please run: tinn mousetrain.lua")()


MouseBehavior_t = {}
MouseBehavior_mt = {
	__index = MouseBehavior_t;
}

MouseBehavior = function(scape, width, height)	

	local obj = {
		sensemin = sensecfg.sensemin;
		sensemax = sensecfg.sensemax;

		Width = width;
		Height = height;

		MouseDownObservers = {};
		MouseMoveObservers = {};
		MouseUpObservers = {};
		MouseClickObservers = {};

		Clock = StopWatch.new();
		CurrentBehavior = "none";
		LastAction = "none";
		LastTime = 0;
		TimeThreshold = 1000/100;
	}

	setmetatable(obj, MouseBehavior_mt);

	if scape then
		scape:AddFrameObserver(obj.OnFrame, obj)
		obj.LeapScape = scape;
	end

	return obj;
end

MouseBehavior_t.AddListener = function(self, event, func, arg)
--print("AddListener: ", event, func, arg)
	if event == "mouseMove" then
		self:AddMoveObserver(func, arg);
	elseif event == "mouseDown" then
		self:AddDownObserver(func, arg);
	elseif event == "mouseUp" then
		self:AddUpObserver(func, arg);
	elseif event == "mouseClick" then
		self:AddClickObserver(func, arg);
	end
end

MouseBehavior_t.RemoveListener = function(self, event, func, arg)
--print("AddListener: ", event, func, arg)
	if event == "mouseMove" then
		self:RemoveMoveObserver(func, arg);
	elseif event == "mouseDown" then
		self:RemoveDownObserver(func, arg);
	elseif event == "mouseUp" then
		self:RemoveUpObserver(func, arg);
	elseif event == "mouseClick" then
		self:RemoveClickObserver(func, arg);
	end
end


MouseBehavior_t.AddMoveObserver = function(self, func, arg)
	self.MouseMoveObservers[func] = arg or self;
end
MouseBehavior_t.RemoveMoveObserver = function(self, func)
	if func then
		self.MouseMoveObservers[func] = nil;
	end
end

MouseBehavior_t.AddClickObserver = function(self, func, arg)
	self.MouseClickObservers[func] = arg or self;
end
MouseBehavior_t.RemoveClickObserver = function(self, func)
	if func then
		self.MouseClickObservers[func] = nil;
	end
end


--[[
	Reacting to events
--]]
MouseBehavior_t.OnFrame = function(self, frame)
	if frame.pointables and #frame.pointables > 0 then
		for _, pointable in ipairs(frame.pointables) do
			self:OnPointer(pointable);
		end
	end
end


MouseBehavior_t.OnPointer = function(self, event)
	--print("==== POINTER ====");
	tp = event.tipPosition;
	d = event.direction;
	v = event.tipVelocity;

	--print("  Pos: ", x, y);
	--print("  Dir: ", d[1], d[2], d[3]);
	local yvelocity = mapit(v[2], -300, 300, -1, 1);


	-- convert a tip position to a mouse location on screen
	x = clampit(math.floor(mapit(tp[1], self.sensemin[1], self.sensemax[1], 0, self.Width-1)), 0, self.Width-1);
	y = clampit(math.floor(mapit(tp[2], self.sensemax[2], self.sensemin[2], 0, self.Height-1)), 0, self.Height-1);

	--print(string.format("  Vel: %03.4f", yvelocity));

	self:HandleMouseMove(x, y);

end

MouseBehavior_t.HandleMouseMove = function(self, x, y)
	if self.Clock:Milliseconds() - self.LastTime > self.TimeThreshold then
		for func, arg in pairs(self.MouseMoveObservers) do
			func(arg, x, y)
		end
		self.LastTime = self.Clock:Milliseconds();
	end
end

MouseBehavior_t.HandleMouseDown = function(self, x, y)
	if #self.MouseMoveObservers > 0 then
		for func, arg in pairs(self.MouseDownObservers) do
			func(arg, x, y)
		end
	end
end

MouseBehavior_t.HandleMouseUp = function(self, x, y)
	if not (self.OnCircleBegin or self.OnCircling or self.OnCircleEnd) then
		return
	end

	if self.CurrentGesture == "circle" then
		if gesture.state == "stop" then
			if self.OnCircleEnd then
				self.OnCircleEnd(gesture);
			end
			self.CurrentGesture = "none";
		elseif gesture.state == "update" then
			if self.OnCircling then
				self.OnCircling(gesture)
			end
		end
	elseif self.CurrentGesture == "none" then
		self.CurrentGesture = "circle";
		if self.OnCircleBegin then
			self.OnCircleBegin(gesture)
		end
	end
end

--[[
	A mouse click is a behavior consisting of a 
	MouseDown, followed by a MouseUp
	So, this is fired essentially after a MouseUp event
--]]
MouseBehavior_t.HandleMouseClick = function(self, x, y)
end



return MouseBehavior

--[===[
{
	"id":179207,
	"timestamp":1557379153
	"r":[[0.772041,-0.0784329,0.630715],[0.150047,0.986798,-0.0609544],[-0.617608,0.141696,0.773617]],
	"s":316.101,
	"t":[-970.359,-1234.53,-326.587],

	"gestures":[{
			"direction":[-0.905729,-0.212455,-0.366768],
			"duration":0,
			"handIds":[4],
			"id":6,
			"pointableIds":[6],
			"position":[103.715,198.518,69.9831],
			"speed":927.044,
			"startPosition":[211.811,223.874,113.756],
			"state":"start",
			"type":"swipe"
	}],
	
	"hands":[],
	"pointables":[{
		"direction":[0.0895224,0.593076,-0.800154],
		"handId":4,
		"id":6,
		"length":45.1865,
		"tipPosition":[103.715,198.518,69.9831],
		"tipVelocity":[-911.124,-122.308,-119.6],
		"tool":false
	}]
}
--]===]
