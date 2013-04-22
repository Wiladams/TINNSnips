
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

local SecurityInterface = require("SecurityInterface");
local SecError = require("SecError");
local schannel = require("schannel");


-- List of schannel protocols.  
-- Used wit GetSupportedProtocols()
local Protocols = {
[0x00000000]={"SP_PROT_NONE"},        
[0xffffffff]={"SP_PROT_ALL"},                 

[0x00000001]={"SP_PROT_PCT1_SERVER"},          
[0x00000002]={"SP_PROT_PCT1_CLIENT"},          

[0x00000004]={"SP_PROT_SSL2_SERVER"},          
[0x00000008]={"SP_PROT_SSL2_CLIENT"},          

[0x00000010]={"SP_PROT_SSL3_SERVER"},          
[0x00000020]={"SP_PROT_SSL3_CLIENT"},          

[0x00000040]={"SP_PROT_TLS1_SERVER"},          
[0x00000080]={"SP_PROT_TLS1_CLIENT"},           


[0x40000000]={"SP_PROT_UNI_SERVER"},           
[0x80000000]={"SP_PROT_UNI_CLIENT"},              


[0x00000100]={"SP_PROT_TLS1_1_SERVER"},        
[0x00000200]={"SP_PROT_TLS1_1_CLIENT"},        

[0x00000400]={"SP_PROT_TLS1_2_SERVER"},         
[0x00000800]={"SP_PROT_TLS1_2_CLIENT"},           
}


CredHandle = ffi.typeof("CredHandle");
CredHandle_t = {}
CredHandle_mt = {
	__gc = function(self)
		--print("GC: CredHandle");
		SecurityInterface.FreeCredentialHandle(self);
	end,

	__index = CredHandle_t;
}
ffi.metatype(CredHandle, CredHandle_mt);

CredHandle_t.GetAttribute = function(self, which, pBuffer)
	local res = SecurityInterface.QueryCredentialsAttributesA(self, which, pBuffer);

	if res ~= SEC_E_OK then
		return false, res;
	end

	return pBuffer;
end

CredHandle_t.GetUserName = function(self)
	local pBuffer = ffi.new("SecPkgCredentials_NamesA");

	local res, err = self:GetAttribute(ffi.C.SECPKG_CRED_ATTR_NAMES, pBuffer);

	if not res then
		return false, err;
	end

	return ffi.string(pBuffer.sUserName);
end

CredHandle_t.GetSupportedAlgorithms = function(self)
	local pBuffer = ffi.new("SecPkgCred_SupportedAlgs");

	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_ALGS, pBuffer);

	if not res then
		return false, err;
	end

	local res = {}
	for i=0,pBuffer.cSupportedAlgs do
		table.insert(res, pBuffer.palgSupportedAlgs[i]);
	end

	return res;
end

CredHandle_t.GetCipherStrengths = function(self)
	local pBuffer = ffi.new("SecPkgCred_CipherStrengths");

	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_CIPHER_STRENGTHS, pBuffer);

	if not res then
		return false, err;
	end

	return pBuffer.dwMinimumCipherStrength, pBuffer.dwMaximumCipherStrength;
end



CredHandle_t.SupportsProtocol = function(self, which)
	local pBuffer = ffi.new("SecPkgCred_SupportedProtocols");
	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_PROTOCOLS, pBuffer);

	if not res then
		return false, err;
	end

	return band(pBuffer.grbitProtocol, which) > 0;
end

local ListProtocols = function(protobits)
	local res = {};
	for i=0,31 do
		local bitval = math.pow(2,i);
		if band(bitval, protobits) > 0 then
			local proto = Protocols[bitval][1];
			table.insert(res, proto);
		end
	end
	return table.concat(res, '\n');
end


CredHandle_t.ListSupportedProtocols = function(self)
	local pBuffer = ffi.new("SecPkgCred_SupportedProtocols");
	local res, err = self:GetAttribute(ffi.C.SECPKG_ATTR_SUPPORTED_PROTOCOLS, pBuffer);

	if not res then
		return false, err;
	end
	
	return ListProtocols(pBuffer.grbitProtocol);
end

CredHandle_t.InitializeSecurityContext = function(self, phContext,pszTargetName, fContextReq)
--print("InitializeSecurityContext : ", phContext, pszTargetName, fContextReq);

	fContextReq = fContextReq or 0;
	local Reserved1 = 0;							-- Reserved, MUST be 0
	local TargetDataRep = 0;						-- for schannel, MUST be 0

	local TCP_SSL_REQUEST_CONTEXT_FLAGS =bor(
		ffi.C.ISC_REQ_ALLOCATE_MEMORY,
		ffi.C.ISC_REQ_CONFIDENTIALITY,
		ffi.C.ISC_RET_EXTENDED_ERROR,
		ffi.C.ISC_REQ_REPLAY_DETECT,
		ffi.C.ISC_REQ_SEQUENCE_DETECT,
		ffi.C.ISC_REQ_STREAM);

	--local pInput = ffi.new("PSecBufferDesc[1]");
	local pInput = ffi.new("SecBufferDesc");
	local Reserved2 = 0								-- Reserved, MUST be 0
	--local phNewContext = ffi.new("PCtxtHandle[1]");
	local phNewContext = ffi.new("CtxtHandle");
	local pfContextAttr = ffi.new("ULONG[1]");
	local ptsExpiry = nil;

	local sendBuffer = ffi.new("SecBuffer");
	sendBuffer.cbBuffer = 0;
	sendBuffer.pvBuffer = nil;
	sendBuffer.BufferType = ffi.C.SECBUFFER_TOKEN;

	local pOutput = ffi.new("SecBufferDesc");
	local outBufferDesc = ffi.new("SecBufferDesc");
	outBufferDesc.cBuffers = 1;
	outBufferDesc.pBuffers = sendBuffer;
	outBufferDesc.ulVersion = ffi.C.SECBUFFER_VERSION;

	local res = SecurityInterface.InitializeSecurityContextA(
		self,
		phContext,                 			-- must be NULL on first call. 
		ffi.cast("char *",pszTargetName),
		TCP_SSL_REQUEST_CONTEXT_FLAGS,
		0,                    				-- must be 0. 
		ffi.C.SECURITY_NATIVE_DREP, 		-- must be 0 on msdn, but ... 
		nil,                 				-- must be NULL on first call. 
		0,                    				-- must be 0. 
		phNewContext,
		outBufferDesc,
		pfContextAttr,
		nil);


	-- parse the result to see what we got
	local severity, facility, code = HRESULT_PARTS(res);

print(string.format("InitializeSecurityContextA: 0x%x, 0x%x, 0x%x", severity, facility, code));

	if severity ~= 0 then
		return false, code;
	end

	return phNewContext, code;
end


return CredHandle;
