package.path = package.path..";../?.lua"

local ffi = require "ffi"
local bit = require("bit");
local bor = bit.bor;

local Kernel32 = require("win_kernel32");
local GDI32 = require ("GDI32");
local User32 = require("User32");
local GLWindow = require ("GLWindow");
local KeyMouse = require("KeyMouse");
local StopWatch = require ("StopWatch");
local ogm = require("OglMan");

-- Handle any keyboard or mouse messages
function keyMouseHandler(hwnd, msg, wparam, lparam)
	local event = KeyMouse.ConvertKeyMouse(hwnd, msg, wparam, lparam);

	if event then
		print("==========")
		for k,v in pairs(event) do
			print(k,v);
		end
	end
end


function ontick(win, tickCount)
	glClearColor(math.random(), math.random(), math.random(), 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	win:SwapBuffers();
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
	win:Show();
	win:Update();
	win.IsRunning = true;

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
print("Exiting Window Loop")
	stop();
end


local appwin = GLWindow({
	Title = "Game Window",
	Extent = {1024,768},
	FrameRate = 10,

	OnMouseDelegate = keyMouseHandler,
	OnKeyDelegate = keyMouseHandler,
	OnTickDelegate = ontick,
	})

run(Loop, appwin);

