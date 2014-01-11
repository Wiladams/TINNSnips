--[[
	Processing Language skin

	From the Processing Reference: http://processing.org/reference/
--]]

--local Application = require("Application")
local GDIWindow = require("GDIWindow")
local RendererGdi = require("RendererGdi")
local Language = require("ProcessingLanguage")
local Functor = require("Functor")

-- Constants for Processing Environment
HALF_PI = math.pi / 2
PI = math.pi
QUARTER_PI = math.pi/4
TWO_PI = math.pi * 2

-- Constants related to colors
RGB = 1
HSB = 2


-- for beginShape()
POINTS 			= 0x0000; -- GL_POINTS
LINES 			= 0x0001; -- GL_LINES
TRIANGLES 		= 0x0004; -- GL_TRIANGLES
TRIANGLE_STRIP 	= 0x0005; -- GL_TRIANGLE_STRIP
TRIANGLE_FAN 	= 0x0006; -- GL_TRIANGLE_FAN
QUADS 			= 0x0007; -- GL_QUADS
QUAD_STRIP 		= 0x0008; -- GL_QUAD_STRIP
POLYGON 		= 0x0009; -- GL_POLYGON
CLOSE = 1;

LEFT = 1;
CENTER = 2;
RIGHT = 4;

TOP = 8;
BOTTOM = 16;
BASELINE = 32;

MODEL = 1;
SCREEN = 2;
SHAPE = 3;

local canvas_width = 1024;
local canvas_height = 768;

width = 1024;
height = 768;

focused = false;
frameCount = 0;
--frameRate = 0
online = false;
screen = nil;
width = 1024;
height = 768;

-- Mouse State information
-- These are changed live
mouseButton = false;
isMousePressed = false;

-- Mouse position during current frame
mouseX = 0;
mouseY = 0;

-- Mouse position from previous frame
pmouseX = 0;
pmouseY = 0;


key = 0;
keyCode = 0;





