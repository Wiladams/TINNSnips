-- OclMan.lua

local ffi = require "ffi"

ffi.cdef[[
typedef int8_t		cl_char;
typedef uint8_t		cl_uchar;
typedef int16_t		cl_short;
typedef uint16_t	cl_ushort;
typedef int32_t		cl_int;
typedef uint32_t	cl_uint;
typedef int64_t		cl_long;
typedef uint64_t	cl_ulong;

typedef uint16_t	cl_half;
typedef float		cl_float;
typedef double		cl_double;
]]

-- Macro names and corresponding values defined by OpenCL
CL_CHAR_BIT         = 8
CL_SCHAR_MAX        = 127
CL_SCHAR_MIN        = (-127-1)
CL_CHAR_MAX         = CL_SCHAR_MAX
CL_CHAR_MIN         = CL_SCHAR_MIN
CL_UCHAR_MAX        = 255
CL_SHRT_MAX         = 32767
CL_SHRT_MIN         = (-32767-1)
CL_USHRT_MAX        = 65535
CL_INT_MAX          = 2147483647
CL_INT_MIN          = (-2147483647-1)
CL_UINT_MAX         = 0xffffffff
CL_LONG_MAX         = (0x7FFFFFFFFFFFFFFFLL)
CL_LONG_MIN         = (-0x7FFFFFFFFFFFFFFFLL - 1LL)
CL_ULONG_MAX        = (0xFFFFFFFFFFFFFFFFULL)

CL_FLT_DIG          = 6
CL_FLT_MANT_DIG     = 24
--CL_FLT_MAX_10_EXP   +38
--CL_FLT_MAX_EXP      +128
--CL_FLT_MIN_10_EXP   -37
--CL_FLT_MIN_EXP      -125
CL_FLT_RADIX        = 2
CL_FLT_MAX          = 340282346638528859811704183484516925440.0
CL_FLT_MIN          = 1.175494350822287507969e-38
--CL_FLT_EPSILON      0x1.0p-23

CL_DBL_DIG          = 15
CL_DBL_MANT_DIG     = 53
--CL_DBL_MAX_10_EXP   +308
--CL_DBL_MAX_EXP      +1024
--CL_DBL_MIN_10_EXP   -307
--CL_DBL_MIN_EXP      -1021
CL_DBL_RADIX        = 2
CL_DBL_MAX          = 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.0
CL_DBL_MIN          = 2.225073858507201383090e-308
CL_DBL_EPSILON      = 2.220446049250313080847e-16

 CL_M_E             = 2.718281828459045090796
 CL_M_LOG2E         = 1.442695040888963387005
 CL_M_LOG10E        = 0.434294481903251816668
 CL_M_LN2           = 0.693147180559945286227
 CL_M_LN10          = 2.302585092994045901094
 CL_M_PI            = 3.141592653589793115998
 CL_M_PI_2          = 1.570796326794896557999
 CL_M_PI_4          = 0.785398163397448278999
 CL_M_1_PI          = 0.318309886183790691216
 CL_M_2_PI          = 0.636619772367581382433
 CL_M_2_SQRTPI      = 1.128379167095512558561
 CL_M_SQRT2         = 1.414213562373095145475
 CL_M_SQRT1_2       = 0.707106781186547572737

 CL_M_E_F           = 2.71828174591064
 CL_M_LOG2E_F       = 1.44269502162933
 CL_M_LOG10E_F      = 0.43429449200630
 CL_M_LN2_F         = 0.69314718246460
 CL_M_LN10_F        = 2.30258512496948
 CL_M_PI_F          = 3.14159274101257
 CL_M_PI_2_F        = 1.57079637050629
 CL_M_PI_4_F        = 0.78539818525314
 CL_M_1_PI_F        = 0.31830987334251
 CL_M_2_PI_F        = 0.63661974668503
 CL_M_2_SQRTPI_F    = 1.12837922573090
 CL_M_SQRT2_F       = 1.41421353816986
 CL_M_SQRT1_2_F     = 0.70710676908493

CL_HUGE_VALF        = (1e50)
CL_INFINITY 		= CL_HUGE_VALF
CL_NAN              = (CL_INFINITY - CL_INFINITY)
CL_HUGE_VAL         = (1e500)
CL_FLT_MAX			= CL_MAXFLOAT


require "cl"

ocl = ffi.load("OpenCL")




