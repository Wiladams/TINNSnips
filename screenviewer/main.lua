
-- Put this at the top of any test


local ffi = require "ffi"

local IOProcessor = require("IOProcessor")
local GameWindow = require("GameWindow")
local GDI32 = require "GDI32"
local StopWatch = require "StopWatch"
local chunkiter = require "HttpChunkIterator"
local MemoryStream = require("MemoryStream");
local BinaryStream = require("BinaryStream");
local NetStream = require ("NetStream");
local URL = require ("url");
local HttpRequest = require ("WebRequest");
local HttpResponse = require("WebResponse");
local zlib = require "zlib"

local RemoteScreen = require("RemoteScreen")



local sw = StopWatch();




-- create an instance of a remote screen
local screenUrl = arg[1] or "http://localhost:8080/screen.bmp";
local screen, err = RemoteScreen(screenUrl);

print("RemoteScreen: ", screen, err)


local updateScreen = function(win)
	-- get screen content
	local info, pixels = screen:GetCurrentImage();

	if not info then 
		print("updateScreen() FAILURE: ", pixels)
		return nil, pixels
	end
	
	local XDest = 0
	local YDest = 0
	local nDestWidth = info.bmiHeader.biWidth;
	local nDestHeight = info.bmiHeader.biHeight;
	local XSrc = 0
	local YSrc = 0
	local nSrcWidth = info.bmiHeader.biWidth
	local nSrcHeight = info.bmiHeader.biHeight
	local lpBits = pixels
	local lpBitsInfo = info
	local iUsage = 0
	local dwRop = GDI32.FFI.SRCCOPY;

--print("GDI Handle: ", win.GDIContext.Handle);

	GDI32.Lib.StretchDIBits(win.GDIContext.Handle,
		XDest,YDest,nDestWidth,nDestHeight,
		XSrc,YSrc,nSrcWidth,nSrcHeight,
		lpBits,
		lpBitsInfo,
		iUsage,dwRop);
end


-- The routine that gets called for any
-- mouse activity messages
function mouseinteraction(msg, wparam, lparam)
	print(string.format("Mouse: 0x%x", msg))
end

function keyboardinteraction(msg, wparam, lparam)
	print(string.format("Keyboard: 0x%x", msg))
end

function ontick(win, tickCount)
	local black = RGB(0,0,0)
	win.GDIContext:SetDCPenColor(black)

	updateScreen(win)

	local stats = string.format("Seconds: %f  Frame: %d  FPS: %f", sw:Seconds(), tickCount, tickCount/sw:Seconds())
	win.GDIContext:Text(stats)
end




local function main()
-- Setup and run the application
local width = 1024;
local height = 768;
local title = "Screen Viewer"
--local appwin = NativeWindow:create(className, width, height, title);


local appwin = GameWindow({
	Title = title,
	KeyboardInteractor = keyboardinteraction,
	MouseInteractor = mouseinteraction,
	FrameRate = 15,
	OnTickDelegate = ontick,
	Extent = {width,height},
	})


appwin:Run()
end

run(main)
