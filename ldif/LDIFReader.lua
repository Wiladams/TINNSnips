-- LDIFReader.lua

local base64 = require("base64");
local utils = require("utils");
local lpeg = require("lpeg");

-- lpeg patterns
local match = lpeg.match;
local C = lpeg.C;
local P = lpeg.P;
local R = lpeg.R;

local SPACE = P' ';
local FILL = SPACE^1;
local SEP = CRLF + LF;
local CR = P'\r';
local LF = P'\n';
local CRLF = P'\r\n';

local upalpha 			= R("AZ")
local lowalpha 			= R("az")
local ALPHA 			= lowalpha + upalpha;
local DIGIT 			= R("09")

--[[
local space = lpeg.S' \t\n\v\f\r'
local nospace = 1 - space
local ptrim = space^0 * lpeg.C((space^0 * nospace^1)^0)

local trim = function(s)
	return match(ptrim, s);
end
--]]

local ldif_attrval_record      = dn_spec * SEP * attrval_spec^1;


local LDIFReader = {}
setmetatable(LDIFReader, {
	__call = function(self, ...)
		return self:init(...);
	end,
});

local LDIFReader_mt = {
	__index = LDIFReader,
}

-- Source must be a stream
LDIFReader.init = function(self, Source)
	local obj = {
		Source = Source,
	};
	setmetatable(obj, LDIFReader_mt);

	-- read the first line to see if we 
	-- have a version: line
	-- really, read lines until we see 'version:' or
	-- eof, with intervening comments
	-- local line, err = self.Source:ReadLine();

	return obj;
end

LDIFReader.reset = function(self)
	self.Version = nil;
	if self.Source then
		self.Source:Seek(0);
	end

	return self;
end

LDIFReader.readEntry = function(self)
	--local firstline = self.Source:ReadLine();
	--print(firstline);
	
	local res = {};
	local count = 0;

	while true do
		local line, err = self.Source:ReadLine();
		
		-- we've come to a blank line or end of file
		-- so break out of loop
		if not line or line == '' then
			break;
		end


		if not self.FirstLine then
			self.FirstLine = line;
			-- should be 'version: 1'
			vinfo = utils.split(line, ':');
			if vinfo[1] == "version" then
				self.Version = tonumber(vinfo[2]);
			end
		else
			local attr = utils.split(line, ':');
			local name = attr[1];
			local value = attr[2];
			if name ~= nil and value ~= nil then
				count = count + 1;
				if not res[name] then
					res[name] = value;
				else
					if type(res[name]) == "string" then
						local oldvalue = res[name];
						res[name] =  {};
						table.insert(res[name], oldvalue);
					end

					table.insert(res[name], value);
				end
			end
		end
	end

	if count == 0 then
		return nil;
	end

	return res;
end

LDIFReader.entries = function(self)

	local closure = function()
		local attr = self:readEntry();
		return attr;
	end

	return closure;
end

return LDIFReader;
