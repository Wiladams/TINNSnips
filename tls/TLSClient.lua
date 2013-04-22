-- TLSClient.lua

local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;
local band = bit.band;

--1.0 Initialize Windows Sockets
local SocketUtils = require("SocketUtils");
local sspi = require("sspi");

--2.0 Initialize Security Interface
local SecurityInterface = sspi.SecurityInterface;
local SecurityPackage = sspi.SecurityPackage;

function ConnectToServer(serverName, serverPort)
	serverName = serverName or "localhost";
	serverPort = serverPort or 443;

	local sock, err = SocketUtils.CreateTcpClientSocket(serverName, serverPort);
	if not sock then
		return false, err
	end

	return sock;
end

function CreateCreds()
	local package, err = SecurityPackage:FindPackage(sspi.schannel.UNISP_NAME);
	
	local authData = ffi.new("SCHANNEL_CRED");

	authData.dwVersion = ffi.C.SCHANNEL_CRED_VERSION;
	authData.grbitEnabledProtocols = ffi.C.SP_PROT_TLS1_CLIENT;
	authData.dwFlags = bor(ffi.C.SCH_CRED_AUTO_CRED_VALIDATION, ffi.C.SCH_CRED_USE_DEFAULT_CREDS);

	local creds, err = package:CreateCredentials(ffi.C.SECPKG_CRED_OUTBOUND, authData);

	return creds;
end


local IO_BUFFER_SIZE = 10000;

