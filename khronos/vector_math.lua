-- math_vector.lua

local ffi = require "ffi"

-- Useful constants
local kEpsilon = 1.0e-6


--[[
	HELPER FUNCTIONS
--]]


local function IsZero(a)
    return (math.abs(a) < kEpsilon);
end


-- Some generic vector routines
local vec_t =  {}
vec_t.equal = function(self, rhs)
	for i=0,#self-1 do
		if self[i] ~= rhs[i] then
			return false
		end
	end
	return true
end

vec_t.unm = function(self)
	local obj = ffi.new(ffi.typeof(self))
	for i=0,#self-1 do
		obj[i] = -self[i];
	end
	return obj
end

vec_t.add = function(self, rhs)
	local obj = ffi.new(ffi.typeof(self))
	for i=0,#self-1 do
		obj[i] = self[i] + rhs[i];
	end

	return obj
end

vec_t.sub = function(self, rhs)
	local obj = ffi.new(ffi.typeof(self))
	for i=0,#self-1 do
		obj[i] = self[i] - rhs[i];
	end
	
	return obj
end

vec_t.mul = function(self, scalar)
		local obj = ffi.new(ffi.typeof(self))

		if type(scalar) == "number" then
			for i=0,#self do
				obj[i] = self[i] * scalar;
			end
		elseif type(scalar) == "cdata" then
			for i=0,#self do
				obj[i] = self[i] * scalar[i];
			end
		end

		return obj;
	end

vec_t.div = function(self, scalar)
		local obj = ffi.new(ffi.typeof(self))

		if type(scalar) == "number" then
			for i=0,#self do
				obj[i] = self[i] / scalar;
			end
		elseif type(scalar) == "cdata" then
			for i=0,#self do
				obj[i] = self[i] / scalar[i];
			end
		end
		
		return obj;
	end

	-- Vector specific functions
vec_t.angleBetween = function(self,rhs)
		return math.acos(self:Dot(rhs))
end

vec_t.assign = function(self, rhs)
	local lowest = math.min(#self, #rhs)
	for i=0,lowest-1 do
		self[i] = rhs[i];
	end
	return self;
end

vec_t.clone = function(self)
	return ffi.new(ffi.typeof(self), self);
end

vec_t.cross = function(self, v)
	local res = ffi.new(ffi.typeof(self));

	res[0] = self[1]*v[2] - v[1]*self[2];
	res[1] = -self[0]*v[2] + v[0]*self[2];
	res[2] = self[0]*v[1] - v[0]*self[1];

	return res;
end

vec_t.distance = function(self, v)
	return vec_t.length(vec_t.sub(self,v));
end

vec_t.dot = function(self, rhs)
	if #self ~= #rhs then
		return false, "lengths must be equal"
	end

	local dotprod = 0;
	local selfptr = self:asConstPointer();
	local rhsptr = rhs:asConstPointer();
	for i=0,#self-1 do
		dotprod = dotprod + selfptr[i]*rhsptr[i];
	end

	return dotprod;
end

vec_t.length = function(self)
	return math.sqrt(vec_t.lengthSquared(self))
end

vec_t.lengthSquared = function(self)
	return vec_t.dot(self, self);
end

vec_t.normal = function(self)
	local scalar = 1/vec_t.length(self);

	local obj = ffi.new(ffi.typeof(self));

	local selfptr = self:asConstPointer();
	local objptr = rhs:asConstPointer();

	for i=0,#self-1 do
		objptr[i] = selfptr[i] * scalar;
	end

	return obj;
end



--[[
http://lua-users.org/wiki/MetatableEvents

__len +
__index +
__newindex
__mode
__call
__metatable__new

__tostring +
__gc

Math Operators
__unm +
__add +
__sub +
__mul +
__div +
__pow
__concat
__eq +
__lt
__le
--]]

--[[
	vec2 kind
--]]
local function make_vec_kind(ct, nelems)
	local vec_kind = ffi.typeof("struct {$ data[$];}", ct, nelems);
	local ptrType = ffi.typeof("$ *", ct);
	local constptrType = ffi.typeof("const $ *", ct);

	local fieldmap = {
		x = 0;
		y = 1;
		z = 2;
		w = 3;

		r = 0;
		g = 1;
		b = 2;
		a = 3;
	}

	local vec_mt = {
		__len = function(self) return nelems; end;
		__new = function(ct,...)
			local nargs = select("#",...);
			local obj = ffi.new(ct);
			if nargs > 0 then
				if type(select(1, ...)) == "number" then
					for i=1,nargs do
						obj.data[i-1] = select(i,...);
					end
				end
			end

			return obj;
		end;
		__tostring = function(self) return self.x..','..self.y..','..self.z; end;

		-- Math Operators
		__eq = function(self, rhs) return vec_t.equal(self, rhs); end;
		__unm = function(self) return vec_t.unm(self); end;
		__add = function(self, rhs) return vec_t.add(self, rhs); end;
		__sub = function(self, rhs) return vec_t.mul(self, rhs); end;
		__mul = function(self, scalar) return vec_t.mul(self, scalar); end;
		__div = function(self, scalar) return vec_t.div(self, scalar); end;
		
		__index = function(self, key)
			if type(key) == "number" then
				return ffi.cast(ptrType,self)[key];
			elseif key == "asPointer" then
				return ffi.cast(ptrType,self);
			elseif key == "asConstPointer" then
				return ffi.cast(constptrType, self);
			elseif fieldmap[key] then
				return ffi.cast(ptrType,self)[fieldmap[key]];
			end

			return vec_t[key];
		end;

		__newindex = function(self, key, value)
			if type(key) == "number" then
				ffi.cast(ptrType,self)[key] = value;
			end
		end;
	}

	return ffi.metatype(vec_kind, vec_mt);
end




return {

	vec2 = make_vec_kind(ffi.typeof("float"), 2);

	--vec3 = make_vec3_kind(ffi.typeof("float"));
	vec3 = make_vec_kind(ffi.typeof("float"),3);
	dvec3 = make_vec3_kind(ffi.typeof("double"));
	ivec3 = make_vec3_kind(ffi.typeof("int32_t"));
	uvec3 = make_vec3_kind(ffi.typeof("uint32_t"));
	bvec3 = make_vec3_kind(ffi.typeof("uint8_t"));

	vec4 = make_vec_kind(ffi.typeof("float"), 4);


	PlaneNormal = function(point1, point2, point3)
			local v1 = point1 - point2
			local v2 = point2 - point3

			return v1:cross(v2);
	end,

}
