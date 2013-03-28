package.path = package.path..";../?.lua"

local View3D = require("View3D");

function init()
	gl.glClearColor(0,0,0,0);
	gl.glShadeModel(GL_SMOOTH);
end

function triangle()
	gl.glBegin(GL_TRIANGLES);
	gl.glColor3f(1,0,0);
	gl.glVertex2f(5,5);
	gl.glColor3f(0,1,0);
	gl.glVertex2f(25,5);
	gl.glColor3f(0,0,1);
	gl.glVertex2f(5,25);
	gl.glEnd();
end

function display()
	gl.glClear(GL_COLOR_BUFFER_BIT);
	triangle();
	gl.glFlush();
end

function reshape(w, h)
	gl.glViewport(0,0,w,h);
	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity();

	if (w <= h) then
		glu.gluOrtho2D(0,30,0,30*h/w);
	else
		glu.gluOrtho2D(0,30*w/h, 0, 30);
	end

	gl.glMatrixMode(GL_MODELVIEW);
end

run(View3D.main);
