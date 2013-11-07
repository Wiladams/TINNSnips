-- TerminalDevice.lua
--
-- References
-- http://ascii-table.com/ansi-escape-sequences-vt-100.php
--

--[[
	Implement the actual behavior of the terminal
	Maintain terminal device state information
--]]


-- Some constants for setting attributes
local DisplayAttributes = {
	ResetAll 	= 0x00;
	Bright 		= 0x01;
	Dim 		= 0x02;
	Underscore 	= 0x04;
	Blink 		= 0x05;
	Reverse 	= 0x07;
	Hidden 		= 0x08;
}

local FGColors = {
	Black 	= 30;
	Red 	= 31;
	Green 	= 32;
	Yellow 	= 33;
	Blue 	= 34;
	Magenta = 35;
	Cyan 	= 36;
	White 	= 37;
}

local BGColors = {
	Black = 40;
	Red = 41;
	Green = 42;
	Yellow = 43;
	Blue = 44;
	Magenta = 45;
	Cyan = 46;
	White = 47;
}


local TerminalDevice = {}
setmetatable(TerminalDevice, {
	__call = function(self, ...)
		return self:create(...)
	end,
})
local TerminalDevice_mt = {
	__index = TerminalDevice,
}


TerminalDevice.init = function(self, ...)
	local obj = {
		ScreenDimension = {80,24};
		ScreenFrame = {0,0,80,24}
		Origin = {0,0};
		
		CursorPosition = {0,0};
		
		-- character attributes
		DisplayAttributes = DisplayAttributes.ResetAll;
		BackgroundColor = BGColors.Black;
		ForegroundColor = FGColors.White;
		
		-- editing attributes
		LineWrap = false;

	}
	setmetatable(obj, TerminalDevice_mt);

	return obj;
end

TerminalDevice.create = function(self, ...)
	return self:init(...);
end


-- Device Status
TerminalDevice.getDeviceCode = function(self)
--QueryDeviceCode		= CMD + P'c';
--ReportDeviceCode	= CMD + DECIMAL + P"0c";
end

TerminalDevice.getDeviceStatus = function(self)
--QueryDeviceStatus	= CMD + P"5n";
--ReportDeviceOK		= CMD + P"0n";
--ReportDeviceFailure	= CMD + P"3n";
end

TerminalDevice.getCursorPosition = function(self)
-- QueryCursorPosition		= CMD + P"6n";
-- ReportCursorPosition	= CMD + DECIMAL + SEMI + DECIMAL;
end

-- Terminal Setup
TerminalDevice.resetDevice = function(self)
-- ResetDevice 		= CMD + P'c';
end

TerminalDevice.enableLineWrap = function(self)
-- EnableLineWrap 		= CMD + P"7h";
end

TerminalDevice.disableLineWrap = function(self)
-- DisableLineWrap 	= CMD + P"7l";
end

-- Fonts
TerminalDevice.setDefaultFont = function(self)
-- FontSetG0			= ESC + LPAREN;
end

TerminalDevice.setAlternateFont = function(self)
-- FontSetG1 			= ESC + RPAREN;
end

-- Cursor Control
TerminalDevice.cursorHome = function(self, x, y)
	x = x or 0;
	y = y or 0;
-- CursorHome 			= CMD +DECIMAL+SEMI+DECIMAL+P'H';
end

TerminalDevice.cursorUp = function(self)
-- CursorUp			= CMD +DECIMAL+P'A';
end

TerminalDevice.cursorDown = function(self)
--CursorDown			= CMD +DECIMAL+P'B';
end

TerminalDevice.cursorForward = function(self)
-- CursorForward		= CMD +DECIMAL+P'C';
end

TerminalDevice.cursorBackward = function(self)
--CursorBackward		= CMD +DECIMAL+P'D';
end

TerminalDevice.setCursorPosition = function(self, x, y)
--ForceCursorPosition = CMD +DECIMAL+SEMI+DECIMAL+P'f';
end

TerminalDevice.saveCursor = function(self)
--SaveCursor 			= CMD +P's';
end

TerminalDevice.unsaveCursor = function(self)
-- UnsaveCursor		= CMD +P'u';
end

TerminalDevice.saveCursorAndAttributes = function(self)
--SaveCursorAndAttrs  = CMD +P'7';
end

TerminalDevice.restoreCursorAndAttributes = function(self)
--RestoreCursorAndAttrs = CMD + P'8';
end


-- Scrolling
TerminalDevice.enableScrollScreen = function(self)
--EnableScrollScreen	= CMD+P'r';								-- Enable Scrolling for entire display
end

TerminalDevice.enableScrollPortion = function(self)
--EnableScrollPortion = CMD+DECIMAL+SEMI+DECIMAL+P'r';		-- Enable Scrolling a portion
end

TerminalDevice.scrollDown = function(self)
--ScrollDown			= ESC+P'D';								-- Scroll display down one line
end

TerminalDevice.scrollUp = function(self)
--ScrollUp			= ESC+P'M';								-- Scroll display up one line
end

-- Tab Control
TerminalDevice.setTab = function(self)
--SetTab				= ESC+P'H';								-- Set a tab at the current position
end

TerminalDevice.clearTab = function(self)
--ClearTab			= CMD+P'g';								-- Clear tab at the current position
end

TerminalDevice.clearAllTabs = function(self)
-- ClearAllTabs		= CMD+P"3g";							-- Clear all tabs
end

-- Erasing Text
TerminalDevice.eraseEndOfLine = function(self)
--EraseEndOfLine 		= CMD+P"K";								-- Erases from the current cursor position to the end of the current line.
end

TerminalDevice.eraseStartOfLine = function(self)
--EraseStartOfLine 	= CMD+"1K";								-- Erases from the current cursor position to the start of the current line.
end

TerminalDevice.eraseLine = function(self)
--EraseLine 			= CMD+P"2K";							-- Erases the entire current line.
end

TerminalDevice.eraseDown = function(self)
--EraseDown 			= CMD+P"J";								-- Erases the screen from the current line down to the bottom of the screen.
end

TerminalDevice.eraseUp = function(self)
--EraseUp 			= CMD+P"1J";							-- Erases the screen from the current line up to the top of the screen.
end

TerminalDevice.eraseScreen = function(self)
--EraseScreen 		= CMD+P"2J";							-- Erases the screen with the background colour and moves the cursor to home.
end

-- Printing
TerminalDevice.printScreen = function(self)
--PrintScreen 		= CMD+P'i';								-- Print the current screen.
end

TerminalDevice.printLine = function(self)
--PrintLine 			= CMD+P"1i";							-- Print the current line.
end

TerminalDevice.stopPrintLog = function(self)
--StopPrintLog 		= CMD+P"4i";							-- Disable log.
end

TerminalDevice.startPrintLog = function(self)
--StartPrintLog 		= CMD+P"5i";							-- Start log; all received text is echoed to a printer.
end


-- Define Key
TerminalDevice.setKeyDefinition = function(self, key, sequence)
--SetKeyDefinition	= CMD+DECIMAL+DQUOT+STRING+DQUOT+P'p';
end


-- Set Display Attributes
TerminalDevice.setAttributeMode = funciton(self, fgcolor, bgcolor, attrib)
	fgcolor = fgcolor or FGColors.White;
	bgcolor = bgcolor or BGColors.Black;
	attrib = attrib or DisplayAttributes.ResetAll;

	self.ForegroundColor = fgcolor;
	self.BackgroundColor = bgcolor;
	self.DisplayAttributes = attrib;

--SetAttributeMode = CMD +[DECIMAL]^1+m;
end




