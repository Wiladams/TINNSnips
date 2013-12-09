
local GameWindow = require "GameWindow"
local StopWatch = require "StopWatch"

local sw = StopWatch();

-- The routine that gets called for any
-- mouse activity messages
function mouseinteraction(msg, wparam, lparam)
	print(string.format("Mouse: 0x%x", msg))
end

function keyboardinteraction(msg, wparam, lparam)
	print(string.format("Keyboard: 0x%x", msg))
end


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
	local ctxt = win.GDIContext;

	ctxt:SetDCPenColor(color)

	ctxt:MoveTo(x1, y1)
	ctxt:LineTo(x2, y2)
end

function randomrect(win)
	local width = math.random(2,40)
	local height = math.random(2,40)
	local x = math.random(0,win.Width-1-width)
	local y = math.random(0, win.Height-1-height)
	local right = x + width
	local bottom = y + height
	local brushColor = randomColor()

	local ctxt = win.GDIContext;

	ctxt:SetDCBrushColor(brushColor)
	--ctxt:RoundRect(x, y, right, bottom, 0, 0)
	ctxt:Rectangle(x, y, right, bottom)
end


function ontick(win, tickCount)

	for i=1,30 do
		randomrect(win)
		randomline(win)
	end

	local stats = string.format("Seconds: %f  Frame: %d  FPS: %f", sw:Seconds(), tickCount, tickCount/sw:Seconds())
	win.GDIContext:Text(stats)
end



local appwin = GameWindow({
		Title = "Game Window",
		KeyboardInteractor = keyboardinteraction,
		MouseInteractor = mouseinteraction,
		FrameRate = 24,
		OnTickDelegate = ontick,
		Extent = {1024,768},
		})


appwin:run()

