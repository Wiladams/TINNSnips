
--[[
	References: http://tools.ietf.org/html/rfc6455
]]

local ffi = require("ffi")
local bit = require("bit")
local bxor = bit.bxor
local base64 = require("base64")
local CryptUtils = require("BCryptUtils")
local URL = require("url")

local FileStream = require ("FileStream");
local NetStream = require("NetStream");
local HttpRequest = require ("HttpRequest");
local HttpResponse = require ("HttpResponse");
local HttpChunkIterator = require("HttpChunkIterator");

local BCrypt = require ("BCryptUtils");
local b64 = require("base64");
--local sout = FileStream.new(io.stdout)
local sout = FileStream.Open("file.txt");


BinaryStream = require("BinaryStream");
BitBang = require("BitBang");

local webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

local opcodes = {
	-- control frames
	[0x08] = "close",
	[0x09] = "ping",
	[0x0a] = "pong",

}
--[[
CONNECTING = 0;
OPEN = 1;
CLOSING = 2;
CLOSED = 3;
--]]

WebSocketStream_t = {}
WebSocketStream_mt = {
	__index = WebSocketStream_t,
}

local WebSocketStream = function(obj)
	obj = obj or {
		readyState = "CLOSED",
	}

	setmetatable(obj, WebSocketStream_mt);

	return obj
end

WebSocketStream_t.InitiateClientHandshake = function(self, urlparts)
	print("WebSocketStream_t.InitiateClientHandshake()", urlparts.host, urlparts.port, urlparts.path, urlparts.query)

	-- establish a TCP connection to the intended service
	local stream, err = NetStream.Open(urlparts.host, urlparts.port);
	if not stream then
		return false, err
	end

print("NETSTREAM: ", stream);

	-- Construct the initial handshake request
	local host = urlparts.host
	if urlparts.port ~= 80 then
		host = urlparts.host..':'..urlparts.port
	end
	
	local path = urlparts.path
	if urlparts.query then
		path = path..'?'..urlparts.query
	end

	local rngBuff, err = BCrypt.GetRandomBytes(16)
	if not rngBuff then
		return false, err
	end
	local nonce = b64.encode(rngBuff, 16);

print("NONCE: ", nonce);

--		["Sec-WebSocket-Protocol"]	= "chat, superchat",
--		["User-Agent"]				= "TINN",
--[[
	local headers = {
		["Pragma"]						= "no-cache",
		["Cache-Control"]				= "no-cache",
		["Host"] 						= host,
		["Upgrade"]						= "websocket",
		["Connection"]					= "Upgrade",
		["Origin"]						= "http://localhost",
		["Sec-WebSocket-Key"]			= nonce,
		["Sec-WebSocket-Version"]		= "13",
		["Sec-WebSocket-Extensions"]	= "x-webkit-deflate-frame",
	};
	local body = nil;
	local resource = string.format("ws://%s:%s%s", urlparts.host, urlparts.port, urlparts.path);
	local request = HttpRequest.new("GET", resource, headers, body);
print("REQUEST: ", request.Method, request.Resource)
request:Send(sout);

	request:Send(stream);
--]]

