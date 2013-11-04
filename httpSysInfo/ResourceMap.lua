local handlers = require "ResourceHandlers"
local HandleFileSystem = require("HandleFileSystem")
Runtime = require("Runtime")


local ResourceMap = {
	["/exit"]				= {name="/exit",
		GET 				= function(request, response)
								response:writeHead(204);
								response:writeEnd();
								
								Runtime.stop();
							end,
	};

	["/"]					= {name="/",
		GET 				= handlers.HandleLoginGET,
	};

	["/acebuilds"] = {name="/acebuilds",
		GET 				= handlers.HandleAceBuildGET,
	};

	["/favicon.ico"]		= {name="/favicon.ico",
		GET 				= handlers.HandleFaviconGET,
	};
	

	["/jquery.js"]			= {name="/jquery.js",
		GET 				= handlers.HandleJQueryGET,
	};


	["/files"] 				= {name="/files",
		GET					= HandleFileSystem.HandleFilesGET,
	};

	["/memory"] 				= {name="/memory",
		GET					= handlers.HandleMemoryGET,
	};

	["/processes"] 			= {name="/processes",
		GET					= handlers.HandleProcessesGET,
	};

	["/processes/data"] 			= {name="/processes/data",
		GET					= handlers.HandleProcessesGETData,
	};

	["/services"] 			= {name="/services",
		GET					= handlers.HandleServicesGET,
	};

	["/services/data"] 		= {name="/services/data",
		GET 				= handlers.HandleServicesGETData,
	};

}


return ResourceMap;
