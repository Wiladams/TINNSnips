local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;
local lshift = bit.lshift;

local WTypes = require("WTypes")
local WinError = require("win_error")
local core_library = require("core_libraryloader_l1_1_1")


-- Forward Declarations
ffi.cdef[[
typedef struct INuiCoordinateMapper INuiCoordinateMapper;
typedef struct INuiColorCameraSettings INuiColorCameraSettings;
typedef struct INuiDepthFilter INuiDepthFilter;
typedef struct INuiSensor INuiSensor;


]]

ffi.cdef[[


//
// NUI Common Initialization Declarations
//

static const int NUI_INITIALIZE_FLAG_USES_AUDIO                  =0x10000000;
static const int NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX =0x00000001;
static const int NUI_INITIALIZE_FLAG_USES_COLOR                  =0x00000002;
static const int NUI_INITIALIZE_FLAG_USES_SKELETON               =0x00000008;  
static const int NUI_INITIALIZE_FLAG_USES_DEPTH                  =0x00000020;
static const int NUI_INITIALIZE_FLAG_USES_HIGH_QUALITY_COLOR     =0x00000040;  // implies COLOR stream will be from uncompressed YUY2 @ 15fps

static const int NUI_INITIALIZE_DEFAULT_HARDWARE_THREAD          =0xFFFFFFFF;

]]


-- Define NUI specific error codes

--[[
//
// Define NUI error codes derived from win32 errors
//

#define E_NUI_DEVICE_NOT_CONNECTED  __HRESULT_FROM_WIN32(ERROR_DEVICE_NOT_CONNECTED)
#define E_NUI_DEVICE_NOT_READY      __HRESULT_FROM_WIN32(ERROR_NOT_READY)
#define E_NUI_ALREADY_INITIALIZED   __HRESULT_FROM_WIN32(ERROR_ALREADY_INITIALIZED)
#define E_NUI_NO_MORE_ITEMS         __HRESULT_FROM_WIN32(ERROR_NO_MORE_ITEMS)


#define FACILITY_NUI 0x301

#define S_NUI_INITIALIZING                      MAKE_HRESULT(SEVERITY_SUCCESS, FACILITY_NUI, 1)                                             // 0x03010001
#define E_NUI_FRAME_NO_DATA                     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 1)
static_assert(E_NUI_FRAME_NO_DATA == 0x83010001, "Error code has changed.");
#define E_NUI_STREAM_NOT_ENABLED                MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 2)
#define E_NUI_IMAGE_STREAM_IN_USE               MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 3)
#define E_NUI_FRAME_LIMIT_EXCEEDED              MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 4)
#define E_NUI_FEATURE_NOT_INITIALIZED           MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 5)
#define E_NUI_NOTGENUINE                        MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 6)
#define E_NUI_INSUFFICIENTBANDWIDTH             MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 7)
#define E_NUI_NOTSUPPORTED                      MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 8)
#define E_NUI_DEVICE_IN_USE                     MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, 9)

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
#define E_NUI_BADINDEX                          MAKE_HRESULT(SEVERITY_ERROR, FACILITY_NUI, /* 1413 */ ERROR_INVALID_INDEX)                   // 0x83010585
#define E_NUI_BADIINDEX                         E_NUI_BADINDEX // V 1.0 compatibility
--]]

