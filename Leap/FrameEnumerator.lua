local JSON = require("dkjson");
local ffi = require("ffi");

local FrameEnumerator = function(interface)
	local nextFrame = interface:RawFrames();

	local closure = function()
		local rawframe = nextFrame();
		return JSON.decode(ffi.string(rawframe.Data, rawframe.DataLength));
	end

	return closure;
end

return FrameEnumerator
