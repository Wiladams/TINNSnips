local DigestAuthenticator = require("DigestAuthenticator") 

local authenticator = DigestAuthenticator({Realm = "users@Contoso.com"})


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

	return HandleFileGET(request, response)
end

return HandleProtectedGET
