
--[[
	A general object to handle gestures from the LEAP controller
--]]



GestureObserver_t = {}
GestureObserver_mt = {
	__index = GestureObserver_t;
}

GestureObserver = function(scape)
	local obj = {
		CurrentGesture = "none";
	}

	setmetatable(obj, GestureObserver_mt);

	if scape then
		scape:AddFrameObserver(obj.OnFrame, obj)
		obj.LeapScape = scape;
	end

	return obj;
end

GestureObserver_t.OnFrame = function(self, frame)
	if frame.gestures and #frame.gestures > 0 then
		for _, gesture in ipairs(frame.gestures) do
			self:OnGesture(gesture);
		end
	end
end


GestureObserver_t.OnGesture = function(self, gesture)
	--print("==== GESTURE ====")
	--print("type: ", gesture.type, gesture.state);

	if gesture.type == "screenTap" then
		self:HandleScreenTap(gesture)
	elseif gesture.type == "keyTap" then
		self:HandleKeyTap(gesture)
	elseif gesture.type == "swipe" then
		self:HandleSwipe(gesture);
	elseif gesture.type == "circle" then
		self:HandleCircle(gesture);
	end
end

GestureObserver_t.HandleScreenTap = function(self, gesture)
	if self.CurrentGesture == "none" then
		if self.OnScreenTap then
			self.OnScreenTap(gesture);
		end
	end
end

GestureObserver_t.HandleKeyTap = function(self, gesture)
	if self.CurrentGesture == "none" then
		if self.OnKeyTap then
			self.OnKeyTap(gesture);
		end
	end
end

GestureObserver_t.HandleCircle = function(self, gesture)
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

GestureObserver_t.HandleSwipe = function(self, gesture)
	if not (self.OnSwipeBegin or self.OnSwiping or self.OnSwipeEnd) then
		return
	end

	if self.CurrentGesture == "swipe" then
		if gesture.state == "stop" then
			if self.OnSwipeEnd then
				self.OnSwipeEnd(gesture);
			end
			self.CurrentGesture = "none";
		elseif gesture.state == "update" then
			if self.OnSwiping then
				self.OnSwiping(gesture)
			end
		end
	elseif self.CurrentGesture == "none" then
		self.CurrentGesture = "swipe";
		if self.OnSwipeBegin then
			self.OnSwipeBegin(gesture)
		end
	end
end

return GestureObserver

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
