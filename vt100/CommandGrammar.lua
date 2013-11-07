-- commands.lua
--
-- References
-- http://ascii-table.com/ansi-escape-sequences-vt-100.php
-- http://www.termsys.demon.co.uk/vtansi.htm
-- http://vt100.net/docs/vt100-ug/chapter3.html
--


local chars = require("chars")

local m=require("lpeg")
local P = m.P
local R = m.R
local S = m.S
local C = m.C
local Cf = m.Cf
local Ct = m.Ct
local Cp = m.Cp
local match = m.match


local ESC 		= P(chars.C_ESC);
local LBRACKET 	= P'[';
local LPAREN 	= P'(';
local RPAREN	= P')';
local LCURLY 	= P'{';
local RCURLY 	= P'}';
local SEMI 		= P';';
local DQUOTE	= P'"';
local DIGIT 	= R("09");

local CMD = ESC+LBRACKET;
local DECIMAL = DIGIT^1;




-- Device Status
QueryDeviceCode		= CMD + P'c';
ReportDeviceCode	= CMD + DECIMAL + P"0c";

QueryDeviceStatus	= CMD + P"5n";
ReportDeviceOK		= CMD + P"0n";
ReportDeviceFailure	= CMD + P"3n";

QueryCursorPosition		= CMD + P"6n";
ReportCursorPosition	= CMD + DECIMAL + SEMI + DECIMAL;

-- Terminal Setup
ResetDevice 		= CMD + P'c';
EnableLineWrap 		= CMD + P"7h";
DisableLineWrap 	= CMD + P"7l";

-- Fonts
FontSetG0			= ESC + LPAREN;
FontSetG1 			= ESC + RPAREN;


-- Cursor Control
CursorHome 			= CMD +DECIMAL+SEMI+DECIMAL+P'H';
CursorUp			= CMD +DECIMAL+P'A';
CursorDown			= CMD +DECIMAL+P'B';
CursorForward		= CMD +DECIMAL+P'C';
CursorBackward		= CMD +DECIMAL+P'D';
ForceCursorPosition = CMD +DECIMAL+SEMI+DECIMAL+P'f';
SaveCursor 			= CMD +P's';
UnsaveCursor		= CMD +P'u';
SaveCursorAndAttrs  = CMD +P'7';
RestoreCursorAndAttrs = CMD + P'8';

-- Scrolling
EnableScrollScreen	= CMD+P'r';								-- Enable Scrolling for entire display
EnableScrollPortion = CMD+DECIMAL+SEMI+DECIMAL+P'r';		-- Enable Scrolling a portion
ScrollDown			= ESC+P'D';								-- Scroll display down one line
ScrollUp			= ESC+P'M';								-- Scroll display up one line

-- Tab Control
SetTab				= ESC+P'H';								-- Set a tab at the current position
ClearTab			= CMD+P'g';								-- Clear tab at the current position
ClearAllTabs		= CMD+P"3g";							-- Clear all tabs

-- Erasing Text
EraseEndOfLine 		= CMD+P"K";								-- Erases from the current cursor position to the end of the current line.
EraseStartOfLine 	= CMD+"1K";								-- Erases from the current cursor position to the start of the current line.
EraseLine 			= CMD+P"2K";							-- Erases the entire current line.
EraseDown 			= CMD+P"J";								-- Erases the screen from the current line down to the bottom of the screen.
EraseUp 			= CMD+P"1J";							-- Erases the screen from the current line up to the top of the screen.
EraseScreen 		= CMD+P"2J";							-- Erases the screen with the background colour and moves the cursor to home.

-- Printing
PrintScreen 		= CMD+P'i';								-- Print the current screen.
PrintLine 			= CMD+P"1i";							-- Print the current line.
StopPrintLog 		= CMD+P"4i";							-- Disable log.
StartPrintLog 		= CMD+P"5i";							-- Start log; all received text is echoed to a printer.

-- Define Key
SetKeyDefinition	= CMD+DECIMAL+DQUOT+STRING+DQUOT+P'p';

-- Set Display Attributes
SetAttributeMode = CMD +[DECIMAL]^1+m;




