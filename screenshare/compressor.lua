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
   12 bytes.

     compress2 returns Z_OK if success, Z_MEM_ERROR if there was not enough
   memory, Z_BUF_ERROR if there was not enough room in the output buffer,
   Z_STREAM_ERROR if the level parameter is invalid.

  Return:
  The actual sized of the compressed data
--]]

local Compressor = {}
setmetatable(Compressor, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
local Compressor_mt = {
  __index = Compressor,
}



Compressor.init = function(self, params)
    params = params or {}

    local strm = ffi.new("z_stream");
    --stream.zalloc = (alloc_func)0;
    --stream.zfree = (free_func)0;
    --stream.opaque = (voidpf)0;
    local level = params.Level or zlib.Z_DEFAULT_COMPRESSION;
    local method = zlib.Z_DEFLATED;
    local windowBits = 15 + 16; -- add 16 to get gzip header
    local memLevel = 8;
    local strategy = params.Strategy or zlib.Z_DEFAULT_STRATEGY;
    local stream_size = ffi.sizeof("z_stream")

    err = zlib.deflateInit2_(strm, 
      level, 
      method, 
      windowBits, 
      memLevel,
      strategy, 
      zlib.zlibVersion(), 
      stream_size);

    if (err ~= zlib.Z_OK) then
        return nil, err;
    end

    local obj = {
      Level = level,
      Method = method,
      WindowBits = windowBits,
      MemLevel = memLevel,
      Strategy = strategy,
      StreamSize = stream_size,
      Stream = strm,
    }
    setmetatable(obj, Compressor_mt);

    return obj;
end

Compressor.create = function(self, ...)
	return self:init(...);
end

Compressor.reset = function(self)
    -- zero out the stream object
    ffi.fill(self.Stream, ffi.sizeof("z_stream"), 0);

    local err = zlib.deflateInit2_(self.Stream, 
      self.Level, 
      self.Method, 
      self.WindowBits, 
      self.MemLevel,
      self.Strategy, 
      zlib.zlibVersion(), 
      ffi.sizeof("z_stream"));

    if (err ~= zlib.Z_OK) then
        print("reset ERROR: ", err)
        return nil, err;
    end

    return self;
end

Compressor.compress = function(self, dest, destLen, source, sourceLen)

    local err;

    self.Stream.next_in = ffi.cast("char *",source);
    self.Stream.avail_in = ffi.cast("unsigned int", sourceLen);

    self.Stream.next_out = ffi.cast("char *", dest);
    self.Stream.avail_out = destLen;
    
    if (self.Stream.avail_out ~= destLen) then
	    return zlib.Z_BUF_ERROR;
    end
	
    err = zlib.deflate(self.Stream, zlib.Z_FINISH);
    if (err ~= zlib.Z_STREAM_END) then
        zlib.deflateEnd(self.Stream);
	      if err == zlib.Z_OK then
	          return zlib.Z_BUF_ERROR;
	      end
        
        return err;
    end

    err = zlib.deflateEnd(self.Stream);
    if err ~= zlib.Z_OK then
        return false, err;
    end
    
    return self.Stream.total_out;
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
