
local ffi = require("ffi");

local NetStream = require("NetStream");
local UrlParser = require("url");
local BCrypt = require ("BCryptUtils");
local b64 = require("base64");
local HttpResponse = require("HttpResponse");
local JSON = require("dkjson");

local WebSocketStream = require("WebSocketStream");

local tinsert = table.insert
local format = string.format


local LeapInterface_t = {}
local LeapInterface_mt = {
	__index = LeapInterface_t,
}


local LeapInterface = function(params)
	params = params or {url = "ws://127.0.0.1:6437/", enableGestures=true}

--print("LeapInterface(): ",  params.url);

	-- establish a TCP connection to the intended service
	local urlparts = UrlParser.parse(params.url or "ws://127.0.0.1:6437/", {port="80", path="/", scheme="ws"});

--print("URL Parts: ", urlparts.host, urlparts.port);

	local stream, err = NetStream.Open(urlparts.host, urlparts.port);

	if not stream then
--print("LeapInterface(), NETSTREAM: ", stream, err);
		return false, err
	end

	local socketstream = WebSocketStream(stream);

	local req = {
		uri = params.url,
		host = urlparts.host,
		port = urlparts.port,
		key = nonce,
		origin = "http://localhost",
		protocols = {},
	}
	local origin = "http://localhost"

	socketstream:InitiateClientHandshake(params.url, origin);

	local obj = {
		SocketStream = socketstream,
	}
	setmetatable(obj, LeapInterface_mt);

	if params.enableGestures then
		obj:EnableGestures();
	end

	return obj;
end

LeapInterface_t.EnableGestures = function(self)
	self.SocketStream:WriteFrame([[{"enableGestures": true}]], 1, 1, true);
end

--[[
	The RawFrames() iterator will return the raw frames coming
	off of the websocket interface of the Leap.
--]]
LeapInterface_t.RawFrames = function(self)
	local closure = function()
		local frame, err = self.SocketStream:ReadFrame();
		if not frame then
			return nil, err
		end

		return frame;
	end

	return closure;
end

LeapInterface_t.Frames = function(self)
	local closure = function()
		local frame, err = self.SocketStream:ReadFrame();
		if not frame then
			return nil, err
		end

		-- turn each frame into a table 
		-- structure and return it
		local tbl = JSON.decode(ffi.string(frame.Data, frame.DataLength))
		return tbl;
	end

	return closure;
end

return	LeapInterface;
