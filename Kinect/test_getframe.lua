
local ffi = require("ffi")
local kinect = require("kinect10_ffi")
local SecError = require("SecError")

local getSensorCount = function()
	-- See how many sensors exist
	local pCount = ffi.new("int[1]");

	local res = kinect.NuiGetSensorCount(pCount);
	
	if res ~= 0 then
		return false, res
	end

	return pCount[0]
end


local getImageStream = function(eImageType, eResolution)
	eImageType = eImageType or ffi.C.NUI_IMAGE_TYPE_COLOR;
	eResolution = eResolution or ffi.C.NUI_IMAGE_RESOLUTION_640x480;
	local dwImageFrameFlags = 0;
	local dwFrameLimit = 2;
	local hNextFrameEvent = nil;
	local phStreamHandle = ffi.new("HANDLE [1]")
	
	local hr = kinect.NuiImageStreamOpen(
    	eImageType,
    	eResolution,
    	dwImageFrameFlags,
    	dwFrameLimit,
    	hNextFrameEvent,
    	phStreamHandle);

	local severity, facility, code = HRESULT_PARTS(hr)

print("ERRORS: ", severity, facility, code)

	if hr ~= 0 then
		return false, hr;
	end

	return phStreamHandle[0];
end



local nSensors, err = getSensorCount();

print("Sensor Count: ", nSensors, err)

if nSensors < 1 then
	print("NO SENSORS")
	return false
end

local strm, err = getImageStream()


print("strm, err: ", strm, err)
