
local handlers = require("ResourceHandlers")


local ResourceMap = {
	["/"]		= {name="/",
		GET 				= handlers.HandleFileGET,
	};

	["/protected.htm"] = {name="/protected.htm",
		GET 		= handlers.HandleProtectedGET,
	};
}


return ResourceMap;
