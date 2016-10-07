local animation = require("gamewindow.animation")
local random = math.random
local min = math.min
local max = math.max

local bouncer = function(constraint)
	-- initial parameters
	local width = random(2,20)
	local height = width
	local x = random(constraint.Left,constraint.Left+constraint.Width-width)
	local y = random(constraint.Top, constraint.Top+constraint.Height-height)
	local right = x + width
	local bottom = y + height
	local brushColor = animation.randomColor()
	local speedX = random(-20,20)
	local speedY = random(-3,5)

--print("DY, DX: ", dy, dx)

	local closure = function(ctxt, millis)
		--print("bouncer - BEGIN: ", ctxt, millis)

		ctxt:SetDCBrushColor(brushColor)
		ctxt:Rectangle(x, y, right, bottom)

		-- do some movement
		--if (math.floor(millis) % 33) == 0 then
			--print("MOVING")
			x = x + speedX;
			y = y + speedY;

			if x < constraint.Left or x > constraint.Left+constraint.Width-width then
				speedX = speedX * -1;
			end

			if y < constraint.Top or y > constraint.Top+constraint.Height-height then
				speedY = speedY * -1;
			end

			x = max(constraint.Left, min(x,constraint.Left+constraint.Width-width))
			y = max(constraint.Top, min(y, constraint.Top +constraint.Height-height))
			right = x + width;
			bottom = y + height;
--			print(x,y)
		--end
	end

	return closure
end

return {
	bouncer = bouncer
}