local function ClientHandshakeLoop(Socket, phCreds, phContext, fDoInitialRead, pExtraData)


	local OutBuffer = ffi.new("SecBufferDesc"); 
	local InBuffer = ffi.new("SecBufferDesc");
    local InBuffers = ffi.new("SecBuffer[2]");
    local OutBuffers = ffi.new("SecBuffer[1]");
    local dwSSPIOutFlags = ffi.new("DWORD[1]");
    local cbData;
	local tsExpiry = nil;	-- ffi.new("TimeStamp");
    local fDoRead = fDoInitialRead;


    local dwSSPIFlags = bor(
    	ffi.C.ISC_REQ_SEQUENCE_DETECT,
    	ffi.C.ISC_REQ_REPLAY_DETECT,
    	ffi.C.ISC_REQ_CONFIDENTIALITY,
        ffi.C.ISC_RET_EXTENDED_ERROR,
        ffi.C.ISC_REQ_ALLOCATE_MEMORY,
        ffi.C.ISC_REQ_STREAM);

    -- Allocate data buffer.
    local IoBuffer = ffi.new("uint8_t[?]", IO_BUFFER_SIZE);
    if (IoBuffer == nil) then 
    	print("**** Out of memory (1)"); 
    	return SEC_E_INTERNAL_ERROR; 
    end

    local cbIoBuffer = 0;




    -- Loop until the handshake is finished or an error occurs.
    local scRet = SEC_I_CONTINUE_NEEDED;
    local err;

    while( scRet == SEC_I_CONTINUE_NEEDED        or
           scRet == SEC_E_INCOMPLETE_MESSAGE     or
           scRet == SEC_I_INCOMPLETE_CREDENTIALS ) do

        if(0 == cbIoBuffer or scRet == SEC_E_INCOMPLETE_MESSAGE) then -- Read data from server.
        
            if (fDoRead) then
                cbData, err = Socket:Receive(IoBuffer + cbIoBuffer, IO_BUFFER_SIZE - cbIoBuffer, 0 );
                if not cbData and (err == SOCKET_ERROR) then
                    print(string.format("**** Error %d reading data from server\n",err));
                    scRet = SEC_E_INTERNAL_ERROR;
                    break;
                elseif (cbData == 0) then
                    print("**** Server unexpectedly disconnected");
                    scRet = SEC_E_INTERNAL_ERROR;
                    break;
                end
                print("#### bytes of handshake data received: ", cbData);
                
                if(fVerbose) then
                	PrintHexDump(cbData, IoBuffer + cbIoBuffer); 
                	print(); 
                end
                cbIoBuffer = cbIoBuffer + cbData;
            else
              fDoRead = true;
            end
        end


        -- Set up the input buffers. Buffer 0 is used to pass in data
        -- received from the server. Schannel will consume some or all
        -- of this. Leftover data (if any) will be placed in buffer 1 and
        -- given a buffer type of SECBUFFER_EXTRA.
        InBuffers[0].pvBuffer   = IoBuffer;
        InBuffers[0].cbBuffer   = cbIoBuffer;
        InBuffers[0].BufferType = ffi.C.SECBUFFER_TOKEN;

        InBuffers[1].pvBuffer   = nil;
        InBuffers[1].cbBuffer   = 0;
        InBuffers[1].BufferType = ffi.C.SECBUFFER_EMPTY;

        InBuffer.cBuffers       = 2;
        InBuffer.pBuffers       = InBuffers;
        InBuffer.ulVersion      = ffi.C.SECBUFFER_VERSION;


        -- Set up the output buffers. These are initialized to nil
        -- so as to make it less likely we'll attempt to free random
        -- garbage later.
        OutBuffers[0].pvBuffer  = nil;
        OutBuffers[0].BufferType= ffi.C.SECBUFFER_TOKEN;
        OutBuffers[0].cbBuffer  = 0;

        OutBuffer.cBuffers      = 1;
        OutBuffer.pBuffers      = OutBuffers;
        OutBuffer.ulVersion     = ffi.C.SECBUFFER_VERSION;

        -- Call InitializeSecurityContext.
        scRet = SecurityInterface.InitializeSecurityContextA(phCreds,
			phContext,
			nil,
			dwSSPIFlags,
			0,
			ffi.C.SECURITY_NATIVE_DREP,
			InBuffer,
			0,
			nil,
			OutBuffer,
			dwSSPIOutFlags,
			tsExpiry );


        -- If InitializeSecurityContext was successful (or if the error was 
        -- one of the special extended ones), send the contends of the output
        -- buffer to the server.
        if(scRet == SEC_E_OK                or
           scRet == SEC_I_CONTINUE_NEEDED   or
           FAILED(scRet) and band(dwSSPIOutFlags[0], ffi.C.ISC_RET_EXTENDED_ERROR)>0) then
        
            if(OutBuffers[0].cbBuffer ~= 0 and OutBuffers[0].pvBuffer ~= nil) then
            
                cbData, err = Socket:Send(OutBuffers[0].pvBuffer, OutBuffers[0].cbBuffer, 0 );
                if(not cbData and err == SOCKET_ERROR or cbData == 0) then
                    print( "**** Error sending data to server (2): ", err);
                    --DisplayWinSockError( WSAGetLastError() );
                    SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
                    SecurityInterface.DeleteSecurityContext(phContext);
                    return SEC_E_INTERNAL_ERROR;
                end

                print("## bytes of handshake data sent: ", cbData);
                if(fVerbose) then
                	PrintHexDump(cbData, OutBuffers[0].pvBuffer); 
                	print(); 
                end

                -- Free output buffer.
                SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
                OutBuffers[0].pvBuffer = nil;
            end
        end



        -- If InitializeSecurityContext returned SEC_E_INCOMPLETE_MESSAGE,
        -- then we need to read more data from the server and try again.
        if(scRet == SEC_E_INCOMPLETE_MESSAGE) then
        	--continue;
        else


        -- If InitializeSecurityContext returned SEC_E_OK, then the 
        -- handshake completed successfully.
        if(scRet == SEC_E_OK) then
        
            -- If the "extra" buffer contains data, this is encrypted application
            -- protocol layer stuff. It needs to be saved. The application layer
            -- will later decrypt it with DecryptMessage.
            print("Handshake was successful");

            if(InBuffers[1].BufferType == ffi.C.SECBUFFER_EXTRA) then
                pExtraData.pvBuffer = ffi.new("uint8_t[?]", InBuffers[1].cbBuffer);

                if(pExtraData.pvBuffer == nil) then
                
                	print("**** Out of memory (2)"); 
                	return SEC_E_INTERNAL_ERROR; 
                end

                ffi.copy( pExtraData.pvBuffer,
                            IoBuffer + (cbIoBuffer - InBuffers[1].cbBuffer),
                            InBuffers[1].cbBuffer );

                pExtraData.cbBuffer   = InBuffers[1].cbBuffer;
                pExtraData.BufferType = ffi.C.SECBUFFER_TOKEN;

                print( "## bytes of app data were bundled with handshake data: ", pExtraData.cbBuffer );        
            else
                pExtraData.pvBuffer   = nil;
                pExtraData.cbBuffer   = 0;
                pExtraData.BufferType = ffi.C.SECBUFFER_EMPTY;
            end
            break; -- Bail out to quit
        end



        -- Check for fatal error.
        if(FAILED(scRet)) then
        	print("**** Error returned by InitializeSecurityContext (2): ", string.format("0x%x",scRet)); 
        	break; 
        end

        -- If InitializeSecurityContext returned SEC_I_INCOMPLETE_CREDENTIALS,
        -- then the server just requested client authentication. 
        if(scRet == SEC_I_INCOMPLETE_CREDENTIALS) then
        
            -- Busted. The server has requested client authentication and
            -- the credential we supplied didn't contain a client certificate.
            -- This function will read the list of trusted certificate
            -- authorities ("issuers") that was received from the server
            -- and attempt to find a suitable client certificate that
            -- was issued by one of these. If this function is successful, 
            -- then we will connect using the new certificate. Otherwise,
            -- we will attempt to connect anonymously (using our current credentials).
            --GetNewClientCredentials(phCreds, phContext);

            -- Go around again.
            fDoRead = false;
            scRet = SEC_I_CONTINUE_NEEDED;
            --continue;
        end

        -- Copy any leftover data from the "extra" buffer, and go around again.
        if ( InBuffers[1].BufferType == ffi.C.SECBUFFER_EXTRA ) then
        	ffi.copy(IoBuffer, IoBuffer + (cbIoBuffer - InBuffers[1].cbBuffer), InBuffers[1].cbBuffer);
            cbIoBuffer = InBuffers[1].cbBuffer;
        else
          cbIoBuffer = 0;
        end
    	end
    end

    -- Delete the security context in the case of a fatal error.
    if(FAILED(scRet)) then
    	SecurityInterface.DeleteSecurityContext(phContext);
    end


    return scRet;
