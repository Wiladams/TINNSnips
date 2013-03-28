package.path = package.path..";../?.lua"

local ffi = require("ffi");
local View3D = require("View3D");
local shapes = require("shapes");

local double4 = ffi.typeof("double[4]");


function init()
	gl.glClearColor(0,0,0,0);
	gl.glShadeModel(GL_FLAT);
end

function display()
	local eqn = double4(0,1,0,0);
	local eqn2 = double4(1,0,0,0);

	gl.glClear(GL_COLOR_BUFFER_BIT);
	gl.glColor3f(1,1,1);
	gl.glPushMatrix();
	gl.glTranslatef(0,0,-5);

	-- clip lower half -- y < 0
	gl.glClipPlane(GL_CLIP_PLANE0, eqn);
	gl.glEnable(GL_CLIP_PLANE0);

	-- clip left half -- x < 0
	gl.glClipPlane(GL_CLIP_PLANE1, eqn2);
	gl.glEnable(GL_CLIP_PLANE1);

	gl.glRotatef(90, 1, 0, 0);

	--glutSolidSphere(1, 8, 8);
	glutWireSphere(1, 8, 8);

	gl.glPopMatrix();
	gl.glFlush();
end

function reshape(w, h)
	gl.glViewport(0,0,w,h);
	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity();

	glu.gluPerspective(60, w/h, 1, 20);
	gl.glMatrixMode(GL_MODELVIEW);
end

run(View3D.main);

