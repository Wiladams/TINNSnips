
local WebApp = require("WebApp")


local HttpRequest = require "HttpRequest"
local HttpResponse = require "HttpResponse"
local URL = require("url");
local StaticService = require("StaticService");


local contentTemplate = [[
<html>
	<head><title>This is the title</title></head>
	<body>
		Hello, World!
	</body>
</html>
]]



local HandleSingleRequest = function(stream, pendingqueue)
	local request, err  = HttpRequest.Parse(stream);

	if not request then
		-- dump the stream
		--print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource)
	
--	print(urlparts.scheme, urlparts.path)
	

	if urlparts.path == "/ping" then
		--print("echo")
		local response = HttpResponse.Open(stream)
		response:writeHead("204")
		response:writeEnd();
	else
		local filename = './wwwroot'..urlparts.path;
--		print("FILE: ", filename);
	
		local response = HttpResponse.Open(stream);

		StaticService.SendFile(filename, response)
	end

	-- recycle the stream in case a new request comes 
	-- in on it.
	return pendingqueue:Enqueue(stream)
end


--[[ Configure and start the service ]]
local port = tonumber(arg[1]) or 8080

Runtime = WebApp({port = port, backlog=100})
Runtime:Run(HandleSingleRequest);