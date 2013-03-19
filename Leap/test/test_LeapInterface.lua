package.path = package.path.."../../?.lua"

local ffi = require("ffi");
local LeapInterface = require("Leap.LeapInterface");

local leap, err = LeapInterface();

print(leap, err);

if not leap then
	return false, err
end

local readRawFrames = function(leap)
	for frame in leap:RawFrames() do
		print(ffi.string(frame.Data, frame.DataLength));
	end
end


local main = function()
	spawn(readRawFrames, leap);
end

run(main);
