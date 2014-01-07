
local Stopwatch = require("StopWatch")


--[[
	Animated Sprite
--]]

local Animite = {}
setmetatable(Animite, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
local Animite_mt = {
	__index = Animite;
}


Animite.init = function(self, ctxt, handler)
	local obj = {
		Clock = Stopwatch();
		Context = ctxt;
		Handler = handler;
	}
	setmetatable(obj, Animite_mt)

	return obj;
end

Animite.create = function(self, ctxt, handler)
	return self:init(ctxt, handler)
end

Animite.loop = function(self)
--print("Animite.loop - BEGIN")
	while self.IsRunning do
		self.Handler(self.Context, self.Clock:Milliseconds())

		yield();
	end
end

Animite.start = function(self)
	self.IsRunning = true;

	spawn(Animite.loop, self)
end

Animite.stop = function(self)
	self.IsRunning = false;
end

return Animite
