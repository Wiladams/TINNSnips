-- test_nuimodule.lua
local ffi = require("ffi")

ffi.cdef[[
typedef void * (* FARPROC)();

int FreeLibrary (void * hLibModule);

FARPROC GetProcAddress (void * hModule, const char * lpProcName);
void * LoadLibraryExA(const char * lpLibFileName,void * hFile,int dwFlags);
int GetLastError(void);
]]

ffi.cdef[[

int NuiInitialize(int dwFlags);

static const int NUI_INITIALIZE_FLAG_USES_COLOR = 0x00000002;

typedef int (__stdcall * PFNNuiInitialize)(int32_t dwFlags);

]]


local function testfail()
	local Lib = ffi.load("kinect10")

	print(Lib.NuiInitialize(ffi.C.NUI_INITIALIZE_FLAG_USES_COLOR))

	print("Hello World!")
end

local function testsuccess()
	local k32Lib = ffi.load("kernel32.dll")
	local handle = k32Lib.LoadLibraryExA("kinect10", nil, 0);
	
	if handle == nil then
		print("Error from LoadLibraryExA: ", k32Lib.GetLastError())
		return nil;
	end


	local proc = k32Lib.GetProcAddress(handle, "NuiInitialize");
	print("GetProcAddress: ", proc)

	if proc == nil then
		print("Error from GetProcAddress: ", k32Lib.GetLastError())
		return nil;
	end


	print("Call: ", ffi.cast("PFNNuiInitialize", proc)(ffi.C.NUI_INITIALIZE_FLAG_USES_COLOR))

	k32Lib.FreeLibrary(handle)
end

--testfail();
testsuccess()
