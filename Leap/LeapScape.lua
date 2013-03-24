
local ffi = require("ffi");

local Collections = require("Collections");
local LeapInterface = require("Leap.LeapInterface");
local JSON = require("dkjson");


local LeapScape_t = {}
local LeapScape_mt = {
	__index = LeapScape_t,
}

local LeapScape = function()
	local interface, err = LeapInterface();

	if not interface then
		return nil, err;
	end

	local obj = {
		Interface = interface;

		-- Handlers
		FrameObservers = {};

		FrameQueue = Collections.Queue.new();
		ContinueRunning = false;
	};

	setmetatable(obj, LeapScape_mt);

	return obj;
end

LeapScape_t.Start = function(self)
	self.ContinueRunning = true;

	Runtime.Scheduler:Spawn(LeapScape_t.ProcessRawFrames, self);
	Runtime.Scheduler:Spawn(LeapScape_t.ProcessFrames, self)
end

LeapScape_t.Stop = function(self)
	self.ContinueRunning = false;
end

--[[
	Processing raw frames runs a continuous iterator on retrieving frames
	from the Leap Controller.  This process does nothing more than grab
	the frame and stick it into a queue for further processing by handlers.
--]]
LeapScape_t.ProcessRawFrames = function(self)
	
	for rawframe in self.Interface:RawFrames() do
		if not self.ContinueRunning then
			break
		end

		local frame = JSON.decode(ffi.string(rawframe.Data, rawframe.DataLength));
		self.FrameQueue:Enqueue(frame);

		coroutine.yield();
	end
end

--[[
	ProcessFrames

	Running continuously once :Start() is called, and until Stop() is called.
	ProcessFrames pulls the individual frames off the frame queue, and dispatches
	events to the various handlers that are waiting.
--]]
LeapScape_t.ProcessFrames = function(self, frame)
	while self.ContinueRunning do
		-- get a frame off the queue
		local frame = self.FrameQueue:Dequeue()
		if frame then
			self:OnFrame(frame);
		end
		coroutine.yield();
	end
end


--[[
	Adding Observers for events
--]]
LeapScape_t.AddFrameObserver = function(self, observer, arg)
	self.FrameObservers[observer] = arg or self;
end

LeapScape_t.OnFrame = function(self, frame)
	
	-- First, hand out to any frame handlers
	for func, param in pairs(self.FrameObservers) do
		func(param, frame);
	end
end


return LeapScape;