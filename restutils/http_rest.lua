
local StopWatch = require("StopWatch");
local Collections = require ("Collections");

local Application = require("Application");
local NetStream = require("NetStream");
local FileStream = require ("FileStream");

local URL = require ("url");
local WebRequest = require ("WebRequest");
local WebResponse = require("WebResponse");
local chunkiter = require ("HttpChunkIterator");

local sout = FileStream()


local http_get = function(resource, showheaders, onfinish)
print("http_get: ", resource, showheaders, onfinish)
	if not resource then
		return onfinish(nil, "no resource specified");
	end

	local urlparts = URL.parse(resource, {port="80", path="/", scheme="http"});

	local hostname = urlparts.host
	local path = urlparts.path
	local port = urlparts.port

	print("URL: ", hostname, port, path);

	-- Open up a stream to get the real content
	local resourcestream, err = NetStream:connect(hostname, port)

	if not resourcestream then
		return onfinish(nil, err)
	end

	-- Send a proper http request to the service
	if port and port ~= "80" then
		hostname = hostname..':'..port
	end

	local headers = {
		["Host"]		= urlparts.authority,
		["Connection"]	= "close",
	}
	if urlparts.query then
		path = path..'?'..urlparts.query
	end

	local request = WebRequest("GET", path, headers, nil);
	local success, err = request:Send(resourcestream);

	if not success then
		return onfinish(false, err)
	end

	local response, err = WebResponse:Parse(resourcestream);

	if response then
		-- successful read of preamble
		-- so print it out, and keep out of queue
		if showheaders then
			response:WritePreamble(sout);
		end

		for chunk, err in chunkiter.ReadChunks(response) do
			-- do nothing
			-- but read the chunks
			io.write(chunk);
		end
		result = "OK";
	else
		result = err;
	end
	
	return onfinish(result);
end

return {
	GET = http_get,
}
