-- ScreenCapture.lua
local sync = require("core_synch_l1_2_0");
local IOProcessor = require("IOProcessor")

local ScreenCapture = require("ScreenCapture");
local FileStream = require("FileStream");

local screenCap = ScreenCapture();

local snapscreen = function(filename)
	local fs = FileStream.Open(filename, "wb+");
	screenCap:captureScreen();

	local contentlength = screenCap.CapturedStream:GetPosition()

	fs:writeBytes(screenCap.CapturedStream.Buffer, contentlength)
	fs:Close();
end

for i=1,10 do
	print("snap frame: ", i);
	local filename = "screen"..tostring(i)..".bmp"
	snapscreen(filename);

	sync.Sleep(500);
end

