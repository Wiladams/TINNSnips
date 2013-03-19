
local Runtime = require("Runtime")
local REST = require("http_rest");

local main = function()
	local url = arg[1];
	local showheaders = arg[2] or false;

	onfinish = function(result)
		stop();
	end

	spawn(REST.GET, url, showheaders, onfinish);
end

run(main);