ffi.cdef[[
#pragma pack(8)

static const int NUI_CAMERA_ELEVATION_MAXIMUM  = 27;
static const int NUI_CAMERA_ELEVATION_MINIMUM  = -27;

typedef enum _NUI_IMAGE_TYPE
{
  NUI_IMAGE_TYPE_DEPTH_AND_PLAYER_INDEX = 0,            // USHORT
  NUI_IMAGE_TYPE_COLOR,                                 // RGB32 data
  NUI_IMAGE_TYPE_COLOR_YUV,                             // YUY2 stream from camera h/w, but converted to RGB32 before user getting it.
  NUI_IMAGE_TYPE_COLOR_RAW_YUV,                         // YUY2 stream from camera h/w.
  NUI_IMAGE_TYPE_DEPTH,                                 // USHORT
  NUI_IMAGE_TYPE_COLOR_INFRARED,                        // USHORT
  NUI_IMAGE_TYPE_COLOR_RAW_BAYER,                       // 8-bit Bayer
} NUI_IMAGE_TYPE;

typedef enum _NUI_IMAGE_RESOLUTION
{
  NUI_IMAGE_RESOLUTION_INVALID = -1,
  NUI_IMAGE_RESOLUTION_80x60 = 0,
  NUI_IMAGE_RESOLUTION_320x240,
  NUI_IMAGE_RESOLUTION_640x480,                         // 15 fps
  NUI_IMAGE_RESOLUTION_1280x960,                         // for hires color only
} NUI_IMAGE_RESOLUTION;

typedef enum _NUI_IMAGE_DIGITALZOOM
{
    NUI_IMAGE_DIGITAL_ZOOM_1X = 0,
} NUI_IMAGE_DIGITALZOOM;

typedef struct _NUI_IMAGE_VIEW_AREA
{
    NUI_IMAGE_DIGITALZOOM  eDigitalZoom;
    LONG                   lCenterX;
    LONG                   lCenterY;
} NUI_IMAGE_VIEW_AREA;

typedef struct _NUI_LOCKED_RECT
{
    INT                 Pitch;
    int                 size;   // Size of pBits, in bytes.
    BYTE*               pBits;
} NUI_LOCKED_RECT;

typedef struct _NUI_SURFACE_DESC
    {
    UINT Width;
    UINT Height;
    }   NUI_SURFACE_DESC;

typedef struct INuiFrameTexture INuiFrameTexture;

    typedef struct INuiFrameTextureVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            INuiFrameTexture * This,
            REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            INuiFrameTexture * This);
        
        ULONG ( __stdcall *Release )( 
            INuiFrameTexture * This);
        
        int ( __stdcall *BufferLen )( 
            INuiFrameTexture * This);
        
        int ( __stdcall *Pitch )( 
            INuiFrameTexture * This);
        
        HRESULT ( __stdcall *LockRect )( 
            INuiFrameTexture * This,
            UINT Level,
            /* [ref] */ NUI_LOCKED_RECT *pLockedRect,
            /* [unique] */ RECT *pRect,
            DWORD Flags);
        
        HRESULT ( __stdcall *GetLevelDesc )( 
            INuiFrameTexture * This,
            UINT Level,
            NUI_SURFACE_DESC *pDesc);
        
        HRESULT ( __stdcall *UnlockRect )( 
            INuiFrameTexture * This,
            UINT Level);
        
    } INuiFrameTextureVtbl;

    typedef struct INuiFrameTexture
    {
        const struct INuiFrameTextureVtbl *lpVtbl;
    } INuiFrameTexture;



typedef struct _NUI_IMAGE_FRAME
{
  LARGE_INTEGER             liTimeStamp;
  DWORD                     dwFrameNumber;
  NUI_IMAGE_TYPE            eImageType;
  NUI_IMAGE_RESOLUTION      eResolution;
  INuiFrameTexture          *pFrameTexture;
  DWORD                     dwFrameFlags;  
  NUI_IMAGE_VIEW_AREA       ViewArea;
} NUI_IMAGE_FRAME;


// Skeleton routines
static const int NUI_SKELETON_COUNT = 6;
static const int NUI_SKELETON_MAX_TRACKED_COUNT = 2;
static const int NUI_SKELETON_INVALID_TRACKING_ID = 0;

typedef enum _NUI_SKELETON_POSITION_INDEX
{
    NUI_SKELETON_POSITION_HIP_CENTER = 0,
    NUI_SKELETON_POSITION_SPINE,
    NUI_SKELETON_POSITION_SHOULDER_CENTER,
    NUI_SKELETON_POSITION_HEAD,
    NUI_SKELETON_POSITION_SHOULDER_LEFT,
    NUI_SKELETON_POSITION_ELBOW_LEFT,
    NUI_SKELETON_POSITION_WRIST_LEFT,
    NUI_SKELETON_POSITION_HAND_LEFT,
    NUI_SKELETON_POSITION_SHOULDER_RIGHT,
    NUI_SKELETON_POSITION_ELBOW_RIGHT,
    NUI_SKELETON_POSITION_WRIST_RIGHT,
    NUI_SKELETON_POSITION_HAND_RIGHT,
    NUI_SKELETON_POSITION_HIP_LEFT,
    NUI_SKELETON_POSITION_KNEE_LEFT,
    NUI_SKELETON_POSITION_ANKLE_LEFT,
    NUI_SKELETON_POSITION_FOOT_LEFT,
    NUI_SKELETON_POSITION_HIP_RIGHT,
    NUI_SKELETON_POSITION_KNEE_RIGHT,
    NUI_SKELETON_POSITION_ANKLE_RIGHT,
    NUI_SKELETON_POSITION_FOOT_RIGHT,
    NUI_SKELETON_POSITION_COUNT
} NUI_SKELETON_POSITION_INDEX;


typedef struct _Vector4
{
    FLOAT x;
    FLOAT y;
    FLOAT z;
    FLOAT w;
} Vector4;

typedef enum _NUI_SKELETON_POSITION_TRACKING_STATE
{
    NUI_SKELETON_POSITION_NOT_TRACKED = 0,
    NUI_SKELETON_POSITION_INFERRED,
    NUI_SKELETON_POSITION_TRACKED
} NUI_SKELETON_POSITION_TRACKING_STATE;

