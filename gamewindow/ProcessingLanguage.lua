
local Renderer = require("RendererGdi")


local ProcessingLanguage = {
	--Camera = OrthoCamera(),
	Renderer = defaultrenderer,

	ColorMode = RGB,

	BackgroundColor = Color(127, 127, 127, 255),
	FillColor = Color(255,255,255,255),
	StrokeColor = Color(0,0,0,255),

	Running = false,
	FrameRate = 20,

	-- Typography
	TextSize = 12,
	TextAlignment = LEFT,
	TextYAlignment = BASELINE,
	TextLeading = 0,
	TextMode = SCREEN,
	TextSize = 12,

	Graphics = {},
	Actors = {},
	Interactors = {},
	MouseInteractors = {},
	KeyboardInteractors = {},
}










--[==================================================[
		LANGUAGE COMMANDS
--]==================================================]

function blue(c)
	return c.B
end

function green(c)
	return c.G
end

function red(c)
	return c.R
end

function alpha(c)
	return c.A
end


function color(...)
	return Color(unpack(arg))
end

function background(...)
	if arg.n == 1 and type(arg[1]) == "table" then
		return ProcessingLanguage.SetBackgroundColor(arg[1])
	end

	local acolor = Color(unpack(arg))
--print("background: ", acolor[1], acolor[2], acolor[3], acolor[4])
	return ProcessingLanguage.SetBackgroundColor(acolor)
end

function colorMode(amode)
	-- if it's not valid input, just return
	if amode ~= RGB and amode ~= HSB then return end

	--return ProcessingLanguage.SetColorMode(amode)
end

function fill(...)
	-- See if we're being passed a 'Color'
	-- type
	if arg.n == 1 and type(arg[1]) == "table" then
		return ProcessingLanguage.Renderer:SetFillColor(arg[1])
		--return ProcessingLanguage.SetFillColor(arg[1])
	end

	local acolor = Color(unpack(arg))

	return ProcessingLanguage.Renderer:SetFillColor(acolor)
end

function noFill()
	local acolor = Color(0,0)

	return ProcessingLanguage.Renderer:SetFillColor(acolor)
end

function noStroke(...)
	local acolor = Color(0,0)

	return ProcessingLanguage.Renderer:SetStrokeColor(acolor)

	--return ProcessingLanguage.SetStrokeColor(acolor)
end

function stroke(...)
	if arg.n == 1 and type(arg[1]) == "table" then
		-- We already have a color structure
		-- so just set it
		return ProcessingLanguage.Renderer:SetStrokeColor(arg[1])
	end

	-- Otherwise, construct a new color object
	-- and set it
	local acolor = color(unpack(arg))

	return ProcessingLanguage.Renderer:SetStrokeColor(acolor)
end


function point(x,y,z)
	--y = ProcessingLanguage.Renderer.height - y

	ProcessingLanguage.Renderer:DrawPoint(x,y)
end

function line(...)
	-- We either have 4, or 6 parameters
	local x1, y1, z1, x2, y2, z2

	if arg.n == 4 then
		x1 = arg[1]
		y1 = arg[2]
		x2 = arg[3]
		y2 = arg[4]
	elseif arg.n == 6 then
		x1 = arg[1]
		y1 = arg[2]
		z1 = arg[3]
		x2 = arg[4]
		y2 = arg[5]
		z2 = arg[6]
	end

	ProcessingLanguage.Renderer:DrawLine(x1, y1, x2, y2)
end

function rect(x, y, w, h)
	ProcessingLanguage.Renderer:DrawRect(x, y, w, h)
end

function triangle(x1, y1, x2, y2, x3, y3)
	ProcessingLanguage.Renderer:DrawTriangle(x1, y1, x2, y2, x3, y3)
end

function polygon(pts)
	ProcessingLanguage.Renderer:DrawPolygon(pts)
end

function quad(x1, y1, x2, y2, x3, y3, x4, y4)
	local pts = {
		Point3D(x1, y1, 0),
		Point3D(x2, y2, 0),
		Point3D(x3, y3, 0),
		Point3D(x4, y4, 0),
	}

	polygon(pts)
end

function ellipse(centerx, centery, awidth, aheight)
	local steps = 30
	local pts = {}

	for i = 0, steps do
		local u = i/steps
		local angle = u * 2*PI
		local x = awidth/2 * cos(angle)
		local y = aheight/2 * sin(angle)
		local pt = Point3D(x+centerx, y+centery, 0)
		table.insert(pts, pt)
	end

	polygon(pts)
end

--[====================================[
--	Curves
--]====================================]



function bezier(x1, y1,  x2, y2,  x3, y3,  x4, y4)
	ProcessingLanguage.Renderer:DrawBezier(
		{x1, y1, 0},
		{x2, y2, 0},
		{x3, y3, 0},
		{x4, y4, 0})
end

function bezierDetail(...)
end

function bezierPoint(...)
end

-- Catmull - Rom curve
function curve(x1, y1,  x2, y2,  x3, y3,  x4, y4)
	ProcessingLanguage.Renderer:DrawCurve(
		{x1, y1, 0},
		{x2, y2, 0},
		{x3, y3, 0},
		{x4, y4, 0})
end

function curveDetail(...)
end

function curvePoint(...)
end

function curveTangent(...)

end

function curveTightness(...)
end

-- ATTRIBUTES
function smooth()
	ProcessingLanguage.Renderer:SetAntiAlias(true)
end

function noSmooth()
	ProcessingLanguage.Renderer:SetAntiAlias(false)
end

function pointSize(ptSize)
	ProcessingLanguage.Renderer:SetPointSize(ptSize)
end

function strokeCap(cap)
	ProcessingLanguage.Renderer:SetLineCap(cap);
