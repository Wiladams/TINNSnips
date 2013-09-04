local handlers = require "ResourceHandlers"
local HandleFileSystem = require("HandleFileSystem")

local ResourceMap = {
	["/"]		= {name="/",
		GET 				= handlers.HandleLoginGET,
	};

	["/favicon.ico"]		= {name="/favicon.ico",
		GET 				= handlers.HandleFaviconGET,
	};
	

	["/jquery.js"]		= {name="/jquery.js",
		GET 				= handlers.HandleJQueryGET,
	};


	["/files"] 				= {name="/files",
		GET					= HandleFileSystem.HandleFilesGET,
	};

	["/processes"] 			= {name="/processes",
		GET					= handlers.HandleProcessesGET,
	};

	["/services"] 			= {name="/services",
		GET					= handlers.HandleServicesGET,
	};

}


return ResourceMap;
