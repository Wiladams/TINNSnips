
-- Start up a web app

local WebApp = require("WebApp")
local resourceMap = require("sqlizermap");


local port = arg[1] or 8080

local app = WebApp(resourceMap, port);
app:run();
