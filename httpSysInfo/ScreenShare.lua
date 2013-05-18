
local ffi = require "ffi"

local WebApp = require("WebApp")

local HttpRequest = require "HttpRequest"
local HttpResponse = require "HttpResponse"
local URL = require("url")
local StaticService = require("StaticService")

local GDI32 = require ("GDI32")
local User32 = require ("User32")
local BinaryStream = require("BinaryStream")
local MemoryStream = require("MemoryStream")
local WebSocketStream = require("WebSocketStream")
local Network = require("Network")

local utils = require("utils")
local zlib = require ("zlib")

local UIOSimulator = require("UIOSimulator")


--[[
	Application Variables
--]]
local ScreenWidth = User32.GetSystemMetrics(User32.FFI.CXSCREEN);
local ScreenHeight = User32.GetSystemMetrics(User32.FFI.CYSCREEN);

local captureWidth = ScreenWidth;
local captureHeight = ScreenHeight;

local ImageWidth = captureWidth;
local ImageHeight = captureHeight;
local ImageBitCount = 16;

local hbmScreen = GDIDIBSection(ImageWidth, ImageHeight, ImageBitCount);
local hdcScreen = GDI32.CreateDCForDefaultDisplay();

local net = Network();

--[[
	Application Functions
--]]
function captureScreen(nWidthSrc, nHeightSrc, nXOriginSrc, nYOriginSrc)
  nXOriginSrc = nXOriginSrc or 0;
  nYOriginSrc = nYOriginSrc or 0;

  -- Copy some of the screen into a
  -- bitmap that is selected into a compatible DC.
  local ROP = GDI32.FFI.SRCCOPY;


  local nXOriginDest = 0;
  local nYOriginDest = 0;
  local nWidthDest = ImageWidth;
  local nHeightDest = ImageHeight;
  local nWidthSrc = nWidthSrc;
  local nHeightSrc = nHeightSrc;

  GDI32.Lib.StretchBlt(hbmScreen.hDC.Handle,
    nXOriginDest,nYOriginDest,nWidthDest,nHeightDest,
    hdcScreen.Handle,
    nXOriginSrc,nYOriginSrc,nWidthSrc,nHeightSrc,
    ROP);


  hbmScreen.hDC:Flush();
end


-- Serve the screen up as a bitmap image (.bmp)
local getContentSize = function(width, height, bitcount, alignment)
  alignment = alignment or 4

  local rowsize = GDI32.GetAlignedByteCount(width, bitcount, alignment);
  local pixelarraysize = rowsize * math.abs(height);
  local filesize = 54+pixelarraysize;
  local pixeloffset = 54;

  return filesize;
end

local filesize = getContentSize(ImageWidth, ImageHeight, ImageBitCount);
local memstream = MemoryStream.new(filesize);
local zstream = MemoryStream.new(filesize);

local writeImage = function(dibsec, memstream)
	--print("printImage")
  local width = dibsec.Info.bmiHeader.biWidth;
  local height = dibsec.Info.bmiHeader.biHeight;
  local bitcount = dibsec.Info.bmiHeader.biBitCount;
  local rowsize = GDI32.GetAlignedByteCount(width, bitcount, 4);
  local pixelarraysize = rowsize * math.abs(height);
  local filesize = 54+pixelarraysize;
  local pixeloffset = 54;
	

  -- allocate a MemoryStream to fit the file size
  local streamsize = GDI32.GetAlignedByteCount(filesize, 8, 4);

  memstream:Seek(0);

  local bs = BinaryStream.new(memstream);

	-- Write File Header
  bs:WriteByte(string.byte('B'))
  bs:WriteByte(string.byte('M'))
  bs:WriteInt32(filesize);
  bs:WriteInt16(0);
  bs:WriteInt16(0);
  bs:WriteInt32(pixeloffset);

  -- Bitmap information header
  bs:WriteInt32(40);
  bs:WriteInt32(dibsec.Info.bmiHeader.biWidth);
  bs:WriteInt32(dibsec.Info.bmiHeader.biHeight);
  bs:WriteInt16(dibsec.Info.bmiHeader.biPlanes);
  bs:WriteInt16(dibsec.Info.bmiHeader.biBitCount);
  bs:WriteInt32(dibsec.Info.bmiHeader.biCompression);
  bs:WriteInt32(dibsec.Info.bmiHeader.biSizeImage);
  bs:WriteInt32(dibsec.Info.bmiHeader.biXPelsPerMeter);
  bs:WriteInt32(dibsec.Info.bmiHeader.biYPelsPerMeter);
  bs:WriteInt32(dibsec.Info.bmiHeader.biClrUsed);
  bs:WriteInt32(dibsec.Info.bmiHeader.biClrImportant);

  -- Write the actual pixel data
  memstream:WriteBytes(dibsec.Pixels, pixelarraysize, 0);
end


local getSingleShot = function(response, compressed)
  captureScreen(captureWidth, captureHeight);

  writeImage(hbmScreen, memstream);

  zstream:Seek(0);
  local compressedLen = ffi.new("int[1]", zstream.Length);
  local err = zlib.compress(zstream.Buffer,   compressedLen, memstream.Buffer, memstream:GetPosition() );

  zstream.BytesWritten = compressedLen[0];

  local contentlength = zstream.BytesWritten;
  local headers = {
    ["Content-Length"] = tostring(contentlength);
	["Content-Type"] = "image/bmp";
	["Content-Encoding"] = "deflate";
  }

  response:writeHead("200", headers);
  response:WritePreamble();
  return response.DataStream:WriteBytes(zstream.Buffer, zstream.BytesWritten);
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

local ScreenShare = {};
ScreenShare.handleStartupRequest = function(request, response)

  -- read the entire contents
  if not startupContent then
    -- load the file into memory
    local fs, err = io.open("viewscreen.htm")

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
      ["frameinterval"]	= 300,
      ["hostip"] 			= net:GetLocalAddress(),
      ["capturewidth"]	= captureWidth,
      ["captureheight"]	= captureHeight,
      ["imagewidth"]		= ImageWidth,
      ["imageheight"]		= ImageHeight,
      ["screenwidth"]		= ScreenWidth,
      ["screenheight"]	= ScreenHeight,
      ["serviceport"] 	= Runtime.config.port,
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
        local bytes, bytesread = ws:ReadFrame();

        if not bytes then
          print("handleUIOSocketData() - END: ", err);
          break
        end

        local command = ffi.string(bytes, bytesread);
        handleUIOCommand(command);
    end
end

local handleUIOSocket = function(request, response)

    local ws = WebSocketStream();
    ws:RespondWithServerHandshake(request, response);

    Runtime.Scheduler:Spawn(handleUIOSocketData, ws);

    return false;
end


--[[
	Primary Service Response routine
--]]
ScreenShare.handleRequest = function(request, response)
    local urlparts = URL.parse(request.Resource)

    local success = nil;

    if urlparts.path == "/desktop" then
        ScreenShare.handleStartupRequest(request, response);
    elseif urlparts.path == "/desktop/uiosocket" then
      --success, err = handleUIOSocket(request, response)
    elseif urlparts.path == "/desktop/screen.bmp" then
      --print("SCREEN.BMP")
      success, err = getSingleShot(response, true);
    else
	    response:writeHead("404");
	    local success, err = response:writeEnd();
    end
end


return ScreenShare;
