
local ffi = require "ffi"
ffi.cdef[[
typedef struct Vector4 {
	double x;
	double y;
	double z;
	double w;
} Vector4;
]]

local Vector4 = {}
setmetatable(Vector4, Vector4)
Vector4.__index = Vector4

local math3DTypes
local tempVector4

function Vector4.set(self, x, y, z, w)
	if Vector4.isVector4(x) then
		ffi.copy(self, x, ffi.sizeof(self))
	else
		self.x = x self.y = y self.z = z self.w = w
	end
	return self
end

function Vector4.copy(v)
	local out = Vector4()
	ffi.copy(out, v, ffi.sizeof(v))
	return out
end

function Vector4.getLength(v)
	return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z+v.w*v.w)
end

function Vector4.getLengthSquared(v)
	return v.x*v.x+v.y*v.y+v.z*v.z+v.w*v.w
end

function Vector4.getNormalized(v)
	local out = v:copy()
	out:normalize()
	return out
end

function Vector4.normalize(v)
	local length = v:getLength()
	if length == 0 then
		v.x = 0 v.y = 0 v.z = 0 v.w = 0
	else
		v.x = v.x/length v.y = v.y/length v.z = v.z/length v.w = v.w/length
	end
	return v
end

function Vector4.trim(v, mag)
	if v:getLength() < mag then return v end
	return v:getNormalized()*mag
end

function Vector4.unpack(v)
	return v.x, v.y, v.z, v.w
end

function Vector4.dot(v1, v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w
end

function Vector4.isVector4(arg)
	return ffi.istype("Vector4", arg)
end

function Vector4.add(v1, v2, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector4()
	Vector4.set(out, v1.x+v2.x, v1.y+v2.y, v1.z+v2.z, v1.w+v2.w)
	return out
end

function Vector4.subtract(v1, v2, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector4()
	Vector4.set(out, v1.x-v2.x, v1.y-v2.y, v1.z-v2.z, v1.w-v2.w)
	return out
end

function Vector4.multiplyMatrix(v1, matrix, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and tempVector4 or Vector4()

	out.x = v1.x * matrix.m0 + v1.y * matrix.m4 + v1.z * matrix.m8  + v1.w * matrix.m12
	out.y = v1.x * matrix.m1 + v1.y * matrix.m5 + v1.z * matrix.m9 + v1.w * matrix.m13
	out.z = v1.x * matrix.m2 + v1.y * matrix.m6 + v1.z * matrix.m10 + v1.w * matrix.m14
	out.w = v1.x * matrix.m3 + v1.y * matrix.m7 + v1.z * matrix.m11 + v1.w * matrix.m15

	if mutate == true then
		v1:set(out)
		return v1
	end

	return out
end

function Vector4.multiply(v1, op, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector4()
	if  type(op) == "cdata" then
		out:set(v1.x*op.x, v1.y*op.y, v1.z*op.z, v1.w*op.w)
	else
		out:set(v1.x*op, v1.y*op, v1.z*op, v1.w*op)
	end
	return out
end

function Vector4.divide(v1, op, mutate)
	if mutate == nil then mutate = true end

	if type(op) ~= "number" then error("must divide by a scalar") end
	local out = mutate and v1 or Vector4()
	out:set(v1.x/op, v1.y/op, v1.z/op, v1.w/op)
	return out
end

function Vector4.negate(v, mutate)
	if mutate == nil then mutate = true end
	
	local out = mutate and v or Vector4()
	Vector4.set(-v.x, -v.y, -v.z, -v.w)
	return out
end

function Vector4.__add(v1, v2)
	return Vector4.add(v1, v2, false)
end

function Vector4.__sub(v1, v2)
	return Vector4.subtract(v1, v2, false)
end

function Vector4.__mul(v1, op)
	return Vector4.multiply(v1, op, false)
end

function Vector4.__div(v1, op)
	return Vector4.divide(v1, op, false)
end

function Vector4.__unm(v)
	return Vector4.negate(v, false)
end

function Vector4.__eq(v1,v2)
	if (not ffi.istype("Vector4",v2)) or (not ffi.istype("Vector4",v1)) then return false end
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z and v1.w == v2.w
end

function Vector4.__tostring(t)
	return string.format("(%.4f, %.4f, %.4f, %.4f)", t.x, t.y, t.z, t.w)
end

function Vector4.__concat(v1, v2)
	return v1 .. tostring(v2)
end

local Vector4_T

function Vector4.__call(t, x, y, z, w)
	return Vector4_T(x or 0, y or 0, z or 0, w or 0)
end

function Vector4.initialize(types)
	math3DTypes = types
	tempVector4 = types.Vector4()
end

Vector4_T = ffi.metatype("Vector4", Vector4)

Vector4.default = Vector4_T()
Vector4.one = Vector4_T(1, 1, 1, 1)

return Vector4_T
