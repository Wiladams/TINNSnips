-- iocpserver.lua
local HttpServer = require("HttpServer");

local StaticService = require("StaticService");

local pingtemplate = [[
<html>
  <head>
    <title>HTTP Server</title>
  </head>
  <body>ping</body>
</html>
]]

local OnRequest = function(param, request, response)
	print(string.format("PATH: %s", request.Url.path));

	if request.Url.path == "/ping" then
		--print("echo")
		response:writeHead("200")
		response:writeEnd(pingtemplate);
	else
		local filename = './wwwroot'..request.Url.path;
		StaticService.SendFile(filename, response);
	end
end

local server = HttpServer(8080, OnRequest);
server:run();
