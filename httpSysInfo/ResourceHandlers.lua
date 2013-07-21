local JSON = require("dkjson");
local pages = require("pages");
local StaticService = require("StaticService");
local Query = require("Query");
local utils = require("utils");
local OSProcess = require("OSProcess");
local SCManager = require("SCManager");
local ScreenShare = require("ScreenShare");
local FileSystem = require("FileSystem");


local Handlers = {}
local wfs = FileSystem("c:");

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
end

Handlers.HandleDefaultGET = function(request, response)
	response:writeHead("200")
	response:writeEnd(pages.index);

	-- StaticService.SendFile("."..urlparts.path, response);
end

-- favicon.ico
Handlers.HandleFaviconGET = function(request, response)
    return StaticService.SendFile("favicon.ico", response)
end

Handlers.HandleJQueryGET = function(request, response)
    return StaticService.SendFile("jquery.js", response)
end

-- /files
Handlers.HandleFilesGET = function(request, response)
print("HandleFilesGET(): ", request.Url.path);

	-- get the relative path
	local relativePath = request.Url.path:sub(7);

print("REL PATH: ", relativePath);
	if relativePath ~= '' then
		fsItem = wfs:getItem(relativePath);
		
		if not fsItem then
			response:writeHead(400);
			response:writeEnd();
			return true;		
		end

		-- if it's a file, then return the file using
		-- the static handler
		if not fsItem:isDirectory() then
    		return StaticService.SendFile(relativePath, response);
		end
	end

	-- If we've gotten to here, we've got a directory that we 
	-- need to list.
	local searchPath = relativePath.."/*";

print("SEARCH: ", searchPath);


    local headers = {
        ["Server"] = "http-server",
        ["Content-Type"] = "text/html",
        ["Connection"] = "close",
    };

    response:writeHead("200", headers);

    local body = {};
    table.insert(body, "<html><head><title>Files in " .. relativePath .. "</title></head>");
    table.insert(body, "<body><h2>Files in " .. request.Url.path .. "</h2>\n");
    table.insert(body, "<ul>\n");

    for item in wfs:getItems(searchPath) do
    	-- skip various undesirable files and
    	-- directories
    	if item.Name ~= "." and item.Name ~= ".." and
    		not item:isHidden() and not item:isSystem() then
    		local filepath
    		if relativePath ~= "" then
    			filepath = relativePath..'/'..item.Name;
    		else
    			filepath = '/'..item.Name;
    		end

        	if item:isDirectory() then
        		table.insert(body, [[<li><a href="\files]] .. filepath.. [[">]] .. item.Name .. [[/</a></li>]]);
         	else
        		table.insert(body, [[<li><a href="\files]] .. filepath.. [[">]] .. item.Name .. [[</a></li>]]);
    		end
    	end
    end

    table.insert(body, "</ul></body></html>\n");
    local stuffit = table.concat(body);
    return response:writeEnd(stuffit);
end

-- /desktop
Handlers.HandleDesktopGET = function(request, response)
--print("HandleDesktopGET")
	return ScreenShare.handleRequest(request, response);
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
