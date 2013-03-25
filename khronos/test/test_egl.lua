package.path = package.path..";Win32\\?.lua";

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local NativeWindow = require "User32Window"
local EGL = require "egl_utils"

local OpenVG = require "OpenVG"
local OpenVGUtils = require "OpenVG_Utils"
local ogm = require "OglMan"

local dpy = EglDisplay.new(nil, EGL.EGL_OPENVG_API);
assert(dpy, "EglDisplay not created");

local screenWidth = 640;
local screenHeight = 480;



-- Start begins the picture, clearing a rectangular region with a specified color
function Start(width, height) 

	local color = ffi.new("VGfloat[4]", 255, 255, 255, 1);
	EGL.Lib.vgSetfv(ffi.C.VG_CLEAR_COLOR, 4, color);
	EGL.Lib.vgClear(0, 0, width, height);
	color[0] = 0;
	color[1] = 0; 
	color[2] = 0;
	setfill(color);
	setstroke(color);
	--StrokeWidth(0);
	EGL.Lib.vgLoadIdentity();
end

-- End checks for errors, and renders to the display
function End(display)
	--assert(EGL.Lib.vgGetError() == ffi.C.VG_NO_ERROR);
	display:SwapBuffers();
	--assert(EGL.Lib.eglGetError() == EGL.EGL_SUCCESS);
end
--
-- Color functions
--
--

-- RGBA fills a color vectors from a RGBA quad.
function RGBA(r, g, b, a, color) 
	if (r > 255) then
		r = 0;
	end
	if (g > 255) then
		g = 0;
	end
	if (b > 255) then
		b = 0;
	end
	if (a < 0.0 or a > 1.0) then
		a = 1.0;
	end
	
	color[0] = r / 255.0;
	color[1] = g / 255.0;
	color[2] = b / 255.0;
	color[3] = a;
	
	return color
end

-- RGB returns a solid color from a RGB triple
function RGB(r, g, b, color) 
	return RGBA(r, g, b, 1.0, color);
end

--
-- Style functions
--

-- setfill sets the fill color
function setfill(color) 
	local fillPaint = OpenVGUtils.Paint();
	fillPaint:SetType(ffi.C.VG_PAINT_TYPE_COLOR);
	fillPaint:SetColor(color);
	fillPaint:SetModes(ffi.C.VG_FILL_PATH);
end

-- setstroke sets the stroke color
function setstroke(color) 
	local strokePaint = OpenVGUtils.Paint();
	strokePaint:SetType(ffi.C.VG_PAINT_TYPE_COLOR);
	strokePaint:SetColor(color);
	strokePaint:SetModes(ffi.C.VG_STROKE_PATH);
end

-- Fill sets the fillcolor, defined as a RGBA quad.
function Fill(r, g, b, a) 

	local color = ffi.new("VGfloat[4]")
	RGBA(r, g, b, a, color);
	setfill(color);
end

-- Rect makes a rectangle at the specified location and dimensions
function Rect(x, y, w, h) 
	local path = OpenVGUtils.Path();
	EGL.Lib.vguRect(path.Handle, x, y, w, h);
	path:Draw();
end

-- Ellipse makes an ellipse at the specified location and dimensions
function Ellipse(x, y, w, h) 
	local path = OpenVGUtils.Path();
	EGL.Lib.vguEllipse(path.Handle, x, y, w, h);
	path:Draw(bor(ffi.C.VG_FILL_PATH,ffi.C.VG_STROKE_PATH));
end

-- Circle makes a circle at the specified location and dimensions
function Circle(x, y, r)
	Ellipse(x, y, r, r);
end

-- clear the screen to a background color
function Background(r, g, b) 

	Fill(r, g, b, 1);
	Rect(0, 0,screenWidth, screenHeight);
end






local tick = function(ticker, tickCount)
	print("Tick: ", tickCount);
	
	Start(screenWidth, screenHeight)
	Background(0, 0, 0);				   -- Black background
	Fill(44, 77, 232, 1);				   -- Big blue marble
	Circle(screenWidth / 2, 0, screenWidth);		-- The "world"
	Fill(255, 255, 255, 1);					-- White text

	End(dpy);
end



-- Create a window
local winParams = {
	ClassName = "EGLWindow",
	Title = "EGL Window",
	Origin = {10,10},
	Extent = {screenWidth, screenHeight},
	FrameRate = 3,

	OnTickDelegate = tick;
};


-- create an EGL window surface
local win = NativeWindow.new()
assert(win, "Window not created");
win.OnTickDelegate = tick;

local surf = dpy:CreateWindowSurface(win:GetHandle())

-- Make the context current
dpy:MakeCurrent();

glViewport(0,0,screenWidth,screenHeight);
glMatrixMode(GL_PROJECTION);
glLoadIdentity();

local ratio = screenWidth/screenHeight;
glFrustum(-ratio, ratio, -1, 1, 1, 10);


Start(screenWidth, screenHeight);
Background(0,0,0);
Fill(44, 77, 232, 1);

-- Now, finally do some drawing
win:Run();


-- free up the display
dpy:free();