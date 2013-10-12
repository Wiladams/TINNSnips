local URL = require("url");
local FileService = require("FileService");
local DigestAuthenticator = require("DigestAuthenticator") 

local authenticator = DigestAuthenticator({Realm = "users@Contoso.com"})

local function replacedotdot(s)
    return string.gsub(s, "%.%.", '%.')
end

local HandleFileGET = function(request, response)
    local absolutePath = replacedotdot(URL.unescape(request.Url.path));

	local filename = './wwwroot'..absolutePath;
	
	FileService.SendFile(filename, response)

	return false;
end

local HandleProtectedGET = function(request, response)
	-- look for the authorization header
	local authorization = request:GetHeader("Authorization")
	
	-- If we don't see the authorization header, 
	-- then send back a 401, with an authorization challenge
	if not authorization then
		authenticator:issueServerChallenge(request, response)
		return false;
	end

-- There is an authorization header
-- so print out headers
	print("REQUEST HEADERS")
	for k,v in pairs(request.Headers) do
		print(k,v)
	end

    local absolutePath = replacedotdot(URL.unescape(request.Url.path));

	local filename = './wwwroot'..absolutePath;
	
	FileService.SendFile(filename, response)

end


return {
	HandleFileGET = HandleFileGET,
	HandleProtectedGET = HandleProtectedGET,
}