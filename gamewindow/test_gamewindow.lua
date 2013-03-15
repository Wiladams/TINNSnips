

local ffi = require "ffi"

local GameWindow = require "GameWindow"
local GDI32 = require "GDI32"
local StopWatch = require "StopWatch"

-- The routine that gets called for any
-- mouse activity messages
function mouseinteraction(msg, wparam, lparam)
	print(string.format("Mouse: 0x%x", msg))
end

function keyboardinteraction(msg, wparam, lparam)
	print(string.format("Keyboard: 0x%x", msg))
end

local sw = StopWatch.new();

function randomColor()
		local r = math.random(0,255)
		local g = math.random(0,255)
		local b = math.random(0,255)
		local color = RGB(r,g,b)

	return color
end

function randomline(win)
	local x1 = math.random() * win.Width
	local y1 = 40 + (math.random() * (win.Height - 40))
	local x2 = math.random() * win.Width
	local y2 = 40 + (math.random() * (win.Height - 40))

	local color = randomColor()

	win.GDIContext:SetDCPenColor(color)

	win.GDIContext:MoveTo(x1, y1)
	win.GDIContext:LineTo(x2, y2)
end

function randomrect(win)
	local width = math.random(2,40)
	local height = math.random(2,40)
	local x = math.random(0,win.Width-1-width)
	local y = math.random(0, win.Height-1-height)
	local right = x + width
	local bottom = y + height
--print(x,y,width,height)
	local brushColor = randomColor()
	win.GDIContext:SetDCBrushColor(brushColor)
	win.GDIContext:RoundRect(x, y, right, bottom, 0, 0)
end


function ontick(win, tickCount)
	local black = RGB(0,0,0)
	win.GDIContext:SetDCPenColor(black)

	for i=1,win.FrameRate do
		randomrect(win)
	end

	--for i=1,win.FrameRate do
	--	randomline(win)
	--end

	local stats = string.format("Seconds: %f  Frame: %d  FPS: %f", sw:Seconds(), tickCount, tickCount/sw:Seconds())
	win.GDIContext:Text(stats)
end


-- MouseInteractor = mouseinteraction,

---[[
	local appwin = GameWindow({
		Title = "Game Window",
		KeyboardInteractor = keyboardinteraction,
		FrameRate = 120,
		OnTickDelegate = ontick,
		Extent = {1024,768},
		})
--]]

--local appwin = GameWindow({OnTickDelegate = ontick, Extent = {1024,768}, FrameRate=24.99})

appwin:Run()

