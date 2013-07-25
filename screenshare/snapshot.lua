-- ScreenCapture.lua
local sync = require("core_synch_l1_2_0");

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

snapscreen("screen1.bmp");

print("snap another")
sync.Sleep(500);

snapscreen("screen2.bmp");
