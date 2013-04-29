-- shell.lua
local langutils = require("langutils");

import = function(name)
print("Importing: ", name);
	local module = require(name);
print("Module: ", module);

	if module then
		langutils.makeGlobal(module);
	end
end

--import 'ver';

