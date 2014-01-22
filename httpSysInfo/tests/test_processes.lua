-- test_processes.lua

local ffi = require("ffi")
local errorhandling = require("core_errorhandling_l1_1_1");
local core_psapi = require("core_psapi_l1_1_0");
local OSProcess = require("OSProcess")
local JSON = require("dkjson")
local ResourceMapper = require("ResourceMapper");
local HttpServer = require("HttpServer")
local routines = require("routines")



function processIds(self)
	-- enumerate processes
print("processIds, 1.0")
	local pProcessIds = ffi.new("DWORD[1024]");
	local cb = ffi.sizeof(pProcessIds);
	local pBytesReturned = ffi.new("DWORD[1]");

print("processIds, 2.0")

	--local status = Lib.EnumProcesses(pProcessIds, cb, pBytesReturned);
	local status = routines.EnumProcesses(pProcessIds, cb, pBytesReturned);

print("processIds, 3.0")

--print("processIds: ", status)

	if status == 0 then
		local err = errorhandling.GetLastError();
		print("ERROR: ", err)
		return false, err;
	end 

	local cbNeeded = pBytesReturned[0];
	local nEntries = cbNeeded / ffi.sizeof("DWORD");

print("Needed: ", cbNeeded, nEntries)

	local idx = -1;

	local function closure()
		idx = idx + 1;
		if idx >= nEntries then
			return nil;
		end

		return pProcessIds[idx];
	end

	return closure;
end


local function getProcessData()
print("getProcessData, 1.0")

	local res = {};
--[[
	for proc in processIds() do
		local record = {id = proc}
		table.insert(res, record)
	end
--]]

---[[
	for proc in OSProcess:processes() do
		print("Process: ", proc)
		local record = {
			id = proc:getId(), 
			filename = proc:getImageName(),
			priorityClass = proc:getPriorityClass(),
			sessionId = proc:getSessionId(),
			isActive = proc:isActive(),
		}
		table.insert(res, record)
	end
--]]
print("getprocessData - END")

	return res;
end

local function HandleProcessesGETData(request, response)
	--Runtime.writeLine("HandleProcessesGETData - BEGIN")
print("HandleProcessesGETData, 1.0")


	local body = JSON.encode(getProcessData(), {indent=true});

print("HandleProcessesGETData, 2.0")
	local headers = {
		["Content-Type"] = "application/json",
	}
	
print("HandleProcessesGETData, 3.0")
	response:writeHead("200", headers)
print("HandleProcessesGETData, 4.0")
	response:writeEnd(body);
print("HandleProcessesGETData, 5.0")

end

local ResourceMap = {
	["/processes/data"] 			= {name="/processes/data",
		GET					= HandleProcessesGETData,
	};
}

local Mapper = ResourceMapper(ResourceMap);
local Server = nil;

local function OnRequest(request, response)
	getProcessData();
	--HandleProcessesGETData(request, response)

--[[
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
--]]
end

Server = HttpServer(8080, OnRequest);
Server:run()
