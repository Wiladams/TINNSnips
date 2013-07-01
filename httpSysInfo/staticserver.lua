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
local SCManager = require("SCManager");
local JSON = require("dkjson");
local Query = require("Query");
local utils = require("utils");
local OSProcess = require("OSProcess");
local Workstation = require("Workstation");
local pages = require("pages");
local ScreenShare = require("ScreenShare");

local station = Workstation();



local getRecords = function(source, filterfunc)
	local res = {}
	for record in Query.query {
		source = source,
		filter = filterfunc,
	} do
		table.insert(res,record);
	end

	return res;
end


local getServices = function(filterfunc)
	local mgr, err = SCManager();

	local res = {};

	for record in Query.query {
		source = mgr:services(), 

		filter = filterfunc,
		} do
		table.insert(res, record);
	end

	return res;
end

local getProcesses = function(filterfunc)
	local res = {};
	
	for record in Query.query {
		source = OSProcess:processes(), 

		filter = filterfunc,
		} do
		table.insert(res, record);
	end

	return res;
end




local HandleSingleRequest = function(stream, pendingqueue)
	local request, err  = HttpRequest.Parse(stream);

	if not request then
		print("HandleSingleRequest, Dump stream: ", err)
		return 
	end

	local urlparts = URL.parse(request.Resource);
	local queryparts;
	local filterfunc;

	if urlparts.query then
		queryparts = utils.parseparams(urlparts.query);

		filterfunc = function(self, record)
			return Query.recordfilter(record, queryparts);
		end
	end

	local response = HttpResponse.Open(stream)
--print("PATH: ", urlparts.path);
--for k,v in pairs(request.Headers) do
--	print(k,v);
--end
	if urlparts.path == "/" then
		response:writeHead("200")
		response:writeEnd(pages.index);
  	elseif urlparts.path == "/favicon.ico" then
    	local success, err = StaticService.SendFile("favicon.ico", response)
  	elseif string.find(urlparts.path, "/desktop") then
  		print("/DESKTOP ++++++")
    	local success, err = ScreenShare.handleRequest(request, response);
	elseif urlparts.path == "/services" then
		local res = getServices(filterfunc);
		local jsonstr = JSON.encode(res, {indent=true});

		--print("echo")
		response:writeHead("200")
		response:writeEnd(jsonstr);
	elseif urlparts.path == "/processes" then
		local res = getProcesses(filterfunc);
		local jsonstr = JSON.encode(res, {indent=true});

		response:writeHead("200")
		response:writeEnd(jsonstr);
	elseif urlparts.path == "/transports" then
		local jsonstr = JSON.encode(getRecords(station:transports()), {indent=true});
		
		response:writeHead("200")
		response:writeEnd(jsonstr);		
	elseif urlparts.path == "/uses" then
		local jsonstr = JSON.encode(getRecords(station:uses(1)), {indent=true});
		
		response:writeHead("200")
		response:writeEnd(jsonstr);		
	elseif urlparts.path == "/users" then
		local jsonstr = JSON.encode(getRecords(station:users(1)), {indent=true});
		
		response:writeHead("200")
		response:writeEnd(jsonstr);		
	elseif urlparts.path == "/login" then
		local auth = request:GetHeader("authorization");
		if not auth then
			local headers = {["WWW-Authenticate"] = 'Basic realm="redmond"'};
			response:writeHead("401", headers);
			response:writeEnd();
		else
			response:writeHead("200");
			response:writeEnd(pages.login);
		end
	else
		response:writeHead("404");
		response:writeEnd();
	end

	-- recycle the stream in case a new request comes 
	-- in on it.
	return pendingqueue:Enqueue(stream)
end


--[[ Configure and start the service ]]
local port = tonumber(arg[1]) or 8080

Runtime = WebApp({port = port, backlog=100})
Runtime:Run(HandleSingleRequest);