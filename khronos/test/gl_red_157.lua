package.path = package.path..";../?.lua"

local ffi = require("ffi");
local View3D = require("View3D");
local shapes = require("shapes");

local shoulder = 0;
local elbow = 0;

function init()
	glClearColor(0,0,0,0);
	glShadeModel(GL_FLAT);
end

function display()
	glClear(GL_COLOR_BUFFER_BIT);
	glPushMatrix();
	glTranslate(-1, 0, 0);
	glRotate(shoulder, 0, 0, 1);
	glTranslate(1, 0, 0);
	glPushMatrix();
	glScale(2, 0.4, 1);
	glutWireCube(1);
	glPopMatrix();

	glTranslate(1, 0, 0);
	glRotate(elbow, 0, 0, 1);
	glTranslate(1, 0, 0);
	glPushMatrix();
	glScale(2, 0.4, 1.0);
	glutWireCube(1);
	glPopMatrix();

	glPopMatrix();

	-- swap buffers
end

function reshape(w, h)
	glViewport(0,0,w, h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glu.gluPerspective(65, w/h, 1, 20);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslate(0,0,-5);
end

function keychar(event)
	local key = event.char;
	
	if key == 's' then
		shoulder = (shoulder + 5) % 360;
	elseif key == 'S' then
		shoulder = (shoulder - 5) % 360;
	elseif key == 'e' then
		elbow = (elbow + 5) % 360;
	elseif key == 'E' then
		elbow = (elbow-5) % 360;
	else
		-- do nothing
	end
end


run(View3D.main);
