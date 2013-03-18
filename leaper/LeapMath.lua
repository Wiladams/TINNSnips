--[[*****************************************************************************\
* Copyright (C) 2012-2013 Leap Motion, Inc. All rights reserved.               *
* Leap Motion proprietary and confidential. Not for distribution.              *
* Use subject to the terms of the Leap Motion SDK Agreement available at       *
* https://developer.leapmotion.com/sdk_agreement, or another agreement         *
* between Leap Motion and you, your company or other organization.             *
\*****************************************************************************--]]


local acos = math.acos;
local atan2 = math.atan2;
local sqrt = math.sqrt;

local PI = math.pi;
local Epsilon = 0.0000001;

--[[* The constant pi as a single precision floating point number. --]]
--local PI          = 3.1415926536;
--[[*
 * The constant ratio to convert an angle measure from degrees to radians.
 * Multiply a value in degrees by this constant to convert to radians.
 --]]
local DEG_TO_RAD  = 0.0174532925;
--[[*
 * The constant ratio to convert an angle measure from radians to degrees.
 * Multiply a value in radians by this constant to convert to degrees.
 --]]
local RAD_TO_DEG  = 57.295779513;

--[[*
 * The Vector struct represents a three-component mathematical vector or point
 * such as a direction or position in three-dimensional space.
 *
 * The Leap software employs a right-handed Cartesian coordinate system.
 * Values given are in units of real-world millimeters. The origin is centered
 * at the center of the Leap device. The x- and z-axes lie in the horizontal
 * plane, with the x-axis running parallel to the long edge of the device.
 * The y-axis is vertical, with positive values increasing upwards (in contrast
 * to the downward orientation of most computer graphics coordinate systems).
 * The z-axis has positive values increasing away from the computer screen.
 *
 * \image html images/Leap_Axes.png
 --]]


