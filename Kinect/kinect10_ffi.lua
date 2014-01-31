local ffi = require("ffi")
local bit = require("bit")
local band = bit.band;
local bor = bit.bor;
local lshift = bit.lshift

local WTypes = require("WTypes")


local NuiLib = ffi.load("kinect10")


ffi.cdef[[
static const int  NUI_INITIALIZE_FLAG_USES_AUDIO                =  0x10000000;
static const int  NUI_INITIALIZE_FLAG_USES_DEPTH_AND_PLAYER_INDEX =0x00000001;
static const int  NUI_INITIALIZE_FLAG_USES_COLOR                  =0x00000002;
static const int  NUI_INITIALIZE_FLAG_USES_SKELETON               =0x00000008;  
static const int  NUI_INITIALIZE_FLAG_USES_DEPTH                  =0x00000020;
static const int  NUI_INITIALIZE_FLAG_USES_HIGH_QUALITY_COLOR     =0x00000040;  // implies COLOR stream will be from uncompressed YUY2 @ 15fps

static const int  NUI_INITIALIZE_DEFAULT_HARDWARE_THREAD          =0xFFFFFFFF;
]]


ffi.cdef[[
HRESULT NuiInitialize(DWORD dwFlags);
void NuiShutdown();
]]






ffi.cdef[[
typedef struct INuiCoordinateMapper INuiCoordinateMapper;
typedef struct INuiColorCameraSettings INuiColorCameraSettings;
typedef struct INuiDepthFilter INuiDepthFilter;
]]

ffi.cdef[[
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
  NUI_IMAGE_RESOLUTION_640x480,
  NUI_IMAGE_RESOLUTION_1280x960,                         // for hires color only
} NUI_IMAGE_RESOLUTION;
]]

ffi.cdef[[
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
]]

ffi.cdef[[
typedef struct _NUI_LOCKED_RECT
{
    INT                 Pitch;
    int                 size;   // Size of pBits, in bytes.
    BYTE*               pBits;
} NUI_LOCKED_RECT;
]]

ffi.cdef[[
typedef struct _NUI_SURFACE_DESC
    {
    UINT Width;
    UINT Height;
    }   NUI_SURFACE_DESC;
]]

ffi.cdef[[
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

]]

ffi.cdef[[
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
]]

