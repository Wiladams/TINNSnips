-- comp_handler.lua
local IOCPSocket = require("IOCPSocket");
local NetStream = require("IOCPNetStream");
local HttpRequest = require("WebRequest");
local HttpResponse = require("WebResponse");
local StaticService = require("StaticService");

local URL = require("url");

local pingtemplate = [[
<html>
  <head>
    <title>iocpserver</title>
  </head>
  <body>Hello, World</body>
</html>
]]

HandleSingleRequest = function(stream)
	local request, err  = HttpRequest:Parse(stream);
	if not request then
		print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource)

print(string.format("PATH: %s", urlparts.path));

	if urlparts.path == "/ping" then
		--print("echo")
		local response = HttpResponse:OpenResponse(stream)
		response:writeHead("200")
		response:writeEnd(pingtemplate);
	else
		local filename = './wwwroot'..urlparts.path;
	
		local response = HttpResponse:OpenResponse(stream);

		StaticService.SendFile(filename, response);
	end
end

local HandleNewConnection = function(sock)
	print("HandleNewConnection: ", sock);

	local socket = IOCPSocket:init(sock, IOProcessor);
	local netstream = NetStream:init(socket);

	socket:send("HTTP/1.1 200 OK\r\n")
	socket:send("Host: localhost\r\n");
	socket:send("\r\n");
	socket:send(pingtemplate);


	if HandleSingleRequest then
		--print("HandleSingleRequest Defined")
		HandleSingleRequest(netstream);
	else
		print("HandleSingleRequest, NOT defined")
	end

	-- close the stream
	-- an alternative is to pass along to a defined continuation
	--netstream:closeDown();

	-- not strictly needed here, but instructive
	--collectgarbage();
end

OnIdle = function(counter)
	if newConnectionQueue then
		key, bytetrans, overlap = newConnectionQueue:dequeue();
		if not key then
			return ;
		end

		spawn(HandleNewConnection, key);
	end
end


