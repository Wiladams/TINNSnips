local ffi = require("ffi")
local WTypes = require("WTypes")

ffi.cdef[[
BOOL
EnumProcesses (
    DWORD * lpidProcess,
    DWORD cb,
    LPDWORD lpcbNeeded
    );
]]

local Lib = ffi.load("psapi");

--return Lib
return {
	Lib = Lib,
	EnumProcesses = Lib.EnumProcesses,	
}
