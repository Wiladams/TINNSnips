-- /files
local FileSystem = require("FileSystem");
local wfs = FileSystem("c:");
local FileService = require("FileService");
local URL = require("url")

local function replacedotdot(s)
    return string.gsub(s, "%.%.", '%.')
end


HandleFilesGET = function(request, response)
print("HandleFilesGET(): ", request.Url.path);
-- Need to URL decode the filename
    local absolutePath = replacedotdot(URL.unescape(request.Url.path));
print("ABS Path: ", absolutePath);

	-- get the relative path
	--local relativePath = request.Url.path:sub(7);
    local relativePath = absolutePath:sub(7);

print("REL PATH: ", relativePath);
	if relativePath ~= '' then
		fsItem = wfs:getItem(relativePath);
		
		if not fsItem then
			response:writeHead(400);
			response:writeEnd();
			return true;		
		end

		-- if it's a file, then return the file using
		-- the static handler
		if not fsItem:isDirectory() then
    		FileService.SendFile(relativePath, response);
    		return recycleRequest(request);
		end
	end

	-- If we've gotten to here, we've got a directory that we 
	-- need to list.
	local searchPath = relativePath.."/*";

print("SEARCH: ", searchPath);


    local headers = {
        ["Server"] = "http-server",
        ["Content-Type"] = "text/html",
--        ["Connection"] = "close",
    };

    response:writeHead("200", headers);

    local body = {};
    table.insert(body, "<html><head><title>Files in " .. relativePath .. "</title></head>");
    table.insert(body, "<body><h2>Files in " .. request.Url.path .. "</h2>\n");
    table.insert(body, "<ul>\n");

    for item in wfs:getItems(searchPath) do
    	-- skip various undesirable files and
    	-- directories
    	if item.Name ~= "." and item.Name ~= ".." and
    		not item:isHidden() and not item:isSystem() then
    		local filepath
    		if relativePath ~= "" then
    			filepath = relativePath..'/'..item.Name;
    		else
    			filepath = '/'..item.Name;
    		end

        	if item:isDirectory() then
        		table.insert(body, [[<li><a href="\files]] .. filepath.. [[">]] .. item.Name .. [[/</a></li>]]);
         	else
        		table.insert(body, [[<li><a href="\files]] .. filepath.. [[">]] .. item.Name .. [[</a></li>]]);
    		end
    	end
    end

    table.insert(body, "</ul></body></html>\n");
    local stuffit = table.concat(body);
    response:writeEnd(stuffit);

    return recycleRequest(request);
end

return {
    HandleFilesGET = HandleFilesGET,
}