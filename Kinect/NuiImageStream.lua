local ffi = require("ffi")

local NuiApi = require("NuiApi")

local NuiImageFrame = {}
setmetatable(NuiImageFrame, {
	__call = function(self, ...)
		return self:create(...);
	end,
})

local NuiImageFrame_mt = {
	__index = NuiImageFrame,	
} 

function NuiImageFrame.init(self, imgstream, pframe)
	local obj = {
		ImageStream = imgstream,
		Frame = pframe,
	}
	setmetatable(obj, NuiImageFrame_mt);

	return obj;
end

function NuiImageFrame.create(self, imgstream, pframe)
	return self:init(imgstream, pframe)
end

function NuiImageFrame.release(self)
	local hr = NuiApi.NuiImageStreamReleaseFrame(self.ImageStream:getNativeHandle(), self.Frame);
	if hr ~= 0 then
		return false, hr;
	end

	return true
end


local NuiImageStream = {}
setmetatable(NuiImageStream, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local NuiImageStream_mt = {
	__index = NuiImageStream,
}

function NuiImageStream.init(self, rawhandle)
	local obj = {
		Handle = rawhandle;
	}
	setmetatable(obj, NuiImageStream_mt)

	return obj;
end

function NuiImageStream.create(self, eImageType, eResolution, dwImageFrameFlags, dwFrameLimit, hNextFrameEvent)
	eImageType = eImageType or ffi.C.NUI_IMAGE_TYPE_COLOR;
	eResolution = eResolution or ffi.C.NUI_IMAGE_RESOLUTION_640x480;
	dwImageFrameFlags = dwImageFrameFlags or 0;
	dwFrameLimit = dwFrameLimit or 2;

	-- try to open up the stream
	local phStreamHandle = ffi.new("HANDLE[1]")

	local hr = NuiApi.NuiImageStreamOpen(eImageType, eResolution, dwImageFrameFlags, dwFrameLimit, hNextFrameEvent, phStreamHandle)
	
	if hr ~= 0 then
		print("NuiImageStream.create, ERROR: ", hr)
		return nil, hr;
	end

	return self:init(phStreamHandle[0])
end

function NuiImageStream.getNativeHandle(self)
	return self.Handle;
end

function NuiImageStream.getNextFrame(self, dwMillisecondsToWait)
	dwMillisecondsToWait = dwMillisecondsToWait or 1000/15;	-- 30 fps
	local ppcImageFrame = ffi.new("const NUI_IMAGE_FRAME *[1]")
	local hr = NuiApi.NuiImageStreamGetNextFrame(self:getNativeHandle(),
		dwMillisecondsToWait, 
		ppcImageFrame)
			
	if hr ~= 0 then
		return nil, hr
	end

	return NuiImageFrame(self, ppcImageFrame[0]);
end


return NuiImageStream
