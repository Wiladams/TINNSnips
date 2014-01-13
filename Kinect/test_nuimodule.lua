-- test_nuimodule.lua
local ffi = require("ffi")

local OSModule = require("OSModule")
local NuaApi = require("NuiApi")

local nuimodule, err = OSModule("Kinect10.dll")

print("nuimodule: ", nuimodule, err)

-- get a pointer to the NuiInitialize function
print("nuimodule.NuiInitizlize: ", nuimodule["NuiInitialize"]);
--print("nuimodule.NuiGetSensorCount: ", nuimodule.NuiGetSensorCount);
