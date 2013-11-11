
local handlers = require("ResourceHandlers")

local ResourceMap = {
	["/"]		= {name="/",
		GET 	= handlers.HandleFileGET,
	};

	["/echo"] = {name="/echo",
		GET 	= handlers.HandleEchoGET,
	};

}


return ResourceMap;
