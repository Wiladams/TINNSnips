-- /files
local FileSystem = require("FileSystem");
local wfs = FileSystem("c:");
local FileService = require("FileService");
local URL = require("url")


local AceTemplate = [[
<!DOCTYPE html>
<html lang="en">
<head>
<title>ACE in Action</title>
<style type="text/css" media="screen">
    #editor { 
        position: absolute;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
    }
</style>
</head>
<body>

<div id="editor">
<?editorcontent?>
</div>
    
<script src="/acebuilds/srcnoconflict/ace.js" type="text/javascript" charset="utf-8"></script>
<script>
    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/monokai");
    editor.getSession().setMode("ace/mode/<?language?>");
</script>
</body>
</html>
]]

local function replacedotdot(s)
    return string.gsub(s, "%.%.", '%.')
end


local entities =
{
--  ['&'] = "&amp;",
    ['<'] = "&lt;",
    ['>'] = "&gt;",
    -- French entities (the most common ones)
    ['à'] = "&agrave;",
    ['â'] = "&acirc;",
    ['é'] = "&eacute;",
    ['è'] = "&egrave;",
    ['ê'] = "&ecirc;",
    ['ë'] = "&euml;",
    ['î'] = "&icirc;",
    ['ï'] = "&iuml;",
    ['ô'] = "&ocirc;",
    ['ö'] = "&ouml;",
    ['ù'] = "&ugrave;",
    ['û'] = "&ucirc;",
    ['ÿ'] = "&yuml;",
    ['À'] = "&Agrave;",
    ['Â'] = "&Acirc;",
    ['É'] = "&Eacute;",
    ['È'] = "&Egrave;",
    ['Ê'] = "&Ecirc;",
    ['Ë'] = "&Euml;",
    ['Î'] = "&Icirc;",
    ['Ï'] = "&Iuml;",
    ['Ô'] = "&Ocirc;",
    ['Ö'] = "&Ouml;",
    ['Ù'] = "&Ugrave;",
    ['Û'] = "&Ucirc;",
    ['ç'] = "&ccedil;",
    ['Ç'] = "&Ccedil;",
    ['Ÿ'] = "&Yuml;",
    ['«'] = "&laquo;",
    ['»'] = "&raquo;",
    ['©'] = "&copy;",
    ['®'] = "&reg;",
    ['æ'] = "&aelig;",
    ['Æ'] = "&AElig;",
    ['Œ'] = "&OElig;", -- Not understood by all browsers
    ['œ'] = "&oelig;", -- Not understood by all browsers
}

-- encode html entities
function EncodeEntities(string)
    if string == nil or type(string) ~= "string" then
        return ''
    end

    local EncodeHighAscii = function (char)
        local code = string.byte(char)
        if code > 127 then
            return string.format("&#%d;", code)
        else
            return char
        end
    end

    local encodedString = string
    -- First encode '&' char, to avoid re-encoding already encoded chars
    encodedString = string.gsub(encodedString, '&', "&amp;")
    -- Encode known entities
    for char, entity in pairs(entities) do
        encodedString = string.gsub(encodedString, char, entity)
    end
    encodedString = string.gsub(encodedString, '(.)', EncodeHighAscii)
    return encodedString
end






-- for certain file types, 
-- we want to present an editor
-- application/javascript
-- 

local languageStyles = {
    ["application/javascript"] = "javascript",
    ["application/x-lua"]       = "lua",    
    ["text/x-c"]                = "c/c++",
}

local sendAFile = function(relativePath, response)
    local resourceBody, mimetype = FileService.loadResource(relativePath);

    -- No body, return an error
    if not resourceBody then
print("NO RESPONSE BODY: ", relativePath, mimetype)
        -- send back an error response
        local respHeader = {
            ["Connection"] = "Keep-Alive",
            ["Content-Length"]="0",
        };
        response:writeHead("404", respHeader);
        response:writeEnd();
        return false
    end


    if languageStyles[mimetype] then
         local subs = {
            ["editorcontent"]     = EncodeEntities(resourceBody),
            ["language"]          = languageStyles[mimetype],
        }

        local editableBody = string.gsub(AceTemplate, "%<%?(%a+)%?%>", subs)
        local headers = {
            ["Content-Type"] = "text/html";
        }
        response:writeHead(200, headers);
        response:writeEnd(editableBody);

    else
        local headers = {
            --["Connection"] = "Keep-Alive",
            ["Content-Type"] = mimetype;
        }

        response:writeHead(200, headers);
        response:writeEnd(resourceBody);
    end
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
            return false;
		end

		-- if it's a file, then return the file using
		-- the static handler
		if not fsItem:isDirectory() then
            sendAFile(relativePath, response)
            return false;
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

end

return {
    HandleFilesGET = HandleFilesGET,
}