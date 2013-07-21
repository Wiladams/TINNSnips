//***** object prototypes *****

//*** consoleLog util object
//creat constructor
function ConsoleLog(){
	
}

//create function that will be added to the class
console_log=function(message) {
	if(typeof(console) !== 'undefined' && console != null) {
		console.log(message);
	}
}
//add class/static function to class by assignment
ConsoleLog.log=console_log;

//*** end console log object