-- Skeleton routines
ffi.cdef[[
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


#pragma pack(push, 16)
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


  //NuiSkeletonCalculateBoneOrientations = NuiLib.NuiSkeletonCalculateBoneOrientations,
  //NuiSkeletonGetNextFrame = NuiLib.NuiSkeletonGetNextFrame,
  //NuiSkeletonSetTrackedSkeletons = NuiLib.NuiSkeletonSetTrackedSkeletons,
  //NuiSkeletonTrackingDisable = NuiLib.NuiSkeletonTrackingDisable,
  //NuiSkeletonTrackingEnable = NuiLib.NuiSkeletonTrackingEnable,

  HRESULT NuiTransformSmooth(
         NUI_SKELETON_FRAME *pSkeletonFrame,
         const NUI_TRANSFORM_SMOOTH_PARAMETERS *pSmoothingParams);

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

--[=[
ffi.cdef[[
    typedef struct INuiSensor INuiSensor;

    typedef struct INuiSensorVtbl
    {
        
        HRESULT ( __stdcall *QueryInterface )( 
            INuiSensor * This,
            REFIID riid,
            /* [annotation][iid_is][out] */ 
             void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            INuiSensor * This);
        
        ULONG ( __stdcall *Release )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiInitialize )( 
            INuiSensor * This,
            DWORD dwFlags);
        
        void ( __stdcall *NuiShutdown )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiSetFrameEndEvent )( 
            INuiSensor * This,
            HANDLE hEvent,
            DWORD dwFrameEventFlag);
        
        HRESULT ( __stdcall *NuiImageStreamOpen )( 
            INuiSensor * This,
            NUI_IMAGE_TYPE eImageType,
            NUI_IMAGE_RESOLUTION eResolution,
            DWORD dwImageFrameFlags,
            DWORD dwFrameLimit,
            HANDLE hNextFrameEvent,
            HANDLE *phStreamHandle);
        
        HRESULT ( __stdcall *NuiImageStreamSetImageFrameFlags )( 
            INuiSensor * This,
            HANDLE hStream,
            DWORD dwImageFrameFlags);
        
        HRESULT ( __stdcall *NuiImageStreamGetImageFrameFlags )( 
            INuiSensor * This,
            HANDLE hStream,
            DWORD *pdwImageFrameFlags);
        
        HRESULT ( __stdcall *NuiImageStreamGetNextFrame )( 
            INuiSensor * This,
            HANDLE hStream,
            DWORD dwMillisecondsToWait,
            NUI_IMAGE_FRAME *pImageFrame);
        
        HRESULT ( __stdcall *NuiImageStreamReleaseFrame )( 
            INuiSensor * This,
            HANDLE hStream,
            NUI_IMAGE_FRAME *pImageFrame);
        
        HRESULT ( __stdcall *NuiImageGetColorPixelCoordinatesFromDepthPixel )( 
            INuiSensor * This,
            NUI_IMAGE_RESOLUTION eColorResolution,
            const NUI_IMAGE_VIEW_AREA *pcViewArea,
            LONG lDepthX,
            LONG lDepthY,
            USHORT usDepthValue,
            LONG *plColorX,
            LONG *plColorY);
        
        HRESULT ( __stdcall *NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution )( 
            INuiSensor * This,
            NUI_IMAGE_RESOLUTION eColorResolution,
            NUI_IMAGE_RESOLUTION eDepthResolution,
            const NUI_IMAGE_VIEW_AREA *pcViewArea,
            LONG lDepthX,
            LONG lDepthY,
            USHORT usDepthValue,
            LONG *plColorX,
            LONG *plColorY);
        
        HRESULT ( __stdcall *NuiImageGetColorPixelCoordinateFrameFromDepthPixelFrameAtResolution )( 
            INuiSensor * This,
            NUI_IMAGE_RESOLUTION eColorResolution,
            NUI_IMAGE_RESOLUTION eDepthResolution,
            DWORD cDepthValues,
            USHORT *pDepthValues,
            DWORD cColorCoordinates,
            LONG *pColorCoordinates);
        
        HRESULT ( __stdcall *NuiCameraElevationSetAngle )( 
            INuiSensor * This,
            LONG lAngleDegrees);
        
        HRESULT ( __stdcall *NuiCameraElevationGetAngle )( 
            INuiSensor * This,
            LONG *plAngleDegrees);
        
        HRESULT ( __stdcall *NuiSkeletonTrackingEnable )( 
            INuiSensor * This,
            HANDLE hNextFrameEvent,
            DWORD dwFlags);
        
        HRESULT ( __stdcall *NuiSkeletonTrackingDisable )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiSkeletonSetTrackedSkeletons )( 
            INuiSensor * This,
            DWORD *TrackingIDs);
        
        HRESULT ( __stdcall *NuiSkeletonGetNextFrame )( 
            INuiSensor * This,
            DWORD dwMillisecondsToWait,
            NUI_SKELETON_FRAME *pSkeletonFrame);
        
        HRESULT ( __stdcall *NuiTransformSmooth )( 
            INuiSensor * This,
            NUI_SKELETON_FRAME *pSkeletonFrame,
            const NUI_TRANSFORM_SMOOTH_PARAMETERS *pSmoothingParams);
        
        HRESULT ( __stdcall *NuiGetAudioSource )( 
            INuiSensor * This,
            INuiAudioBeam **ppDmo);
        
        int ( __stdcall *NuiInstanceIndex )( 
            INuiSensor * This);
        
        BSTR ( __stdcall *NuiDeviceConnectionId )( 
            INuiSensor * This);
        
        BSTR ( __stdcall *NuiUniqueId )( 
            INuiSensor * This);
        
        BSTR ( __stdcall *NuiAudioArrayId )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiStatus )( 
            INuiSensor * This);
        
        DWORD ( __stdcall *NuiInitializationFlags )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiGetCoordinateMapper )( 
            INuiSensor * This,
            INuiCoordinateMapper **pMapping);
        
        HRESULT ( __stdcall *NuiImageFrameGetDepthImagePixelFrameTexture )( 
            INuiSensor * This,
            HANDLE hStream,
            NUI_IMAGE_FRAME *pImageFrame,
            BOOL *pNearMode,
            INuiFrameTexture **ppFrameTexture);
        
        HRESULT ( __stdcall *NuiGetColorCameraSettings )( 
            INuiSensor * This,
            INuiColorCameraSettings **pCameraSettings);
        
        BOOL ( __stdcall *NuiGetForceInfraredEmitterOff )( 
            INuiSensor * This);
        
        HRESULT ( __stdcall *NuiSetForceInfraredEmitterOff )( 
            INuiSensor * This,
            BOOL fForceInfraredEmitterOff);
        
        HRESULT ( __stdcall *NuiAccelerometerGetCurrentReading )( 
            INuiSensor * This,
            Vector4 *pReading);
        
        HRESULT ( __stdcall *NuiSetDepthFilter )( 
            INuiSensor * This,
            INuiDepthFilter *pDepthFilter);
        
        HRESULT ( __stdcall *NuiGetDepthFilter )( 
            INuiSensor * This,
            INuiDepthFilter **ppDepthFilter);
        
        HRESULT ( __stdcall *NuiGetDepthFilterForTimeStamp )( 
            INuiSensor * This,
            LARGE_INTEGER liTimeStamp,
            INuiDepthFilter **ppDepthFilter);
        
    } INuiSensorVtbl;

    typedef struct INuiSensor
    {
        const struct INuiSensorVtbl *lpVtbl;
<<<<<<< HEAD
    };
=======
    }INuiSensor;
