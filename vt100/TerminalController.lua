-- TermimalController.lua


--[[
	The TerminalController manages the communications channels, and is ultimately
	responsible for calling functions on the TerminalDevice.

	The controller has multiple channels for input, output, and printer
	It receives a stream of data on the input channel
	It will decode commands if they are specified, otherwise it will 
	pass the content through to the TerminalDevice to be displayed.

	This separation allows the TerminalDevice to be an independent character
	buffer manager, without having to know how to parse the various commands.
--]]