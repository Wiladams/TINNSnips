
local ffi = require("ffi")
local NuiApi = require("NuiApi")
local NuiImageStream = require("NuiImageStream")
local Application = require("Application")
local WinError = require("win_error")


local getSensorCount = function()
	-- See how many sensors exist
	local pCount = ffi.new("int[1]");

	local res = NuiApi.NuiGetSensorCount(pCount);
	
	if res ~= 0 then
		return false, res
	end

	return pCount[0]
end

local function loop(imgstream)
	while true do
		local frame, err = imgstream:getNextFrame(1000/15);
		if frame then
			print("Frame: ", frame)
			frame:release();
		else
			if err then
				print(HRESULT_PARTS(err))
			end
		end
		collectgarbage();
	end
end

local function main()
	local hr = NuiApi.NuiInitialize(ffi.C.NUI_INITIALIZE_FLAG_USES_COLOR);
	if hr ~= 0 then
		print("Initialization ERROR: ", hr)
		return false;
	end

	local nSensors, err = getSensorCount();

	print("Sensor Count: ", nSensors, err)

	if nSensors < 1 then
		print("NO SENSORS")
		return false
	end

	local strm, err = NuiImageStream();

	if err then
		print(HRESULT_PARTS(hr))
	end

	coop(loop, strm)
end

run(main)
