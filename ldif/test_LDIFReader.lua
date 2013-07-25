-- test_LDIFReader.lua

local MemoryStream = require("MemoryStream");
local LDIFReader = require("LDIFReader");
local JSON = require("dkjson");

-- Open up a stream on a file
local openStream = function(filename)
	local fs = io.open(filename, "rb+");
	if not fs then 
		return false, "could not open file";
	end

	local memstream = MemoryStream.Open(fs:read("*all"));
	fs:close();

	return memstream;
end

local printEntry = function(entry)
	local jsonstr = JSON.encode(entry, {indent = true});
	print(jsonstr);
end

local filename = arg[1] or "example1.ldif";
local strm, err = openStream(filename);

if not strm then
	print("No Stream: ", err);
	return err;
end


local reader = LDIFReader(strm);


for entry in reader:entries() do
	print("==== ENTRY ====")
	printEntry(entry);
end

print("Version: ", reader.Version);