ffi.cdef[[
typedef struct {
	cl_platform_id	ID;
} CLPlatform;

typedef struct {
	cl_device_id ID;
} CLDevice;

typedef struct {
	cl_context ID;
	cl_device_id	DeviceHandle;
} CLContext;

typedef struct {
	cl_program Handle;
} CLProgram;

typedef struct {
	cl_mem Handle;
	int	Size;
} CLMem;

typedef struct {
	cl_kernel Handle;
} CLKernel;

typedef struct {
	cl_command_queue Handle;
} CLCommandQueue;

typedef struct {
	cl_event Handle;
} CLEvent;
]]

function CL_CHECK(err, expr)
	assert(err == CL_SUCCESS, string.format("OpenCL Error: '%s' returned %d!\n", expr, err))
	return err
end


CLPlatform = {}
CLPlatform_mt = {
	__index = {
		GetPlatformInfo = function(self, param_name)
			local lpparam_value_size_ret = ffi.new("size_t[1]")
			local param_value = ffi.new("char[1024]")
			ocl.clGetPlatformInfo(self.ID, param_name, 256, param_value,
				lpparam_value_size_ret);
			local param_value_size = lpparam_value_size_ret[0]

			return ffi.string(param_value), param_value_size
		end,

		GetDevices = function(self, device_type)
			device_type = device_type or CL_DEVICE_TYPE_ALL

			local lpnum_devices = ffi.new("int[1]")
			local device_ids = ffi.new("cl_device_id[256]")
			local err = ocl.clGetDeviceIDs(self.ID, device_type, 256, device_ids, lpnum_devices)
			local num_devices = lpnum_devices[0];

			if num_devices == 0 then return nil end

			local devices = {}
			for i=0,num_devices-1 do
				table.insert(devices, CLDevice(device_ids[i]))
			end

			return devices;
		end,
	},
}
CLPlatform = ffi.metatype("CLPlatform", CLPlatform_mt)


CLDevice = {}
CLDevice_mt = {
	__index = {
		GetInfo = function(self, param_name)
			local lpparam_value_size_ret = ffi.new("size_t[1]")
			local param_value_size = 1024;
			local param_value = ffi.new("char[1024]")

			local err = ocl.clGetDeviceInfo(self.ID, param_name, param_value_size, param_value,
				lpparam_value_size_ret);
			local param_value_size = lpparam_value_size_ret[0]
--print("CLDevice:GetInfo: err ", err);
			return ffi.string(param_value)
		end,
	},
}
CLDevice = ffi.metatype("CLDevice", CLDevice_mt);




CLContext = {}
CLContext_mt = {
	__index = {
		-- Create a context for a particular device
		CreateForDevice = function(self, device)
			local devices = ffi.new("cl_device_id[1]", device.ID);
			local lperrcode_ret = ffi.new("cl_int[1]");
			local context = ocl.clCreateContext(nil, 1, devices, pfn_notify, nil, lperrcode_ret);
			local errcode_ret = lperrcode_ret[0];
			if errcode_ret == CL_SUCCESS then
				self.ID = context
				self.DeviceHandle = device.ID;
			end
			return self;
		end,

		CreateProgramFromSource = function(self, program_source)
			local lperrcode_ret = ffi.new("cl_int[1]");
			local src_array = ffi.new("char*[1]", ffi.cast("char *",program_source));
			local program = ocl.clCreateProgramWithSource(self.ID, 1, src_array, nil,lperrcode_ret);
			local errcode_ret = lperrcode_ret[0];
			CL_CHECK(errcode_ret, "clCreateProgramWithSource");
			return CLProgram(program);
		end,

		CreateBuffer = function(self, size, flags, hostPtr)
			local lperrcode_ret = ffi.new("cl_int[1]");
			local mem = ocl.clCreateBuffer(self.ID, flags, size, hostPtr, lperrcode_ret);
			local errcode_ret = lperrcode_ret[0];

			assert(errcode_ret == CL_SUCCESS, "clCreateBuffer");

			local buff = CLMem(mem, size);

			return buff;
		end,

		CreateCommandQueue = function(self)
			local lperrcode_ret = ffi.new("cl_int[1]");
			local queue_id = ocl.clCreateCommandQueue(self.ID, self.DeviceHandle, 0, lperrcode_ret);
			local errcode_ret = lperrcode_ret[0];
			assert(errcode_ret == CL_SUCCESS, "clCreateCommandQueue");

			local queue = CLCommandQueue(queue_id);

			return queue;
		end,
	},
}
CLContext = ffi.metatype("CLContext", CLContext_mt);



