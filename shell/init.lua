-- shell.lua
local langutils = require("langutils");

import = function(name)
--print("Importing: ", name);
	local module = require(name);
--print("Module: ", module);

	if module then
		langutils.makeGlobal(module);
	end
end

exit = function(retValue)
	assert(false, retValue);
end

import 'shell.ver';
import 'datetime';
import "Heap";
import "processenvironment";
import 'SysInfo';
