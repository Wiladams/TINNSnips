local handlers = require "ResourceHandlers"
local HandleFileSystem = require("HandleFileSystem")
local Processes = require("Processes")
local OSProcess = require("OSProcess")


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

	["/echo"] = {name="/echo",
		GET 				= handlers.HandleEchoGET,
	};

	["/favicon.ico"]		= {name="/favicon.ico",
		GET 				= handlers.HandleFaviconGET,
	};
	

	["/jquery.js"]			= {name="/jquery.js",
		GET 				= handlers.HandleJQueryGET,
	};


	["/drives"]				= {name="/drives",
		GET 				= HandleFileSystem.HandleDrivesGET,
	};

	["/files"] 				= {name="/files",
		GET					= HandleFileSystem.HandleFilesGET,
	};

	["/memory"] 				= {name="/memory",
		GET					= handlers.HandleMemoryGET,
	};

	["/processes"] 			= {name="/processes",
		GET					= Processes.HandleProcessesGET,
	};

	["/processes/data"] 			= {name="/processes/data",
		GET					= Processes.HandleProcessesGETData,
	};

	["/services"] 			= {name="/services",
		GET					= handlers.HandleServicesGET,
	};

	["/services/data"] 		= {name="/services/data",
		GET 				= handlers.HandleServicesGETData,
	};

}


return ResourceMap;
