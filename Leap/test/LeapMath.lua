--[[
  These are some basic vector and matrix math functions

--]]


 
local ffi = require("ffi");

local acos = math.acos;
local atan2 = math.atan2;
local sqrt = math.sqrt;

local PI = math.pi;
local DEG_TO_RAD  = 0.0174532925;
local RAD_TO_DEG  = 57.295779513;
local Epsilon = 0.0000001;			-- A fairly small number for comparisons


-- These are used to represent a matrix as a flat array
local float16_t = ffi.typeof("float[16]")
local double16_t = ffi.typeof("double[16]")


--[[*
 The Vector struct represents a three-component mathematical vector or point
 such as a direction or position in three-dimensional space.
 --]]

local Vector_t = {}
local Vector_mt = {
  __index = function(self, key)
    if type(key) == "number" then
      if key == 0 then
        return self.x;
      elseif key == 1 then
        return self.y;
      elseif key == 2 then
        return self.z;
      end
      return nil;
    end

    return Vector_t[key];
  end;

  __tostring = function(self)
    return string.format("{%3.3f, %3.3f, %3.3f}", self.x, self.y, self.z);
  end;


  __add = function(self, other)
    return Vector_t.new(self.x + other.x, self.y + other.y, self.z + other.z);
  end;

  __div = function(self, s)
    return Vector_t.new(self.x / s, self.y /s, self.z /s);
  end;

  __eq = function(self, other)
    return math.abs(self.x - other.x) < Epsilon and 
      math.abs(self.y - other.y) < Epsilon and 
      math.abs(self.z - other.z);
  end;

  __mul = function(self, s)
    return Vector_t.new(self.x * s, self.y *s, self.z *s);
  end;

  __sub = function(self, other)
    return Vector_t.new(self.x - other.x, self.y - other.y, self.z - other.z);
  end;

  __unm = function(self)
    return Vector_t.new(-self.x, -self.y, -self.z);
  end;
}

Vector_t.new = function (...)
  local nargs = select("#",...);

  local obj = {x=0,y=0,z=0}

  if nargs == 3 then
    obj.x = select(1, ...);
    obj.y = select(2, ...);
    obj.z = select(3, ...);
  elseif nargs == 1 then
    local arg1 = select(1,...)
    if getmetatable(arg1) == Vector_mt then
      -- Copy constructor for vector
      obj.x = arg1.x;
      obj.y = arg1.y;
      obj.z = arg1.z;
    elseif type(arg1) == "number" then
      obj.x = arg1;
      obj.y = arg1;
      obj.z = arg1;
    end 
  end

  setmetatable(obj, Vector_mt)

  return obj;
end



Vector_t.zero = Vector_t.new(0,0,0); --[[ The zero vector: (0, 0, 0) --]]

Vector_t.xAxis = Vector_t.new(1, 0, 0);   --[[ The x-axis unit vector: (1, 0, 0) --]]
Vector_t.yAxis = Vector_t.new(0, 1, 0);   --[[ The y-axis unit vector: (0, 1, 0) --]]
Vector_t.zAxis = Vector_t.new(0, 0, 1);   --[[ The z-axis unit vector: (0, 0, 1) --]]

Vector_t.left = Vector_t.new(-1, 0, 0);   --[[ The unit vector pointing left along the negative x-axis: (-1, 0, 0) --]]
Vector_t.right = Vector_t.xAxis;          --[[* The unit vector pointing right along the positive x-axis: (1, 0, 0) --]]
Vector_t.down = Vector_t.new(0, -1, 0);   --[[* The unit vector pointing down along the negative y-axis: (0, -1, 0) --]]
Vector_t.up = Vector_t.yAxis;             --[[* The unit vector pointing up along the positive y-axis: (0, 1, 0) --]]
Vector_t.forward = Vector_t.new(0, 0, -1);   --[[* The unit vector pointing forward along the negative z-axis: (0, 0, -1) --]]
Vector_t.backward = Vector_t.zAxis;       --[[* The unit vector pointing backward along the positive z-axis: (0, 0, 1) --]]


Vector_t.magnitude = function(self)
  return sqrt(self.x*self.x + self.y*self.y + self.z*self.z);
end

Vector_t.magnitudeSquared = function(self)
    return self.x*self.x + self.y*self.y + self.z*self.z;
end

