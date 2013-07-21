local handlers = require "ResourceHandlers"

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


	["/desktop"] 			= {name="/desktop",
		GET					= handlers.HandleDesktopGET,
	};

	["/files"] 				= {name="/files",
		GET					= handlers.HandleFilesGET,
	};

	["/processes"] 			= {name="/processes",
		GET					= handlers.HandleProcessesGET,
	};

	["/services"] 			= {name="/services",
		GET					= handlers.HandleServicesGET,
	};

}


return ResourceMap;
