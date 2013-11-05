-- README.txt

If the server is to support Windows Integrated Authentication, it must
answer a request with a authentication challenge.

This challenge is represented through the 'WWW-Authenticate' header.

So, a typical request/response would look like the following exchange.

[REQUEST]
GET /ac/login.aspx HTTP/1.1 
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */* 
Accept-Language: en-us 
UA-CPU: x86 
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; .NET
CLR 1.1.4322; .NET CLR 2.0.50727)
Host: myhost
Connection: Keep-Alive
 
[RESPONSE]   
HTTP/1.1 401 Unauthorized
Content-Length: 1656
Content-Type: text/html
Server: Microsoft-IIS/6.0
WWW-Authenticate: Negotiate 
WWW-Authenticate: NTLM
MicrosoftOfficeWebServer: 5.0_Pub
X-Powered-By: ASP.NET
Date: Wed, 26 Sep 2007 21:26:01 GMT 
