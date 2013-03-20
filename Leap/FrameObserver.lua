local FrameObserver_t = {}
local FrameObserver_mt = {
	__index = FrameObserver_t;
}

local FrameObserver = function(scape)
	local obj = {
		HandObservers = {};
		GestureObservers = {};
		PointerObservers = {};
		ToolObservers = {};
		FingerObservers = {};

		FrameFilters = {};
	}

	setmetatable(obj, FrameObserver_mt);

	if scape then
		scape:AddFrameObserver(obj.OnFrame, obj)
		obj.LeapScape = scape;
	end

	return obj
end


--[[
	Adding Observers for events
--]]

FrameObserver_t.AddHandObserver = function(self, observer, arg)
	if observer then
		self.HandObservers[observer] = arg or self;
	end
end

FrameObserver_t.AddGestureObserver = function(self, observer, arg)
	if observer then
		self.GestureObservers[observer] = arg or self;
	end
end


FrameObserver_t.AddPointerObserver = function(self, observer, arg)
	if observer then
		self.PointerObservers[observer] = arg or self;
	end
end
FrameObserver_t.RemovePointerObserver = function(self, observer)
	if observer then
		self.PointerObservers[observer] = nil;
	end
end

FrameObserver_t.AddToolObserver = function(self, handler, arg)
	self.ToolObservers[handler] = arg or self;
end

FrameObserver_t.AddFingerObserver = function(self, handler, arg)
	self.FingerObservers[handler] = arg or self;
end


--[[
	As an observer of the Leapscape, we are notified of this
	frame event every time they are available.
--]]
FrameObserver_t.OnFrame = function(self, frame)

	-- Hand Observers
	if frame.hands and #frame.hands > 0 then
		for _, hand in ipairs(frame.hands) do
			self:OnHand(hand);
		end
	end

	-- Pointable Observers
	if frame.pointables and #frame.pointables > 0 then
		for _, pointable in ipairs(frame.pointables) do
			self:OnPointer(pointable);
		end
	end


	-- Gesture Observers
	if frame.gestures and #frame.gestures > 0 then
		for _, gesture in ipairs(frame.gestures) do
			self:OnGesture(gesture);
		end
	end
end


--[[
	Event Observers
--]]
FrameObserver_t.OnHand = function(self, event)
	for func, param in pairs(self.HandObservers) do
		func(param, event);
	end
end

FrameObserver_t.OnGesture = function(self, event)
	for func, param in pairs(self.GestureObservers) do
		func(param, event);
	end
end

FrameObserver_t.OnPointer = function(self, event)

	for func, param in pairs(self.PointerObservers) do
		func(param, event);
	end

	if event.tool then
		self:OnTool(event);
	else
		self:OnFinger(event);
	end
end

FrameObserver_t.OnTool = function(self, event)
	for func, param in pairs(self.ToolObservers) do
		func(param, event);
	end
end

FrameObserver_t.OnFinger = function(self, event)
	for func, param in pairs(self.FingerObservers) do
		func(param, event);
	end
end


return FrameObserver



