package.path = package.path..";../?.lua"

local View3D = require("View3D");

mousemove = function(event)
	print("mousemove: ", event.kind, event.x, event.y)
	return true;
end

run(View3D.main);

