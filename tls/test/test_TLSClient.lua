package.path = package.path..";../?.lua"

local ffi = require("ffi");
local stringzutils = require("stringzutils");
--1.0 Initialize Windows Sockets
local SocketUtils = require("SocketUtils");

local TLSClient = require("TLSClient");
local SecurityInterface = require("sspi").SecurityInterface;


local serverName = "www.google.com";
local serverPort = 443;


-- 4.0  Connect to the server
local sock = SocketUtils.CreateTcpClientSocket(serverName, serverPort)
if not sock then
	return false, err
end


local session, err = TLSClient.ClientSession(sock, serverName);

if not session then
	print("NO Session Created: ", err);
	return false, err;
end



print("EncryptSend: ", session:Send("GET / HTTP/1.1\r\n\r\n"));


-- Now do a receive
local recvLength = 640*1024;
local recvBuffer = ffi.new("uint8_t[?]", recvLength);
local res, err = TLSClient.DecryptReceive(session.Socket,session.Credentials, session.Context, recvBuffer,recvLength );

print("DecryptReceive: ", res, string.format("0x%x",err));

--print(ffi.string(recvBuffer, recvLength));
