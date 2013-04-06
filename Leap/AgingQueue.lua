local Collections = require("Collections");

local AgingQueue_t = {}
local AgingQueue_mt = {
	__index = AgingQueue_t;
}

AgingQueue_t.new = function(capacity)
	capacity = capacity or 100;

	local obj = {
		queue = Collections.Queue.new();
		Capacity = capacity;
	}

	setmetatable(obj, AgingQueue_mt);

	return obj
end

AgingQueue_t.Enqueue = function(self, item)
	while self.queue:Len() >= self.Capacity do
		self.queue:Dequeue();
	end

	return self.queue:Enqueue(item);
end

AgingQueue_t.Dequeue = function(self)
	return self.queue:Dequeue();
end

AgingQueue_t.Entries = function(self, func, param)
	return self.queue:Entries(func, param);
end

return AgingQueue_t.new;