>>>>>>> 6b9b97a640a85ab28f150fc70006b9225c9c72aa
]]
--]=]

ffi.cdef[[
typedef struct INuiCoordinateMapper INuiCoordinateMapper;
]]

ffi.cdef[[
typedef void (__stdcall * NuiStatusProc)( HRESULT hrStatus, const OLECHAR* instanceName, const OLECHAR* uniqueDeviceName, void* pUserData );
]]

ffi.cdef[[
  HRESULT NuiCameraElevationGetAngle(LONG * plAngleDegrees);

  HRESULT NuiCameraElevationSetAngle(LONG lAngleDegrees);

/*
  HRESULT NuiCreateCoordinateMapperFromParameters(
                ULONG dataByteCount, 
                void* pData,
                INuiCoordinateMapper **ppCoordinateMapper);
*/

  //NuiCreateDepthFilter = NuiLib.NuiCreateDepthFilter,
  //HRESULT NuiCreateSensorById(const OLECHAR *strInstanceId, INuiSensor ** ppNuiSensor );

  //NuiCreateSensorByIndex = NuiLib.NuiCreateSensorByIndex,
  //HRESULT NuiGetAudioSource(INuiAudioBeam ** ppDmo );

  HRESULT NuiGetSensorCount(int * pCount );

  HRESULT NuiImageGetColorPixelCoordinatesFromDepthPixel(
    NUI_IMAGE_RESOLUTION eColorResolution,
    const NUI_IMAGE_VIEW_AREA *pcViewArea,
    LONG   lDepthX,
    LONG   lDepthY,
    USHORT usDepthValue,
    LONG *plColorX,
    LONG *plColorY);

  //NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution = NuiLib.NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution,
  //NuiImageStreamGetImageFrameFlags = NuiLib.NuiImageStreamGetImageFrameFlags,

  HRESULT NuiImageStreamGetNextFrame(
    HANDLE hStream,
    DWORD dwMillisecondsToWait,
    const NUI_IMAGE_FRAME **ppcImageFrame);

  HRESULT NuiImageStreamOpen(
    NUI_IMAGE_TYPE eImageType,
    NUI_IMAGE_RESOLUTION eResolution,
    DWORD dwImageFrameFlags,
    DWORD dwFrameLimit,
    HANDLE hNextFrameEvent,
    HANDLE *phStreamHandle);

  HRESULT NuiImageStreamReleaseFrame(
    HANDLE hStream,
    const NUI_IMAGE_FRAME *pImageFrame);

  HRESULT NuiImageStreamSetImageFrameFlags(
    HANDLE hStream,
    DWORD dwImageFrameFlags);
  
  
  void NuiSetDeviceStatusCallback( NuiStatusProc callback, void* pUserData );

  HRESULT NuiSetFrameEndEvent(
    HANDLE hEvent,
    DWORD dwFrameEventFlag);

]]






