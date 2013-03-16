
local Scheduler = require("EventScheduler");
local REST = require("http_rest");



local GET = function(url, showheaders)
	showheaders = showheaders or false

	local sched = Scheduler();
	Runtime={}
	Runtime.Scheduler = sched;

	onfinish = function(result)
		--print("\nonfinish RESULT: ", result)
		sched:Stop();
	end

	sched:Spawn(REST.GET, url, showheaders, onfinish);

	sched:Start();
end

GET(arg[1], arg[2]);

