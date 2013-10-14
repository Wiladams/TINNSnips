--[[
	Description: A very simple demonstration of one way a static web server
	can be built using TINN.

	In this case, the WebApp object is being used.  
	A resource map is provided, which simply maps all calls to being
	file retrievals, if the 'GET' method is used.

	Either a file is fetched, or an error is returned.

	Usage:
	  tinn main.lua 8080

	default port used is 8080
]]

local WebApp = require("WebApp")
local resourceMap = require("ResourceMap");


local port = arg[1] or 8080

local app = WebApp(resourceMap, port);
app:run();
