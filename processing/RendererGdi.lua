
local ffi = require("ffi")
local GDI = require ("GDI32")
local gdi_ffi = require("gdi32_ffi")


--[[
	A renderer using GDI32 functions
--]]

local RendererGdi = {}
setmetatable(RendererGdi, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
RendererGdi_mt = {
	__index = RendererGdi;
}

RendererGdi.init = function(self, ctxt, awidth, aheight)
	local obj = {
		GraphPort = ctxt;
		Width = awidth;
		Height = aheight;

		-- Drawing Attributes
		PointSize = 1;
		LineCap = 1;
		LineJoin = 1;
		LineWidth = 1;

		StrokeColor = GDI.RGB(0,0,0);
		FillColor = GDI.RGB(255, 255, 255);
		BackgroundColor = GDI.RGB(255, 255, 255);

		AntiAlias = false;
	}
	setmetatable(obj, RendererGdi_mt)

	-- Setup the device context to be the way we want it
	ctxt:setGraphicsMode("GM_ADVANCED")
	ctxt:setMapMode("MM_ANISOTROPIC")

	-- Create the basic image
	--self.Image = im.ImageCreate(awidth, aheight, im.RGB, im.BYTE)
	--self.Image:AddAlpha();


	--local black = Color(0,0,0,255)
	--local white = Color(255, 255, 255, 255)
	--local gray = Color(53, 53, 53, 255)

	--self:SetStrokeColor(black)
	--self:SetFillColor(white)
	--self:SetBackgroundColor(gray)


	return obj;
end


RendererGdi.create = function(self, ctxt, awidth, aheight)
	ctxt = ctxt or DeviceContext();

	return self:init(ctxt, awidth, aheight);
end

function RendererGdi.ApplyAttributes(self)
	-- Apply attributes before any drawing occurs
	self:setStrokeColor(self.StrokeColor)
	self:setFillColor(self.FillColor)
	self:setBackgroundColor(self.BackgroundColor)
	--self:SetSmooth(Processing.Smooth)
end


--[==========[
	Rendering
--]==========]
function RendererGdi.loadPixels(self)
-- copy the pixels from the backing store
-- to the parent context
end

--[[
	ATTRIBUTES
--]]
function RendererGdi.setPointSize(self, asize)
	self.PointSize = asize;
	return true;
end

function RendererGdi.setLineCap(self, cap)
	self.LineCap = cap;
end

function RendererGdi.setLineJoin(self, join)
	self.LineJoin = join;
end

function RendererGdi.setLineWidth(self, lwidth)
	self.LineWidth = lwidth;
end

function RendererGdi.setStrokeColor(self, acolor)
	self.StrokeColor = acolor;
end

function RendererGdi.setFillColor(self, acolor)
	self.FillColor = acolor;
end

function RendererGdi.setBackgroundColor(self, acolor)
	self.BackgroundColor = acolor;
end

function RendererGdi.setAntiAlias(self, smoothing)
	self.AntiAlias = smoothing
end

function RendererGdi.clear(self)
	self.GraphPort:SetDCBrushColor(self.BackgroundColor);
	self.GraphPort:Rectangle(0,0,self.Width-1, self.Height-1)
end

--[[
	PRIMITIVES
--]]
function RendererGdi.get(self, x, y)
	return self.GraphPort:GetPixel(x,y)
end

function RendererGdi.set(self, x, y, acolor)
	self.GraphPort:SetPixel(x,y,acolor)
end

function RendererGdi.drawPoint(self, x, y)
	self:set(x,y,self.StrokeColor);
end

function RendererGdi.drawLine(self, x1, y1, x2, y2)
	self.GraphPort:MoveTo(x1, y1);
	self.GraphPort:LineTo(x2, y2)
end

function RendererGdi.drawBezier(self, p1, p2, p3, p4)
	local pts = {p1, p2, p3, p4}
	local curveSteps = 30;

	local cv4 = cubic_vec3_to_cubic_vec4(pts);

	local lastPoint = bezier_eval(0, cv4);
	for i=1, curveSteps do
		local u = i/curveSteps;
		local cpt = bezier_eval(u, cv4);

		self:DrawLine(lastPoint[1], lastPoint[2], cpt[1], cpt[2])
		lastPoint = cpt;
	end
end

function RendererGdi.drawCurve(self, p1, p2, p3, p4)
	local pts = {p1, p2, p3, p4}
	local curveSteps = 30;

	local cv4 = cubic_vec3_to_cubic_vec4(pts);

	local lastPoint = catmull_eval(0, 1/2, cv4);
	for i=1, curveSteps do
		local u = i/curveSteps;
		local cpt = catmull_eval(u, 1/2, cv4);

		self:DrawLine(lastPoint[1], lastPoint[2], cpt[1], cpt[2])
		lastPoint = cpt;
	end
end

function RendererGdi.drawPolygon(self, pts)
	local nPts = #pts;
	local vertices = ffi.new("POINT[?]",nPts, pts)

	self.GraphPort:Polygon(vertices, nPts)
end

function RendererGdi.drawTriangle(self, x1, y1, x2, y2, x3, y3)
	local pts = ffi.new("POINT[3]",{{x1, y1},{x2, y2},{x3, y3}})

	self.GraphPort:Polygon(pts, 3)
end

function RendererGdi.drawRect(self, x, y, w, h)
	self.GraphPort:Rectangle(x,y,x+w,y+h)
end

function RendererGdi.drawEllipse(self, centerx, centery, awidth, aheight)
	local x = centerx - awidth/2;
	local y = centery - aheight/2;
	local right = centerx + awidth/2;
	local bottom = centery + aheight/2;

	self.GraphPort:Ellipse(x, y, right, bottom)

	return true;
end




--[[
	TYPOGRAPHY
--]]

function RendererGdi.setFont(self, fontname, style, points)
	return false;
end

function RendererGdi.setTextAlignment(self, alignment)
	return false;
end

function RendererGdi.drawText(self, x, y, txt)
	self.GraphPort:Text(txt, x, y)

	return true;
end

--[==============================[
	TRANSFORMATION
--]==============================]
function RendererGdi.resetTransform(self)
	self.Transformer:Clear()
end

function RendererGdi.translate(self, dx, dy, dz)
	dz = dz or 0
	dy = dy or 0

	self.Transformer:Translate(dx, dy, dz)
end

function RendererGdi.rotate(self, rads)
	self.Transformer:Rotate(rads)
end

function RendererGdi.scale(self, sx, sy, sz)
	self.Transformer:Scale(sx, sy, sz)
end

function RendererGdi.pushMatrix(self)
	self.Transformer:PushMatrix()
end

function RendererGdi.popMatrix(self)
	self.Transformer:PopMatrix()
end

return RendererGdi