end


local function PerformClientHandshake(Socket, phCreds, pszServerName)
	
	local phNewContext = ffi.new("CtxtHandle");


    local OutBuffer = ffi.new("SecBufferDesc");
    local OutBuffers = ffi.new("SecBuffer[1]");
 	local pfContextAttr = ffi.new("DWORD[1]");
    local tsExpiry = ffi.new("TimeStamp");
    local scRet;


    local dwSSPIFlags = bor(
    	ffi.C.ISC_REQ_SEQUENCE_DETECT,
    	ffi.C.ISC_REQ_REPLAY_DETECT, 
    	ffi.C.ISC_REQ_CONFIDENTIALITY,
        ffi.C.ISC_RET_EXTENDED_ERROR, 
        ffi.C.ISC_REQ_ALLOCATE_MEMORY, 
        ffi.C.ISC_REQ_STREAM);


    --  Initiate a ClientHello message and generate a token.
    OutBuffers[0].pvBuffer   = nil;
    OutBuffers[0].BufferType = ffi.C.SECBUFFER_TOKEN;
    OutBuffers[0].cbBuffer   = 0;

    OutBuffer.cBuffers  = 1;
    OutBuffer.pBuffers  = OutBuffers;
    OutBuffer.ulVersion = ffi.C.SECBUFFER_VERSION;

    scRet = SecurityInterface.InitializeSecurityContextA(  phCreds,
		nil,
		pszServerName,
		dwSSPIFlags,
		0,
		ffi.C.SECURITY_NATIVE_DREP,
		nil,
		0,
		phNewContext,
		OutBuffer,
		pfContextAttr,
		nil );

    if (scRet ~= SEC_I_CONTINUE_NEEDED)  then
    	print(string.format("**** Error %d returned by InitializeSecurityContext (1)", scRet)); 
    	return scRet; 
    end

    -- Send response to server if there is one.
    if(OutBuffers[0].cbBuffer ~= 0 and OutBuffers[0].pvBuffer ~= nil) then
    
        local cbData, err = Socket:Send(OutBuffers[0].pvBuffer, OutBuffers[0].cbBuffer, 0 );
        if not cbData then
        --if( cbData == SOCKET_ERROR or cbData == 0 ) then
            print("**** Error sending data to server (1): ", err);
            SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer);
            SecurityInterface.DeleteSecurityContext(phNewContext);
            return SEC_E_INTERNAL_ERROR;
        end

        print("handshake bytes sent: ", cbData);
        if (fVerbose) then 
       		--PrintHexDump(cbData, OutBuffers[0].pvBuffer); 
       		print(); 
       	end

        SecurityInterface.FreeContextBuffer(OutBuffers[0].pvBuffer); -- Free output buffer.
        OutBuffers[0].pvBuffer = nil;
    end

    print("phNewContext: ", phNewContext);
    print("pfContextAttr: ", string.format("%0x",pfContextAttr[0]));
    
	local pExtraData = ffi.new("SecBuffer");

    return ClientHandshakeLoop(Socket, phCreds, phNewContext, true, pExtraData);
end

local serverName = "www.google.com";
local serverPort = 443;

-- 3.0  Create an SSPI credential
local creds = CreateCreds();

-- 4.0  Connect to the server
local sock = ConnectToServer(serverName, serverPort);

-- 5.0  Perform handshaking
local res = PerformClientHandshake(sock, creds, ffi.cast("char *",serverName));

print("END Client Handshake: ", res);


-- 6.0  Authenticate the server's credentials
-- 7.0  Get the server's certificate.
-- 8.0  Verify the server's certificate
