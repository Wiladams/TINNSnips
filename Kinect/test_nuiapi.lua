-- test_nuiapi.lua
local ffi = require("ffi")
local NuiApi = require("NuiApi")
local Application = require("Application")


local function testangle()
	local pAngle = ffi.new("long[1]")
	local hr = NuiApi.NuiCameraElevationGetAngle(pAngle)

	print("Angle: ", hr, pAngle[0])

	hr = NuiApi.NuiCameraElevationSetAngle(ffi.C.NUI_CAMERA_ELEVATION_MINIMUM);

	sleep(2000)

	hr = NuiApi.NuiCameraElevationSetAngle(ffi.C.NUI_CAMERA_ELEVATION_MAXIMUM);

	sleep(2000)

	hr = NuiApi.NuiCameraElevationSetAngle(0);

	sleep(2000)
end

local function main()
	local hr = NuiApi.NuiInitialize(ffi.C.NUI_INITIALIZE_FLAG_USES_COLOR);
	print("NuiInitialize: ", hr);

	local pCount = ffi.new("int[1]");
	local res = NuiApi.NuiGetSensorCount(pCount);
	print("Sensor Count: ", res, pCount[0]);


	testangle();

	NuiApi.NuiShutdown();

end

run(main)
