package.path = package.path..";../?.lua"

local View3D = require("View3D");

function init ( )
  glShadeModel(GL_SMOOTH);							-- Enable Smooth Shading
	glClearColor(0.0, 0.0, 0.0, 0.5);				-- Black Background
	glClearDepth(1.0);									-- Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);							-- Enables Depth Testing
	glDepthFunc(GL_LEQUAL);								-- The Type Of Depth Testing To Do
   glEnable ( GL_COLOR_MATERIAL );
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
end

function display ()
  glClear(bor(GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT));
	glLoadIdentity();
	glTranslatef(-1.5,0.0,-6.0);
	glBegin(GL_TRIANGLES);
		glColor3f(1.0,0.0,0.0);
		glVertex3f( 0.0, 1.0, 0.0);
		glColor3f(0.0,1.0,0.0);
		glVertex3f(-1.0,-1.0, 0.0);
		glColor3f(0.0,0.0,1.0);
		glVertex3f( 1.0,-1.0, 0.0);
	glEnd();
	glTranslatef(3.0,0.0,0.0);
	glColor3f(0.5,0.5,1.0);
	glBegin(GL_QUADS);
		glVertex3f(-1.0, 1.0, 0.0);
		glVertex3f( 1.0, 1.0, 0.0);
		glVertex3f( 1.0,-1.0, 0.0);
		glVertex3f(-1.0,-1.0, 0.0);
	glEnd();


  --glutSwapBuffers ( );
end

function reshape (w, h)
  glViewport     ( 0, 0, w, h );
  glMatrixMode   ( GL_PROJECTION );
  glLoadIdentity ( );
  if ( h==0 )  then
     gluPerspective ( 80, w, 1.0, 5000.0 );
  else
     gluPerspective ( 80, w / h, 1.0, 5000.0 );
  end

  glMatrixMode   ( GL_MODELVIEW );
  glLoadIdentity ( );
end


run(View3D.main);

