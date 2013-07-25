
local ffi = require "ffi"

local HttpServer = require("HttpServer")
local StaticService = require("StaticService");
local WebSocket = require("WebSocket")
local Network = require("Network")


local GDI32 = require ("GDI32")
local User32 = require ("User32")
local MemoryStream = require("MemoryStream")
local FileStream = require("FileStream");
local ScreenCapture = require("ScreenCapture");

local utils = require("utils")
local zlib = require ("zlib")

local UIOSimulator = require("UIOSimulator")


local arg = {...}
local serviceport = tonumber(arg[1]) or 8080

local fsout = FileStream();

--[[
	Application Variables
--]]
local ScreenWidth = User32.GetSystemMetrics(User32.FFI.CXSCREEN);
local ScreenHeight = User32.GetSystemMetrics(User32.FFI.CYSCREEN);


local captureWidth = ScreenWidth;
local captureHeight = ScreenHeight;

local ImageWidth = captureWidth * 1.0;
local ImageHeight = captureHeight * 1.0;
local ImageBitCount = 16;

local net = Network();
local screenCap = ScreenCapture();

--[[
	Application Functions
--]]


-- Serve the screen up as a bitmap image (.bmp)

local getContentSize = function(width, height, bitcount, alignment)
  alignment = alignment or 4

  local rowsize = GDI32.GetAlignedByteCount(width, bitcount, alignment);
  local pixelarraysize = rowsize * math.abs(height);
  local pixeloffset = 54;
  local totalsize = pixeloffset+pixelarraysize;

  return totalsize;
end


local filesize = getContentSize(ImageWidth, ImageHeight, ImageBitCount);
local zstream = MemoryStream.new(filesize);


local getCompressedSingleShot = function(response)
  screenCap:captureScreen();

  zstream:Seek(0);
  local compressedLen = ffi.new("int[1]", zstream.Length);
  local err = zlib.compress(zstream.Buffer,   compressedLen, 
      screenCap.CapturedStream.Buffer, screenCap.CapturedStream:GetPosition() );

  zstream.BytesWritten = compressedLen[0];
  local contentlength = zstream.BytesWritten;

  local headers = {
    ["Content-Length"] = tostring(contentlength),
    ["Content-Type"] = "image/bmp",
    ["Content-Encoding"] = "deflate",
  }

  response:writeHead("200", headers);
  response:WritePreamble();


  response.DataStream:writeBytes(zstream.Buffer, contentlength);

  return true;
end


local getSingleShot = function(response)
  screenCap:captureScreen();

  local contentlength = screenCap.CapturedStream:GetPosition();

  local headers = {
    ["Content-Length"] = tostring(contentlength),
	  ["Content-Type"] = "image/bmp",
  }

  response:writeHead("200", headers);
  response:WritePreamble();


  response.DataStream:writeBytes(screenCap.CapturedStream.Buffer, contentlength);

  return true;
end

local handleUIOCommand = function(command)
	
  local values = utils.parseparams(command)

  if values["action"] == "mousemove" then
    UIOSimulator.MouseMove(tonumber(values["x"]), tonumber(values["y"]))
  elseif values["action"] == "mousedown" then
    UIOSimulator.MouseDown(tonumber(values["x"]), tonumber(values["y"]))
  elseif values["action"] == "mouseup" then
    UIOSimulator.MouseUp(tonumber(values["x"]), tonumber(values["y"]))		
  elseif values["action"] == "keydown" then
    UIOSimulator.KeyDown(tonumber(values["which"]))
  elseif values["action"] == "keyup" then
    UIOSimulator.KeyUp(tonumber(values["which"]))
  end
end

local startupContent = nil

local handleStartupRequest = function(request, response)

  -- read the entire contents
  if not startupContent then
    -- load the file into memory
    --local fs, err = io.open("viewscreen.htm")
    local fs, err = io.open("sharescreen.htm")

    if not fs then
      response:writeHead("500")
      response:writeEnd();

      return true
    end
		
    local content = fs:read("*all")
    fs:close();

    -- perform the substitution of values
    -- assume content looks like this:
    -- <?hostip?>:<?serviceport?>
    local subs = {
      ["frameinterval"]	= 500,
      ["hostip"] 			= net:GetLocalAddress(),
      ["capturewidth"]	= captureWidth,
      ["captureheight"]	= captureHeight,
      ["imagewidth"]		= ImageWidth,
      ["imageheight"]		= ImageHeight,
      ["screenwidth"]		= ScreenWidth,
      ["screenheight"]	= ScreenHeight,
      ["serviceport"] 	= serviceport,
    }
    startupContent = string.gsub(content, "%<%?(%a+)%?%>", subs)
  end

  -- send the content back to the requester
  response:writeHead("200",{["Content-Type"]="text/html"})
  response:writeEnd(startupContent);

  return true
end

--[[
	Responding to remote user input
]]--
local handleUIOSocketData = function(ws)
  while true do
    local frame, err = ws:ReadFrame()

    if not frame then
      print("handleUIOSocketData() - END: ", err);
      break
    end

    local command = ffi.string(frame.Data, frame.DataLength);
    handleUIOCommand(command);
  end
end

local handleUIOSocket = function(request, response)
  local ws = WebSocket();
  ws:RespondWithServerHandshake(request, response);

  spawn(handleUIOSocketData, ws);

  return false;
end


--[[
	Primary Service Response routine
]]--
local server = nil;

local OnRequest = function(param, request, response)
print("OnRequest: ", request.Url.path);

  local success = nil;

  if request.Url.path == "/uiosocket" then
    success, err = handleUIOSocket(request, response)
    
    -- For this case, return after handing off the socket
    -- as we don't want the socket to be recycled from here
    return true;
  elseif request.Url.path == "/screen.bmp" then
    --success, err = getSingleShot(response, true);
    success, err = getCompressedSingleShot(response);
  elseif request.Url.path == "/screen" then
    success, err = handleStartupRequest(request, response)
  elseif request.Url.path == "/favicon.ico" then
    success, err = StaticService.SendFile("favicon.ico", response)
  elseif request.Url.path == "/jquery.js" then
    success, err = StaticService.SendFile("jquery.js", response)
  else
	  response:writeHead("404");
	  success, err = response:writeEnd();
  end

  -- Recycle the socket
  server:HandleRequestFinished(request)
end


--[[ 
  Start running the service 
--]]
server = HttpServer(serviceport, OnRequest);
server:run();
