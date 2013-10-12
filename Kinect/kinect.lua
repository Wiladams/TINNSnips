


require "win_kernel32"
require "WTypes"
require "WinError"

local kinectlib = ffi.load("Kinect10")
local kernel32 = ffi.load("kernel32")






--
-- NUI Common Initialization Declarations
--

NUI_INITIALIZE_FLAG_USES_AUDIO                  =0x10000000
NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX =0x00000001
NUI_INITIALIZE_FLAG_USES_COLOR                  =0x00000002
NUI_INITIALIZE_FLAG_USES_SKELETON               =0x00000008
NUI_INITIALIZE_FLAG_USES_DEPTH                  =0x00000020

NUI_INITIALIZE_DEFAULT_HARDWARE_THREAD  =0xFFFFFFFF


ffi.cdef[[
HRESULT NuiInitialize(DWORD dwFlags);

void NuiShutdown();
]]


--
-- Define NUI error codes derived from win32 errors
--

E_NUI_DEVICE_NOT_CONNECTED  = __HRESULT_FROM_WIN32(ERROR_DEVICE_NOT_CONNECTED)
E_NUI_DEVICE_NOT_READY      = __HRESULT_FROM_WIN32(ERROR_NOT_READY)
E_NUI_ALREADY_INITIALIZED   = __HRESULT_FROM_WIN32(ERROR_ALREADY_INITIALIZED)
E_NUI_NO_MORE_ITEMS         = __HRESULT_FROM_WIN32(ERROR_NO_MORE_ITEMS)


FACILITY_NUI = 0x301

S_NUI_INITIALIZING                      = MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_NUI, 1)   -- 0x03010001
E_NUI_FRAME_NO_DATA                     = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 1)



--static_assert(E_NUI_FRAME_NO_DATA == 0x83010001, "Error code has changed.");
E_NUI_STREAM_NOT_ENABLED                = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 2)
E_NUI_IMAGE_STREAM_IN_USE               = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 3)
E_NUI_FRAME_LIMIT_EXCEEDED              = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 4)
E_NUI_FEATURE_NOT_INITIALIZED           = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 5)
E_NUI_NOTGENUINE                        = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 6)
E_NUI_INSUFFICIENTBANDWIDTH             = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 7)
E_NUI_NOTSUPPORTED                      = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 8)
E_NUI_DEVICE_IN_USE                     = MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 9)
--[[
#define E_NUI_DATABASE_NOT_FOUND                MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 13)
#define E_NUI_DATABASE_VERSION_MISMATCH         MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 14)
// The requested feateure is not available on this version of the hardware
#define E_NUI_HARDWARE_FEATURE_UNAVAILABLE      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 15)                                              // 0x8301000F
// The hub is no longer connected to the machine
#define E_NUI_NOTCONNECTED                      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 20 */ ERROR_BAD_UNIT)                         // 0x83010014
// Some part of the device is not connected.
#define E_NUI_NOTREADY                          MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 21 */ ERROR_NOT_READY)                        // 0x83010015
// Skeletal engine is already in use
#define E_NUI_SKELETAL_ENGINE_BUSY              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 170 */ ERROR_BUSY)
// The hub and motor are connected, but the camera is not
#define E_NUI_NOTPOWERED                        MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 639 */ ERROR_INSUFFICIENT_POWER)               // 0x8301027F
// Bad index passed in to NuiCreateInstanceByXXX
#define E_NUI_BADIINDEX                         MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 1413 */ ERROR_INVALID_INDEX)                   // 0x83010585
--]]




NUI_SKELETON_COUNT = 6
MICARRAY_ADAPTIVE_BEAM = 0x1100


ffi.cdef[[
typedef struct _Vector4
{
    FLOAT x;
    FLOAT y;
    FLOAT z;
    FLOAT w;
} 	Vector4;
]]
Vector4 = ffi.typeof("Vector4")


