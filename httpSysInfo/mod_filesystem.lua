function handleDirectory( request, response )

    local a = FileSystemItem(request.Url.path);

    local headers = {
        ["Server"] = "http-server",
        ["Content-Type"] = "text/html",
        ["Connection"] = "close",
    };

    response:writeHead("200", headers);

    local body = {};
    table.insert(body, "<html><head><title>Files in " .. request.Url.path .. "</title></head>");
    table.insert(body, "<body><h2>Files in " .. request.Url.path .. "</h2>\n");
    table.insert(body, "<ul>\n");

    for item in a:items() do
         if ( socket.is_dir( path .. "/" .. item ) ) then
            item = item .. "/";
         end
        table.insert(body, "<li><a href=\"" .. item .. "\">" .. item .. "</a></li>\n");
    end

    table.insert(body, "</ul></body></html>\n");
    local stuffit = table.concat(body);
    return response:writeEnd(stuffit);
end
