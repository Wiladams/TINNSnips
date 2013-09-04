

local ffi = require("ffi")
local MemoryStream = require("MemoryStream");
local BinaryStream = require("BinaryStream");
local IOCPNetStream = require("IOCPNetStream")

local WebRequest = require ("WebRequest");
local WebResponse = require("WebResponse")
local URL = require ("url");
local zlib = require "zlib"
local chunkiter = require("HttpChunkIterator")



local RemoteScreen = {}
setmetatable(RemoteScreen, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local RemoteScreen_mt = {
	__index = RemoteScreen,
}


RemoteScreen.init = function(self, url)
	local urlparts = URL.parse(url, {port="80", path="/", scheme="http"});

	local obj = {
		Url = urlparts;
		Path = urlparts.path;
		Port = urlparts.port;
		ScreenRequest = WebRequest("GET", urlparts.path, {["Host"] = urlparts.host,}, nil),	
		ZStream = MemoryStream(256*1024);
		ImageStream = MemoryStream(1024*1024*1024);
	}

	setmetatable(obj, RemoteScreen_mt);

	-- make connection
	local err = nil
	obj.Connection, err = IOCPNetStream:create(urlparts.host, urlparts.port);
	if not obj.Connection then
		return nil, err
	end

	return obj
end

RemoteScreen.create = function(self, url)
	return self:init(url);
end


local readImage = function(stream)
	local bs = BinaryStream.new(stream);

	-- Read File Header
	local bm1 = bs:ReadByte()
	local bm2 = bs:ReadByte()
	local filesize = bs:ReadInt32();
	bs:ReadInt16(0);
	bs:ReadInt16(0);
	local pixeloffset = bs:ReadInt32();

	-- Bitmap information header
	local bminfo = ffi.new("BITMAPINFO");
	bminfo.bmiHeader.biSize = bs:ReadInt32();
	bminfo.bmiHeader.biWidth = bs:ReadInt32();
	bminfo.bmiHeader.biHeight = bs:ReadInt32();
	bminfo.bmiHeader.biPlanes = bs:ReadInt16();
	bminfo.bmiHeader.biBitCount = bs:ReadInt16();
	bminfo.bmiHeader.biCompression = bs:ReadInt32();
	bminfo.bmiHeader.biSizeImage = bs:ReadInt32();
	bminfo.bmiHeader.biXPelsPerMeter = bs:ReadInt32();
	bminfo.bmiHeader.biYPelsPerMeter = bs:ReadInt32();
	bminfo.bmiHeader.biClrUsed = bs:ReadInt32();
	bminfo.bmiHeader.biClrImportant = bs:ReadInt32();

	-- Read the actual pixel data
	--local pixelarray = ffi.new("uint8_t[?]", bminfo.bmiHeader.biSizeImage);
	--stream:ReadBytes(pixelarray, bminfo.bmiHeader.biSizeImage, 0);
	
	return bminfo, pixeloffset;
end

RemoteScreen.GetCurrentImage = function(self)
	-- issue the request
	local success, err = self.ScreenRequest:Send(self.Connection);

	print("GetCurrentImage: ", success, err);

	if not success then
		return false, err
	end

	-- get the response
	local response, err = WebResponse:Parse(self.Connection);
			
	if not response then
		return false, string.format("WebResponse:Parse(): %d",err)
	end

	local encoding = response:GetHeader("Content-Encoding")
	print("Content-Encoding: ", encoding);

	self.ZStream:Seek(0);
	


	-- read the chunks of the response
	for chunk, err in chunkiter.ReadChunks(response) do
		-- read chunks stuffing into memory stream
		self.ZStream:WriteString(chunk);
	end

--print("Bytes in ZStream: ", self.ZStream:GetPosition(), result);
	-- unzip it
	local destLen = ffi.new("unsigned long[1]", self.ImageStream.Length);
	local err = zlib.uncompress(self.ImageStream.Buffer, destLen, self.ZStream.Buffer, self.ZStream:GetPosition());

--print("UNCOMPRESS: ", err, destLen[0])

	if err ~= 0 then
		return false, err
	end

	self.ImageStream.BytesWritten = destLen[0];
	self.ImageStream:Seek(0);

	local info, pixeloffset = readImage(self.ImageStream)
	if not info then
		return false, pixeloffset
	end

	local pixels = self.ImageStream.Buffer + pixeloffset;

	return info, pixels
end

return RemoteScreen
