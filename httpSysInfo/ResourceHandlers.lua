

local SysInfo = require("SysInfo");
local JSON = require("dkjson");
local pages = require("pages");
local FileService = require("FileService");
local Query = require("Query");
local utils = require("utils");
local OSProcess = require("OSProcess");
local SCManager = require("SCManager");
local HandleFileSystem = require("HandleFileSystem")
local FileService = require("FileService")
local URL = require("url")
local HtmlTemplate = require("HtmlTemplate")
local MemoryStream = require("MemoryStream")

local Handlers = {}

-- /
-- /login
Handlers.HandleLoginGET = function(request, response)
	Runtime.writeLine("GET: ", request.Resource)

	local auth = request:GetHeader("authorization");

	if not auth then
		local headers = {["WWW-Authenticate"] = 'Basic realm="redmond"'};
		response:writeHead("401", headers);
		response:writeEnd();
	else
		local pageContent = pages.getIndexPage();

		response:writeHead("200");
		response:writeEnd(pageContent);
	end

end

Handlers.HandleDefaultGET = function(request, response)
	Runtime.writeLine("HandleDefaultGET - BEGIN")

	response:writeHead("200")
	response:writeEnd(pages.index);
end

Handlers.HandleEchoGET = function(request, response)
	-- write the request into a memory buffer
	local ms = MemoryStream(16*1024);
	request:Send(ms)

	-- write the memory buffer as a response
	response:writeHead(200, {["Content-Type"] = "text/plain"})
	response:writeEnd(ms:ToString())
end

-- favicon.ico
Handlers.HandleFaviconGET = function(request, response)
	Runtime.writeLine("HandleFaviconGET - BEGIN")
    
    FileService.SendFile("favicon.ico", response)

end

Handlers.HandleJQueryGET = function(request, response)
    FileService.SendFile("jquery.js", response)
end

local getServiceData = function(request)
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

	return getServices(filterfunc)
end

local servicesTemplate = HtmlTemplate([[
<html>
  <head><title>Services</title>
  	<style>
		table
		{
			border-collapse:collapse;
		}
		table,th,td
		{
			border:1px solid black;
		}
	</style>
  </head>
  <body>
  <table summary="List of services available on machine">
    <colgroup align="center">
    <colgroup align="left">
    <colgroup align="left">
    <colgroup align="left">
    <colgroup align="left">
  <TR>
  	<TH colspan="5" scope="colgroup">Machine Services</TH>
  <TR>
    <TH scope="col" abbr="ID">Service ID</TH>
    <TH scope="col" abbr="Type">Service Type</TH>
    <TH scope="col" abbr="Name">Service Name</TH>
    <TH scope="col" abbr="Description">Display Name</TH>
    <TH scope="col" abbr="State">State</TH>
  </TR>
    <TBODY>
	<?tablebody?>
    </TBODY>
  </table>
</body>
</html>
]])

Handlers.HandleServicesGETData = function(request, response)
	Runtime.writeLine("HandleServicesGETData - BEGIN")

	local body = JSON.encode(getServiceData(request), {indent=true});

	local headers = {
		["Content-Type"] = "application/json",
	}
	
	response:writeHead("200", headers)
	response:writeEnd(body);
end

Handlers.HandleServicesGET = function(request, response)
	Runtime.writeLine("HandleServicesGET - BEGIN")
	
	local data = getServiceData(request)

--[[
ProcessId
ServiceType
ServiceName
DisplayName
State
--]]
	local createBody = function()
		local tbody = {}
		
		for _,row in ipairs(data) do
			local rowstr = string.format([[<tr><td>%d<td>%s<td>%s<td>%s<td>%s]], 
				row.ProcessId, row.ServiceType, row.ServiceName, row.DisplayName, row.State)
			table.insert(tbody, rowstr)
		end

		return servicesTemplate:fillTemplate({tablebody = table.concat(tbody)})
	end


	local headers = {
		["Content-Type"] = "text/html",
	}
	
	response:writeHead("200", headers)
	response:writeEnd(createBody());

end

-- /processes
local getProcessData = function(request)
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

	return getProcesses(filterfunc);
end


Handlers.HandleProcessesGETData = function(request, response)
	Runtime.writeLine("HandleProcessesGETData - BEGIN")

	local body = JSON.encode(getProcessData(request), {indent=true});

	local headers = {
		["Content-Type"] = "application/json",
	}
	
	response:writeHead("200", headers)
	response:writeEnd(body);