CLProgram = {}
CLProgram_mt = {
	__index = {
		Build = function(self, flags)
			flags = flags or ""
			local err = ocl.clBuildProgram(self.Handle, 0, nil, flags, nil, nil)
			if  err ~= CL_SUCCESS then
				local buffer = ffi.new("char[10240]");
				ocl.clGetProgramBuildInfo(self.Handle, nil, CL_PROGRAM_BUILD_LOG, ffi.sizeof(buffer), buffer, nil);
				print("CL Compilation failed:", err);
				print(ffi.string(buffer));

				return err;
			end
		end,

		CreateKernel = function(self, kernel_name)
			local lperrcode_ret = ffi.new("int[1]");
			local handle = ocl.clCreateKernel(self.Handle, kernel_name, lperrcode_ret)
			local errcode_ret = lperrcode_ret[0];

			return CLKernel(handle), errcode_ret
		end,
	},
}
CLProgram = ffi.metatype("CLProgram", CLProgram_mt);



CLKernel = {}
CLKernel_mt = {
	__index = {
		SetIndexedArg = function(self, idx, valuePtr, size)
			local handle = ffi.cast("void *", valuePtr);
			local lparg = ffi.new("void *[1]", handle);

		--print("SetIndexedArg: ", idx, valuePtr, size);
			CL_CHECK(ocl.clSetKernelArg(self.Handle, idx, size, lparg), "clSetKernelArg");
		end,
	},
}
CLKernel = ffi.metatype("CLKernel", CLKernel_mt);



CLMem = {}
CLMem_mt = {
	__tostring = function(self)
		return string.format("Size: %d", self.Size);
	end,

	__index = {
		CreateForContext = function(self, context, size, flags, hostPtr)
			local lperrcode_ret = ffi.new("cl_int[1]");
			local mem = ocl.clCreateBuffer(context.ID, flags, size, hostPtr, lperrcode_ret);
			local errcode_ret = lperrcode_ret[0];

			assert(errcode_ret == CL_SUCCESS, "clCreateBuffer");

			self.Handle = mem;
			self.Size = size;

			return self;
		end,
	},
}
CLMem = ffi.metatype("CLMem", CLMem_mt);


CLCommandQueue = {}
CLCommandQueue_mt = {
	__index = {
		EnqueueWriteBuffer = function(self, buffer, offset, valuePtr, sizeofvalue, blocking)
			local err = ocl.clEnqueueWriteBuffer(self.Handle, buffer.Handle, CL_TRUE, offset, sizeofvalue,valuePtr, 0, nil, nil);
			CL_CHECK(err,"clEnqueueWriteBuffer");
		end,

		EnqueueNDRangeKernel = function(self, kernel, global_work_size, dims)
			dims = dims or 1
			local global_work_offset = nil;
			local local_work_size = nil;
			local num_events_in_wait_list = 0;
			local event_wait_list = nil;
			local lpCompletion = ffi.new("cl_event[1]");

			local err = ocl.clEnqueueNDRangeKernel(self.Handle, kernel.Handle, dims,
				global_work_offset, global_work_size,
				local_work_size,
				num_events_in_wait_list, event_wait_list,
				lpCompletion);
			CL_CHECK(err,"clEnqueueNDRangeKernel");

			return CLEvent(lpCompletion[0]), err;
		end,

	},
}
CLCommandQueue = ffi.metatype("CLCommandQueue", CLCommandQueue_mt);



CLEvent = {}
CLEvent_mt = {
	__index = {
		Wait = function(self)
			local lpEventHandle = ffi.new("cl_event[1]", self.Handle);
			local err = ocl.clWaitForEvents(1, lpEventHandle);
			CL_CHECK(err,"clWaitForEvents");
		end,

		Release = function(self)
			local err = ocl.clReleaseEvent(self.Handle);
			CL_CHECK(err,"clReleaseEvent");
		end,
	},
}
CLEvent = ffi.metatype("CLEvent", CLEvent_mt);






function CLGetPlatform()
	local lpnum_platforms = ffi.new("int[1]")
	local lpplatforms = ffi.new("cl_platform_id[256]");
	local err = ocl.clGetPlatformIDs(256, lpplatforms , lpnum_platforms);
	local num_platforms = lpnum_platforms[0];

	return CLPlatform(lpplatforms[0]), num_platforms
end





return ocl
