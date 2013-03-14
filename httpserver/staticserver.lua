--[[
	Description: A very simple demonstration of one way a static web server
	can be built using TINN.

	In this case, the WebApp object is being used.  It is handed a routine to be
	run for every http request that comes in (HandleSingleRequest()).

	Either a file is fetched, or an error is returned.

	Usage:
	  tinn staticserver.lua 8080

	default port used is 8080
]]

local WebApp = require("WebApp")


local HttpRequest = require "HttpRequest"
local HttpResponse = require "HttpResponse"
local URL = require("url");
local StaticService = require("StaticService");



local HandleSingleRequest = function(stream, pendingqueue)
	local request, err  = HttpRequest.Parse(stream);

	if not request then
		print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource)
	

	if urlparts.path == "/ping" then
		--print("echo")
		local response = HttpResponse.Open(stream)
		response:writeHead("204")
		response:writeEnd();
	else
		local filename = './wwwroot'..urlparts.path;
	
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