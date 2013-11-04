-- test_nuiapi.lua
local ffi = require("ffi")
local kinect = require("kinect10_ffi")
local IOProcessor = require("IOProcessor")



local testangle = function()
	local plAngleDegrees = ffi.new("LONG[1]")
	res = kinect.NuiCameraElevationGetAngle(plAngleDegrees);

	if res ~= 0 then
		print("ERROR Reading Camera: ", res);
		return false, res
	end

	print("Elevation Angle: ", plAngleDegrees[0])

	-- set it to zero
	res = kinect.NuiCameraElevationSetAngle(1)
	print("Angle set to Zero: ", res)
	wait(300)

	-- set it to max
	--res = kinect.NuiCameraElevationSetAngle(1)
	res = kinect.NuiCameraElevationSetAngle(kinect.NUI_CAMERA_ELEVATION_MAXIMUM)
	print("Angle set to MAX: ", res)
	wait(300);

	-- set it to min
	res = kinect.NuiCameraElevationSetAngle(kinect.NUI_CAMERA_ELEVATION_MINIMUM)
	print("Angle set to MIN: ", res)
	wait(300)
	
	-- set it back to zero
	res = kinect.NuiCameraElevationSetAngle(0)
	print("angle  back to zero: ", res)

end


local main = function()
	local pCount = ffi.new("int[1]");

	local res = kinect.NuiGetSensorCount(pCount);

print("Sensor Count: ", res, pCount[0]);

local dwFlags = kinect.NUI_INITIALIZE_FLAG_USES_COLOR;
res =  kinect.NuiInitialize(dwFlags);

print("Initialize: ", res);

	testangle();

	--kinect.NuiShutdown();
end

run(main)
