-- comp_getbing.lua
--IOProcessor = require("IOProcessor");
local IOCPNetStream = require("IOCPNetStream");
local HttpRequest = require("WebRequest");
local HttpResponse = require("WebResponse");
local HttpChunkIterator = require("HttpChunkIterator");

local hostname = "localhost"

local netstream, err = IOCPNetStream:create(hostname, 8080);

local function GET()

	if not netstream then
		print("netstream, ERROR: ", err);
		return false, err;
	end

	local request = HttpRequest("GET", "/ping", {Host= hostname});
	request:Send(netstream);

--print("== REQUEST ==");
--print(request);
--print("** REQUEST **");

	--local bytes, err = netstream:writeString(request);

--print("after writeLine: ", bytes, err);
	local response = HttpResponse:Parse(netstream);
	print("== RESPONSE ==")
	print(response.Status, response.Phrase);

	for chunk in HttpChunkIterator.ReadChunks(response) do
		print(chunk);
	end

	exit();
end

IOProcessor:spawn(GET);

