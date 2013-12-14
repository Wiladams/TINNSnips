--
-- GameWindow.lua
--

local ffi = require "ffi"
local bit = require "bit"
local bor = bit.bor

local Task = require("IOProcessor")
local Timer = require("Timer")

local Gdi32 = require "GDI32"
local User32 = require "user32_ffi"
local errorhandling = require("core_errorhandling_l1_1_1")
local libraryloader = require("core_libraryloader_l1_1_1");
local core_synch = require("core_synch_l1_2_0");
local WindowKind = require("WindowKind");



local GameWindow = {
	Defaults = {
		ClassName = "GameWindow",
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



--[[
-- The following 'jit.off(WindowProc)' is here because LuaJit
-- can't quite fix-up the case where a callback is being
-- called from LuaJit'd code
-- http://lua-users.org/lists/lua-l/2011-12/msg00712.html
--
-- I found the proper way to do this is to put the jit.off
-- call before the function body.
--
--]]
jit.off(WindowProc)
function WindowProc(hwnd, msg, wparam, lparam)
-- lookup which window object is associated with the
-- window handle
	local winptr = ffi.cast("intptr_t", hwnd)
	local winnum = tonumber(winptr)

	local self = GameWindow.WindowMap[winnum]

--print(string.format("WindowProc: 0x%x, Window: 0x%x, self: %s", msg, winnum, tostring(self)))

	-- If we don't find a window object associated with 
	-- the window handle, then use the default window proc
	if not self then
		return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
	end

	-- if we have a self, then the window is capable
	-- of handling the message
	if (self.MessageDelegate) then
		result = self.MessageDelegate(hwnd, msg, wparam, lparam)
		return result
	end

	if (msg == User32.WM_DESTROY) then
		return self:OnDestroy()
	elseif (msg >= User32.WM_MOUSEFIRST and msg <= User32.WM_MOUSELAST) or
		(msg >= User32.WM_NCMOUSEMOVE and msg <= User32.WM_NCMBUTTONDBLCLK) then
		self:OnMouseMessage(msg, wparam, lparam)
	elseif (msg >= User32.WM_KEYDOWN and msg <= User32.WM_SYSCOMMAND) then
		self:OnKeyboardMessage(msg, wparam, lparam)
	end
	
--print(string.format("WindowProc Default: 0x%04x", msg))

	return User32.DefWindowProcA(hwnd, msg, wparam, lparam);
end




local winKind = WindowKind:create("GameWindow", WindowProc);


GameWindow.init = function(self, nativewindow, params)

	local obj = {
		NativeWindow = nativewindow,

		Width = params.Extent[1];
		Height = params.Extent[2];

		IsReady = false;
		IsValid = false;
		IsRunning = false;

		-- Interactor routines
		MessageDelegate = params.MessageDelegate;
		OnSetFocusDelegate = params.OnSetFocusDelegate;
		OnTickDelegate = params.OnTickDelegate;
		OnQuitDelegate = params.OnQuitDelegate;

		KeyboardInteractor = params.KeyboardInteractor;
		MouseInteractor = params.MouseInteractor;
		GestureInteractor = params.GestureInteractor;
	}
	setmetatable(obj, GameWindow_mt);
	
	obj:SetFrameRate(params.FrameRate)
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
	local win, err = winKind:createWindow(params.Extent[1], params.Extent[2], params.Title);
	
	if not win then
		return nil, err;
	end
	
	return self:init(win, params);
end

GameWindow.getBackBuffer = function(self)
	if not self.BackBuffer then
		-- get the GDIcontext for the native window
		local err
		local bbfr, err = self.GDIContext:createCompatibleBitmap(self.Width, self.Height)

		if not bbfr then
			return nil, err;
		end

		self.BackBuffer = bbfr;
	end

	return self.BackBuffer;
end

function GameWindow:GetClientSize()
	return self.NativeWindow:GetClientSize();
end

function GameWindow:SetFrameRate(rate)
	self.FrameRate = rate
	self.Interval = 1/self.FrameRate
end



function GameWindow:show()
	self.NativeWindow:Show();
end

function GameWindow:hide()
	self.NativeWindow:Hide();
end

GameWindow.redraw = function(self, flags)
	return self.NativeWindow:redraw(flags);
end

function GameWindow:update()
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

	self.GDIContext = DeviceContext:init(User32.GetDC(nativewindow:getNativeHandle()));


	self.GDIContext:UseDCPen()
	self.GDIContext:UseDCBrush()

--print("GDIContext: ", self.GDIContext);

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

	if self.OnQuitDelegate then
		self.OnQuitDelegate(self)
	end
	-- return true, indicating it is ok to
	-- continue to quit.
	return true;
end

GameWindow.handleFrameTick = function(self)
	local tickCount = 0;

	local closure = function(timer)
		tickCount = tickCount + 1;

		if (self.OnTickDelegate) then
			self.OnTickDelegate(self, tickCount)
		end
	end

	return closure;
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
		return 0;
	end
	return 1;
end

function GameWindow:OnMouseMessage(msg)
	if self.MouseInteractor then
		self.MouseInteractor(msg)
		return 0;
	end
	return 1;
end


--[[
	This is a predicate with side effects
	appQuit() returns a closure which will check the 
	event queue for messages, and dispatch them.

	If the WM_QUIT message is encountered, the OnQuit() method
	is called.  If that in turn sets 'IsRunning' == false
	then the predicate will return 'true', indicating that the 
	condition has been met.

	The window will go away, and whatever consequence there is 
	to this predicate becoming true will be enacted.

--]]
local appClose = function(win)

	win.IsRunning = true
	local msg = ffi.new("MSG")

	local closure = function()

		ffi.fill(msg, ffi.sizeof("MSG"))
		local peeked = User32.PeekMessageA(msg, nil, 0, 0, User32.PM_REMOVE);

--print("PEEKED: ", peeked)

		if peeked ~= 0 then

			local res = User32.TranslateMessage(msg)
			
			User32.DispatchMessageA(msg)

			if msg.message == User32.WM_QUIT then
				print("APP QUIT == TRUE")
				win:OnQuit()
			end
		end

		if win.IsRunning == false then
			print("APP CLOSE, IsRunning == false")		
			if win.FrameTimer then
				win.FrameTimer:cancel();
			end

			return true;
		end

		return false;
	end

	return closure;
end

GameWindow.runWindow = function(self)
	
	self:show()
	self:update()

	-- Start the FrameTimer
	local period = 1000/self.FrameRate;
	self.FrameTimer = Timer({Delay=period, Period=period, OnTime =self:handleFrameTick()})

	-- wait here until the application window is closed
	local res = waitFor(appClose(self))
	print("RESULT, waitFor(appClose): ", res)
	
	print("GameWindow.runWindow == APP CLOSED PREDICATE ")
end

GameWindow.run = function(self)
	if not self.IsValid then
		print('Window Handle is NULL')
		return
	end

	-- set quanta to 0 so we don't waste time
	-- in i/o processing if there's nothing there
	Task:setMessageQuanta(0);
	

	-- spawn the thread that will wait
	-- for messages to finish
	Task:spawn(GameWindow.runWindow, self);

	Task:start()

	print("EXIT GameWindow.run")
end


return GameWindow;
