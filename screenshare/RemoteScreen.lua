
local MemoryStream = require("MemoryStream");
local NetStream = require("NetStream")
local HttpRequest = require ("HttpRequest");
local URL = require ("url");
local zlib = require "zlib"

local RemoteScreen = {}
setmetatable(RemoteScreen, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local RemoteScreen_mt = {
	__index = RemoteScreen,
}

RemoteScreen.init = function(self, url)
	local urlparts = URL.parse(url, {port="80", path="/", scheme="http"});

	local obj = {
		Url = urlparts;
		Path = urlparts.path;
		Port = urlparts.port;
		ScreenRequest = HttpRequest.new("GET", urlparts.path, {["Host"] = urlparts.host,}, nil),	
		ZStream = MemoryStream.new(256*1024);
		ImageStream = MemoryStream.new(1024*1024*1024);
	}

	setmetatable(obj, RemoteScreen_mt);

	-- make connection
	obj.Connection = NetStream.Open(urlparts.host, urlparts.port);
	if not obj.Connection then
		return nil
	end

	return obj
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

RemoteScreen_t.GetCurrentImage = function(self)
	-- issue the request
	local success, err = self.ScreenRequest:Send(self.Connection);

	--print("GetCurrentImage: ", success, err);

	if not success then
		return false, err
	end

	-- get the response
	local response, err = HttpResponse.Parse(self.Connection);
			

	self.ZStream:Seek(0);
	local result

	if response then
		-- successful read of preamble
		-- so print it out, and keep out of queue
		--response:WritePreamble(sout);

		for chunk, err in chunkiter.ReadChunks(response) do
			-- read chunks stuffing into memory stream
			self.ZStream:WriteString(chunk);
		end
		result = "OK";
	else
		result = "FAILURE:"..tostring(err);
	end

--print("Bytes in ZStream: ", self.ZStream:GetPosition(), result);
	-- unzip it
	local destLen = ffi.new("unsigned long[1]", self.ImageStream.Length);
	local err = zlib.uncompress(self.ImageStream.Buffer, destLen, self.ZStream.Buffer, self.ZStream:GetPosition());

--print("UNCOMPRESS: ", err, destLen[0])

	if err ~= 0 then
		return nil, err
	end

	self.ImageStream.BytesWritten = destLen[0];
	self.ImageStream:Seek(0);

	local info, pixeloffset = readImage(self.ImageStream)
	if not info then
		return nil, pixeloffset
	end

	local pixels = self.ImageStream.Buffer + pixeloffset;

	return info, pixels
end

return RemoteScreen