ffi.cdef[[
typedef enum _NUI_SKELETON_POSITION_INDEX
    {	NUI_SKELETON_POSITION_HIP_CENTER	= 0,
	NUI_SKELETON_POSITION_SPINE	= ( NUI_SKELETON_POSITION_HIP_CENTER + 1 ) ,
	NUI_SKELETON_POSITION_SHOULDER_CENTER	= ( NUI_SKELETON_POSITION_SPINE + 1 ) ,
	NUI_SKELETON_POSITION_HEAD	= ( NUI_SKELETON_POSITION_SHOULDER_CENTER + 1 ) ,
	NUI_SKELETON_POSITION_SHOULDER_LEFT	= ( NUI_SKELETON_POSITION_HEAD + 1 ) ,
	NUI_SKELETON_POSITION_ELBOW_LEFT	= ( NUI_SKELETON_POSITION_SHOULDER_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_WRIST_LEFT	= ( NUI_SKELETON_POSITION_ELBOW_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_HAND_LEFT	= ( NUI_SKELETON_POSITION_WRIST_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_SHOULDER_RIGHT	= ( NUI_SKELETON_POSITION_HAND_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_ELBOW_RIGHT	= ( NUI_SKELETON_POSITION_SHOULDER_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_WRIST_RIGHT	= ( NUI_SKELETON_POSITION_ELBOW_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_HAND_RIGHT	= ( NUI_SKELETON_POSITION_WRIST_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_HIP_LEFT	= ( NUI_SKELETON_POSITION_HAND_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_KNEE_LEFT	= ( NUI_SKELETON_POSITION_HIP_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_ANKLE_LEFT	= ( NUI_SKELETON_POSITION_KNEE_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_FOOT_LEFT	= ( NUI_SKELETON_POSITION_ANKLE_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_HIP_RIGHT	= ( NUI_SKELETON_POSITION_FOOT_LEFT + 1 ) ,
	NUI_SKELETON_POSITION_KNEE_RIGHT	= ( NUI_SKELETON_POSITION_HIP_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_ANKLE_RIGHT	= ( NUI_SKELETON_POSITION_KNEE_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_FOOT_RIGHT	= ( NUI_SKELETON_POSITION_ANKLE_RIGHT + 1 ) ,
	NUI_SKELETON_POSITION_COUNT	= ( NUI_SKELETON_POSITION_FOOT_RIGHT + 1 )
    } 	NUI_SKELETON_POSITION_INDEX;

typedef enum _NUI_IMAGE_TYPE
{
  NUI_IMAGE_TYPE_DEPTH_AND_PLAYER_INDEX = 0,            // USHORT
  NUI_IMAGE_TYPE_COLOR,                                 // RGB32 data
  NUI_IMAGE_TYPE_COLOR_YUV,                             // YUY2 stream from camera h/w, but converted to RGB32 before user getting it.
  NUI_IMAGE_TYPE_COLOR_RAW_YUV,                         // YUY2 stream from camera h/w.
  NUI_IMAGE_TYPE_DEPTH,                                 // USHORT
} NUI_IMAGE_TYPE;

typedef enum _NUI_IMAGE_RESOLUTION
{
  NUI_IMAGE_RESOLUTION_INVALID = -1,
  NUI_IMAGE_RESOLUTION_80x60 = 0,
  NUI_IMAGE_RESOLUTION_320x240,
  NUI_IMAGE_RESOLUTION_640x480,
  NUI_IMAGE_RESOLUTION_1280x960                         // for hires color only
} NUI_IMAGE_RESOLUTION;
]]

ffi.cdef[[
typedef struct _NUI_IMAGE_VIEW_AREA
{
    int eDigitalZoom;
    LONG lCenterX;
    LONG lCenterY;
} 	NUI_IMAGE_VIEW_AREA;

typedef struct _NUI_TRANSFORM_SMOOTH_PARAMETERS
{
    FLOAT fSmoothing;
    FLOAT fCorrection;
    FLOAT fPrediction;
    FLOAT fJitterRadius;
    FLOAT fMaxDeviationRadius;
} 	NUI_TRANSFORM_SMOOTH_PARAMETERS;



typedef enum _NUI_SKELETON_POSITION_TRACKING_STATE
{
	NUI_SKELETON_POSITION_NOT_TRACKED	= 0,
	NUI_SKELETON_POSITION_INFERRED	= ( NUI_SKELETON_POSITION_NOT_TRACKED + 1 ) ,
	NUI_SKELETON_POSITION_TRACKED	= ( NUI_SKELETON_POSITION_INFERRED + 1 )
} 	NUI_SKELETON_POSITION_TRACKING_STATE;

typedef enum _NUI_SKELETON_TRACKING_STATE
{
	NUI_SKELETON_NOT_TRACKED	= 0,
	NUI_SKELETON_POSITION_ONLY	= ( NUI_SKELETON_NOT_TRACKED + 1 ) ,
	NUI_SKELETON_TRACKED	= ( NUI_SKELETON_POSITION_ONLY + 1 )
} 	NUI_SKELETON_TRACKING_STATE;

typedef struct _NUI_SKELETON_DATA
{
    NUI_SKELETON_TRACKING_STATE eTrackingState;
    DWORD dwTrackingID;
    DWORD dwEnrollmentIndex;
    DWORD dwUserIndex;
    Vector4 Position;
    Vector4 SkeletonPositions[ 20 ];
    NUI_SKELETON_POSITION_TRACKING_STATE eSkeletonPositionTrackingState[ 20 ];
    DWORD dwQualityFlags;
} 	NUI_SKELETON_DATA;


//	#pragma pack(push, 16)
typedef struct _NUI_SKELETON_FRAME
{
    LARGE_INTEGER liTimeStamp;
    DWORD dwFrameNumber;
    DWORD dwFlags;
    Vector4 vFloorClipPlane;
    Vector4 vNormalToGravity;
    NUI_SKELETON_DATA SkeletonData[ 6 ];
} 	NUI_SKELETON_FRAME;

typedef struct _NUI_LOCKED_RECT
{
	int32_t		Pitch;
	int32_t		size;
	void*		pBits;
} NUI_LOCKED_RECT;
]]
NUI_LOCKED_RECT = ffi.typeof("NUI_LOCKED_RECT")



-- {8c3cebfa-a35d-497e-bc9a-e9752a8155e0}
IID_INuiAudioBeam = DEFINE_UUID("IID_INuiAudioBeam", 0x8c3cebfa, 0xa35d, 0x497e, 0xbc, 0x9a, 0xe9, 0x75, 0x2a, 0x81, 0x55, 0xe0);

ffi.cdef[[
	typedef struct INuiAudioBeam INuiAudioBeam;

    typedef struct INuiAudioBeamVtbl
    {
        HRESULT (  *QueryInterface )(
            INuiAudioBeam * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */
            void **ppvObject);

        ULONG (  *AddRef )(INuiAudioBeam * This);
        ULONG (  *Release )(INuiAudioBeam * This);


        HRESULT (  *GetBeam )(INuiAudioBeam * This,
            /* [retval][out] */ double *angle);

        HRESULT (  *SetBeam )(
            INuiAudioBeam * This,
            /* [in] */ double angle);

        HRESULT (  *GetPosition )(
            INuiAudioBeam * This,
            /* [out] */ double *angle,
            /* [out] */ double *confidence);

    } INuiAudioBeamVtbl;

    typedef struct INuiAudioBeam
    {
        INuiAudioBeamVtbl *lpVtbl;
    }INuiAudioBeam;
]]



-- 13ea17f5-ff2e-4670-9ee5-1297a6e880d1
IID_INuiFrameTexture = DEFINE_UUID("IID_INuiFrameTexture",0x13ea17f5,0xff2e,0x4670,0x9e,0xe5,0x12,0x97,0xa6,0xe8,0x80,0xd1);

ffi.cdef[[
typedef struct _NUI_SURFACE_DESC
{
    uint32_t Width;
    uint32_t Height;
} 	NUI_SURFACE_DESC;
]]

ffi.cdef[[
typedef struct INuiFrameTexture INuiFrameTexture;

typedef struct INuiFrameTextureVtbl
{
	// IUnknown
	HRESULT (*QueryInterface )(
		INuiFrameTexture * This,
		REFIID riid,
		void **ppvObject);

	ULONG (*AddRef)(INuiFrameTexture * This);

	ULONG (*Release )(INuiFrameTexture * This);


	// INuiFrameTexture Specific
	int (*BufferLen )(INuiFrameTexture * This);

	int (*Pitch )(INuiFrameTexture * This);

	HRESULT (*LockRect )(INuiFrameTexture * This,
		UINT Level,
		NUI_LOCKED_RECT *pLockedRect,
        RECT *pRect,
		DWORD Flags);

	HRESULT (*GetLevelDesc )(INuiFrameTexture * This,
		UINT Level,
		NUI_SURFACE_DESC *pDesc);

	HRESULT (*UnlockRect )(INuiFrameTexture * This,
		UINT Level);

} INuiFrameTextureVtbl;

typedef struct INuiFrameTexture
{
	struct INuiFrameTextureVtbl *lpVtbl;
} INuiFrameTexture;
]]

ffi.cdef[[
typedef struct _NUI_IMAGE_FRAME
{
	LARGE_INTEGER liTimeStamp;
    DWORD dwFrameNumber;
    NUI_IMAGE_TYPE eImageType;
    NUI_IMAGE_RESOLUTION eResolution;
    INuiFrameTexture *pFrameTexture;
    DWORD dwFrameFlags;
    NUI_IMAGE_VIEW_AREA ViewArea;
} NUI_IMAGE_FRAME, *PNUI_IMAGE_FRAME;
]]


INuiFrameTexture = nil
INuiFrameTexture_mt = {
	__index = {
		GetBufferLength = function(self)
			local len = self.lpVtbl.BufferLen(self);
			return len
		end,

		GetPitch = function(self)
			local pitch = self.lpVtbl.Pitch(self);
			return pitch
		end,

		LockRect = function(self, Level, Flags)
			Level = Level or 0
			Flags = Flags or 0

			local lockedrect = ffi.new("NUI_LOCKED_RECT[1]")
			local frame = ffi.new("RECT[1]")

			local hr = self.lpVtbl.LockRect(self, Level, lockedrect, frame, Flags)
			local severity, facility, code = HRESULT_PARTS(hr)
--print("Lock Rect: ", severity, facility, code)
			return lockedrect[0], frame[0]
		end,

		UnlockRect = function(self, Level)
			Level = Level or 0
			local hr = self.lpVtbl.UnlockRect(self,Level)
			return hr
		end,
	},
}
INuiFrameTexture = ffi.metatype("INuiFrameTexture", INuiFrameTexture_mt)



-- 1f5e088c-a8c7-41d3-9957-209677a13e85
IID_INuiSensor = DEFINE_UUID("IID_INuiSensor",0x1f5e088c,0xa8c7,0x41d3,0x99,0x57,0x20,0x96,0x77,0xa1,0x3e,0x85);

ffi.cdef[[
typedef struct INuiSensor INuiSensor;

typedef struct INuiSensorVtbl
{
	// IUnknown
	HRESULT (*QueryInterface)(INuiSensor * This,
		REFIID riid,
		void **ppvObject);

	ULONG (*AddRef)(INuiSensor * This);
	ULONG (*Release)(INuiSensor * This);


	// INuiSensor
	HRESULT (*NuiInitialize)(INuiSensor * This,
            /* [in] */ DWORD dwFlags);

	void (  *NuiShutdown )(INuiSensor * This);

	HRESULT (*NuiSetFrameEndEvent)(INuiSensor * This,
            /* [in] */ HANDLE hEvent,
            /* [in] */ DWORD dwFrameEventFlag);

	HRESULT (*NuiImageStreamOpen)(INuiSensor * This,
            NUI_IMAGE_TYPE eImageType,
            NUI_IMAGE_RESOLUTION eResolution,
            DWORD dwImageFrameFlags,
            DWORD dwFrameLimit,
            HANDLE hNextFrameEvent,
            HANDLE *phStreamHandle);

	HRESULT (  *NuiImageStreamSetImageFrameFlags )(INuiSensor * This,
            /* [in] */ HANDLE hStream,
            /* [in] */ DWORD dwImageFrameFlags);

	HRESULT (  *NuiImageStreamGetImageFrameFlags )(INuiSensor * This,
            /* [in] */ HANDLE hStream,
            /* [retval][out] */ DWORD *pdwImageFrameFlags);

	HRESULT (*NuiImageStreamGetNextFrame )(INuiSensor * This,
		HANDLE hStream,
        DWORD dwMillisecondsToWait,
        NUI_IMAGE_FRAME *pImageFrame);

	HRESULT (  *NuiImageStreamReleaseFrame )(INuiSensor * This,
            HANDLE hStream,
            NUI_IMAGE_FRAME *pImageFrame);

	HRESULT (  *NuiImageGetColorPixelCoordinatesFromDepthPixel )(INuiSensor * This,
            /* [in] */ NUI_IMAGE_RESOLUTION eColorResolution,
            /* [in] */ const NUI_IMAGE_VIEW_AREA *pcViewArea,
            /* [in] */ LONG lDepthX,
            /* [in] */ LONG lDepthY,
            /* [in] */ USHORT usDepthValue,
            /* [out] */ LONG *plColorX,
            /* [out] */ LONG *plColorY);

	HRESULT (*NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution )(INuiSensor * This,
            /* [in] */ NUI_IMAGE_RESOLUTION eColorResolution,
            /* [in] */ NUI_IMAGE_RESOLUTION eDepthResolution,
            /* [in] */ const NUI_IMAGE_VIEW_AREA *pcViewArea,
            /* [in] */ LONG lDepthX,
            /* [in] */ LONG lDepthY,
            /* [in] */ USHORT usDepthValue,
            /* [out] */ LONG *plColorX,
            /* [out] */ LONG *plColorY);

	HRESULT (*NuiImageGetColorPixelCoordinateFrameFromDepthPixelFrameAtResolution )(INuiSensor * This,
            /* [in] */ NUI_IMAGE_RESOLUTION eColorResolution,
            /* [in] */ NUI_IMAGE_RESOLUTION eDepthResolution,
            /* [in] */ DWORD cDepthValues,
            /* [size_is][in] */ USHORT *pDepthValues,
            /* [in] */ DWORD cColorCoordinates,
            /* [size_is][out][in] */ LONG *pColorCoordinates);

	HRESULT (  *NuiCameraElevationSetAngle )(INuiSensor * This,
            /* [in] */ LONG lAngleDegrees);

	HRESULT (  *NuiCameraElevationGetAngle )(INuiSensor * This,
            /* [retval][out] */ LONG *plAngleDegrees);

	HRESULT (  *NuiSkeletonTrackingEnable )(INuiSensor * This,
            /* [in] */ HANDLE hNextFrameEvent,
            /* [in] */ DWORD dwFlags);

	HRESULT (  *NuiSkeletonTrackingDisable )(INuiSensor * This);

	HRESULT (  *NuiSkeletonSetTrackedSkeletons )(INuiSensor * This,
            /* [size_is][in] */ DWORD *TrackingIDs);

	HRESULT (  *NuiSkeletonGetNextFrame )(INuiSensor * This,
            /* [in] */ DWORD dwMillisecondsToWait,
            /* [out][in] */ NUI_SKELETON_FRAME *pSkeletonFrame);

	HRESULT (  *NuiTransformSmooth )(INuiSensor * This,
            NUI_SKELETON_FRAME *pSkeletonFrame,
            const NUI_TRANSFORM_SMOOTH_PARAMETERS *pSmoothingParams);

        /* [helpstring] */ HRESULT (  *NuiGetAudioSource )(
            INuiSensor * This,
            /* [out] */ INuiAudioBeam **ppDmo);

	int (*NuiInstanceIndex)(INuiSensor * This);

	BSTR (*NuiDeviceConnectionId)(INuiSensor * This);

	BSTR (*NuiUniqueId)(INuiSensor * This);

	BSTR (*NuiAudioArrayId)(INuiSensor * This);

	HRESULT (*NuiStatus)(INuiSensor * This);

	DWORD (*NuiInitializationFlags)(INuiSensor * This);

} INuiSensorVtbl;

typedef struct INuiSensor
{
	INuiSensorVtbl *lpVtbl;
} INuiSensor, *PINuiSensor;

]]

INuiSensor = nil
INuiSensor_mt = {
	__index = {
		Initialize = function(self, flags)
			flags = flags or bor(NUI_INITIALIZE_FLAG_USES_AUDIO,
				NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX ,
				NUI_INITIALIZE_FLAG_USES_COLOR,
				NUI_INITIALIZE_FLAG_USES_SKELETON,
				NUI_INITIALIZE_FLAG_USES_DEPTH)

			local hr = self.lpVtbl.NuiInitialize(self, flags)

			local severity, facility, code = HRESULT_PARTS(hr)


			return severity, facility, code
		end,

		OpenImageStream = function(self, whichstream, resolution, flags, framelimit, frameevent)
			local lpHandle = ffi.new("HANDLE[1]")

			local hr = self.lpVtbl.NuiImageStreamOpen(self, whichstream, resolution,
				flags, framelimit, frameevent, lpHandle);

			return lpHandle[0], hr;
		end,

		ReleaseFrame = function(self, streamHandle, imageFrame)
			return self.lpVtbl.NuiImageStreamReleaseFrame(self, streamHandle, imageFrame);
		end,

		GetNextFrame = function(self, streamHandle, timeout)
			local lpimageFrame = ffi.new("NUI_IMAGE_FRAME[1]")
			local hr = self.lpVtbl.NuiImageStreamGetNextFrame(self, streamHandle, timeout,lpimageFrame);

			return lpimageFrame[0], hr
		end,

		GetCameraElevationAngle = function(self)
			local lpAngleDegrees = ffi.new("LONG[1]");
			local hr = self.lpVtbl.NuiCameraElevationGetAngle(self, lpAngleDegrees);
			return lpAngleDegrees[0], hr
		end,
	},
}
INuisensor = ffi.metatype("INuiSensor", INuiSensor_mt)





ffi.cdef[[
HRESULT  NuiGetSensorCount(int * pCount );
HRESULT  NuiCreateSensorByIndex(int index, INuiSensor ** ppNuiSensor );
HRESULT  NuiCreateSensorById(const OLECHAR *strInstanceId, INuiSensor ** ppNuiSensor );
HRESULT  NuiGetAudioSource(INuiAudioBeam ** ppDmo );

typedef void (* NuiStatusProc)( HRESULT hrStatus, const OLECHAR* instanceName, const OLECHAR* uniqueDeviceName, void* pUserData );

void NuiSetDeviceStatusCallback( NuiStatusProc callback, void* pUserData );
]]






ffi.cdef[[
enum {
	MAX_DEV_STR_LEN = 512,
};

typedef struct
{
    wchar_t szDeviceName[MAX_DEV_STR_LEN];
    wchar_t szDeviceID[MAX_DEV_STR_LEN];
    int iDeviceIndex;
} NUI_MICROPHONE_ARRAY_DEVICE, *PNUI_MICROPHONE_ARRAY_DEVICE;


HRESULT NuiGetMicrophoneArrayDevices(PNUI_MICROPHONE_ARRAY_DEVICE pDeviceInfo, int size,  int *piDeviceCount);

typedef struct
{
    wchar_t szDeviceName[MAX_DEV_STR_LEN];
    int iDeviceIndex;
    bool fDefault;
} NUI_SPEAKER_DEVICE, *PNUI_SPEAKER_DEVICE;

HRESULT NuiGetSpeakerDevices(PNUI_SPEAKER_DEVICE pDeviceInfo, int size, int *piDeviceCount);
]]


ffi.cdef[[
typedef enum _NUI_IMAGE_DIGITALZOOM
{
    NUI_IMAGE_DIGITAL_ZOOM_1X = 0,
} NUI_IMAGE_DIGITALZOOM;

]]



ffi.cdef[[
HRESULT  NuiImageStreamSetImageFrameFlags(HANDLE hStream, DWORD dwImageFrameFlags);

HRESULT  NuiImageStreamGetImageFrameFlags(HANDLE hStream, DWORD *pdwImageFrameFlags);

HRESULT  NuiSetFrameEndEvent(HANDLE hEvent, DWORD dwFrameEventFlag);

HRESULT  NuiImageStreamOpen(NUI_IMAGE_TYPE eImageType,
    NUI_IMAGE_RESOLUTION eResolution,
	DWORD dwImageFrameFlags,
	DWORD dwFrameLimit,
    HANDLE hNextFrameEvent,HANDLE *phStreamHandle);

HRESULT  NuiImageStreamGetNextFrame(HANDLE hStream, DWORD dwMillisecondsToWait, const NUI_IMAGE_FRAME **ppcImageFrame);

HRESULT  NuiImageStreamReleaseFrame(HANDLE hStream, const NUI_IMAGE_FRAME *pImageFrame);

HRESULT  NuiImageGetColorPixelCoordinatesFromDepthPixel(NUI_IMAGE_RESOLUTION eColorResolution,
	const NUI_IMAGE_VIEW_AREA *pcViewArea,
	LONG   lDepthX, LONG   lDepthY,
	USHORT usDepthValue,
    LONG *plColorX, LONG *plColorY);

HRESULT  NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution(
	NUI_IMAGE_RESOLUTION eColorResolution,
	NUI_IMAGE_RESOLUTION eDepthResolution,
    const NUI_IMAGE_VIEW_AREA *pcViewArea,
	LONG   lDepthX,
	LONG   lDepthY,
	USHORT usDepthValue,
    LONG *plColorX,
    LONG *plColorY);

HRESULT  NuiCameraElevationGetAngle(LONG * plAngleDegrees);

HRESULT  NuiCameraElevationSetAngle(LONG lAngleDegrees);
]]

NUI_IMAGE_PLAYER_INDEX_SHIFT          =3
NUI_IMAGE_PLAYER_INDEX_MASK           =((lshift(1, NUI_IMAGE_PLAYER_INDEX_SHIFT))-1)
NUI_IMAGE_DEPTH_MAXIMUM               =(bor((lshift(4000, NUI_IMAGE_PLAYER_INDEX_SHIFT)), NUI_IMAGE_PLAYER_INDEX_MASK))
NUI_IMAGE_DEPTH_MINIMUM               =(lshift(800, NUI_IMAGE_PLAYER_INDEX_SHIFT))
NUI_IMAGE_DEPTH_MAXIMUM_NEAR_MODE     =(bor((lshift(3000, NUI_IMAGE_PLAYER_INDEX_SHIFT)), NUI_IMAGE_PLAYER_INDEX_MASK))
NUI_IMAGE_DEPTH_MINIMUM_NEAR_MODE     =(lshift(400, NUI_IMAGE_PLAYER_INDEX_SHIFT))
NUI_IMAGE_DEPTH_NO_VALUE              =0
NUI_IMAGE_DEPTH_TOO_FAR_VALUE         =(lshift(0x0fff, NUI_IMAGE_PLAYER_INDEX_SHIFT))
NUI_DEPTH_DEPTH_UNKNOWN_VALUE         =(lshift(0x1fff, NUI_IMAGE_PLAYER_INDEX_SHIFT))

NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS         =(285.63)   -- Based on 320x240 pixel size.
NUI_CAMERA_DEPTH_NOMINAL_INVERSE_FOCAL_LENGTH_IN_PIXELS =(3.501e-3) -- (1/NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS)
NUI_CAMERA_DEPTH_NOMINAL_DIAGONAL_FOV                   =(70.0)
NUI_CAMERA_DEPTH_NOMINAL_HORIZONTAL_FOV                 =(58.5)
NUI_CAMERA_DEPTH_NOMINAL_VERTICAL_FOV                   =(45.6)

NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS         =(531.15)   -- Based on 640x480 pixel size.
NUI_CAMERA_COLOR_NOMINAL_INVERSE_FOCAL_LENGTH_IN_PIXELS =(1.83e-3)  -- (1/NUI_CAMERA_COLOR_NOMINAL_FOCAL_LENGTH_IN_PIXELS)
NUI_CAMERA_COLOR_NOMINAL_DIAGONAL_FOV                   =( 73.9)
NUI_CAMERA_COLOR_NOMINAL_HORIZONTAL_FOV                 =( 62.0)
NUI_CAMERA_COLOR_NOMINAL_VERTICAL_FOV                   =( 48.6)

NUI_IMAGE_FRAME_FLAG_NONE              = 0x00000000
NUI_IMAGE_FRAME_FLAG_VIEW_AREA_UNKNOWN = 0x00000001

-- return S_FALSE instead of E_NUI_FRAME_NO_DATA if NuiImageStreamGetNextFrame( ) doesn't have a frame ready and a timeout != INFINITE is used
NUI_IMAGE_STREAM_FLAG_SUPPRESS_NO_FRAME_DATA              = 0x00010000
-- Set the depth stream to near mode
NUI_IMAGE_STREAM_FLAG_ENABLE_NEAR_MODE                    = 0x00020000
-- Use distinct values for depth values that are either too close, too far or unknown
NUI_IMAGE_STREAM_FLAG_DISTINCT_OVERFLOW_DEPTH_VALUES      = 0x00040000

-- the max # of NUI output frames you can hold w/o releasing
NUI_IMAGE_STREAM_FRAME_LIMIT_MAXIMUM = 4


NUI_CAMERA_ELEVATION_MAXIMUM  = 27
NUI_CAMERA_ELEVATION_MINIMUM = -27


function NuiImageResolutionToSize(res)

    if res == C.NUI_IMAGE_RESOLUTION_80x60 then
        return 80, 60;
	end

	if res == C.NUI_IMAGE_RESOLUTION_320x240 then
        return 320,240;
	end

    if res == C.NUI_IMAGE_RESOLUTION_640x480 then
        return 640, 480;
	end

    if res == C.NUI_IMAGE_RESOLUTION_1280x960 then
        return 1280, 960;
	end

    return 0,0
end


--
-- Unpacks the depth value from the packed pixel format
--
function NuiDepthPixelToDepth(packedPixel)
    return rshift(packedPixel, NUI_IMAGE_PLAYER_INDEX_SHIFT);
end

--
-- Unpacks the player index value from the packed pixel format
--
function NuiDepthPixelToPlayerIndex(packedPixel)
    return band(packedPixel, NUI_IMAGE_PLAYER_INDEX_MASK);
end


ffi.cdef[[
HRESULT NuiTransformSmooth(NUI_SKELETON_FRAME *pSkeletonFrame,
    const NUI_TRANSFORM_SMOOTH_PARAMETERS *pSmoothingParams);
]]

FLT_EPSILON     = 1.192092896e-07        -- smallest such that 1.0+FLT_EPSILON != 1.0

--
--  Number of NUI_SKELETON_DATA elements that can be in the NUI_SKELETON_TRACKED state
--

NUI_SKELETON_MAX_TRACKED_COUNT = 2

--
--  Tracking IDs start at 1
--

NUI_SKELETON_INVALID_TRACKING_ID =0


NUI_SKELETON_QUALITY_CLIPPED_RIGHT  = 0x00000001
NUI_SKELETON_QUALITY_CLIPPED_LEFT   = 0x00000002
NUI_SKELETON_QUALITY_CLIPPED_TOP    = 0x00000004
NUI_SKELETON_QUALITY_CLIPPED_BOTTOM = 0x00000008


NUI_SKELETON_TRACKING_FLAG_SUPPRESS_NO_FRAME_DATA       =0x00000001
NUI_SKELETON_TRACKING_FLAG_TITLE_SETS_TRACKED_SKELETONS =0x00000002


ffi.cdef[[
HRESULT NuiSkeletonTrackingEnable(HANDLE hNextFrameEvent, DWORD  dwFlags);

HRESULT NuiSkeletonTrackingDisable();

HRESULT NuiSkeletonGetNextFrame(DWORD dwMillisecondsToWait, NUI_SKELETON_FRAME *pSkeletonFrame);

HRESULT NuiSkeletonSetTrackedSkeletons(DWORD *TrackingIDs);
]]


--[[
// Assuming a pixel resolution of 320x240
// x_meters = (x_pixelcoord - 160) * NUI_CAMERA_DEPTH_IMAGE_TO_SKELETON_MULTIPLIER_320x240 * z_meters;
// y_meters = (y_pixelcoord - 120) * NUI_CAMERA_DEPTH_IMAGE_TO_SKELETON_MULTIPLIER_320x240 * z_meters;
#define NUI_CAMERA_DEPTH_IMAGE_TO_SKELETON_MULTIPLIER_320x240 (NUI_CAMERA_DEPTH_NOMINAL_INVERSE_FOCAL_LENGTH_IN_PIXELS)

// Assuming a pixel resolution of 320x240
// x_pixelcoord = (x_meters) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / z_meters + 160;
// y_pixelcoord = (y_meters) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / z_meters + 120;
#define NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 (NUI_CAMERA_DEPTH_NOMINAL_FOCAL_LENGTH_IN_PIXELS)
--]]

--[[
function NuiTransformSkeletonToDepthImage(
    Vector4 vPoint,
    LONG *plDepthX,
    LONG *plDepthY,
    USHORT *pusDepthValue,
    NUI_IMAGE_RESOLUTION eResolution)
{
    if((plDepthX == nil) or (plDepthY == nil) or (pusDepthValue == nil)) then

        return;
    end

    --
    -- Requires a valid depth value.
    --

    if(vPoint.z > FLT_EPSILON) then

        DWORD width;
        DWORD height;
        NuiImageResolutionToSize( eResolution, width, height );

        //
        // Center of depth sensor is at (0,0,0) in skeleton space, and
        // and (width/2,height/2) in depth image coordinates.  Note that positive Y
        // is up in skeleton space and down in image coordinates.
        //
        // The 0.5f is to correct for casting to int truncating, not rounding

        *plDepthX = static_cast<INT>( width / 2 + vPoint.x * (width/320.f) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / vPoint.z + 0.5f);
        *plDepthY = static_cast<INT>( height / 2 - vPoint.y * (height/240.f) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / vPoint.z + 0.5f);

        //
        //  Depth is in meters in skeleton space.
        //  The depth image pixel format has depth in millimeters shifted left by 3.
        //

        *pusDepthValue = static_cast<USHORT>(vPoint.z *1000) << 3;
    else

        *plDepthX = 0;
        *plDepthY = 0;
        *pusDepthValue = 0;
    end
end

function NuiTransformSkeletonToDepthImage(
    vec4 vPoint,
    LONG *plDepthX,
    LONG *plDepthY,
    USHORT *pusDepthValue)

    NuiTransformSkeletonToDepthImage( vPoint, plDepthX, plDepthY, pusDepthValue, NUI_IMAGE_RESOLUTION_320x240);
end


function NuiTransformSkeletonToDepthImage(
    vec4 vPoint,
    float *pfDepthX,
    float *pfDepthY,
    NUI_IMAGE_RESOLUTION eResolution)

    if((pfDepthX == nil) or (pfDepthY == nil))
    {
        return;
    }

    //
    // Requires a valid depth value.
    //

    if(vPoint.z > FLT_EPSILON)
    {
        DWORD width;
        DWORD height;
        NuiImageResolutionToSize( eResolution, width, height );

        //
        // Center of depth sensor is at (0,0,0) in skeleton space, and
        // and (width/2,height/2) in depth image coordinates.  Note that positive Y
        // is up in skeleton space and down in image coordinates.
        //

        *pfDepthX = width / 2 + vPoint.x * (width/320.f) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / vPoint.z;
        *pfDepthY = height / 2 - vPoint.y * (height/240.f) * NUI_CAMERA_SKELETON_TO_DEPTH_IMAGE_MULTIPLIER_320x240 / vPoint.z;

    } else
    {
        *pfDepthX = 0.0f;
        *pfDepthY = 0.0f;
    }
end

inline
VOID
NuiTransformSkeletonToDepthImage(
    _In_ Vector4 vPoint,
    _Out_ FLOAT *pfDepthX,
    _Out_ FLOAT *pfDepthY
    )
{
    NuiTransformSkeletonToDepthImage(vPoint, pfDepthX, pfDepthY, NUI_IMAGE_RESOLUTION_320x240);
}

function NuiTransformDepthImageToSkeleton(LONG lDepthX,LONG lDepthY,
    USHORT usDepthValue, NUI_IMAGE_RESOLUTION eResolution)
{
    DWORD width;
    DWORD height;
    NuiImageResolutionToSize( eResolution, width, height );

    //
    //  Depth is in meters in skeleton space.
    //  The depth image pixel format has depth in millimeters shifted left by 3.
    //

    FLOAT fSkeletonZ = static_cast<FLOAT>(usDepthValue >> 3) / 1000.0f;

    //
    // Center of depth sensor is at (0,0,0) in skeleton space, and
    // and (width/2,height/2) in depth image coordinates.  Note that positive Y
    // is up in skeleton space and down in image coordinates.
    //

    FLOAT fSkeletonX = (lDepthX - width/2.0f) * (320.0f/width) * NUI_CAMERA_DEPTH_IMAGE_TO_SKELETON_MULTIPLIER_320x240 * fSkeletonZ;
    FLOAT fSkeletonY = -(lDepthY - height/2.0f) * (240.0f/height) * NUI_CAMERA_DEPTH_IMAGE_TO_SKELETON_MULTIPLIER_320x240 * fSkeletonZ;

    //
    // Return the result as a vector.
    //

    Vector4 v4;
    v4.x = fSkeletonX;
    v4.y = fSkeletonY;
    v4.z = fSkeletonZ;
    v4.w = 1.0f;
    return v4;
}

function NuiTransformDepthImageToSkeleton(LONG lDepthX, LONG lDepthY, USHORT usDepthValue)
    return NuiTransformDepthImageToSkeleton(lDepthX, lDepthY, usDepthValue, NUI_IMAGE_RESOLUTION_320x240);
end
--]]



function HasSkeletalEngine(pNuiSensor)

    if (not pNuiSensor) then
		return false;
	end

    return band(pNuiSensor.NuiInitializationFlags(), NUI_INITIALIZE_FLAG_USES_SKELETON) or
	band(pNuiSensor.NuiInitializationFlags(), NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX);
end














class.KinectImageStream()

function KinectImageStream:_init(sensor, whichstream, resolution)
	whichstream = whichstream or C.NUI_IMAGE_TYPE_COLOR
	resolution = resolution or C.NUI_IMAGE_RESOLUTION_640x480

	self.Sensor = sensor;

	local hr
	self.StreamHandle, hr = self.Sensor:OpenImageStream(whichstream,
		resolution, 0, 2,nil)
end


function KinectImageStream:GetCurrentFrame(timeout)
	timeout = timeout or 1000/15

	local hr;
	self.CurrentFrame, hr = self.Sensor:GetNextFrame(self.StreamHandle, timeout);

	if hr ~= 0 then return false end

	-- Get the texture object out
	-- lock the bits, for later rendering
	self.CurrentTexture = self.CurrentFrame.pFrameTexture
	self.LockedRect, self.Frame = self.CurrentTexture:LockRect()

	return true
end

function KinectImageStream:ReleaseCurrentFrame()
	local hr
	if self.CurrentTexture == nil then
		return ;
	end

	hr = self.CurrentTexture:UnlockRect()
	hr = self.Sensor:ReleaseFrame(self.StreamHandle, self.CurrentFrame)

	local severity, facility, code = HRESULT_PARTS(hr)
--	print("Kinect:ReleaseCurrentColorFrame: ", severity, facility, code)
end









class.KinectSensor()

function KinectSensor:_init(index, flags)
	local psensor = ffi.new("PINuiSensor[1]")
	local hr = kinectlib.NuiCreateSensorByIndex(index, psensor)

	local severity, facility, code = HRESULT_PARTS(hr)

	-- If there was an error, then return early
	if severity == 1 then return nil end

	self.Sensor = psensor[0]
	self.VTable = self.Sensor.lpVtbl


	-- Create events for signaling
	self.NextColorFrameEvent = kernel32.CreateEventA(nil, true, false, nil);
	self.NextDepthFrameEvent = kernel32.CreateEventA(nil, true, false, nil);
	self.NextSkeletonEvent = kernel32.CreateEventA(nil, true, false, nil);

	self:Initialize(flags)

	if band(flags, NUI_INITIALIZE_FLAG_USES_COLOR) then
		self.ColorStream = KinectImageStream(self.Sensor, C.NUI_IMAGE_TYPE_COLOR, C.NUI_IMAGE_RESOLUTION_640x480)
		--self:GetVideoStream()
	end

	if band(flags, NUI_INITIALIZE_FLAG_USES_DEPTH) then
		self.DepthStream = KinectImageStream(self.Sensor, C.NUI_IMAGE_TYPE_DEPTH, C.NUI_IMAGE_RESOLUTION_320x240)
	end
end

--
-- Some attributes
--

function KinectSensor:GetCameraElevationAngle()
	return self.Sensor:GetCameraElevationAngle();
end

function KinectSensor:SetCameraElevationAngle(angle)
	if angle < NUI_CAMERA_ELEVATION_MINIMUM then
		angle = NUI_CAMERA_ELEVATION_MINIMUM
	elseif angle > NUI_CAMERA_ELEVATION_MAXIMUM then
		angle = NUI_CAMERA_ELEVATION_MAXIMUM
	end

	local hr = self.VTable.NuiCameraElevationSetAngle(self.Sensor, angle)
	local severity, facility, code = HRESULT_PARTS(hr)
end


function KinectSensor:GetConnectionID()
	self.ConnectionID = self.VTable.NuiDeviceConnectionId(self.Sensor);
	return self.ConnectionID
end

function KinectSensor:GetSensorIndex()
	local index = self.VTable.NuiInstanceIndex(self.Sensor)
	return index
end

function KinectSensor:GetStatus()
	local hr = self.VTable.NuiStatus(self.Sensor)
	local severity, facility, code = HRESULT_PARTS(hr)
	return severity, facility, code
end

--[[
	Some Actual Functions
--]]
function KinectSensor:Initialize(flags)
	return self.Sensor:Initialize(flags);
end








class.Kinect()

function Kinect.GetSensorCount()
	local count = ffi.new("int32_t[1]")
	local hr = kinectlib.NuiGetSensorCount(count)
	count = count[0]

	return count
end

function Kinect.GetSensorByIndex(idx, flags)
	flags = flags or 0
	return KinectSensor(idx, flags)
end




