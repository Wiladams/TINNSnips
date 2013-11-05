-- sqlizermap.lua

local ffi = require("ffi")
local sqlite = require("sqlite3")

local URL = require("url");
local base64 = require("base64")
local JSON = require("dkjson")

-- Establish a database connection to an in memory database
local dbconn,err = sqlite.DBConnection:open();



local HandleQuery = function(request, response)

	-- the contents of the query are in the
	-- 'query' header
	-- it should be base64 encoded, so decode it

	local query = request:GetHeader("query")
	if not query then
		response:writeHead(400)
		response:writeEnd([[
	<html>
		<head><title>SQLizer Error</title></head>
		<body>
			The 'query' header was not specified
		</body>
	</html>
		]]);

		return false
	end

	query = base64.decode(query)

print("QUERY")
print(query)
	local results = {columns={}, values={}}

	-- This routine is used as a callback from the Exec() function
	-- It is just an example of one way of interacting with the
	-- thing.  All values come back as strings.
	local function dbcallback(userdata, dbargc, dbvalues, dbcolumns)
		print("dbcallback", dbargc);
		local printheadings = userdata ~= nil

		-- the column headings
		if printheadings then
			results.columns = {}
			-- print column names
			for i=0,dbargc-1 do
				table.insert(results.columns, ffi.string(dbcolumns[i]))
			end
		end

		-- the values
		table.insert(results.values, {})
		local row = #results.values
		print("ROW: ", row)
		for i=0,dbargc-1 do
			if dbvalues[i] == nil then
				table.insert(results.values[row], "NULL");
			else
				table.insert(results.values[row], ffi.string(dbvalues[i]))
			end
		end

		return 0;
	end

	-- Now we need to actually execute the query
	local success, err = dbconn:exec(query, dbcallback)

	print("dbconn:exec: ", success, err)

	if success ~= 0 then
		local body = string.format([[
	<html>
		<head><title>SQLizer Error</title></head>
		<body>
			<query>
			%s
			</query>

			Error: %d
			%s
		</body>
	</html>
]], query, success, err)
		response:writeHead(500)
		response:writeEnd(body)
		return false;
	end

	-- form a response
	--local respbody = {}
	--table.insert(respbody, [[<html><head><title>SQLizer</title></head><body>]])
	-- create a json string from the results
	--table.insert(respbody, JSON.encode(results.values, {indent=true}))

	--table.insert(respbody, [[</body></html>]])

	response:writeHead(200, {["Content-Type"]="application/json"})
	response:writeEnd(JSON.encode(results.values, {indent=true}))
end

local HandleSelect = function(request, response)

	-- the contents of the query are in the
	-- 'query' header
	-- it should be base64 encoded, so decode it

	local query = "SELECT * FROM People"
	local results = {columns={}, values={}}

	-- This routine is used as a callback from the Exec() function
	-- It is just an example of one way of interacting with the
	-- thing.  All values come back as strings.
	local function dbcallback(userdata, dbargc, dbvalues, dbcolumns)
		print("dbcallback", dbargc);
		local printheadings = userdata ~= nil

		-- the column headings
		if printheadings then
			results.columns = {}
			-- print column names
			for i=0,dbargc-1 do
				table.insert(results.columns, ffi.string(dbcolumns[i]))
			end
		end

		-- the values
		table.insert(results.values, {})
		local row = #results.values
		print("ROW: ", row)
		for i=0,dbargc-1 do
			if dbvalues[i] == nil then
				table.insert(results.values[row], "NULL");
			else
				table.insert(results.values[row], ffi.string(dbvalues[i]))
			end
		end

		return 0;
	end

	-- Now we need to actually execute the query
	local success, err = dbconn:exec(query, dbcallback)

	print("dbconn:exec: ", success, err)

	if success ~= 0 then
		local body = string.format([[
	<html>
		<head><title>SQLizer Error</title></head>
		<body>
			<query>
			%s
			</query>

			Error: %d
			%s
		</body>
	</html>
]], query, success, err)
		response:writeHead(500)
		response:writeEnd(body)
		return false;
	end

	response:writeHead(200, {["Content-Type"]="application/json"})
	response:writeEnd(JSON.encode(results, {indent=true}))

	return false
end


local ResourceMap = {
	["/query"]		= {name="/query",
		POST 		= HandleQuery,
	};

	["/select"]		= {name="/select",
		GET 		= HandleSelect,
	};
}


return ResourceMap;