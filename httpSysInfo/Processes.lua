-- /processes
local utils = require("utils");
local JSON = require("dkjson");
local OSProcess = require("OSProcess");

local function getProcessData(request)
--print("getProcessData, 1.0")

	local res = {};
	for proc in OSProcess:processes() do
		--print("Process: ", proc)
		local record = {
			id = proc:getId(), 
			filename = proc:getImageName(),
			priorityClass = proc:getPriorityClass(),
			sessionId = proc:getSessionId(),
			isActive = proc:isActive(),
		}
		table.insert(res, record)
	end
--print("getprocessData - END")

	return res;
end


local function HandleProcessesGETData(request, response)
	--Runtime.writeLine("HandleProcessesGETData - BEGIN")


	local body = JSON.encode(getProcessData(request), {indent=true});

	local headers = {
		["Content-Type"] = "application/json",
	}
	
	response:writeHead("200", headers)
	response:writeEnd(body);

end



local function HandleProcessesGET(request, response)
	--Runtime.writeLine("HandleProcessesGET - BEGIN")
	--print("Processes.HandleProcessesGET")

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
	local body = createBody();
	--print("HandleProcessesGET, BODY")
	--print(body)

	response:writeEnd(body);

end


return {
	getProcessData = getProcessData,
	HandleProcessesGET = HandleProcessesGET,
	HandleProcessesGETData = HandleProcessesGETData,
}