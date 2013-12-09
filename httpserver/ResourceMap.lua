
local handlers = require("ResourceHandlers")
local HandleFileSystem = require("HandleFileSystem")

local ResourceMap = {
	["/"]		= {name="/",
		GET 	= handlers.HandleFileGET,
	};

	["/echo"] = {name="/echo",
		GET 	= handlers.HandleEchoGET,
	};

	["/log"] = {name="/log",
		GET 	= handlers.HandleLogGET,
	};
	
	["/files"] = {name="/files",
		GET 	= HandleFileSystem.HandleFilesGET,
	};
}


return ResourceMap;
