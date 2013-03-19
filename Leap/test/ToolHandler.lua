ToolHandler_t = {}
ToolHandler_mt = {
	__index = ToolHandler_t;
}

local ToolHandler = function()
	local obj = {}

	setmetatable(obj, ToolHandler_mt);

	return obj;
end

local printDict = function(dict)
	for k,v, in pairs(dict) do
		print(k,v);
	end
end

ToolHandler_t.OnToolEvent = function(self, event)
	print("==== TOOL EVENT ====");
	printDict(event);
end


return ToolHandler
