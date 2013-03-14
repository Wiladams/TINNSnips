--
-- GameWindow.lua
--


local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor


--local gl = require "gl"

local Gdi32 = require "GDI32"
local User32 = require "User32"
local Kernel32 = require "win_kernel32"

local StopWatch = require "StopWatch"



local GameWindow_t = {
	Defaults = {
		ClassName = "LuaWindow",
		Title = "Game Window",
		Origin = {10,10},
		Extent = {320, 240},
		FrameRate = 30,
	}
}
GameWindow_t.WindowMap = {}

local GameWindow_mt = {
	__index = GameWindow_t;
}

local GameWindow = function(params)
	params = params or GameWindow_t.Defaults

	params.ClassName = params.ClassName or GameWindow_t.Defaults.ClassName
	params.Title = params.Title or GameWindow_t.Defaults.Title
	params.Origin = params.Origin or GameWindow_t.Defaults.Origin
	params.Extent = params.Extent or GameWindow_t.Defaults.Extent
	params.FrameRate = params.FrameRate or GameWindow_t.Defaults.FrameRate

	local self = {
		Registration = nil;
		IsReady = false;
		IsValid = false;
		IsRunning = false;

		FrameRate = params.FrameRate;
		Interval =1/ params.FrameRate;

		-- Interactor routines
		MessageDelegate = params.MessageDelegate;
		OnSetFocusDelegate = params.OnSetFocusDelegate;
		OnTickDelegate = params.OnTickDelegate;

		KeyboardInteractor = params.KeyboardInteractor;
		MouseInteractor = params.MouseInteractor;
		GestureInteractor = params.GestureInteractor;
	}
	setmetatable(self, GameWindow_mt);

	self:Register(params);
	self:CreateWindow(params);

	return self;
end

function GameWindow_t:GetClientSize()
	local csize = ffi.new( "RECT[1]" )
    User32.Lib.GetClientRect(self.WindowHandle, csize);
	csize = csize[0]
	local width = csize.right-csize.left
	local height = csize.bottom-csize.top

	return width, height
end


function GameWindow_t:SetFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end






function GameWindow_t:Register(params)
	self.AppInstance = Kernel32.Lib.GetModuleHandleA(nil)
	self.ClassName = params.ClassName

	local classStyle = bit.bor(User32.FFI.CS_HREDRAW, User32.FFI.CS_VREDRAW, User32.FFI.CS_OWNDC);

	local aClass = ffi.new('WNDCLASSEXA', {
		cbSize = ffi.sizeof("WNDCLASSEXA");
		style = classStyle;
		lpfnWndProc = WindowProc;
		cbClsExtra = 0;
		cbWndExtra = 0;
		hInstance = self.AppInstance;
		hIcon = nil;
		hCursor = nil;
		hbrBackground = nil;
		lpszMenuName = nil;
		lpszClassName = self.ClassName;
		hIconSm = nil;
		})

	self.Registration = User32.Lib.RegisterClassExA(aClass)

	assert(self.Registration ~= 0, "Registration error"..tostring(Kernel32.GetLastError()))
end



function GameWindow_t:CreateWindow(params)
	self.ClassName = params.ClassName
	self.Title = params.Title
	self.Width = params.Extent[1]
	self.Height = params.Extent[2]

	local dwExStyle = bit.bor(User32.FFI.WS_EX_APPWINDOW, User32.FFI.WS_EX_WINDOWEDGE)
	local dwStyle = bit.bor(User32.FFI.WS_SYSMENU, User32.FFI.WS_VISIBLE, User32.FFI.WS_POPUP)

print("GameWindow:CreateWindow - 1.0")
	local hwnd = User32.Lib.CreateWindowExA(
		0,
		self.ClassName,
		self.Title,
		User32.FFI.WS_OVERLAPPEDWINDOW,
		User32.FFI.CW_USEDEFAULT,
		User32.FFI.CW_USEDEFAULT,
		params.Extent[1], params.Extent[2],
		nil,
		nil,
		self.AppInstance,
		nil)
print("GameWindow:CreateWindow - 2.0")

	assert(hwnd,"unable to create window"..tostring(Kernel32.GetLastError()))


	self:OnCreated(hwnd)
end


function GameWindow_t:Show()
	User32.Lib.ShowWindow(self.WindowHandle, User32.FFI.SW_SHOW)
end

function GameWindow_t:Hide()
end

function GameWindow_t:Update()
	User32.Lib.UpdateWindow(self.WindowHandle)
end


function GameWindow_t:SwapBuffers()
	gdi32.SwapBuffers(self.GDIContext.Handle);
end

--[[
function GameWindow_t:CreateGLContext()
	opengl32.wglMakeCurrent(nil, nil)

	self.GLContext = CreateGLContextFromWindow(self.WindowHandle, C.PFD_DOUBLEBUFFER)
	self.GLContext:Attach()

	print("GameWindow:CreateGLContext - GL Device Context: ", self.GLContext)

end
--]]

function GameWindow_t:OnCreated(hwnd)
print("GameWindow:OnCreated: ", hwnd)

	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	self.WindowHandle = hwnd
	GameWindow_t.WindowMap[winnum] = self


	self.GDIContext = DeviceContext(User32.Lib.GetDC(self.WindowHandle));

