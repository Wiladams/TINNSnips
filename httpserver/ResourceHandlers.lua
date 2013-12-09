local URL = require("url");
local FileService = require("FileService");
local MemoryStream = require("MemoryStream")

local function replacedotdot(s)
    return string.gsub(s, "%.%.", '%.')
end

local HandleFileGET = function(request, response)
    local absolutePath = replacedotdot(URL.unescape(request.Url.path));

    if absolutePath == "/" then
    	absolutePath = "/index.htm"
    end

	local filename = './wwwroot'..absolutePath;
	
	FileService.SendFile(filename, response)

	return false;
end

local HandleEchoGET = function(request, response)
	-- write the request into a memory buffer
	local ms = MemoryStream(16*1024);
	request:Send(ms)

	-- write the memory buffer as a response
	response:writeHead(200, {["Content-Type"] = "text/plain"})
	response:writeEnd(ms:ToString())
end

local HandleLogGET = function(request, response)
	-- read the logfile into memory
	local fs = io.open("requests.log")
	local logdata = fs:read("*all");
	fs:close();

	response:writeHead(200, {["Content-Type"] = "text/plain"})
	response:writeEnd(logdata)
end

return {
	HandleEchoGET = HandleEchoGET,
	HandleFileGET = HandleFileGET,
	HandleLogGET = HandleLogGET,
}