
local bit = require "bit"

local band = bit.band
local lshift = bit.lshift
local rshift = bit.rshift

local Color = {}
setmetatable(Color, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local Color_mt = {
	__index = Color;
}

Color.init = function(self, r, g, b, a)
	local obj = {
		R = r;
		G = g;
		B = b;
		A = a;
	}
	setmetatable(obj, Color_mt)

	return obj;
end


Color.create = function(self, ...)
	-- There can be 1, 2, 3, or 4, arguments

	local r = 0
	local g = 0
	local b = 0
	local a = 0

	local nargs = select("#", ...)

	if (nargs == 1) then
		-- specifies gray
		r = select(1, ...)
		g = select(1, ...)
		b = select(1, ...)
		a = 255
	elseif nargs == 2 then
		-- specifies gray/alpha
		r = select(1, ...)
		g = select(1, ...)
		b = select(1, ...)
		a = select(2, ...)
	elseif nargs == 3 then
		-- specifies RGB, default alpha (opaque)
		r = select(1, ...)
		g = select(2, ...)
		b = select(3, ...)
		a = 255
	elseif nargs == 4 then
		-- specifies RGB, with alpha
		r = select(1, ...)
		g = select(2, ...)
		b = select(3, ...)
		a = select(4, ...)
	end
	
	return self:init(r,g,b,a)

end

Color.toInt32 = function(self)
	return lshift(self.A, 24) + lshift(self.R, 16) + lshift(self.G, 8) + self.B;
end

function Color:Normalized()
	if self.Norm == nil then
		self.Norm = {
			self.R/255,
			self.G/255,
			self.B/255,
			self.A/255
		}
	end

	return self.Norm;
end

function Color.__tostring(self)
	local str = string.format("{%u,%u, %u, %u}", self.R, self.G, self.B, self.A)
	return str
end

return Color
