package.path = package.path.."../?.lua"

local LeapMath = require("LeapMath");

local Vector = LeapMath.Vector;

local vec1 = Vector.new();

print("Vector: ", vec1);
print("X Axis: ", Vector.xAxis);
print("Y Axis: ", Vector.yAxis);
print("Z Axis: ", Vector.zAxis);

xplusy = Vector.xAxis + Vector.yAxis;
print("X + Y: ", xplusy);

local v2 = Vector.new(2,3,5)
print("NEG: ", -v2)

print("INDEX Access")
print(v2[0], v2[1], v2[2]);
