local ffi = require "ffi"

local GLUquadricObj quadObj = nil;


function initQuadObj()
	quadObj = glu.gluNewQuadric();
	if not quadObj then
		print("out of memory.");
	end
end

function QUAD_OBJ_INIT()
	if not quadObj then
		initQuadObj();
	end
end



--[[
If we ever changed/used the texture or orientation state
     of quadObj, we'd need to change it to the defaults here
     with gluQuadricTexture and/or gluQuadricOrientation.
--]]

function glutWireSphere(radius, slices, stacks)
	QUAD_OBJ_INIT();

	glu.gluQuadricDrawStyle(quadObj, GLU_POINT);
--	glu.gluQuadricDrawStyle(quadObj, GLU_LINE);
	glu.gluQuadricNormals(quadObj, GLU_SMOOTH);
	glu.gluSphere(quadObj, radius, slices, stacks);
end

function glutSolidSphere(radius, slices, stacks)
	QUAD_OBJ_INIT();

	glu.gluQuadricDrawStyle(quadObj, GLU_FILL);
	glu.gluQuadricNormals(quadObj, GLU_SMOOTH);
	glu.gluSphere(quadObj, radius, slices, stacks);
end


function drawBox(size, btype)

  local n = ffi.new("float[6][3]",
  {
    {-1.0, 0.0, 0.0},
    {0.0, 1.0, 0.0},
    {1.0, 0.0, 0.0},
    {0.0, -1.0, 0.0},
    {0.0, 0.0, 1.0},
    {0.0, 0.0, -1.0}
  });

  local faces = ffi.new("int[6][4]",
  {
    {0, 1, 2, 3},
    {3, 2, 6, 7},
    {7, 6, 5, 4},
    {4, 5, 1, 0},
    {5, 6, 2, 1},
    {7, 4, 0, 3}
  });

	local v = ffi.new("float[8][3]");
	local i;

	local so2 = size/2;

  v[0][0] = -so2;
  v[1][0] = -so2;
  v[2][0] = -so2;
  v[3][0] = -so2;
  v[0][1] = -so2;
  v[1][1] = -so2;
  v[4][1] = -so2;
  v[5][1] = -so2;
  v[0][2] = -so2;
  v[3][2] = -so2;
  v[4][2] = -so2;
  v[7][2] = -so2;


  v[4][0] = so2
  v[5][0] = so2
  v[6][0] = so2
  v[7][0] = so2;
  v[2][1] = so2
  v[3][1] = so2
  v[6][1] = so2
  v[7][1] = so2;
  v[1][2] = so2
  v[2][2] = so2
  v[5][2] = so2
  v[6][2] = so2;

	for i = 5, 0, -1	do
		gl.glBegin(btype);
		  gl.glNormal3fv(n[i]);
		  gl.glVertex3fv(v[faces[i][0]]);
		  gl.glVertex3fv(v[faces[i][1]]);
		  gl.glVertex3fv(v[faces[i][2]]);
		  gl.glVertex3fv(v[faces[i][3]]);
		gl.glEnd();
	end
end


function glutWireCube(size)
  drawBox(size, GL_LINE_LOOP);
end


function glutSolidCube(size)
  drawBox(size, GL_QUADS);
end


--[[
	Draw Triangles
--]]
function DIFF3(_a,_b,_c)
    (_c)[0] = (_a)[0] - (_b)[0];
    (_c)[1] = (_a)[1] - (_b)[1];
    (_c)[2] = (_a)[2] - (_b)[2];
end


function crossprod(v1, v2, prod)

  local  p = float3;         -- in case prod == v1 or v2

  p[0] = v1[1] * v2[2] - v2[1] * v1[2];
  p[1] = v1[2] * v2[0] - v2[2] * v1[0];
  p[2] = v1[0] * v2[1] - v2[0] * v1[1];
  prod[0] = p[0];
  prod[1] = p[1];
  prod[2] = p[2];

	return prod
end


function normalize(v)
	local d;

	d = math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);

	if (d == 0.0) then
		-- __glutWarning("normalize: zero length vector");
		v[0] = 1.0;
		d = 1;
	end

	d = 1 / d;
	v[0] = v[0] * d;
	v[1] = v[1] * d;
	v[2] = v[2] * d;

	return v
end


function recorditem(n1, n2, n3, shadeType)
	local q0 = float3();
	local q1 = float3();

	DIFF3(n1, n2, q0);
	DIFF3(n2, n3, q1);
	crossprod(q0, q1, q1);
	normalize(q1);

	gl.glBegin(shadeType);
	  gl.glNormal3fv(q1);
	  gl.glVertex3fv(n1);
	  gl.glVertex3fv(n2);
	  gl.glVertex3fv(n3);
	gl.glEnd();
end

function subdivide(v0, v1, v2, shadeType)

	local depth = 1;
	local w0 = float3;
	local w1 = float3;
	local w2 = float3;
	local l;
	local i, j, k, n;

	for i = 0, depth-1 do
		local j = 0
		while i+j < depth do
			k = depth - i - j;
			for n = 0, 3-1 do
				w0[n] = (i * v0[n] + j * v1[n] + k * v2[n]) / depth;
				w1[n] = ((i + 1) * v0[n] + j * v1[n] + (k - 1) * v2[n])/ depth;
				w2[n] = (i * v0[n] + (j + 1) * v1[n] + (k - 1) * v2[n])/ depth;
			end

			l = math.sqrt(w0[0] * w0[0] + w0[1] * w0[1] + w0[2] * w0[2]);

			w0[0] = w0[0] / l;
			w0[1] = w0[1] / l;
			w0[2] = w0[2] / l;

			l = math.sqrt(w1[0] * w1[0] + w1[1] * w1[1] + w1[2] * w1[2]);
			w1[0] = w1[0] / l;
			w1[1] = w1[1] / l;
			w1[2] = w1[2] / l;

			l = math.sqrt(w2[0] * w2[0] + w2[1] * w2[1] + w2[2] * w2[2]);
			w2[0] = w2[0] / l;
			w2[1] = w2[1] / l;
			w2[2] = w2[2] / l;

			recorditem(w1, w0, w2, shadeType);

			j = j + 1;
		end
	end
end

function drawtriangle(i, data, ndx, shadeType)
	local x0, x1, x2;

	x0 = data[ndx[i][0]];
	x1 = data[ndx[i][1]];
	x2 = data[ndx[i][2]];

	subdivide(x0, x1, x2, shadeType);
end


-- tetrahedron data:

local  T = 1.73205080756887729;

local tdata = ffi.new("float[4][3]",
{
  {T, T, T},
  {T, -T, -T},
  {-T, T, -T},
  {-T, -T, T}
});

local tndex = ffi.new("int[4][3]",
{
  {0, 1, 3},
  {2, 1, 0},
  {3, 2, 0},
  {1, 2, 3}
});

local function tetrahedron(shadeType)
	local i;

	for i = 3, 0, -1 do
		drawtriangle(i, tdata, tndex, shadeType);
	end
end


function glutWireTetrahedron()
	tetrahedron(GL_LINE_LOOP);
end


function glutSolidTetrahedron()

  tetrahedron(GL_TRIANGLES);
end
