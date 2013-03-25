package.path = package.path..";../?.lua"

local View3D = require("View3D");

-- Lesson 2

function display()
	glClear(GL_COLOR_BUFFER_BIT);
	glClear(GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	glTranslate(-1.5, 0, -6);

	glBegin(GL_TRIANGLES);
	  glVertex(0, 1, 0);
	  glVertex(-1, -1, 0);
	  glVertex(1, -1, 0);
	glEnd();

	glTranslate(3, 0, 0);

	glBegin(GL_QUADS);
		glVertex(-1, 1, 0);
		glVertex(1, 1, 0);
		glVertex(1, -1, 0);
		glVertex(-1, -1, 0);
	glEnd();
end

function init()
	glShadeModel(GL_SMOOTH);
	glClearColor(0.0, 0.0, 0.0, 0.5);
	glClearDepth(1.0);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
end

function reshape(width, height)
	if (height==0) then
		height=1;
	end

	glViewport(0,0,width,height);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	-- Calculate The Aspect Ratio Of The Window
	gluPerspective(45.0, width/height,0.1,100.0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
end


run(View3D.main);

