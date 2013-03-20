--[[
	The purpose of this snippet is to create a mapping between 
	the movement of a tool around the screen, and the corresponding
	mouse positions.

	The app will position a white square in the four corners of the 
	screen, and you will point a tool at the square.  After this 
	brief training period, a file: sensor.cfg is generated.  This contains
	the information required by the mousetrack.lua snippet.
--]]

--package.path = package.path.."../../?.lua"
package.path = package.path.."../?.lua"

local LeapScape = require ("LeapScape");
local FrameObserver = require("FrameObserver");
local UIOSimulator = require("UIOSimulator");
local StopWatch = require("StopWatch");
local GDI32 = require ("GDI32");
local FileStream = require("FileStream");


--[[
	Map a value from one range to another
--]]
local mapit = function(x, minx, maxx, rangemin, rangemax)
--	print(string.format("MAP: %3.2f  %3.2f  %3.2f  %3.2f  %3.2f", x, minx, maxx, rangemin, rangemax));
	return rangemin + (((x - minx)/(maxx - minx)) * (rangemax - rangemin))
end

--[[
	Clamp a value to a range
--]]
local clampit = function(x, minx, maxx)
	if x < minx then return minx end
	if x > maxx then return maxx end

	return x
end


local main = function()
	local scape, err = LeapScape();

	if not scape then 
		print("No LeapScape: ", err)
		return false
	end

	local fo = FrameObserver(scape);

	local sensemin = {math.huge, math.huge, math.huge}
	local sensemax = {-math.huge, -math.huge, -math.huge}

	-- We'll use this to do some drawing on the screen
	local hdcScreen = GDI32.CreateDCForDefaultDisplay();


	local busywait = function(millis)
		sw = StopWatch.new();

		while true do
			if sw:Milliseconds() > millis then
				break
			end
			coroutine.yield();
		end
	end

	local drawTarget = function(originx, originy, width, height)
		local brushColor = RGB(255,0,0);

		x = originx - width/2;
		y = originy - height/2;

		x = clampit(x, 0, UIOSimulator.ScreenWidth-1 - width);
		y = clampit(y, 0, UIOSimulator.ScreenHeight-1 - height);

		local right = x + width
		local bottom = y + height
--print(x,y,width,height)
		hdcScreen:SetDCBrushColor(brushColor)
		hdcScreen:RoundRect(x, y, right, bottom, 4, 4)
	end

	local observerange = function(param, event)
		local newvalue = false

		local tp = event.tipPosition;

		sensemin[1] = math.min(tp[1], sensemin[1])
		sensemin[2] = math.min(tp[2], sensemin[2])
		sensemin[3] = math.min(tp[3], sensemin[3])

		sensemax[1] = math.max(tp[1], sensemax[1])
		sensemax[2] = math.max(tp[2], sensemax[2])
		sensemax[3] = math.max(tp[3], sensemax[3])
	end

	local dwellAtPosition = function(x, y)
		drawTarget(x,y, 32,32);
		busywait(500);
		fo:AddPointerObserver(observerange, nil)
		busywait(1000);
		fo:RemovePointerObserver(observerange, nil)
	end

	local matchTargets = function()
		-- Move Mouse to lower left
		dwellAtPosition(0, UIOSimulator.ScreenHeight-1);

		-- Move Mouse to upper left
		dwellAtPosition(0, 0);

		-- Move Mouse to upper right
		dwellAtPosition(UIOSimulator.ScreenWidth-1, 0);

		-- Move Mouse to lower right
		dwellAtPosition(UIOSimulator.ScreenWidth-1, UIOSimulator.ScreenHeight-1);
	end

	local writeConfig = function()
		fs = FileStream.Open("sensor.cfg");

		local output = {
			string.format("do return {");
			string.format("sensemin = {%3.2f, %3.2f, %3.2f};", sensemin[1], sensemin[2], sensemin[3]);
			string.format("sensemax={%3.2f, %3.2f, %3.2f};", sensemax[1], sensemax[2], sensemax[3]);
			string.format("} end");
		}
		output = table.concat(output,"\n");
		fs:WriteString(output);
		fs:Close();

		print(output);

		--local config = loadstring(output)();
		--print("Config: ", config);
		--print("sensemin: ", config.sensemin[1], config.sensemin[2], config.sensemin[3]);
		--print("sensemax: ", config.sensemax[1], config.sensemax[2], config.sensemax[3]);
	end

	-- Start the LeapScape running
	scape:Start();

	matchTargets();

	-- After training, write out configuration
	writeConfig();

	stop();
end


run(main);
