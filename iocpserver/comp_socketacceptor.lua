-- comp_socketacceptor.lua

gIdleTimeout = 50;

local listener, err = IOProcessor:createServerSocket({port=8080});

if not listener then
	print("Error creating listener: ", err);
	return false, err;
end

print("Listener: ", listener:getNativeSocket(), err);

local currentAccepting = false;

AcceptOne = function()
	print("== AcceptOne ==");

	currentlyAccepting = true;
	local accepted, err = listener:accept();
	if outputQueue then
		print("Stuffinng IOCP: ", accepted);
		outputQueue:enqueue(accepted);
	end
	currentlyAccepting = false;
end

OnIdle = function(counter)
	if not currentlyAccepting then
		spawn(AcceptOne);
	end
end
