
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
local sout = FileStream.new(io.stdout)


BinaryStream = require("BinaryStream");
BitBang = require("BitBang");

local webSocketGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";


WebSocketStream_t = {}
WebSocketStream_mt = {
	__index = WebSocketStream_t,
}

local WebSocketStream = function(obj)
	obj = obj or {}

	setmetatable(obj, WebSocketStream_mt);

	return obj
end

WebSocketStream_t.InitiateClientHandshake = function(self, host, port)
	print("WebSocketStream_t.InitiateClientHandshake()", host, port)

	-- establish a TCP connection to the intended service
	local stream, err = NetStream.Open(host, port);
	if not stream then
		return false, err
	end

	-- Construct the initial handshake request
	if port ~= 80 then
		--host = host..':'..port
	end

	local rngBuff, err = BCrypt.GetRandomBytes(16)
	if not rngBuff then
		return false, err
	end
	local nonce = b64.encode(rngBuff, 16);

	local headers = {
		["Host"] 				= host,
		["Upgrade"]				= "websocket",
		["Connection"]			= "Upgrade",
		["Origin"]				= "localhost",
		["Sec-WebSocket-Key"]	= nonce,
		["Sec-WebSocket-Version"]	= "13",

	};
	local body = nil;
	local request = HttpRequest.new("GET", "/", headers, body);

	request:Send(stream);

request:Send(sout);

	-- Get the response back

	local response = HttpResponse.Parse(stream);
	
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

	if response.Status ~= "200" then
		return false, response.Status
	end

	self.Request = request
	self.SourceStream = stream;
	self.Status = "CONNECTED"

	return true
end

WebSocketStream_t.Connect = function(self, url, onconnected)
	local urlparts = URL.parse(url);

	self.Status = "CONNECTING"


	-- perform the client handshake
	local success, err = self:InitiateClientHandshake(urlparts.host, urlparts.port)

	if not success then
		self.Status = "DISCONNECTED"
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



local unmaskdata =  function(buff, bufflen, mask)
	local buffptr = ffi.cast("uint8_t *", buff);
	local maskptr = ffi.cast("const uint8_t *", mask);

	for i=0,bufflen-1 do
		buff[i] = bxor(buffptr[i], maskptr[i % 4])
	end
end

WebSocketStream_t.ReadFrameHeader = function(self)
print("WebSocketStream_t.ReadFrameHeader()")
	local headerbuff = ffi.new("uint8_t[4]")
	local BStream = BinaryStream.new(self.SourceStream);

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
--print("FIN: ", frameHeader.FIN);
	frameHeader.RSV1 = BitBang.getbitsfrombytes(headerbuff, 1, 1, true)
	frameHeader.RSV2 = BitBang.getbitsfrombytes(headerbuff, 2, 1, true)
	frameHeader.RSV3 = BitBang.getbitsfrombytes(headerbuff, 3, 1, true)
	frameHeader.opcode = BitBang.getbitsfrombytes(headerbuff, 4, 4, true)
--print("Op Code: ", frameHeader.opcode);
	frameHeader.MASK = BitBang.getbitsfrombytes(headerbuff, 8, 1, true)
--print("MASK: ", frameHeader.MASK);
	frameHeader.PayloadLen = BitBang.getbitsfrombytes(headerbuff, 9, 7, true)

--	print("PayloadLen: ", frameHeader.PayloadLen);


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
print("WebSocketStream_t.ReadFrame")
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
	
	return payloaddata, bytesread
end

return WebSocketStream