
local ffi = require("ffi");
local NetStream = require("NetStream");
local UrlParser = require("url");
local BCrypt = require ("BCryptUtils");
local b64 = require("base64");
local HttpResponse = require("HttpResponse");
local WebSocketStream = require("WebSocketStream");
local JSON = require("dkjson");

local tinsert = table.insert
local format = string.format

local printDict = function(dict)
	for k,v in pairs(dict) do
		print(k,v);
	end
end

local UpgradeRequest = function(req)
	local lines = {
    	format('GET %s HTTP/1.1',req.uri or ''),
    	format('Host: %s',req.host),
    	'Upgrade: websocket',
    	'Connection: Upgrade',
    	format('Sec-WebSocket-Key: %s',req.key),
--    	format('Sec-WebSocket-Protocol: %s',table.concat(req.protocols,', ')),
    	'Sec-WebSocket-Version: 13',
	}

	if req.origin then
    	tinsert(lines,string.format('Origin: %s',req.origin))
  	end
  if req.port and req.port ~= 80 then
    lines[2] = format('Host: %s:%d',req.host,req.port)
  end
  tinsert(lines,'\r\n')
  return table.concat(lines,'\r\n')
end

local LeapInterface_t = {}
local LeapInterface_mt = {
	__index = LeapInterface_t,
}


local LeapInterface = function(url)
	url = url or "ws://127.0.0.1:6437/"
	print("LeapInterface()",  url)

	local urlparts = UrlParser.parse(url, {port="80", path="/", scheme="http"});

	printDict(urlparts);

	-- establish a TCP connection to the intended service
	local stream, err = NetStream.Open(urlparts.host, urlparts.port);
	if not stream then
		return false, err
	end

--print("NETSTREAM: ", stream);

	local rngBuff, err = BCrypt.GetRandomBytes(16)
	if not rngBuff then
		return false, err
	end
	local nonce = b64.encode(rngBuff, 16);

	local req = {
		uri = url,
		host = urlparts.host,
		port = urlparts.port,
		key = nonce,
		origin = "http://localhost",
		protocols = {},
	}

	local upgraded = UpgradeRequest(req);

--print("UPGRADED");
--print(upgraded);

	local success, err = stream:WriteString(upgraded);
--print("REQUEST: ", success, err, #upgraded);

	-- Get the response back
	local response, err = HttpResponse.Parse(stream);
--print("RESPONSE");
--print(response, response.Status, response.Phrase)

	if not response then 
		return false, err
	end

	if response.Status ~= "101" then
		return false, response.Status
	end

	local socketstream = WebSocketStream();
	socketstream.SourceStream = stream;

	local obj = {
		SocketStream = socketstream,
	}
	setmetatable(obj, LeapInterface_mt);

	return obj;
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
