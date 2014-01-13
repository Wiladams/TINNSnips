-- http://kfm.verens.com/demo/trunk/index.php?lang=en

local IOProcessor = require("IOProcessor")
local REST = require("http_rest");

local main = function()
	local url = arg[1];
	local showheaders = arg[2] or false;

	onfinish = function(result, err)
		print("onfinish: ", result, err)
		stop();
	end

	REST.GET(url, showheaders, onfinish);
end

run(main);