print("GDIContext: ", self.GDIContext, self.GDIContext.Handle);
	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

--	self:CreateGLContext()

	self.IsValid = true
end

function GameWindow_t:OnDestroy()
	print("GameWindow:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GameWindow_t:OnQuit()
print("GameWindow:OnQuit")
	self.IsRunning = false

	-- delete glcontext
	--if self.GLContext then
	--	self.GLContext:Destroy()
	--end
end

function GameWindow_t:OnTick(tickCount)
	if (self.OnTickDelegate) then
		self.OnTickDelegate(self, tickCount)
	end
end

function GameWindow_t:OnFocusMessage(msg)
print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GameWindow_t:OnKeyboardMessage(msg, wparam, lparam)
	if self.KeyboardInteractor then
		self.KeyboardInteractor(msg)
	end
end

function GameWindow_t:OnMouseMessage(msg)
	if self.MouseInteractor then
		self.MouseInteractor(msg)
	end
end

--[[
	for window creation, we should see the
	following sequence
        WM_GETMINMAXINFO 		= 0x0024
        WM_NCCREATE 			= 0x0081
        WM_NCCALCSIZE 			= 0x0083
        WM_CREATE 				= 0x0001

	Then, after ShowWindow is called
		WM_SHOWWINDOW 			= 0x0018,
		WM_WINDOWPOSCHANGING 	= 0x0046,
		WM_ACTIVATEAPP 			= 0x001C,

	Closing Sequence
		WM_CLOSE 				= 0x0010,
		...
		WM_ACTIVATEAPP 			= 0x001C,
		WM_KILLFOCUS			= 0x0008,
		WM_IME_SETCONTEXT 		= 0x0281,
		WM_IME_NOTIFY 			= 0x0282,
		WM_DESTROY 				= 0x0002,
		WM_NCDESTROY 			= 0x0082,
--]]

function WindowProc(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	local self = GameWindow_t.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, self: %s", msg, winnum, tostring(self)))

	-- if we have a self, then the window is capable
	-- of handling the message
	if self then
		if (self.MessageDelegate) then
			result = self.MessageDelegate(hwnd, msg, wparam, lparam)
			return result
		end

		if (msg == User32.FFI.WM_DESTROY) then
			return self:OnDestroy()
		end

		if (msg >= User32.FFI.WM_MOUSEFIRST and msg <= User32.FFI.WM_MOUSELAST) or
				(msg >= User32.FFI.WM_NCMOUSEMOVE and msg <= User32.FFI.WM_NCMBUTTONDBLCLK) then
				self:OnMouseMessage(msg, wparam, lparam)
		end

		if (msg >= User32.FFI.WM_KEYDOWN and msg <= User32.FFI.WM_SYSCOMMAND) then
				self:OnKeyboardMessage(msg, wparam, lparam)
		end
	end

	-- otherwise, it's not associated with a window that we know
	-- so do default processing
	return User32.Lib.DefWindowProcA(hwnd, msg, wparam, lparam);

end

-- The following 'jit.off(Loop)' is here because LuaJit
-- can't quite fix-up the case where a callback is being
-- called from LuaJit'd code
-- http://lua-users.org/lists/lua-l/2011-12/msg00712.html
--
-- I found the proper way to do this is to put the jit.off
-- call before the function body.
--
jit.off(Loop)
function Loop(win)
	local timerEvent = Kernel32.CreateEvent(nil, false, false, nil)
	-- If the timer event was not created
	-- just return
	if timerEvent == nil then
		error("unable to create timer")
		return
	end

	local handleCount = 1
	local handles = ffi.new('void*[1]', {timerEvent})

	local msg = ffi.new("MSG")
	local sw = StopWatch.new();
	local tickCount = 1
	local timeleft = 0
	local lastTime = sw:Milliseconds()
	local nextTime = lastTime + win.Interval * 1000

	local dwFlags = bor(User32.FFI.MWMO_ALERTABLE,User32.FFI.MWMO_INPUTAVAILABLE)

	while (win.IsRunning) do
		while (User32.Lib.PeekMessageA(msg, nil, 0, 0, User32.FFI.PM_REMOVE) ~= 0) do
			User32.Lib.TranslateMessage(msg)
			User32.Lib.DispatchMessageA(msg)

--print(string.format("Loop Message: 0x%x", msg.message))

			if msg.message == User32.FFI.WM_QUIT then
				return win:OnQuit()
			end

		end

		timeleft = nextTime - sw:Milliseconds();
		if (timeleft <= 0) then
			win:OnTick(tickCount);
			tickCount = tickCount + 1
			nextTime = nextTime + win.Interval * 1000
			timeleft = nextTime - sw:Milliseconds();
		end

		if timeleft < 0 then timeleft = 0 end

		-- use an alertable wait
		User32.Lib.MsgWaitForMultipleObjectsEx(handleCount, handles, timeleft, User32.FFI.QS_ALLEVENTS, dwFlags)
	end
end

function GameWindow_t:Run()
	if not self.IsValid then
		print('Window Handle is NULL')
		return
	end

	self.IsRunning = true

	self:Show()
	self:Update()

	Loop(self)
end


return GameWindow;