end

function strokeJoin(join)
	ProcessingLanguage.Renderer:SetLineJoin(join)
end

function strokeWeight(weight)
	ProcessingLanguage.Renderer:SetLineWidth(weight)
end

function size(awidth, aheight, MODE)
	ProcessingLanguage.SetCanvasSize(awidth, aheight, MODE)
end

-- VERTEX
function beginShape(...)
	local sMode = POLYGON
	if arg.n == 0 then
		ProcessingLanguage.VertexMode = gl.POLYGON
	elseif arg[1] == POINTS then
		ProcessingLanguage.ShapeMode = gl.POINTS
	elseif arg[1] == LINES then
		ProcessingLanguage.ShapeMode = gl.LINES
	end
end

function bezierVertex()
end

function curveVertex()
end

function endShape()
end

function texture()
end

function textureMode()
end

function vertex(...)
	local x = nil
	local y = nil
	local z = nil
	local u = nil
	local v = nil

	if (arg.n == 2) then
		x = arg[1]
		y = arg[2]
		z = 0
	elseif arg.n == 3 then
		x = arg[1]
		y = arg[2]
		z = arg[3]
	elseif arg.n == 4 then
		x = arg[1]
		y = arg[2]
		u = arg[3]
		v = arg[4]
	elseif arg.n == 5 then
		x = arg[1]
		y = arg[2]
		z = arg[3]
		u = arg[4]
		v = arg[5]
	end


	if u and v then
		-- texture coordinate
	end

	if x and y and z then
		gl.vertex(x,y,z)
	end

end






--[==============================[
	TRANSFORM
--]==============================]

-- Matrix Stack
function popMatrix()
	ProcessingLanguage.Renderer:PopMatrix();
end


function pushMatrix()
	ProcessingLanguage.Renderer:PushMatrix();
end

function applyMatrix()
end

function resetMatrix()
end

function printMatrix()
end


-- Simple transforms
function translate(x, y, z)
	ProcessingLanguage.Renderer:Translate(x, y, z)
end

function rotate(rads)
	ProcessingLanguage.Renderer:Rotate(rads)
end

function rotateX(rad)
end

function rotateY(rad)
end

function rotateZ(rad)
end

function scale(sx, sy, sz)
	ProcessingLanguage.Renderer:Scale(sx, sy, sz)
end

function shearX()
end

function shearY()
end



--[[
	Scene
--]]
function addactor(actor)
	if not actor then return end

	if actor.Update then
		table.insert(ProcessingLanguage.Actors, actor)
	end

	if actor.Render then
		addgraphic(actor)
	end

	addinteractor(actor)
end

function addgraphic(agraphic)
	if not agraphic then return end

	table.insert(ProcessingLanguage.Graphics, agraphic)
end

function addinteractor(interactor)
	if not interactor then return end

	if interactor.MouseActivity then
		table.insert(ProcessingLanguage.MouseInteractors, interactor)
	end

	if interactor.KeyboardActivity then
		table.insert(ProcessingLanguage.KeyboardInteractors, interactor)
	end
end


--[==============================[
	TYPOGRAPHY
--]==============================]

function createFont()
end

function loadFont()
end

function text(x, y, txt)
	--ProcessingLanguage.Renderer:Scale(1, -1)
	ProcessingLanguage.Renderer:DrawText(x, y, txt)
	--ProcessingLanguage.Renderer:Scale(1, -1)
end

-- Attributes

function textAlign(align, yalign)
	yalign = yalign or ProcessingLanguage.TextYAlignment

	ProcessingLanguage.TextAlignment = align
	ProcessingLanguage.TextYAlignment = yalign
	--ProcessingLanguage.SetTextAlignment(align, yalign)

	ProcessingLanguage.Renderer:SetTextAlignment(align)
end

function textLeading(leading)
	ProcessingLanguage.TextLeading = leading
end

function textMode(mode)
	ProcessingLanguage.TextMode = mode
end

function textSize(asize)
	ProcessingLanguage.TextSize = asize
end

function textWidth(txt)
	twidth, theight = ProcessingLanguage.Renderer:MeasureString(txt)
	return ProcessingLanguage.GetTextWidth(astring)
end

function textFont(fontname)
	return ProcessingLanguage.Renderer:SetFont(fontname);
	--return ProcessingLanguage.SetFontName(fontname)
end

-- Metrics
--[[
function textAscent()
end

function textDescent()
end
--]]

--[==============================[
	ENVIRONMENT
--]==============================]

function cursor()
end

function noCursor()
end

function frameRate(rate)
	ProcessingLanguage.FrameRate = rate
end




--[==============================[
	IMAGE
--]==============================]
function createImage(awidth, aheight, dtype)
	local pm = PImage(awidth, aheight, dtype)
	return pm
end

-- Loading and Displaying
--(img, offsetx, offsety, awidth, aheight)
function image(img, x, y, awidth, aheight)
	if img == nil then return end
	awidth = awidth or 0
	aheight = aheight or 0

	ProcessingLanguage.Renderer:DrawImage(img, x, y, awidth, aheight)
end

function imageMode()
end

function loadImage(filename)
	local pm = PImage({Filename = filename})

	return pm
end

function requestImage()
end

function tint()
end

function noTint()
end

-- Pixels
function blend()
end

function copy()
end

function filter()
end

function get(x, y)
	return ProcessingLanguage.Renderer:get(x,y)
end

function set(x, y, acolor)
	ProcessingLanguage.Renderer:set(x, y, acolor)
end

function loadPixels()
	ProcessingLanguage.Renderer:loadPixels()
end

function pixels()
end

function updatePixels()
	ProcessingLanguage.Renderer:updatePixels();
end


