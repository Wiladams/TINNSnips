package.path = package.path..";../?.lua"

local View3D = require("View3D");
local shapes = require("shapes");


function init()
	gl.glClearColor(0,0,0,0);
	gl.glShadeModel(GL_FLAT);
end

function display()
	gl.glClear(GL_COLOR_BUFFER_BIT);
	gl.glColor3f(1,1,1);
	gl.glLoadIdentity();

	-- viewing transform
	glu.gluLookAt(0,0,5,0,0,0,0,1,0);
	gl.glScalef(1,2,1);
	glutWireCube(4);
	glutWireCube(3);
	glutWireCube(2);
	glutWireCube(1);
	gl.glFlush();
end

function reshape(w, h)
	gl.glViewport(0,0,w,h);
	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity();

	gl.glFrustum(-1, 1, -1, 1, 1.5, 20);
	gl.glMatrixMode(GL_MODELVIEW);
end


run(View3D.main);