---[[
	--local origin = "http://www.websocket.org"
	local origin = "http://localhost"
--	local reqtemplate = string.format("GET ws://%s%s HTTP/1.1\r\nPragma: no-cache\r\nCache-Control: no-cache\r\nHost: %s\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nOrigin: http://%s\r\nSec-WebSocket-Key: %s\r\nSec-WebSocket-Version: 13\r\nSec-WebSocket-Extensions: x-webkit-deflate-frame\r\n\r\n", 
--		host, path, host, host, nonce);

	local reqtemplate = string.format("GET / HTTP/1.1\r\npragma: no-cache\r\ncache-control: no-cache\r\ncookie: __utma=96992031.350904405.1341167070.1341167070.1341167070.1\r\nhost: %s\r\nupgrade: websocket\r\nconnection: Upgrade\r\norigin: http://localhost\r\nsec-websocket-key: %s\r\nsec-websocket-version: 13\r\nsec-websocket-extensions: x-webkit-deflate-frame\r\n\r\n", 
		host, nonce);

	local success, err = stream:WriteString(reqtemplate);
print("REQUEST: ", success, err, #reqtemplate);
print(reqtemplate);
--]]

	-- Get the response back

	local response, err = HttpResponse.Parse(stream);
	if not response then 
		return false, err
	end

	print("RESPONSE: ", response, response.Status, response.Phrase)
	for key,value in pairs(response.Headers) do
		print(key,value)
	end

	if not response then
		return false, err
	end

	print("== CHUNKS ==")
	for chunk in HttpChunkIterator.ReadChunks(response) do
		io.write(chunk);
	end

	if response.Status ~= "101" then
		return false, response.Status
	end

	self.Request = request
	self.SourceStream = stream;
	self.readyState = "OPEN"

	return true
end

WebSocketStream_t.Connect = function(self, url, onconnected)
	local urlparts = URL.parse(url, {port=80});

for k,v in pairs(urlparts) do
	print(k,v);
end

	self.readyState = "CONNECTING"


	-- perform the client handshake
	local success, err = self:InitiateClientHandshake(urlparts)

	if not success then
		self.readyState = "DISCONNECTED"
		return onconnected(false, err)
	end

	return onconnected(self, err)
end

WebSocketStream_t.RespondWithServerHandshake = function(self, request, response)
	--print("WebSocketStream_t.RespondWithServerHandshake()")
	self.Request = request
	self.SourceStream = request.DataStream;

	-- formulate a websocket handshake response
	local clientkey = request:GetHeader("sec-websocket-key");
	
--io.write("CLIENT NONCE KEY:'", clientkey,"'\r\n")

	local acceptkey = clientkey..webSocketGUID;
	acceptkey, binbuff, binbufflen = CryptUtils.SHA1(acceptkey);

	acceptkey = base64.encode(binbuff, binbufflen);
print("ACCEPT KEY: ", acceptkey);


	-- give a response
	local headers = {
		["Connection"] = "Upgrade",
		["Upgrade"] = "websocket",
		["Sec-WebSocket-Accept"] = acceptkey,
	}
	response:writeHead("101", headers)
	response:writeEnd();

	return false;
end

--[[
      0                   1                   2                   3
      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
     +-+-+-+-+-------+-+-------------+-------------------------------+
     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
     | |1|2|3|       |K|             |                               |
     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
     |     Extended payload length continued, if payload len == 127  |
     + - - - - - - - - - - - - - - - +-------------------------------+
     |                               |Masking-key, if MASK set to 1  |
     +-------------------------------+-------------------------------+
     | Masking-key (continued)       |          Payload Data         |
     +-------------------------------- - - - - - - - - - - - - - - - +
     :                     Payload Data continued ...                :
     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
     |                     Payload Data continued ...                |
     +---------------------------------------------------------------+

]]--

WebSocketStream_t.OnClose = function(self)
	print("CLOSE RECEIVED");
end

WebSocketStream_t.OnPing = function(self)
	print("PING RECEIVED");
end



local unmaskdata =  function(buff, bufflen, mask)
	local buffptr = ffi.cast("uint8_t *", buff);
	local maskptr = ffi.cast("const uint8_t *", mask);

	for i=0,bufflen-1 do
		buff[i] = bxor(buffptr[i], maskptr[i % 4])
	end
end

WebSocketStream_t.ReadFrameHeader = function(self)
--print("WebSocketStream_t.ReadFrameHeader()")
	local headerbuff = ffi.new("uint8_t[4]")
	local BStream = BinaryStream.new(self.SourceStream, true);

	-- Read the first two bytes to get up to the initial
	-- payload length
	local bytesread, err = self.SourceStream:ReadBytes(headerbuff, 2);
--print("WebSocketStream_t.ReadFrameHeader: ", bytesread, err)

	if not bytesread then
		print("Could not read first 2 bytes of frame")
		return false, err
	end

--	print("WS:ReadFrame: ", BitBang.bytestobinary(headerbuff, 2, 0, true));
--print(string.format("0x%x 0x%x", headerbuff[0], headerbuff[1]))
	local frameHeader = {}
	frameHeader.FIN = BitBang.getbitsfrombytes(headerbuff, 0, 1, true)
	frameHeader.RSV1 = BitBang.getbitsfrombytes(headerbuff, 1, 1, true)
	frameHeader.RSV2 = BitBang.getbitsfrombytes(headerbuff, 2, 1, true)
	frameHeader.RSV3 = BitBang.getbitsfrombytes(headerbuff, 3, 1, true)
	frameHeader.opcode = BitBang.getbitsfrombytes(headerbuff, 4, 4, true)
	frameHeader.MASK = BitBang.getbitsfrombytes(headerbuff, 8, 1, true)
	frameHeader.PayloadLen = BitBang.getbitsfrombytes(headerbuff, 9, 7, true)



	-- if payload length == 126 then next two bytes
	-- indicate 16-bit unsigned short payload length
	if frameHeader.PayloadLen == 126 then
		local value, err = BStream:ReadUInt16();
		if not value then
			return false, err
		end
		frameHeader.PayloadLen = value;
	elseif frameHeader.PayloadLen == 127 then
		local value, err = BStream:ReadUInt64();
		if not value then
			return false, err
		end
		frameHeader.PayloadLen = value;
	end

--print("Extended PayloadLen: ", frameHeader.PayloadLen);


	-- If the mask bit is set, then there must be a mask field
	-- otherwise it is absent.
	if frameHeader.MASK > 0 then
		frameHeader.maskingkey = ffi.new("uint8_t[4]");
		local bytesread, err = self.SourceStream:ReadBytes(frameHeader.maskingkey, 4);
		if not bytesread then
			return false, err
		end
	end


	return frameHeader;
end

WebSocketStream_t.ReadFrame = function(self)
--print("WebSocketStream_t.ReadFrame")
	local frameHeader, err = self:ReadFrameHeader();

	if not frameHeader then
		print("Error: ", err)
		return false, err
	end

	-- Finally, read the payload data
	local payloaddata = ffi.new("uint8_t[?]", frameHeader.PayloadLen);
	local bytesread, err = self.SourceStream:ReadBytes(payloaddata, frameHeader.PayloadLen)
--print("PAYLOAD: ", bytesread, err)
	if not bytesread then
		return false, err
	end

	if frameHeader.MASK >0 then
		unmaskdata(payloaddata, bytesread, frameHeader.maskingkey)
	end
	
	frameHeader.Data = payloaddata;
	frameHeader.DataLength = bytesread;

	return frameHeader
end

return WebSocketStream