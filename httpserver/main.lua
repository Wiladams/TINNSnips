--[[
	Description: A very simple demonstration of one way a static web server
	can be built using TINN.

	In this case, the WebApp object is being used.  
	A resource map is provided, which simply maps all calls to being
	file retrievals, if the 'GET' method is used.

	Either a file is fetched, or an error is returned.

	Usage:
	  tinn main.lua 8080

	default port used is 8080
]]

local resourceMap = require("ResourceMap");
local ResourceMapper = require("ResourceMapper");
local HttpServer = require("HttpServer")


local port = arg[1] or 8080

local Mapper = ResourceMapper(resourceMap);
local Logfile = require("Logfile")
local Server = nil;

--local logger = Logfile("requests.log")


local OnRequest = function(request, response)
	local handler, err = Mapper:getHandler(request)

	--logger:writeString(string.format("Date: %s\t%s\t%s\r\n", os.date("%c"), request.Method, request.Resource));

	-- recycle the socket, unless the handler explictly says
	-- it will do it, by returning 'true'
	if handler then
		if not handler(request, response) then
			Server:HandleRequestFinished(request);
		end
	else
		print("NO HANDLER: ", request.Url.path);
		-- send back content not found
		response:writeHead(404);
		response:writeEnd();

		-- recylce the request in case the socket
		-- is still open
		Server:HandleRequestFinished(request);
	end

end


Server = HttpServer(port, OnRequest);
Server:run()
