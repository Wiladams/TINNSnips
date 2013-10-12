local ffi = require("ffi")
local CryptUtils = require("BCryptUtils")
local stringz = require("stringzutils")



local noncefunc = function(nbytes)
	nbytes = nbytes or 16
	return stringz.bintohex(ffi.string(CryptUtils.GetRandomBytes(nbytes),nbytes));
end

local DigestAuthenticator = {}
setmetatable(DigestAuthenticator, {
	__call = function (self, ...)
		return self:create(...)
	end,
})

DigestAuthenticator_mt = {
	__index = DigestAuthenticator,
}

DigestAuthenticator.init = function(self, params)
	local obj = {
		qop = params.qop or "auth, auth-int",
		Realm = params.Realm or "user@domain",
		CredentialSource = params.CredentialSource or {},
	}
	setmetatable(obj, DigestAuthenticator_mt)

	return obj
end

DigestAuthenticator.create = function(self, ...)
	return self:init(...)
end

DigestAuthenticator.issueServerChallenge = function(self, request, response)
	local nonce = noncefunc(16);
	local opaque = "this is opaque"

	print("DigestAuthenticator, NONCE: ", nonce)
	local headers = {
		["Content-Type"] = "text/html",
		["WWW-Authenticate"] = [[Digest realm="]]..self.Realm..[[",
			qop="]]..self.qop..[[",
			nonce = "]]..nonce..[[",
			opaque = "]]..opaque..[["
		]]
	}
	
	local body = [[
<html>
	<head>
		<title>Error</title>
		<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
	</head>
	<body><h1>401 Unauthorized.</h1></body>
</html>
]]

	response:writeHead(401, headers)
	response:writeEnd(body);

	return false;
end

-- Given an authorization header
-- decode the parts
-- and check to see if the credentials match our conception 
-- of valid credentials
DigestAuthenticator.validateCredentials = function(self, authorization)
	
end

return DigestAuthenticator
