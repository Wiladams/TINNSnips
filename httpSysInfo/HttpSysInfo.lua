--[[
	Description: A very simple demonstration of one way a static web server
	can be built using TINN.

	In this case, the HttpServer object is being used.  It is handed a routine to be
	run for every http request that comes in (HandleSingleRequest()).

	Either a file is fetched, or an error is returned.

	Usage:
	  tinn main.lua [port]

	default port used is 8080

			<script type="text/javascript" src="jquery.js"></script>
		<script type="text/javascript" src="minified-web.noie.js"

]]

local WebApp = require("WebApp")

local resourceMap = require("ResourceMap");

local port = arg[1] or 8080

local app = WebApp(resourceMap, port);
app:run();
