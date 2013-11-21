local ffi = require("ffi")

local SysInfo = require("SysInfo");
local core_sysinfo = require("core_sysinfo_l1_2_0");
local Network = require("Network")
local HtmlTemplate = require("HtmlTemplate")

local osvinfo = SysInfo.OSVersionInfo();
local osversion = string.format("Microsoft Windows [Version %s]", tostring(osvinfo));


local indexPageTemplate = HtmlTemplate([[
<html>
	<head>
		<title>System Information</title>
	</head>

	<body>
		<table border="1">
		<tr align=center><h1>Windows Azure Host Information</h1></tr>
		<tr><td><b>Host Name</b></td><td><?hostname?></td>
		<tr><td><b>OS Version</b></td><td><?osversion?></td>
		<tr><td><b>System Directory</b></td><td><?systemdir?></td>
		<tr><td><b>Windows Directory</b></td><td><?windowsdir?></td>
		<tr><td><td><a href="/memory">Memory</a></td>
		<tr><td><td><a href="/processes">Processes</a></td>
		<tr><td><td><a href="/services">Services</a></td>
		<tr><td><td><a href="/files">Files</a></td>
		</table>
	</body>
</html>
]]);

local indexSubs = {
	hostname = Network:getHostName();
	osversion = osversion;
	systemdir = SysInfo.getSystemDirectory();
	windowsdir = SysInfo.getSystemWindowsDirectory();
}

return {
	getAceEditor = function()
		return getAceEditor();
	end,

-- Construct the home (index) page
	getIndexPage = function()
		return indexPageTemplate:fillTemplate(indexSubs)
	end,

	login = [[
<html>
	<body>
		<a href="/desktop">Desktop</a>
	</body>
</html>
]];
}