typedef enum _NUI_SKELETON_TRACKING_STATE
{
    NUI_SKELETON_NOT_TRACKED = 0,
    NUI_SKELETON_POSITION_ONLY,
    NUI_SKELETON_TRACKED
} NUI_SKELETON_TRACKING_STATE;

typedef struct _NUI_SKELETON_DATA
{
  NUI_SKELETON_TRACKING_STATE eTrackingState;
  DWORD dwTrackingID;
  DWORD dwEnrollmentIndex;
  DWORD dwUserIndex;
  Vector4 Position;
  Vector4 SkeletonPositions[NUI_SKELETON_POSITION_COUNT];
  NUI_SKELETON_POSITION_TRACKING_STATE eSkeletonPositionTrackingState[NUI_SKELETON_POSITION_COUNT];
  DWORD dwQualityFlags;
} NUI_SKELETON_DATA;
]]

ffi.cdef[[
#pragma pack(16)

typedef struct _NUI_SKELETON_FRAME
{
  LARGE_INTEGER         liTimeStamp;
  DWORD                 dwFrameNumber;
  DWORD                 dwFlags;
  Vector4              vFloorClipPlane;
  Vector4              vNormalToGravity;
  NUI_SKELETON_DATA     SkeletonData[NUI_SKELETON_COUNT];
} NUI_SKELETON_FRAME;

typedef struct _NUI_TRANSFORM_SMOOTH_PARAMETERS
{
    FLOAT   fSmoothing;             // [0..1], lower values closer to raw data
    FLOAT   fCorrection;            // [0..1], lower values slower to correct towards the raw data
    FLOAT   fPrediction;            // [0..n], the number of frames to predict into the future
    FLOAT   fJitterRadius;          // The radius in meters for jitter reduction
    FLOAT   fMaxDeviationRadius;    // The maximum radius in meters that filtered positions are allowed to deviate from raw data
} NUI_TRANSFORM_SMOOTH_PARAMETERS;
]]





-- {8c3cebfa-a35d-497e-bc9a-e9752a8155e0}
IID_INuiAudioBeam = DEFINE_UUID("IID_INuiAudioBeam", 0x8c3cebfa, 0xa35d, 0x497e, 0xbc, 0x9a, 0xe9, 0x75, 0x2a, 0x81, 0x55, 0xe0);

ffi.cdef[[
  typedef struct INuiAudioBeam INuiAudioBeam;

    typedef struct INuiAudioBeamVtbl
    {
        HRESULT (  *QueryInterface )(
            INuiAudioBeam * This,
            REFIID riid,
            void **ppvObject);

        ULONG (  *AddRef )(INuiAudioBeam * This);
        ULONG (  *Release )(INuiAudioBeam * This);


        HRESULT (  *GetBeam )(INuiAudioBeam * This,
           double *angle);

        HRESULT (  *SetBeam )(
            INuiAudioBeam * This,
            double angle);

        HRESULT (  *GetPosition )(
            INuiAudioBeam * This,
            double *angle,
            double *confidence);

    } INuiAudioBeamVtbl;

    typedef struct INuiAudioBeam
    {
        const INuiAudioBeamVtbl *lpVtbl;
    }INuiAudioBeam;
]]


--#include <NuiSensor.h>

--#include <NuiImageCamera.h>

--#include <NuiSkeleton.h>

--#include <poppack.h>


--[[
  //NuiSkeletonCalculateBoneOrientations = NuiLib.NuiSkeletonCalculateBoneOrientations,
  //NuiSkeletonGetNextFrame = NuiLib.NuiSkeletonGetNextFrame,
  //NuiSkeletonSetTrackedSkeletons = NuiLib.NuiSkeletonSetTrackedSkeletons,
  //NuiSkeletonTrackingDisable = NuiLib.NuiSkeletonTrackingDisable,
  //NuiSkeletonTrackingEnable = NuiLib.NuiSkeletonTrackingEnable,
--]]

