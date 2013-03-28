-- gl_red_24.lua
package.path = package.path..";../?.lua"

local View3D = require("View3D");


local spin = 0.0;

function init()
	gl.glClearColor(0,0,0,0);
	gl.glShadeModel(GL_FLAT);
end

function display(canvas)
	gl.glClear(GL_COLOR_BUFFER_BIT);

	gl.glPushMatrix();
	  gl.glRotatef(spin, 0,0,1);
	  gl.glColor3f(1,1,1);
	  gl.glRectf(-25, -25, 25, 25);
	gl.glPopMatrix();

	spinDisplay();
end

function spinDisplay()
	spin = spin + 4;
	if spin > 360 then
		spin = spin-360;
	end
end

function reshape(w, h)
	gl.glViewport(0,0,w,h)

	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity();
	gl.glOrtho(-50, 50, -50, 50, -1, 1);

	gl.glMatrixMode(GL_MODELVIEW);
	gl.glLoadIdentity();
end

run(View3D.main);
