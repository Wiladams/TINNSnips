-- comp_socketacceptor.lua

local IOCPSocket = require("IOCPSocket");

--gIdleTimeout = 50;

local listener, err = IOProcessor:createServerSocket({port=8080});

if not listener then
	print("Error creating listener: ", err);
	exit(err);
end

print("Listener: ", listener:getNativeSocket(), err);

PostAccept = function()
	--print("== AcceptOne ==");
	while true do
		local accepted, err = listener:accept();
		
		print("ACCEPTED: ", accepted, err);

		if outputQueue then
			print("Stuffinng IOCP: ", accepted);
			outputQueue:enqueue(accepted);
		end
	end
end

spawn(PostAccept);
