-- page 335
package.path = package.path..";../?.lua"

local ffi = require("ffi");
local bit = require("bit");
local band = bit.band;
local bxor = bit.bxor;

local View3D = require("View3D");

ffi.cdef[[
typedef struct {
	uint8_t	r;
	uint8_t g;
	uint8_t b;
} pixel_RGB_b;
]]
local PixelRGB = ffi.typeof("pixel_RGB_b");


local CheckerboardPattern_t = {}
local CheckerboardPattern_mt = {
	__index = CheckerboardPattern_t;
}

local CheckerboardPattern = function(w, h)
	w = w or 64
	h = h or 64
	local pixelBuff = ffi.typeof("pixel_RGB_b[$][$]", h, w);
	
	local obj = {
		Width = w;
		Height = h;
		Data = pixelBuff();
	}

	setmetatable(obj, CheckerboardPattern_mt);

	function bitnum(value)
		if value then return 1 else return 0 end
	end

	local i = 0;
	local j = 0;
	local c = 0;

	for i=0, obj.Height-1 do
		for j=0, obj.Width-1 do
			c = bxor(bitnum((band(i,0x8)==0)), bitnum((band(j,0x8)==0)))  * 255;
			obj.Data[i][j] = PixelRGB(c,c,c)
		end
	end

	return obj;
end



local height = 0;
local zoomFactor = 1;
local pattern = CheckerboardPattern(64,64);


function init()
	glClearColor(0,0,0,0);
	glShadeModel(GL_FLAT);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
end

function display()
	glClear(GL_COLOR_BUFFER_BIT);
	glRasterPos2i(0,0);
	gl.glDrawPixels(pattern.Width, pattern.Height, GL_RGB, GL_UNSIGNED_BYTE, pattern.Data);
	glFlush();
end

function reshape(w,h)
	glViewport(0,0,w,h);

	height = h;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0,w, 0,h);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
end

local screeny = 0;

function motion()
	screeny = height - y;
	gl.glRasterPos2i(x, screeny);
	gl.glPixelZoom(zoomFactor, zoomFactor);
	gl.glCopyPixels(0,0,checkImageWidth, checkImageHeight, GL_COLOR);
	gl.glPixelZoom(1, 1);
	glFlush();
end

function keychar(event)
	local key = event.char;

	if key == 'r' or key == 'R' then
		zoomFactor = 1;
	end

	if key == 'z' then
		zoomFactor = zoomFactor + 0.5;
		if zoomFactor >= 3 then
			zoomFactor = 3
		end
	end

	if key == 'Z' then
		zoomFactor = zoomFactor - 0.5;
		if zoomFactor <= 0.5 then
			zoomFactor = 0.5;
		end
	end
end


run(View3D.main);
