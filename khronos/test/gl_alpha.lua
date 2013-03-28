package.path = package.path..";../?.lua"

local View3D = require("View3D");


local leftFirst = GL_TRUE;

function init()
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glShadeModel(GL_FLAT);
	glClearColor(0,0,0,0);
end

function drawLeftTriangle()
	glBegin(GL_TRIANGLES);
	  glColor(1,1,0,0.75);
	  glVertex(0.1, 0.9, 0);
	  glVertex(0.1, 0.1, 0);
	  glVertex(0.7, 0.5, 0);
	glEnd();
end

function drawRightTriangle()
	glBegin(GL_TRIANGLES);
	  glColor(0,1,1,0.75);
	  glVertex(0.9, 0.9, 0);
	  glVertex(0.3, 0.5, 0);
	  glVertex(0.9, 0.1, 0);
	glEnd();
end

function display()
	glClear(GL_COLOR_BUFFER_BIT);

	if (leftFirst) then
		drawLeftTriangle();
		drawRightTriangle();
	else
		drawRightTriangle();
		drawLeftTriangle();
	end
	glFlush();
end

function reshape(w,h)
	glViewport(0,0,w,h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	if (w <= h) then
		glu.gluOrtho2D(0,1,0,1*h/w);
	else
		glu.gluOrtho2D(0,1*w/h, 0, 1);
	end
end

function keychar(event)
	if event.char == 't' or event.char == 'T' then
		leftFirst = not leftFirst
	end
end


run(View3D.main);