Vector_t.distanceTo = function(self, other)
  return sqrt((self.x - other.x)*(self.x - other.x) +
    (self.y - other.y)*(self.y - other.y) +
    (self.z - other.z)*(self.z - other.z));
end

Vector_t.angleTo = function(self, other)
    local denom = self:magnitudeSquared() * other:magnitudeSquared();
    if (denom <= 0.0) then
      return 0.0;
    end

    return acos(self:dot(other) / sqrt(denom));
end

Vector_t.pitch = function(self) 
    return atan2(self.y, -self.z);
end

Vector_t.yaw = function(self)
  return atan2(self.x, -self.z);
end

Vector_t.roll = function(self)
    return atan2(self.x, -self.y);
end

Vector_t.dot = function(self, other)
    return (self.x * other.x) + (self.y * other.y) + (self.z * other.z);
end

Vector_t.cross = function(self, other)
  return Vector_t.new((self.y * other.z) - (self.z * other.y),
    (self.z * other.x) - (self.x * other.z),
    (self.x * other.y) - (self.y * other.x));
end

Vector_t.normalized = function(self)
  local denom = self:magnitudeSquared();
  if (denom <= 0.0) then
      return Vector_t.zero;
  end
  
  denom = 1.0 / sqrt(denom);
  
  return Vector_t.new(self.x * denom, self.y * denom, self.z * denom);
end


--[[
  In place arithmetic operations
--]]

--[[ Add vectors component-wise and assign the sum. --]]
Vector_t.add = function(self, other)
    self.x = self.x + other.x;
    self.y = self.y + other.y;
    self.z = self.z + other.z;

    return self;
end

--[[* Subtract vectors component-wise and assign the difference. --]]
Vector_t.sub = function(self, other)
    self.x = self.x - other.x;
    self.y = self.y - other.y;
    self.z = self.z - other.z;

    return self;
end

Vector_t.mul = function(self, s)
  self.x = self.x * s;
  self.y = self.y * s;
  self.z = self.z * s;

  return self;
end

Vector_t.div = function(self, s)
  self.x = self.x / s;
  self.y = self.y / s;
  self.z = self.z / s;

  return self;
end

--[[
  Returns true if all of the vector's components are finite.  If any
  component is NaN or infinite, then this returns false.
--]]
Vector_t.isValid = function(self)
  return self.x ~= math.huge and self.y ~= math.huge and self.z ~= math.huge;
end





--[[
  Matrix Representation
--]]

local Matrix_t = {}
local Matrix_mt = {
  __index = Matrix_t;

  --[[* Compare Matrix equality component-wise. --]]
  __eq = function(self, other)
     return self.xBasis == other.xBasis and
           self.yBasis == other.yBasis and
           self.zBasis == other.zBasis and
           self.origin == other.origin;
  end;

  --[[*
   *  Multiply transform matrices.
   *
   * Combines two transformations into a single equivalent transformation.
   *
   * @param other A Matrix to multiply on the right hand side.
   * @returns A new Matrix representing the transformation equivalent to
   * applying the other transformation followed by this transformation.
   --]]
  __mul = function(self, other)
     return Matrix_t.new(self:transformDirection(other.xBasis),
                  self:transformDirection(other.yBasis),
                  self:transformDirection(other.zBasis),
                  self:transformPoint(other.origin));
  end;

  __tostring = function(self) 
    return tostring(self.xBasis)..'\n'..tostring(self.yBasis)..'\n'..tostring(self.zBasis)..'\n'..tostring(self.origin);  
  end;

}

--[[ Constructs an identity transformation matrix. --]]
Matrix_t.new = function(a,b,c,  d,e,f,  g,h,i,  x,y,z)
  a = a or 1;
  b = b or 0;
  c = c or 0;
  d = d or 0;
  e = e or 1;
  f = f or 0;
  g = g or 0;
  h = h or 0;
  i = i or 1;
  x = x or 0;
  y = y or 0;
  z = z or 0;

  local obj = {
    xBasis = Vector_t.new(a,b,c);  --[[* The rotation and scale factors for the x-axis. --]]
    yBasis = Vector_t.new(d,e,f);  --[[* The rotation and scale factors for the y-axis. --]]
    zBasis = Vector_t.new(f,h,i);  --[[* The rotation and scale factors for the z-axis. --]]
    origin = Vector_t.new(x,y,z);  --[[* The translation factors for all three axes. --]]
  }

  setmetatable(obj, Matrix_mt);

  return obj; 
