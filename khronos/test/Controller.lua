
local StopWatch = require "StopWatch"
--require "FileUtils"
--local User32 = require "User32"
local GLSLProgram = require "GLSLProgram"


Controller_t = {}
Controller_mt = {
	__index = Controller_t;
}

local Controller = function(win, awidth, aheight)
	local obj = {
		Window = win;
		Running = false;
		TickCount = 0;
		frameCount = 0;
		Clock = StopWatch.new();
	}

	setmetatable(obj, Controller_mt);

	return obj;
end

function Controller_t:OnIdle(idleTime)
end

function Controller_t:OnTick(tickCount)
	self:Tick(tickCount);
end

function Controller_t:OnWindowResized(width, height)
	print("Controller_t:OnWindowResized");

	self.WindowWidth = width;
	self.WindowHeight = height;

	if _G.reshape then
		reshape(width, height);
	else
		gl.glViewport(0, 0, width, height);
	end
end

function Controller_t:OnWindowResizing(width, height)
	-- It would be good to redisplay from here
	print("OnWindowResizing");
end

--[[
local keymousedispatch = {
	mousemove = mousemove;
	mousedown = mousedown;
	mouseup = mouseup;
	mousewheel = mousewheel;
	keydown = keydown;
	keyup = keyup;
	keychar = keychar;
}

Controller_t.OnKeyMouse = function(self, event)
--print("Controller_t:OnKeyMouse(): ", event.kind);

	local func = _G[event.kind]
	if not func then
		return false, string.format("OnKeyMouse, no event dispatcher found for kind: %s", event.kind);
	end

	func(event);

	return true;
end
--]]

--[==============================[
	Compiling
--]==============================]

function Controller_t:ClearGlobalFunctions()
	-- Clear out the global routines
	-- That the user may have supplied
	_G.init = nil
	_G.display = nil
	_G.reshape = nil
end


function Controller_t:LoadFile(filename)
	if filename ~= nil then
		self.LoadedFile = filename
		self.FileAttributes = GetFileAttributes(filename)
		self.LastWriteTime = tostring(self.FileAttributes.ftLastWriteTime)
		print("Loaded File last Write Time: ", self.LastWriteTime)

		local f = assert(io.open(filename, "r"))
		local txt = f:read("*all")
		self:Compile(txt)
		f:close()
	end
end

function Controller_t:ReloadCurrentFile()
	self:LoadFile(self.LoadedFile)
end

function Controller_t:Compile(inputtext)
	-- Stop animation if currently running
	self:StopAnimation()


	-- Ideally, create a new lua state to run
	-- the script in.  That way, cleanup becomes
	-- very easy, and an error in the script will
	-- not take down the entire application.
	-- Fow now, just use the same script environment
	-- but clean up the global functions that we use

	self:ClearGlobalFunctions();

	-- Compile the code
	local f = loadstring(inputtext)
	f()

	-- If there is a setup routine,
	-- run that before anything else
	if _G.init ~= nil then
		_G.init()
	end

	-- Run animation loop
	self:StartAnimation()
end

function Controller_t:StartAnimation()
	self.Running = true
	self.TickCount = 0
	self.FramesPerSecond = 0
	self.frameCount = 0
	self.Clock:Reset()
end

function Controller_t:StopAnimation()
	self.Running = false
	self.TickCount = 0
end

function Controller_t:ReloadScriptIfChanged()
	-- Check to see if file has changed,
	-- if it has, then reload it
	--print("Loaded File Write Time: ", self.LastWriteTime)

	-- Get the current attributes on the file
	local fa = GetFileAttributes(self.LoadedFile)
	local currentWriteTime = tostring(fa.ftLastWriteTime)
	--print("Current Write Time: ", currentWriteTime)

	-- Compare the current write time with the last write time
	local writeTimesEqual = currentWriteTime == self.LastWriteTime
	--print("Write Times Equal: ", writeTimesEqual)

	if (writeTimesEqual == false) then
		self:ReloadCurrentFile()
	end
end

--[[
	Perform the actual tick
--]]
function Controller_t:Tick(tickCount)
	if not self.Running then return end

	self.TickCount = self.TickCount + 1
	self.frameCount = self.frameCount + 1

	self.FramesPerSecond = self.TickCount / self.Clock:Seconds()

	if (_G.ontick) ~= nil then
		ontick(tickCount)
	end

	-- If the user has created a global 'display()' function
	-- then execute that function
	if (_G.display) ~= nil then
		display()
	end

	-- Check every 30 ticks
	--local timeToCheck = ((tickCount %30) == 0);
	--if timeToCheck and (self.LoadedFile ~= nil) then
	--	self:ReloadScriptIfChanged()
	--end
end

return Controller

