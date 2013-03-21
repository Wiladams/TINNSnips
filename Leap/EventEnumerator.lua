local Collections = require("Collections");

printDict = function(dict)
	for k,v in pairs(dict) do
		print(k,v);
	end
end


local EventEnumerator = function(frameemitter, filterfunc)
	local eventqueue = Collections.Queue.new();

	local addevent = function(event)
		if filterfunc then
			if filterfunc(event) then
				eventqueue:Enqueue(event);
			end
		else
			print("FORCE ADD")
			eventqueue:Enqueue(event);
		end
	end


	local closure = function()
		-- If the event queue is empty, then grab the
		-- next frame from the emitter, and turn it into
		-- discreet events.
		while eventqueue:Len() < 1 do
			local frame = frameemitter();
			if frame == nil then
				return nil
			end

--print("===== frame ========")
--printDict(frame);

			-- turn a frame into separable events
			-- Hands
			if frame.hands ~= nil then
				for _,hand in ipairs(frame.hands) do
					addevent(hand);
				end
			end

			-- Pointables
			if frame.pointables ~= nil then
				for _,pointable in ipairs(frame.pointables) do
					addevent(pointable);
				end
			end

			-- Gestures
			if frame.gestures then
				for _,gesture in ipairs(frame.gestures) do
					addevent(gesture);
				end
			end						
		end

			return eventqueue:Dequeue();
	end	

	return closure;
end

return EventEnumerator