end

--[[
  Returns the identity matrix specifying no translation, rotation, and scale.
--]]
Matrix_t.identity = Matrix_t.new(1,0,0,  0,1,0,  0,0,1,  0,0,0);

  --[[*
   *  Sets this transformation matrix to represent a rotation around the specified vector.
   *
   * This function erases any previous rotation and scale transforms applied
   * to this matrix, but does not affect translation.
   *
   * @param _axis A Vector specifying the axis of rotation.
   * @param angleRadians The amount of rotation in radians.
   --]]
Matrix_t.setRotation = function(self, _axis, angleRadians) 
    local axis = _axis:normalized();
    local s = math.sin(angleRadians);
    local c = math.cos(angleRadians);
    local C = (1-c);

    self.xBasis = Vector_t.new(axis.x*axis.x*C + c, axis.x*axis.y*C - axis.z*s, axis.x*axis.z*C + axis.y*s);
    self.yBasis = Vector_t.new(axis.y*axis.x*C + axis.z*s, axis.y*axis.y*C + c, axis.y*axis.z*C - axis.x*s);
    self.zBasis = Vector_t.new(axis.z*axis.x*C - axis.y*s, axis.z*axis.y*C + axis.x*s, axis.z*axis.z*C + c);
end

--[[
  Transforms a vector with this matrix by transforming its rotation and
 scale only.

 @param in The Vector to transform.
 @returns A new Vector representing the transformed original.
--]]
Matrix_t.transformDirection = function(self, incoming)
    return xBasis*incoming.x + yBasis*incoming.y + zBasis*incoming.z;
end

--[[
  Transforms a vector with this matrix by transforming its rotation,
  scale, and translation.

  Translation is applied after rotation and scale.

  @param in The Vector to transform.
  @returns A new Vector representing the transformed original.
--]]
Matrix_t.transformPoint = function(self, incoming)
    return self.xBasis*incoming.x + self.yBasis*incoming.y + self.zBasis*incoming.z + self.origin;
end

--[[
   *  Performs a matrix inverse if the matrix consists entirely of rigid
   * transformations (translations and rotations).  If the matrix is not rigid,
   * this operation will not represent an inverse.
   *
   * Note that all matricies that are directly returned by the API are rigid.
   *
   * @returns The rigid inverse of the matrix.
--]]
Matrix_t.rigidInverse = function(self)
  local rotInverse = Matrix_t.new(
    self.xBasis.x, self.yBasis.x, self.zBasis.x,
    self.xBasis.y, self.yBasis.y, self.zBasis.y,
    self.xBasis.z, self.yBasis.z, self.zBasis.z);

  rotInverse.origin = rotInverse:transformDirection( -self.origin );
  
  return rotInverse;
end

--[===[
  --[[* Constructs a copy of the specified Matrix object. --]]
  Matrix(const Matrix& other) :
    xBasis(other.xBasis),
    yBasis(other.yBasis),
    zBasis(other.zBasis),
    origin(other.origin) {
  }

  --[[*
   *  Constructs a transformation matrix from the specified basis vectors.
   *
   * @param _xBasis A Vector specifying rotation and scale factors for the x-axis.
   * @param _yBasis A Vector specifying rotation and scale factors for the y-axis.
   * @param _zBasis A Vector specifying rotation and scale factors for the z-axis.
   --]]
  Matrix(const Vector& _xBasis, const Vector& _yBasis, const Vector& _zBasis) :
    xBasis(_xBasis),
    yBasis(_yBasis),
    zBasis(_zBasis),
    origin(0, 0, 0) {
  }

  --[[*
   *  Constructs a transformation matrix from the specified basis and translation vectors.
   *
   * @param _xBasis A Vector specifying rotation and scale factors for the x-axis.
   * @param _yBasis A Vector specifying rotation and scale factors for the y-axis.
   * @param _zBasis A Vector specifying rotation and scale factors for the z-axis.
   * @param _origin A Vector specifying translation factors on all three axes.
   --]]
  Matrix(const Vector& _xBasis, const Vector& _yBasis, const Vector& _zBasis, const Vector& _origin) :
    xBasis(_xBasis),
    yBasis(_yBasis),
    zBasis(_zBasis),
    origin(_origin) {
  }

  --[[*
   *  Constructs a transformation matrix specifying a rotation around the specified vector.
   *
   * @param axis A Vector specifying the axis of rotation.
   * @param angleRadians The amount of rotation in radians.
   --]]
  Matrix(const Vector& axis, float angleRadians) :
    origin(0, 0, 0) {
    setRotation(axis, angleRadians);
  }

  --[[*
   *  Constructs a transformation matrix specifying a rotation around the specified vector
   * and a translation by the specified vector.
   *
   * @param axis A Vector specifying the axis of rotation.
   * @param angleRadians The angle of rotation in radians.
   * @param translation A Vector representing the translation part of the transform.
   --]]
  Matrix(const Vector& axis, float angleRadians, const Vector& translation)
    : origin(translation) {
    setRotation(axis, angleRadians);
  }
--]===]










  --[[*
   *  Convert a Leap::Matrix object to another 3x3 matrix type.
   *
   * The new type must define a constructor function that takes each matrix
   * element as a parameter in row-major order.
   *
   * Translation factors are discarded.
   --]]
