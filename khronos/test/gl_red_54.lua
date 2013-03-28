package.path = package.path..";../?.lua"

local View3D = require("View3D");

function drawOneLine(x1, y1, x2, y2)
	gl.glBegin(GL_LINES);
	gl.glVertex2f(x1, y1);
	gl.glVertex2f(x2, y2);
	gl.glEnd();
end

function init()
	gl.glClearColor(0,0,0,0);
	gl.glShadeModel(GL_FLAT);
end

function display()
	local i = 0;

	gl.glClear(GL_COLOR_BUFFER_BIT);

	-- select white for all lines
	gl.glColor3f(1,1,1);


	gl.glEnable(GL_LINE_STIPPLE);

	-- in 1st row, 3 lines, each with a different stipple
	gl.glLineStipple(1, 0x0101);	-- dotted
	drawOneLine(50, 125, 150, 125);
	gl.glLineStipple(1, 0x00ff);	-- dashed
	drawOneLine(150, 125, 250, 125);
	gl.glLineStipple(1, 0x1c47);	-- dash/dot/dash
	drawOneLine(250, 125, 350, 125);

	-- in 2nd row,
	-- 3 wide lines, each with different stipple
	gl.glLineWidth(5);
	gl.glLineStipple(1, 0x0101);	-- dotted
	drawOneLine(50, 100, 150, 100);
	gl.glLineStipple(1, 0x00ff);	-- dashed
	drawOneLine(150, 100, 250, 100);
	gl.glLineStipple(1, 0x1c47);	-- dash/dot/dash
	drawOneLine(250, 100, 350, 100);
	gl.glLineWidth(1);

	-- in 3rd row, 6 lines,
	-- with dash/dot/dash stipple
	gl.glLineStipple(1, 0x1c47);
	gl.glBegin(GL_LINE_STRIP);
	for i=0,6 do
		gl.glVertex2f(50+(i*50), 75);
	end
	gl.glEnd();

	-- in 4th row, 6 independent lines with same stipple
	for i=0,5 do
		drawOneLine(50 + (i*50), 50, 50 + ((i+1)*50), 50);
	end

	-- in 5th row, 1 line, with dash/dot/dash stipple
	-- and a stipple repeat factor of 5
	gl.glLineStipple(5, 0x1c47);
	drawOneLine(50, 25, 350, 25);



	gl.glDisable(GL_LINE_STIPPLE);
	gl.glFlush();
end

function reshape(w, h)
	gl.glViewport(0,0, w, h);

	gl.glMatrixMode(GL_PROJECTION);
	gl.glLoadIdentity();
	gl.glOrtho(0, w, 0, h, -1, 1);
--	glu.gluOrtho2D(0, w, 0, h);
end

run(View3D.main);