ffi.cdef[[
// Standard function declarations
typedef void (* NuiStatusProc)( HRESULT hrStatus, const OLECHAR* instanceName, const OLECHAR* uniqueDeviceName, void* pUserData );

HRESULT NuiCreateSensorByIndex(int index, INuiSensor ** ppNuiSensor );
HRESULT NuiCreateSensorById(const OLECHAR *strInstanceId, INuiSensor ** ppNuiSensor );
HRESULT NuiGetSensorCount(int * pCount );
HRESULT NuiInitialize(DWORD dwFlags);
void  	NuiShutdown();



typedef HRESULT (__stdcall * PFNNuiCameraElevationSetAngle )(LONG lAngleDegrees);        
typedef HRESULT (__stdcall * PFNNuiCameraElevationGetAngle )(LONG *plAngleDegrees);
typedef HRESULT (__stdcall * PFNNuiCreateSensorByIndex)(int index, INuiSensor ** ppNuiSensor );
typedef HRESULT (__stdcall * PFNNuiGetSensorCount)(int * pCount);
typedef HRESULT (__stdcall * PFNNuiInitialize)(DWORD dwFlags);

typedef HRESULT (__stdcall * PFNNuiImageStreamGetImageFrameFlags)(HANDLE hStream, DWORD *pdwImageFrameFlags);
typedef HRESULT (__stdcall * PFNNuiImageStreamGetNextFrame)(HANDLE hStream, DWORD dwMillisecondsToWait, const NUI_IMAGE_FRAME **ppcImageFrame);
typedef HRESULT (__stdcall * PFNNuiImageStreamOpen)(NUI_IMAGE_TYPE eImageType, NUI_IMAGE_RESOLUTION eResolution, DWORD dwImageFrameFlags, DWORD dwFrameLimit, HANDLE hNextFrameEvent, HANDLE *phStreamHandle);
typedef HRESULT (__stdcall * PFNNuiImageStreamReleaseFrame)(HANDLE hStream, const NUI_IMAGE_FRAME *pImageFrame);
typedef HRESULT (__stdcall * PFNNuiImageStreamSetImageFrameFlags)(HANDLE hStream, DWORD dwImageFrameFlags);

typedef HRESULT (__stdcall * PFNNuiTransformSmooth)(NUI_SKELETON_FRAME *pSkeletonFrame, const NUI_TRANSFORM_SMOOTH_PARAMETERS *pSmoothingParams);

typedef void    (__stdcall * PFNNuiSetDeviceStatusCallback)( NuiStatusProc callback, void* pUserData );

typedef void (__stdcall * PFNNuiShutdown)();
]]

local Lib = core_library.LoadLibraryExA("kinect10.dll", nil, 0);

return {
	Lib = Lib,

	NuiCameraElevationGetAngle = ffi.cast("PFNNuiCameraElevationGetAngle", core_library.GetProcAddress(Lib, "NuiCameraElevationGetAngle"));
	NuiCameraElevationSetAngle = ffi.cast("PFNNuiCameraElevationSetAngle", core_library.GetProcAddress(Lib, "NuiCameraElevationSetAngle"));
	
--NuiCreateCoordinateMapperFromParameters
--NuiCreateDepthFilter
--NuiCreateSensorById
--NuiCreateSensorByIndex

  NuiCreateSensorByIndex = ffi.cast("PFNNuiCreateSensorByIndex", core_library.GetProcAddress(Lib, "NuiCreateSensorByIndex"));

--NuiGetAudioSource = ffi.cast("PFNNuiGetAudioSource", core_library.GetProcAddress(Lib, "NuiGetAudioSource"));
	NuiGetSensorCount = ffi.cast("PFNNuiGetSensorCount", core_library.GetProcAddress(Lib, "NuiGetSensorCount"));
--NuiImageGetColorPixelCoordinatesFromDepthPixel
--NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution

  NuiImageStreamGetImageFrameFlags = ffi.cast("PFNNuiImageStreamGetImageFrameFlags", core_library.GetProcAddress(Lib,"NuiImageStreamGetImageFrameFlags"));
	NuiImageStreamGetNextFrame = ffi.cast("PFNNuiImageStreamGetNextFrame", core_library.GetProcAddress(Lib, "NuiImageStreamGetNextFrame"));
	NuiImageStreamOpen = ffi.cast("PFNNuiImageStreamOpen", core_library.GetProcAddress(Lib, "NuiImageStreamOpen"));
	NuiImageStreamReleaseFrame = ffi.cast("PFNNuiImageStreamReleaseFrame", core_library.GetProcAddress(Lib, "NuiImageStreamReleaseFrame"));
	NuiImageStreamSetImageFrameFlags = ffi.cast("PFNNuiImageStreamSetImageFrameFlags", core_library.GetProcAddress(Lib, "NuiImageStreamSetImageFrameFlags"));

	NuiInitialize = ffi.cast("PFNNuiInitialize", core_library.GetProcAddress(Lib, "NuiInitialize"));

  NuiSetDeviceStatusCallback = ffi.cast("PFNNuiSetDeviceStatusCallback", core_library.GetProcAddress(Lib, "NuiSetDeviceStatusCallback"));
--NuiSetFrameEndEvent

	NuiShutdown = ffi.cast("PFNNuiShutdown", core_library.GetProcAddress(Lib, "NuiShutdown"));

--NuiSkeletonCalculateBoneOrientations
--NuiSkeletonGetNextFrame
--NuiSkeletonSetTrackedSkeletons
--NuiSkeletonTrackingDisable
--NuiSkeletonTrackingEnable
}