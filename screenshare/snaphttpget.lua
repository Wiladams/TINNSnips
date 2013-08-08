-- snaphttpget.lua
local sync = require("core_synch_l1_2_0");
local IOProcessor = require("IOProcessor");
local IOCPNetStream = require("IOCPNetStream");
local WebRequest = require ("WebRequest");
local WebResponse = require("WebResponse");
local URL = require("url");
local chunkiter = require ("HttpChunkIterator");

local FileStream = require("FileStream");


local resource = "http://localhost:8080/xscreen.bmp"
local urlparts = URL.parse(resource, {port="80", path="/", scheme="http"});
local hostname = urlparts.host
local authority = urlparts.authority;
local path = urlparts.path;
local port = urlparts.port;

local resourcestream, err = IOCPNetStream:create(hostname, port)

local snapscreen = function(stream, fileroot, showheaders)
	-- issue get
	local headers = {
		["Host"]		= urlparts.authority,
--		["Connection"]	= "close",
	}

	local request = WebRequest("GET", path, headers, nil);
	local success, err = request:Send(resourcestream);

	-- chunk results to file
	local response, err = WebResponse:Parse(resourcestream);

	if not response then
		print("Response ERROR: ", err);
		return false;
	end

	local httpfilename = fileroot..'.http';
	local fs = FileStream.Open(httpfilename, "wb+");
	local bmpfs = FileStream.Open(fileroot, "wb+");

	if showheaders then
		response:WritePreamble(fs);
	end

	for chunk, err in chunkiter.ReadChunks(response) do
		-- do nothing
		-- but read the chunks
		bmpfs:writeString(chunk);
		fs:writeString(chunk);
	end

	fs:Close();
	bmpfs:Close();
end

local main = function()
	for i=1,1 do
		print("snap frame: ", i);
		local filename = "screen"..tostring(i)..".bmp"
		snapscreen(resourcestream, filename, false);
	end
end


run(main)
