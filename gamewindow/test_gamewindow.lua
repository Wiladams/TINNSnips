
local GDIWindow = require "GDIWindow"
local StopWatch = require "StopWatch"
local Animite = require("animite")
local Behaviors = require("behaviors")


local sw = StopWatch();


-- The routine that gets called for any
-- mouse activity messages
function mouseinteraction(msg, wparam, lparam)
	--print(string.format("Mouse: 0x%x", msg))
end

function keyboardinteraction(msg, wparam, lparam)
	print(string.format("Keyboard: 0x%x", msg))
end


function ontick(win, tickCount)
--print("ONTICK")
	local ctxt = win.GDIContext

	local stats = string.format("Seconds: %f  Frame: %d  FPS: %f", sw:Seconds(), tickCount, tickCount/sw:Seconds())
	ctxt:Text(stats)
end

local liner1 = nil;
local rectangler = nil;
local ellipser = nil;
local pixler = nil;
local rambler = nil;

local animites = {}

function onquit(win)
	print("ON QUIT!")
	
	for name, mite in pairs(animites) do
		mite:stop();
	end

	return true;
end


local win = GDIWindow({
		Title = "Game Window",
		KeyboardInteractor = keyboardinteraction,
		MouseInteractor = mouseinteraction,
		FrameRate = 1000,
		OnTickDelegate = ontick,
		OnQuitDelegate = onquit,
		Extent = {1024,768},
		})

local loadFullscreen = function()
	--animites.liner = Animite(win.GDIContext, Behaviors.lines({Left=0, Top=20, Width=win.Width, Height=(win.Height-1)-20}))
	animites.rectangler = Animite(win.GDIContext, Behaviors.rectangles({Left=0, Top=20, Width=win.Width, Height=(win.Height-1)-20}))
end

local loadQuadScreen = function()
animites.liner = Animite(win.GDIContext, Behaviors.lines({Left=win.Width/2, Top=20, Width=(win.Width-1)/2, Height=((win.Height-1)/2)-20}))
animites.ellipser = Animite(win.GDIContext, Behaviors.ellipses({Left=win.Width/2, Top=win.Height/2, Width=(win.Width-1)/2, Height=((win.Height-1)/2)}))
animites.rectangler = Animite(win.GDIContext, Behaviors.rectangles({Left =0,Top=20,Width=(win.Width-1)/2, Height=((win.Height-1)/2)-20}))
--animites.pixler = Animite(win.GDIContext, Behaviors.pixels({Left=0, Top=win.Height/2, Width=(win.Width-1)/2, Height=((win.Height-1)/2)}))
end


--loadFullscreen();
loadQuadScreen();

-- get the mites running
for name, mite in pairs(animites) do
	mite:start();
end


win:run()