end



Handlers.HandleProcessesGET = function(request, response)
	Runtime.writeLine("HandleProcessesGET - BEGIN")
	
	local data = getProcessData(request)

--[[
id
sessionId
isActive
priorityClass
filename
--]]
	local createBody = function()
		local body = {}
		table.insert(body,
[[
<html>
  <head><title>Services</title>
	<style>
		table
		{
			border-collapse:collapse;
		}
		table,th,td
		{
			border:1px solid black;
		}
	</style>
  </head>
  <body>
  <table summary="List of services available on machine>
    <colgroup align="left">
    <colgroup align="left">
    <colgroup align="left">
    <colgroup align="left">
    <colgroup align="left">
  <TR>
  	<TH colspan="5" scope="colgroup">Machine Processes</TH>
  <TR>
    <TH scope="col" abbr="ID">Process ID</TH>
    <TH scope="col" abbr="Session">Session ID</TH>
    <TH scope="col" abbr="Active">Active</TH>
    <TH scope="col" abbr="Priority">Priority</TH>
    <TH scope="col" abbr="File">File</TH>
  </TR>
]])
		
		for _,row in ipairs(data) do
			local rowstr = string.format([[<tr><td>%d<td>%d<td>%s<td>%d<td>%s]], 
				row.id, row.sessionId, tostring(row.isActive), row.priorityClass, row.filename)
			table.insert(body, rowstr)
		end

table.insert(body,
[[
  </table>
</body>
</html>
]])
		return table.concat(body)
	end


	local headers = {
		["Content-Type"] = "text/html",
	}
	
	response:writeHead("200", headers)
	response:writeEnd(createBody());

end

-- /acebuilds
Handlers.HandleAceBuildGET = function(request, response)
	--Runtime.writeLine("HandleAceBuildGET - BEGIN")


    local absolutePath = string.gsub(URL.unescape(request.Url.path), "%.%.", '%.');
	local filename = './wwwroot'..absolutePath;

	print("FILE: ", filename)

	FileService.SendFile(filename, response)
end

--[[
        TotalPhysical = lpBuffer.ullTotalPhys;
        AvailablePhysical = lpBuffer.ullAvailPhys;

        TotalVirtual = lpBuffer.ullTotalVirtual;
        AvailableVirtual = lpBuffer.ullAvailVirtual;

        TotalPageFile = lpBuffer.ullAvailPageFile;
        AvailablePageFile = lpBuffer.ullAvailablePageFile;
        
        AvailableExtendedVirtual = lpBuffer.ullAvailExtendedVirtual;
--]]

local memoryTemplate = HtmlTemplate([[
<!DOCTYPE html>
<html>
  <head>
    <title>Memory Configuration</title>
	<style>
		table
		{
			border-collapse:collapse;
		}
		table,th,td
		{
			border:1px solid black;
		}
	</style>
  </head>
  <body>
    <table summary="Machine Memory Usage">
  <TR>
    <TH scope="col" abbr="name"></TH>
    <TH scope="col" abbr="ID">Total</TH>
    <TH scope="col" abbr="Session">Available</TH>
  </TR>
      	<tr><td>Memory Load<td><?MemoryLoad?>%</tr>
    	<tr><td>Total Physical<td><?TotalPhysical?>MB<td><?AvailablePhysical?>MB</tr>
    	<tr><td>Total Virtual<td><?TotalVirtual?>MB<td><?AvailableVirtual?>MB</tr>
    	<tr><td>Total Page File<td><?TotalPageFile?>MB<td><?AvailablePageFile?>MB</tr>
    </table>
  </body>
</html>
]])

Handlers.HandleMemoryGET = function(request, response)
	local meminfo, err = SysInfo.getMemoryStatus();

print("HandleMemoryGET: ", meminfo, err)
for k,v in pairs(meminfo) do
	if k ~= "MemoryLoad" then
		meminfo[k] = tonumber(v/1024/1024)
	end
end

	if not meminfo then
		response:writeHead(404);
		response:writeEnd();
		return false;
	end

	response:writeHead(200);
	response:writeEnd(memoryTemplate:fillTemplate(meminfo))
end

return Handlers;
