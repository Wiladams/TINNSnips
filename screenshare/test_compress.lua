-- test_compress.lua
local ffi = require("ffi");

local Compressor = require("compressor");

local cmp = Compressor();

local testString = "This is the test string"
local destLen = 256;
local dest = ffi.new("uint8_t[?]", destLen);

local bytes = cmp:compress(dest, destLen, testString, #testString);

print("Compressed Bytes: ", bytes);
