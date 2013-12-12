
local GDI32 = require("GDI32")

local rand = math.random

function randomColor(low, high)
	low = low or 0
	high = high or 255
	local r = rand(low,high)
	local g = rand(low,high)
	local b = rand(low,high)
	local color = RGB(r,g,b)

	return color
end

return {
	randomColor = randomColor;
}