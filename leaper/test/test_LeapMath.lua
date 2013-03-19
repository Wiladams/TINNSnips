local LeapMath = require("LeapMath");
local Vector = LeapMath.Vector;

local vec1 = Vector.new();

print("Vector: ", vec1);
print("X Axis: ", Vector.xAxis);
print("Y Axis: ", Vector.yAxis);
print("Z Axis: ", Vector.zAxis);

xplusy = Vector.xAxis + Vector.yAxis;
print("X + Y: ", xplusy);

local vec2 = Vector.new(2,3,5)
print("NEG: ", -vec2)