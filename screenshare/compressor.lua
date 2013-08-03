local ffi = require("ffi")
local bit = require("bit");
local rshift = bit.rshift;
local lshift = bit.lshift;

local zlib = require ("zlib")

--[[
 ===========================================================================
     Compresses the source buffer into the destination buffer. The level
   parameter has the same meaning as in deflateInit.  sourceLen is the byte
   length of the source buffer. Upon entry, destLen is the total size of the
   destination buffer, which must be at least 0.1% larger than sourceLen plus
   12 bytes. Upon exit, destLen is the actual size of the compressed buffer.

     compress2 returns Z_OK if success, Z_MEM_ERROR if there was not enough
   memory, Z_BUF_ERROR if there was not enough room in the output buffer,
   Z_STREAM_ERROR if the level parameter is invalid.
--]]

local Compressor = {}
setmetatable(Compressor, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

Compressor.init = function(self, ...)
end

Compressor.create = function(self, ...)
	return self:init(...);
end

Compressor.compress = function(self, dest, destLen, source, sourceLen, level)
    level = level or zlib.Z_DEFAULT_COMPRESSION;
 --[[
 Bytef *dest;
    uLongf *destLen;
    const Bytef *source;
    uLong sourceLen;
--]]

    local stream = ffi.new("z_stream");
    local err;

    stream.next_in = ffi.cast("char *",source);
    stream.avail_in = ffi.cast("unsigned int", sourceLen);

    stream.next_out = ffi.cast("char *", dest);
    stream.avail_out = destLen;
    
    if (stream.avail_out ~= destLen) then
	return zlib.Z_BUF_ERROR;
    end
	
    --stream.zalloc = (alloc_func)0;
    --stream.zfree = (free_func)0;
    --stream.opaque = (voidpf)0;
    local strategy = zlib.Z_DEFAULT_STRATEGY;
    
    err = zlib.deflateInit(stream, level);
    err = zlib.deflateInit2_(stream, level, 
      int method, 
      int windowBits, 
      int memLevel,
      strategy, 
      zlib.zlibVersion(), 
      int stream_size );

    if (err ~= zlib.Z_OK) then
        return err;
    end

    err = zlib.deflate(stream, zlib.Z_FINISH);
    if (err ~= zlib.Z_STREAM_END) then
        zlib.deflateEnd(stream);
	if err == zlib.Z_OK then
	    return zlib.Z_BUF_ERROR;
	end
        return err;
    end

    err = zlib.deflateEnd(stream);
    if err ~= zlib.Z_OK then
        return false, err;
    end
    
    return stream.total_out;
end


--[[
 ===========================================================================
     If the default memLevel or windowBits for deflateInit() is changed, then
   this function needs to be updated.
 --]]
Compressor.compressBound = function (self, sourceLen)
    return sourceLen + rshift(sourceLen, 12) + rshift(sourceLen, 14) +
          rshift (sourceLen, 25) + 13;
end


return Compressor