Vector_t = {}
Vector_mt = {
  __index = Vector_t;

  __tostring = function(self)
    return string.format("Vector(%3.2f, %3.4f, %3.4f)", self.x, self.y, self.z)
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

Vector_t.new = function (x, y, z)
  x = x or 0;
  y = y or 0;
  z = z or 0;

  local obj = {
    x=x;    -- The horizontal component.
    y=y;    -- The vertical component.
    z=z;    -- The depth component.
  }

  setmetatable(obj, Vector_mt)

  return obj;
end

--[=[
  --[[* Creates a new Vector with the specified component values. --]]
  Vector(float _x, float _y, float _z) :
    x(_x), y(_y), z(_z) {}

  --[[* Copies the specified Vector. --]]
  Vector(const Vector& vector) :
    x(vector.x), y(vector.y), z(vector.z) {}
--]=]

Vector_t.zero = Vector_t.new(); --[[ The zero vector: (0, 0, 0) --]]

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

Vector_t.mul = function(self, s)
  self.x = self.x / s;
  self.y = self.y / s;
  self.z = self.z / s;

  return self;
end

--[[
  Returns true if all of the vector's components are finite.  If any
  component is NaN or infinite, then this returns false.
--]]
Vector_t.isValid(self)
  return self.x ~= math.huge and self.y ~= math.huge and self.z ~= math.huge;
end



--[===[

  --[[*
   *  Index vector components numerically.
   * Index 0 is x, index 1 is y, and index 2 is z.
   * @returns The x, y, or z component of this Vector, if the specified index
   * value is at least 0 and at most 2; otherwise, returns zero.
   --]]
  float operator[](unsigned int index) const {
    return index < 3 ? (&x)[index] : 0.0f;
  }

  --[[* Cast the vector to a float array. --]]
  const float* toFloatPointer() const {
    return &x; --[[ Note: Assumes x, y, z are aligned in memory. --]]
  }

  --[[*
   *  Convert a Leap::Vector to another 3-component Vector type.
   *
   * The specified type must define a constructor that takes the x, y, and z
   * components as separate parameters.
   --]]
  template<typename Vector3Type>
  const Vector3Type toVector3() const {
    return Vector3Type(x, y, z);
  }

  --[[*
   *  Convert a Leap::Vector to another 4-component Vector type.
   *
   * The specified type must define a constructor that takes the x, y, z, and w
   * components as separate parameters. (The homogeneous coordinate, w, is set
   * to zero by default, but you should typically set it to one for vectors
   * representing a position.)
   --]]
  template<typename Vector4Type>
  const Vector4Type toVector4(float w=0.0f) const {
    return Vector4Type(x, y, z, w);
  }
--]===]


float16_t = ffi.typeof("float[16]")
double16_t = ffi.typeof("double[16]")

--[===[
--[[*
 *  The FloatArray struct is used to allow the returning of native float arrays
 * without requiring dynamic memory allocation.  It represents a matrix
 * with a size up to 4x4.
 --]]
struct FloatArray {
  --[[* Access the elements of the float array exactly like a native array --]]
  float& operator[] (unsigned int index) {
    return m_array[index];
  }

  --[[* Use the Float Array anywhere a float pointer can be used --]]
  operator float* () {
    return m_array;
  }

  --[[* Use the Float Array anywhere a const float pointer can be used --]]
  operator const float* () const {
    return m_array;
  }

  --[[* An array containing up to 16 entries of the matrix --]]
  float m_array[16];
};
--]===]


Matrix_t = {}
Matrix_mt = {
  __index = Matrix_t;

  __tostring = function(self) 
    return tostring(self.xBasis)..'\n'..tostring(self.yBasis)..'\n'..tostring(self.zBasis)..'\n'..tostring(self.origin);  
  end;

end

--[[ Constructs an identity transformation matrix. --]]
Matrix_t.new = function(a,b,c,  d,e,f, g,h,i,  x,y,z)
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

  --[[*
   *  Returns the identity matrix specifying no translation, rotation, and scale.
   *
   * @returns The identity matrix.
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
Matrix_t.setRotation(self, _axis, angleRadians) 
    local axis = _axis:normalized();
    local s = math.sin(angleRadians);
    local c = math.cos(angleRadians);
    local C = (1-c);

    self.xBasis = Vector_t.new(axis.x*axis.x*C + c, axis.x*axis.y*C - axis.z*s, axis.x*axis.z*C + axis.y*s);
    self.yBasis = Vector_t.new(axis.y*axis.x*C + axis.z*s, axis.y*axis.y*C + c, axis.y*axis.z*C - axis.x*s);
    self.zBasis = Vector_t.new(axis.z*axis.x*C - axis.y*s, axis.z*axis.y*C + axis.x*s, axis.z*axis.z*C + c);
}

--[[
  Transforms a vector with this matrix by transforming its rotation and
 scale only.

 @param in The Vector to transform.
 @returns A new Vector representing the transformed original.
--]]
Matrix_t.transformDirection = function(self, const Vector& incoming)
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











  --[[*
   *  Multiply transform matrices.
   *
   * Combines two transformations into a single equivalent transformation.
   *
   * @param other A Matrix to multiply on the right hand side.
   * @returns A new Matrix representing the transformation equivalent to
   * applying the other transformation followed by this transformation.
   --]]
  Matrix operator*(const Matrix& other) const {
    return Matrix(transformDirection(other.xBasis),
                  transformDirection(other.yBasis),
                  transformDirection(other.zBasis),
                  transformPoint(other.origin));
  }

  --[[* Multiply transform matrices and assign the product. --]]
  Matrix& operator*=(const Matrix& other) {
    return (*this) = (*this) * other;
  }

  --[[* Compare Matrix equality component-wise. --]]
  bool operator==(const Matrix& other) const {
    return xBasis == other.xBasis &&
           yBasis == other.yBasis &&
           zBasis == other.zBasis &&
           origin == other.origin;
  }
  --[[* Compare Matrix inequality component-wise. --]]
  bool operator!=(const Matrix& other) const {
    return xBasis != other.xBasis ||
           yBasis != other.yBasis ||
           zBasis != other.zBasis ||
           origin != other.origin;
  }

  --[[*
   *  Convert a Leap::Matrix object to another 3x3 matrix type.
   *
   * The new type must define a constructor function that takes each matrix
   * element as a parameter in row-major order.
   *
   * Translation factors are discarded.
   --]]
  template<typename Matrix3x3Type>
  const Matrix3x3Type toMatrix3x3() const {
    return Matrix3x3Type(xBasis.x, xBasis.y, xBasis.z,
                         yBasis.x, yBasis.y, yBasis.z,
                         zBasis.x, zBasis.y, zBasis.z);
  }

  --[[*
   *  Convert a Leap::Matrix object to another 4x4 matrix type.
   *
   * The new type must define a constructor function that takes each matrix
   * element as a parameter in row-major order.
   --]]
  template<typename Matrix4x4Type>
  const Matrix4x4Type toMatrix4x4() const {
    return Matrix4x4Type(xBasis.x, xBasis.y, xBasis.z, 0.0f,
                         yBasis.x, yBasis.y, yBasis.z, 0.0f,
                         zBasis.x, zBasis.y, zBasis.z, 0.0f,
                         origin.x, origin.y, origin.z, 1.0f);
  }

  --[[*
   *  Writes the 3x3 Matrix object to a 9 element row-major float or
   * double array.
   *
   * Translation factors are discarded.
   *
   * Returns a pointer to the same data.
   --]]
  template<typename T>
  T* toArray3x3(T* output) const {
    output[0] = xBasis.x; output[1] = xBasis.y; output[2] = xBasis.z;
    output[3] = yBasis.x; output[4] = yBasis.y; output[5] = yBasis.z;
    output[6] = zBasis.x; output[7] = zBasis.y; output[8] = zBasis.z;
    return output;
  }

  --[[*
   *  Convert a 3x3 Matrix object to a 9 element row-major float array.
   *
   * Translation factors are discarded.
   *
   * Returns a FloatArray struct to avoid dynamic memory allocation.
   --]]
  FloatArray toArray3x3() const {
    FloatArray output;
    toArray3x3((float*)output);
    return output;
  }

  --[[*
   *  Writes the 4x4 Matrix object to a 16 element row-major float
   * or double array.
   *
   * Returns a pointer to the same data.
   --]]
  template<typename T>
  T* toArray4x4(T* output) const {
    output[0]  = xBasis.x; output[1]  = xBasis.y; output[2]  = xBasis.z; output[3]  = 0.0f;
    output[4]  = yBasis.x; output[5]  = yBasis.y; output[6]  = yBasis.z; output[7]  = 0.0f;
    output[8]  = zBasis.x; output[9]  = zBasis.y; output[10] = zBasis.z; output[11] = 0.0f;
    output[12] = origin.x; output[13] = origin.y; output[14] = origin.z; output[15] = 1.0f;
    return output;
  }

  --[[*
   *  Convert a 4x4 Matrix object to a 16 element row-major float array.
   *
   * Returns a FloatArray struct to avoid dynamic memory allocation.
   --]]
  FloatArray toArray4x4() const {
    FloatArray output;
    toArray4x4((float*)output);
    return output;
  }




--]===]

return {
  Vector = Vector_t,
}
