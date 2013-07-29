--[[
	Description: A very simple demonstration of one way a static web server
	can be built using TINN.

	In this case, the HttpServer object is being used.  It is handed a routine to be
	run for every http request that comes in (HandleSingleRequest()).

	Either a file is fetched, or an error is returned.

	Usage:
	  tinn main.lua [port]

	default port used is 8080

			<script type="text/javascript" src="jquery.js"></script>
		<script type="text/javascript" src="minified-web.noie.js"

]]

local HttpServer = require("HttpServer")

local ResourceMapper = require("ResourceMapper");
local ResourceMap = require("ResourceMap");

--[[ Configure and start the service ]]
local argv = {...}
serviceport = tonumber(argv[1]) or 8080

local mapper = ResourceMapper(ResourceMap);


local OnRequest = function(param, request, response)
--print("OnRequest(): ", request.Url.path)
	local handler, err = mapper:getHandler(request)

	if handler then
		handler(request, response);
	else
		print("NO HANDLER: ", request.Url.path);
		-- send back content not found
		response:writeHead(404);
		response:writeEnd();

		-- recylce the request in case the socket
		-- is still open
		recycleRequest(request);
	end
end



--[[ 
  Start running the service 
--]]
local server = HttpServer(serviceport, OnRequest);
recycleRequest = function(request)
	return server:HandleRequestFinished(request);
end

server:run();
