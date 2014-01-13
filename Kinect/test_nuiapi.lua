-- test_nuiapi.lua
local ffi = require("ffi")
local NuiApi = require("NuiApi")
local Application = require("Application")


local app = Application(true);




local function main()
	local hr = NuiApi.NuiInitialize(ffi.C.NUI_INITIALIZE_FLAG_USES_COLOR);

--[[
	local pCount = ffi.new("int[1]");
	local res = kinect_ffi.NuiGetSensorCount(pCount);

print("Sensor Count: ", res, pCount[0]);

local dwFlags = kinect_ffi.NUI_INITIALIZE_FLAG_USES_COLOR;
res =  kinect_ffi.NuiInitialize(dwFlags);

print("Initialize: ", res);

	--testangle();
--]]
	--NuiApi.NuiShutdown();

end

--main();
run(main)
