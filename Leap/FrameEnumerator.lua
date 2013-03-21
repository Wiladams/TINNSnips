local JSON = require("dkjson");
local ffi = require("ffi");

local FrameEnumerator = function(interface)

	local closure = function()
		for rawframe in interface:RawFrames() do
			local frame = JSON.decode(ffi.string(rawframe.Data, rawframe.DataLength));
			return frame;
		end
	end	

	return closure;
end

return FrameEnumerator
