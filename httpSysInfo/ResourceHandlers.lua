local JSON = require("dkjson");
local pages = require("pages");
local StaticService = require("StaticService");
local Query = require("Query");
local utils = require("utils");
local OSProcess = require("OSProcess");
local SCManager = require("SCManager");
local HandleFileSystem = require("HandleFileSystem")


local Handlers = {}

-- /
-- /login
Handlers.HandleLoginGET = function(request, response)
	local auth = request:GetHeader("authorization");

	if not auth then
		local headers = {["WWW-Authenticate"] = 'Basic realm="redmond"'};
		response:writeHead("401", headers);
		response:writeEnd();
	else
		response:writeHead("200");
		response:writeEnd(pages.index);
	end

    return recycleRequest(request);
end

Handlers.HandleDefaultGET = function(request, response)
	response:writeHead("200")
	response:writeEnd(pages.index);

	-- StaticService.SendFile("."..urlparts.path, response);
    return recycleRequest(request);
end

-- favicon.ico
Handlers.HandleFaviconGET = function(request, response)
    StaticService.SendFile("favicon.ico", response)

    return recycleRequest(request);
end

Handlers.HandleJQueryGET = function(request, response)
    StaticService.SendFile("jquery.js", response)

    return recycleRequest(request);
end


Handlers.HandleServicesGET = function(request, response)
	local filterfunc;

	if request.Url.query then
		queryparts = utils.parseparams(request.Url.query);

		filterfunc = function(self, record)
			return Query.recordfilter(record, queryparts);
		end
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

	local res = getServices(filterfunc);
	local jsonstr = JSON.encode(res, {indent=true});

	--print("echo")
	response:writeHead("200")
	response:writeEnd(jsonstr);

	return recycleRequest(request);
end

-- /processes
Handlers.HandleProcessesGET = function(request, response)
	local filterfunc;

	if request.Url.query then
		queryparts = utils.parseparams(request.Url.query);

		filterfunc = function(self, record)
			return Query.recordfilter(record, queryparts);
		end
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

	local res = getProcesses(filterfunc);
	local jsonstr = JSON.encode(res, {indent=true});

	response:writeHead("200")
	response:writeEnd(jsonstr);

	return recycleRequest(request);
end

--[[
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

local Workstation = require("Workstation");
local station = Workstation();

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
		StaticService.SendFile("."..urlparts.path, response);
	end
--]]

return Handlers;
