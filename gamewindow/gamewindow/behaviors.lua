local animation = require("gamewindow.animation")
local random = math.random

local ellipses = function(constraint)
	
	-- draw a single random ellipse
	function randomellipse(ctxt, constraint)
		local width = random(2,40)
		local height = random(2,40)
		local x = random(constraint.Left,constraint.Left+constraint.Width-width)
		local y = random(constraint.Top, constraint.Top+constraint.Height-height)
		local right = x + width
		local bottom = y + height
		local brushColor = animation.randomColor()

		ctxt:SetDCBrushColor(brushColor)
		ctxt:Ellipse(x, y, right, bottom)
	end

	local closure = function(ctxt, millis)
		for i=1,30 do
			randomellipse(ctxt, constraint)
		end
	end

	return closure
end

local lines = function(constraint)
	
	-- draw a single random line
	function randomline(ctxt, constraint, millis)
		local x1 = constraint.Left + random() * constraint.Width
		local y1 = constraint.Top + random() * constraint.Height
		local x2 = constraint.Left + random() * constraint.Width
		local y2 = constraint.Top + random() * constraint.Height

		local color = animation.randomColor()

		ctxt:SetDCPenColor(color)

		ctxt:MoveTo(x1, y1)
		ctxt:LineTo(x2, y2)
	end

	local closure = function(ctxt, millis)
		for i=1,1 do
			randomline(ctxt, constraint, millis)
		end
	end

	return closure
end

local pixels = function(constraint)
	
	local closure = function(ctxt, millis)
		for i=1,60 do
			local x1 = constraint.Left + random() * constraint.Width
			local y1 = constraint.Top + random() * constraint.Height

			local color = animation.randomColor()

			ctxt:SetPixel(x1, y1, color)
		end
	end

	return closure
end

local rectangles = function(constraint)
	
	-- draw a single random ellipse
	function randomrectangle(ctxt, constraint, millis)
		local width = random(2,40)
		local height = random(2,40)
		local x = random(constraint.Left,constraint.Left+constraint.Width-width)
		local y = random(constraint.Top, constraint.Top+constraint.Height-height)
		local right = x + width
		local bottom = y + height
		local brushColor = animation.randomColor()

		ctxt:SetDCBrushColor(brushColor)
		ctxt:Rectangle(x, y, right, bottom)
	end

	local closure = function(ctxt, millis)
		for i=1,1 do
			randomrectangle(ctxt, constraint, millis)
		end
	end

	return closure
end

return {
	ellipses = ellipses;
	lines = lines;
	pixels = pixels;
	rectangles = rectangles;
}