Matrix_t.toMatrix3x3 = function(self, ct)
  return ct(self.xBasis.x, self.xBasis.y, self.xBasis.z,
            self.yBasis.x, self.yBasis.y, self.yBasis.z,
            self.zBasis.x, self.zBasis.y, self.zBasis.z);
end



  --[[*
   *  Convert a Leap::Matrix object to another 4x4 matrix type.
   *
   * The new type must define a constructor function that takes each matrix
   * element as a parameter in row-major order.
   --]]
Matrix_t.toMatrix4x4 = function(self, ct)
  return ct(self.xBasis.x, self.xBasis.y, self.xBasis.z, 0.0,
            self.yBasis.x, self.yBasis.y, self.yBasis.z, 0.0,
            self.zBasis.x, self.zBasis.y, self.zBasis.z, 0.0,
            self.origin.x, self.origin.y, self.origin.z, 1.0);
end


--[[
  Writes the 3x3 Matrix object to a 9 element row-major float or
  double array.

  Translation factors are discarded.
  
  Returns a pointer to the same data.
--]]

Matrix_t.copyToArray3x3 = function(self, output)
  output[0] = self.xBasis.x; output[1] = self.xBasis.y; output[2] = self.xBasis.z;
  output[3] = self.yBasis.x; output[4] = self.yBasis.y; output[5] = self.yBasis.z;
  output[6] = self.zBasis.x; output[7] = self.zBasis.y; output[8] = self.zBasis.z;
  
  return output;
end

--[[
  Convert a 3x3 Matrix object to a 9 element row-major float array.
   *
   * Translation factors are discarded.
   *
   * Returns a FloatArray struct to avoid dynamic memory allocation.
--]]
Matrix_t.toArray3x3 = function(self, ct)
  ct = ct or float16_t
  local output = ct();
  self:toArray3x3(output);
  
  return output;
end


--[[
  Writes the 4x4 Matrix object to a 16 element row-major float
  or double array.
   
  Returns a pointer to the same data.
--]]

Matrix_t.copyToArray4x4 = function(self, output)
    output[0]  = self.xBasis.x; output[1]  = self.xBasis.y; output[2]  = self.xBasis.z; output[3]  = 0.0;
    output[4]  = self.yBasis.x; output[5]  = self.yBasis.y; output[6]  = self.yBasis.z; output[7]  = 0.0;
    output[8]  = self.zBasis.x; output[9]  = self.zBasis.y; output[10] = self.zBasis.z; output[11] = 0.0;
    output[12] = self.origin.x; output[13] = self.origin.y; output[14] = self.origin.z; output[15] = 1.0;
    
    return output;
end

--[[
  Convert a 4x4 Matrix object to a 16 element row-major float array. 
--]]
Matrix_t.toArray4x4 = function(self, ct)
  ct = ct or float16_t; 
  local output = ct();
  self:copyToArray4x4(output);
  
  return output;
end


return {
  vec3_t = Vector_t,
  vec3_mt = Vector_mt,
  vec3 = Vector_t.new,

  mat4_t = Matrix_t,
  mat4_mt = Matrix_mt,
  mat4 = Matrix_t.new,
}

