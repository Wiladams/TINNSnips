local Collections = require("Collections");
local StopWatch = require("StopWatch");

local FrameEnumerator = require("FrameEnumerator");
local EventEnumerator = require("EventEnumerator");


local HandyMouse_t = {}
local HandyMouse_mt = {
	__index = HandyMouse_t;
}



local HandyMouse = function(interface, width, height)
	local obj = {
		ContinueRunning = false;
		Interface = interface;
		CurrentState = "none";
		SmallScale = math.huge;
		LargeScale = -math.huge;
		LastScale = 1;
	}
	
	setmetatable(obj, HandyMouse_mt);

	return obj;
end

HandyMouse_t.Start = function(self)
	self.ContinueRunning = true;

	local handfilter = function(param, event)
--	print("handfilter")
		if event.palmNormal ~= nil then
			return event
		end

		return nil
	end

	local trackHand = function()
		for hand in EventEnumerator(FrameEnumerator(self.Interface), handfilter, self) do
			self:OnHand(hand);
			
			if not self.ContinueRunning then
				break
			end

--			coroutine.yield();
		end	

		print("Loop Finished")
	end

	spawn(trackHand)
end

HandyMouse_t.Stop = function(self)
	self.ContinueRunning = false;
end

--[[
	Map a value from one range to another
--]]
local mapit = function(x, minx, maxx, rangemin, rangemax)
--	print(string.format("MAP: %3.2f  %3.2f  %3.2f  %3.2f  %3.2f", x, minx, maxx, rangemin, rangemax));
	return rangemin + (((x - minx)/(maxx - minx)) * (rangemax - rangemin))
end

local scaleFactor= function(s1, s2) 
    return math.exp(s1 -s2);
end

HandyMouse_t.OnHand = function(self, hand)
	local c = hand.sphereCenter;
	local p = hand.palmPosition;

	self.LargeScale = math.max(self.LargeScale, hand.s);
	self.SmallScale = math.min(self.SmallScale, hand.s);

	local scale = mapit(hand.s, self.SmallScale, self.LargeScale, 0, 1);

	if scale < 0.0001 then
		self.LargeScale = self.SmallScale + 0.3
	end


	--print(string.format("OnHand: %03.2f  [%03.2f, %03.2f, %03.2f]", hand.sphereRadius, p[1], p[2], p[3]));
	print(string.format("OnHand: %03.3f  %03.3f", scale, hand.s));
	--print(hand.sphereRadius, self.CurrentState);
--[[
	if hand.sphereRadius < 70 then
		if self.CurrentState == "none" or self.CurrentState == "open" then
			self.CurrentState = "closed";
			self:OnHandClose(hand);
		end
	else
		if self.CurrentState == "none" or self.CurrentState == "closed" then
			self.CurrentState = "open";
			self:OnHandOpen(hand);
		end
	end
--]]
	-- Assumethe position has changed
	-- Really, should average values over a brief
	-- time window
	self:OnHandMove(hand);

end

HandyMouse_t.OnHandClose = function(self, hand)
	local p = hand.palmPosition;
	--print(string.format("Closed: [%03.2f, %03.2f, %03.2f]", p[1], p[2], p[3]));
end

HandyMouse_t.OnHandMove = function(self, hand)
end

HandyMouse_t.OnHandOpen = function(self, hand)
	local p = hand.palmPosition;
	--print(string.format("Open: [%03.2f, %03.2f, %03.2f]", p[1], p[2], p[3]));
end

return HandyMouse