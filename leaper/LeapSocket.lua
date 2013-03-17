
--[[
	You can talk to the Leap through a WebSocket connecting
	on port 6437
--]]

local Scheduler = require("EventScheduler");


local sched = Scheduler();
Runtime={}
Runtime.Scheduler = sched;


local WebSocket = require("WebSocketStream");



local onconnected = function(wsock, err)
	print("ON CONNECTED: ", wsock, err);


	if not wsock then
		return false, err
	end

print("WSOCK Status: ", wsock.Status);
print("Is Connected: ", wsock.SourceStream:IsConnected())
	repeat
		local frame, err = wsock:ReadFrame();
		print("Frame: ", frame, err)
	until true

	sched:Stop();
end

local Connect = function(url, onconnected)
	local leapsock = WebSocket()

	local success, err = leapsock:Connect(url, onconnected);
end


sched:Spawn(Connect, "ws://192.168.1.34:6437", onconnected)

sched:Start();
