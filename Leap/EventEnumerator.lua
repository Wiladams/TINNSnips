local Collections = require("Collections");

local EventEnumerator = function(frameemitter, filterfunc, param)
	local eventqueue = Collections.Queue.new();

	local addevent = function(event)
		if filterfunc then
			local newevent = filterfunc(param, event)
			if newevent then
				eventqueue:Enqueue(newevent);
			end
		else
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

			if frame.hands ~= nil then
				for _,hand in ipairs(frame.hands) do
					addevent(hand);
				end
			end

			if frame.pointables ~= nil then
				for _,pointable in ipairs(frame.pointables) do
					addevent(pointable);
				end
			end

			if frame.gestures then
				for _,gesture in ipairs(frame.gestures) do
					addevent(gesture);
				end
			end		
			
			yield();				
		end

		return eventqueue:Dequeue();
	end	

	return closure;
end

return EventEnumerator