-- Initial Processing State
Processing = {
	--Camera = OrthoCamera(),
	--Renderer = RendererGdi(canvas_width, canvas_height),

	ColorMode = RGB,

	--BackgroundColor = Color(127, 127, 127, 255),
	--FillColor = Color(255,255,255,255),
	--StrokeColor = Color(0,0,0,255),

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

function Processing.ClearCanvas()
	Processing.Renderer:clear();
end


--[==============================[
	Compiling
--]==============================]
--[[
function Processing.ApplyState()
	Processing.Renderer:ApplyAttributes();
end

function Processing.ClearGlobalFunctions()
	Processing.Actors = {}
	Processing.Graphics = {}
	Processing.Interactors = {}
	Processing.MouseInteractors = {}
	Processing.KeyboardInteractors = {}

	-- Clear out the global routines
	-- That the user may have supplied
	_G.setup = nil
	_G.draw = nil
	_G.keyPressed = nil
	_G.mousePressed = nil
end
--]]


--[[
function Processing.Compile(inputtext)
	iup.GLMakeCurrent(defaultglcanvas);

	-- Create a new renderer
	-- destroy old renderer explicitly

	-- create new renderer
	defaultrenderer = IMRenderer(canvas_width, canvas_height)
	Processing.Renderer = defaultrenderer;

	Processing.Renderer:loadPixels();

	-- Apply State before compiling
	-- new code
	Processing.ApplyState()

	-- Set the camera position
	Processing.Camera:Render()

	Processing.ClearGlobalFunctions();
	Processing.Renderer:ResetTransform();
	Processing.Renderer:Clear();

	-- Compile the code
	local f = loadstring(inputtext)
	f()

	if _G.setup ~= nil then
		_G.setup()
	end

	-- Update pixels and draw to screen
	Processing.Renderer:updatePixels()
	Processing.Renderer:Render(defaultcanvas, 0,0)

	-- Run animation loop
	Processing.StartAnimation()
end
--]]

--[[
function Processing.StartAnimation()
	-- How many milliseconds per frame
	local secondsperframe = 1 / Processing.FrameRate
	local status = iup.DEFAULT
	local startTime = socket.gettime()		-- startMillis
	local nextTime = startTime + secondsperframe
	local tolerance = 0.001
	local currentTime = startTime
	local ellapsedTime = 0;

	Processing.Running = true;
	Processing.TickCount = 0
	Processing.FramesPerSecond = 0

	frameCount = 0
	repeat
		-- update seconds per frame
		-- in case it changes during the animation
		--secondsperframe = 1 / Processing.FrameRate

		-- If we don't do this, then UI will never
		-- get a chance to do anything
		status = iup.LoopStep()

		if ((status == iup.CLOSE) or (not Processing.Running)) then
			--print(status)
			break
		end

		currentTime = socket.gettime()
		ellapsedTime = currentTime - startTime
		if currentTime < nextTime then
			-- do nothing but perhaps wait
			--local diff = nextTime - currentTime
			--if diff < tolerance then
			--end
		else
			Processing.TickCount = Processing.TickCount + 1
			frameCount = frameCount + 1
			Processing.FramesPerSecond = Processing.TickCount / ellapsedTime
			Processing.Tick(Processing.TickCount)
			nextTime = nextTime + secondsperframe

		end
	until status == iup.CLOSE

	--print("Processing.StartAnimation - END")
end
--]]
--[[
function Processing.StopAnimation()
	Processing.Running = false
end
--]]
local Startup = function()
	if _G.setup ~= nil then
		_G.setup()
	end
end

OnCreated = function(win)
	spawn(Startup);
end

OnTick = function(win, tickCount)
	frameCount = frameCount + 1;

	-- Render the camera so we can
	-- reset the modelview matrix
	-- This will need to change we we
	-- want to change the camera position for 3D
	--Processing.Camera:Render()

	-- Draw the immediate graphics
	if (_G.draw) ~= nil then
		draw()
	end

	-- Update all the actors
	for _,actor in ipairs(Processing.Actors) do
		actor:Update(Processing.TickCount)
	end


	-- Draw all the retained graphics
	for _,graphic in ipairs(Processing.Graphics) do
		graphic:Render(Processing.Renderer)
	end


	-- if double buffered
	-- swap buffers in the end
	--iup.GLSwapBuffers(self);

	-- Track current mouse position
	pmouseX = mouseX
	pmouseY = mouseY

	-- Update pixels and draw to screen
	-- Draw the pixels to the screen
	--Processing.Renderer:updatePixels()
	--Processing.Renderer:Render(defaultglcanvas, 0,0)
end

--[=[
function Processing.ReSize(awidth, aheight)
	if aheight == 0 then
		aheight = 1
	end

	gl.Viewport(0, 0, awidth, aheight)

--[[
	local canvas2D = defaultglcanvas.canvas2D
	if canvas2D ~= nil then
		canvas2D:Activate()
	end
--]]

	Processing.Camera:SetSize(awidth, aheight)

	iup.Update(defaultglcanvas);	-- will cause action() to be called
end
--]=]

--[==============================[
	Keyboard ACTIVITY
--]==============================]
-- A key has been pressed
--	local ke = KeyboardActivityArgs{
local KeyActivity = function(msg, wparam, lparam)
	local ke = KeyboardActivityArgs{
		EventType = et,
		KeyChar = c,
	}
	-- If the user has implemented
	-- keyPressed()
	-- call that function
	if (_G.keyPressed) ~= nil then
		keyPressed(ke)
	end

	for _,kinteractor in ipairs(Processing.KeyboardInteractors) do
		kinteractor:KeyboardActivity(ke)
	end
end

--[==============================[
	MOUSE ACTIVITY
--]==============================]
local MouseActivity = function(msg, wparam, lparam)
print("Mouse Activity: ", msg)

--[[
	if ma.ActivityType == MouseActivityType.MouseDown then
		Processing.MouseDown(ma.Button, ma.X, ma.Y, ma.KeyFlags)
	elseif ma.ActivityType == MouseActivityType.MouseUp then
		Processing.MouseUp(ma.Button, ma.X, ma.Y, ma.KeyFlags)
	elseif ma.ActivityType == MouseActivityType.MouseMove then
		Processing.MouseMove(ma.X, ma.Y, ma.KeyFlags)
	elseif ma.ActivityType == MouseActivityType.MouseWheel then
		Processing.MouseWheel(ma.Delta, ma.X, ma.Y, ma.KeyFlags)
	end

	for _,minteractor in ipairs(Processing.MouseInteractors) do
		minteractor:MouseActivity(ma);
	end
--]]
end

function Processing.MouseMove(self, x, y, status)
	--x, y = Processing.Renderer.canvas:wWorld2Canvas(x, y)
--print("Processing.MouseMove: ", x, y, status)
	mouseX = x
	mouseY = y
end

function Processing.MouseDown(self, but, x, y, status)
	--x, y = Processing.Renderer.canvas:wWorld2Canvas(x, y)

	isMousePressed = true;
	if (_G.mousePressed) ~= nil then
		mousePressed()
	end
end

function Processing.MouseUp(self, but, x, y, status)
	isMousePressed = false;
end

function Processing.MouseWheel(delta, x, y, status)
	print(string.format("mousewheel: %d", delta))
end


-- create an application window
local win = GDIWindow({
		Title = "Processing",
		--KeyboardInteractor = keyboardinteraction,
		MouseInteractor = MouseActivity,
		FrameRate = 60,
		OnCreatedDelegate = OnCreated,
		OnTickDelegate = OnTick,
		--OnQuitDelegate = onquit,
		Extent = {1024,768},
		})

Processing.Renderer = RendererGdi(win.GDIContext)

-- The begin() function is used to get things running
begin = function()
	periodic(Functor(OnTick,win), 1000/30)
	win:run()
end

return Processing
