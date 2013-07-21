var Debugger = function () { };
Debugger.log = function (message) {
	try {
		console.log(message);
	} catch (exception) {
		return;
	}
}