local __HRESULT_FROM_WIN32 = function(x) 
  if x <= 0 then
    return ((x))
  end

  return bor(band(x, 0x0000FFFF), bor(lshift(FACILITY_WIN32, 16), 0x80000000))
end

return {
    Lib = NuiLib,

  NUI_CAMERA_ELEVATION_MAXIMUM  = 27,
  NUI_CAMERA_ELEVATION_MINIMUM  = (-27),

--[[
  E_NUI_DEVICE_NOT_CONNECTED  = __HRESULT_FROM_WIN32(ERROR_DEVICE_NOT_CONNECTED)
  E_NUI_DEVICE_NOT_READY      = __HRESULT_FROM_WIN32(ERROR_NOT_READY)
  E_NUI_ALREADY_INITIALIZED   = __HRESULT_FROM_WIN32(ERROR_ALREADY_INITIALIZED)
  E_NUI_NO_MORE_ITEMS         = __HRESULT_FROM_WIN32(ERROR_NO_MORE_ITEMS)
--]]




  NuiCameraElevationGetAngle = NuiLib.NuiCameraElevationGetAngle,
  NuiCameraElevationSetAngle = NuiLib.NuiCameraElevationSetAngle,
  --[[
  NuiCreateCoordinateMapperFromParameters = NuiLib.NuiCreateCoordinateMapperFromParameters,
  NuiCreateDepthFilter = NuiLib.NuiCreateDepthFilter,
  NuiCreateSensorById = NuiLib.NuiCreateSensorById,
  NuiCreateSensorByIndex = NuiLib.NuiCreateSensorByIndex,
  NuiGetAudioSource = NuiLib.NuiGetAudioSource,
  --]]

  NuiGetSensorCount = NuiLib.NuiGetSensorCount,
  
--[[
  NuiImageGetColorPixelCoordinatesFromDepthPixel = NuiLib.NuiImageGetColorPixelCoordinatesFromDepthPixel,
  NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution = NuiLib.NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution,
  NuiImageStreamGetImageFrameFlags = NuiLib.NuiImageStreamGetImageFrameFlags,
  NuiImageStreamGetNextFrame = NuiLib.NuiImageStreamGetNextFrame,
--]]
  NuiImageStreamOpen = NuiLib.NuiImageStreamOpen,
--[[
  NuiImageStreamReleaseFrame = NuiLib.NuiImageStreamReleaseFrame,
  NuiImageStreamSetImageFrameFlags = NuiLib.NuiImageStreamSetImageFrameFlags,
--]]

  NuiInitialize = NuiLib.NuiInitialize,

--[[
  NuiSetDeviceStatusCallback = NuiLib.NuiSetDeviceStatusCallback,
  NuiSetFrameEndEvent = NuiLib.NuiSetFrameEndEvent,
--]]
  NuiShutdown = NuiLib.NuiShutdown,

--[[
  NuiSkeletonCalculateBoneOrientations = NuiLib.NuiSkeletonCalculateBoneOrientations,
  NuiSkeletonGetNextFrame = NuiLib.NuiSkeletonGetNextFrame,
  NuiSkeletonSetTrackedSkeletons = NuiLib.NuiSkeletonSetTrackedSkeletons,
  NuiSkeletonTrackingDisable = NuiLib.NuiSkeletonTrackingDisable,
  NuiSkeletonTrackingEnable = NuiLib.NuiSkeletonTrackingEnable,
  NuiTransformSmooth = NuiLib.NuiTransformSmooth,
--]]
}
