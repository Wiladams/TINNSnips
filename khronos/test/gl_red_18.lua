package.path = package.path..";../?.lua"

local View3D = require("View3D");


function display()
	gl.glClear(GL_COLOR_BUFFER_BIT);

	gl.glColor3f(1,0.78,1);
	gl.glBegin(GL_POLYGON);
		gl.glVertex3f(0.25, 0.25, 0.0);
		gl.glVertex3f(0.75, 0.25, 0.0);
		gl.glVertex3f(0.75, 0.75, 0.0);
		gl.glVertex3f(0.25, 0.75, 0.0);
	gl.glEnd();

	gl.glFinish();
	gl.glFlush();
end

function init()

	gl.glClearColor(0,0,0,1);

	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity()
	gl.glOrtho(0, 1, 0, 1, -1, 1 )
end

run(View3D.main);

