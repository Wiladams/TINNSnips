--
-- GameWindow.lua
--

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local Gdi32 = require "GDI32"
local User32 = require "user32_ffi"
local errorhandling = require("core_errorhandling_l1_1_1")
local libraryloader = require("core_libraryloader_l1_1_1");
local core_synch = require("core_synch_l1_2_0");
local WindowKind = require("WindowKind");

local StopWatch = require "StopWatch"


local GameWindow = {
	Defaults = {
		ClassName = "LuaWindow",
		Title = "Game Window",
		Origin = {10,10},
		Extent = {320, 240},
		FrameRate = 30,
	},
	
	WindowMap = {},
}
setmetatable(GameWindow, {
	__call = function(self, ...)
		return self:create(...);
	end,
});

local GameWindow_mt = {
	__index = GameWindow;
}




function WindowProc(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	local self = GameWindow.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, self: %s", msg, winnum, tostring(self)))

	-- if we have a self, then the window is capable
	-- of handling the message
	if self then
		if (self.MessageDelegate) then
			result = self.MessageDelegate(hwnd, msg, wparam, lparam)
			return result
		end

		if (msg == User32.WM_DESTROY) then
			return self:OnDestroy()
		end

		if (msg >= User32.WM_MOUSEFIRST and msg <= User32.WM_MOUSELAST) or
				(msg >= User32.WM_NCMOUSEMOVE and msg <= User32.WM_NCMBUTTONDBLCLK) then
				self:OnMouseMessage(msg, wparam, lparam)
		end

		if (msg >= User32.WM_KEYDOWN and msg <= User32.WM_SYSCOMMAND) then
				self:OnKeyboardMessage(msg, wparam, lparam)
		end
	end

	-- otherwise, it's not associated with a window that we know
	-- so do default processing
	return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
end




local winKind = WindowKind:create("LuaWindow", WindowProc);


GameWindow.init = function(self, nativewindow, params)
	local obj = {
		NativeWindow = nativewindow,

		Width = params.Extent[1];
		Height = params.Extent[2];

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
	setmetatable(obj, GameWindow_mt);
	
	obj:OnCreated(nativewindow);
	
	return obj;
end	

GameWindow.create = function(self, params)
	params = params or GameWindow.Defaults

	params.ClassName = params.ClassName or GameWindow.Defaults.ClassName
	params.Title = params.Title or GameWindow.Defaults.Title
	params.Origin = params.Origin or GameWindow.Defaults.Origin
	params.Extent = params.Extent or GameWindow.Defaults.Extent
	params.FrameRate = params.FrameRate or GameWindow.Defaults.FrameRate

	-- try to create a window of our kind
	local win, err = winKind:createWindow(params.Extent[1], params.Extent[2]);
	
	if not win then
		return nil, err;
	end
	
--	self:Register(params);
--	self:CreateWindow(params);

	return self:init(win, params);
end

function GameWindow:GetClientSize()
	return self.NativeWindow:GetClientSize();
end

function GameWindow:SetFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end



function GameWindow:Show()
	self.NativeWindow:Show();
end

function GameWindow:Hide()
	self.NativeWindow:Hide();
end

function GameWindow:Update()
	self.NativeWindow:Update();
end


function GameWindow:SwapBuffers()
	gdi32.SwapBuffers(self.GDIContext.Handle);
end


function GameWindow:OnCreated(nativewindow)
print("GameWindow:OnCreated: ", nativewindow)

	local winptr = ffi.cast("intptr_t", nativewindow:getNativeHandle())
	local winnum = tonumber(winptr)

	GameWindow.WindowMap[winnum] = self

	self.GDIContext = DeviceContext(User32.GetDC(nativewindow:getNativeHandle()));

print("GDIContext: ", self.GDIContext, self.GDIContext.Handle);
	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

	self.IsValid = true
end

function GameWindow:OnDestroy()
	print("GameWindow:OnDestroy")

	ffi.C.PostQuitMessage(0)

	return 0
end

function GameWindow:OnQuit()
print("GameWindow:OnQuit")
	self.IsRunning = false
end

function GameWindow:OnTick(tickCount)
	if (self.OnTickDelegate) then
		self.OnTickDelegate(self, tickCount)
	end
end

function GameWindow:OnFocusMessage(msg)
print("OnFocusMessage")
	if (self.OnSetFocusDelegate) then
		self.OnSetFocusDelegate(self, msg)
	end
end

function GameWindow:OnKeyboardMessage(msg, wparam, lparam)
	if self.KeyboardInteractor then
		self.KeyboardInteractor(msg)
	end
end

function GameWindow:OnMouseMessage(msg)
	if self.MouseInteractor then
		self.MouseInteractor(msg)
	end
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
	local timerEvent = core_synch.CreateEventA(nil, false, false, nil)
	-- If the timer event was not created
	-- just return
	if timerEvent == nil then
		error("unable to create timer")
		return
	end

	local handleCount = 1
	local handles = ffi.new('void*[1]', {timerEvent})

	local msg = ffi.new("MSG")
	local sw = StopWatch();
	local tickCount = 1
	local timeleft = 0
	local lastTime = sw:Milliseconds()
	local nextTime = lastTime + win.Interval * 1000

	local dwFlags = bor(User32.MWMO_ALERTABLE,User32.MWMO_INPUTAVAILABLE)

	while (win.IsRunning) do
		while (User32.PeekMessageA(msg, nil, 0, 0, User32.PM_REMOVE) ~= 0) do
			User32.TranslateMessage(msg)
			User32.DispatchMessageA(msg)

--print(string.format("Loop Message: 0x%x", msg.message))

			if msg.message == User32.WM_QUIT then
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
		User32.MsgWaitForMultipleObjectsEx(handleCount, handles, timeleft, User32.QS_ALLEVENTS, dwFlags)
	end
end

function GameWindow:Run()
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
