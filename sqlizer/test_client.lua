-- test_client.lua
local IOProcessor = require("IOProcessor")
local IOCPNetStream = require("IOCPNetStream")
local WebRequest = require("WebRequest")
local WebResponse = require("WebResponse")
local base64 = require("base64")

local serviceHost = "localhost"
local servicePort = 8080

execquery = function(query)
	local netstream = IOCPNetStream:create(serviceHost, servicePort)

	local headers = {
		query = base64.encode(query);
	}
	local body = nil;

	local request = WebRequest("POST", "/query", headers, body)
	success, err = request:Send(netstream);

	print("REQUEST SENT: ", success, err)

	-- wait for a response
	local response, err = WebResponse:Parse(netstream)
	if not response then
		print("RESPONSE ERROR: ", err)
	end

	print("RESULTS")
	for chunk in response:chunks() do
		print(chunk)
	end
end

main = function()
	-- Create working table
	execquery([[CREATE TABLE People (First, Middle, Last)]])

	-- Insert some values
	execquery([[INSERT INTO People VALUES ("William", "Albert", "Adams")]])
	execquery([[INSERT INTO People VALUES ("Mubeen", "", "Begum")]])
	execquery([[INSERT INTO People VALUES ("Blaine", "", "Dockter")]])
	execquery([[INSERT INTO People VALUES ("Adam", "", "Larson")]])

	-- Retrieve the values back
	execquery([[SELECT * FROM PEOPLE]])
end


run(main)