package.path = package.path.."../?.lua"

local LeapMath = require("LeapMath");

local vec3_t = LeapMath.vec3_t;
local vec3 = LeapMath.vec3;

local v1 = vec3();

print("Vector: ", v1);
print("X Axis: ", vec3_t.xAxis);
print("Y Axis: ", vec3_t.yAxis);
print("Z Axis: ", vec3_t.zAxis);

xplusy = vec3_t.xAxis + vec3_t.yAxis;
print("X + Y: ", xplusy);

local v2 = vec3(2,3,5)
print("NEG: ", -v2)

print("INDEX Access")
print(v2[0], v2[1], v2[2]);


print("Copy Constructor")
local v3 = vec3(v2);
print("V3: ", v3)