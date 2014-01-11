local FileStream = require("FileStream")

--local logFile = FileStream("logfile.txt")

local Runtime = {}

Runtime.stop = function()

	logFile:Close();
	stop();
end

Runtime.write = function(...)
--io.write("write: ", ...)
--[[
	local args= {...}
--	for _,arg in ipairs(args) do
--		logFile:writeString(tostring(arg));
--	end
--]]
end

Runtime.writeLine = function(...)
---print("writeLine:", ...)
--[[
	local args= {...}
print("writeLine: ",...)

--	for _,arg in ipairs(args) do
--		logFile:writeString(tostring(arg));
--	end
	logFile:writeString("\r\n")
--]]
end

return Runtime
