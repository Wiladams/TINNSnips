-- test_vector_math.lua

package.path = package.path..";../?.lua"

local ffi = require ("ffi");

local math_vector = require("math_vector");

local vec3 = math_vector.vec3;
local dvec3 = math_vector.dvec3;

v1 = vec3(1,7,30);
print("V1: ", v1);
print("V1[0]: ", v1[0]);
print("v1[1]: ", v1[1]);
print("v1[2]: ", v1[2]);

v2 = vec3(10,20,30);
v3 = v1 + v2;
print("V2: ", v2);
print("V3: ", v3);

v4 = vec3();
v4[0] = 11;
v4[1] = 12;
v4[2] = 13;

print("V4: ", v4);

--print("v1 * v2: ", v1*v2);

--print("v2 * 5: ", v2*5);
local xaxis = vec3(1,0,0);
local yaxis = vec3(0,1,0);
local zaxis = xaxis:cross(yaxis);

print("xaxis:cross(yaxis): ", zaxis);

print("zaxis elementType: ", zaxis:elementType());

d1 = dvec3(23, 24, 25);
print("d1 type, size: ", d1:elementType(), #d1, ffi.sizeof(d1));
