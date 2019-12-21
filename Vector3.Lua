
local ffi = require "ffi"
ffi.cdef[[
typedef struct Vector3 {
	double x;
	double y;
	double z;
} Vector3;
]]

local Vector3 = {}
setmetatable(Vector3, Vector3)

local math3DTypes
local tempVector4_1
local tempVector3_1
local tempVector3_2
local tempVector3_3

function Vector3.set(self, x, y, z)
	if Vector3.isVector3(x) then
		ffi.copy(self, x, ffi.sizeof(self))
	else
		self.x = x self.y = y self.z = z
	end
	return self
end

function Vector3.copy(v)
	out = Vector3()
	ffi.copy(out, v, ffi.sizeof(v))
	return out
end

function Vector3.__index(t, k)
	if k == "length" then
		return Vector3.getLength(t)
	elseif k == "normalized" then
		return Vector3.getNormalized(t)
	elseif k == "angle" then
		return Vector3.getAngle(t)
	elseif k == "lengthSquared" then
		return Vector3.getLengthSquared(t)
	end
	return rawget(Vector3, k)
end

function Vector3.getLength(v)
	return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z)
end

function Vector3.getLengthSquared(v)
	return v.x*v.x+v.y*v.y+v.z*v.z
end

function Vector3.getNormalized(v)
	local out = v:copy()
	out:normalize()
	return out
end

function Vector3.normalize(v)
	local length = v.length
	if length == 0 then
		v.x = 0 v.y = 0 v.z = 0
	else
		v.x = v.x/length v.y = v.y/length v.z = v.z/length
	end
	return v
end

function Vector3.getAngle(v)
	return math.atan2(v.y, v.x, v/z)
end

function Vector3.__newindex(t, k, v)
	if k == "length" then
		local res = t.normalized*v
		t.x = res.x
		t.y = res.y
		t.z = res.z
		return
	end
	if k == "angle" then
		local res = t:angled(v)
		t.x = res.x
		t.y = res.y
		t.z = res.z
		return
	end
	if type(t) == "cdata" then
		error("Cannot assign a new property '" .. k .. "' to a Vector3") 
	else
		rawset(t,k,v)
	end
end

function Vector3.angled(v, angle)
	local length = v.length
	return Vector3(math.cos(angle)*length, math.sin(angle)*length, math.tan(angle)*length)
end

function Vector3.trim(v, mag)
	if v.length < mag then return v end
	return v.normalized*mag
end

function Vector3.unpack(v)
	return v.x, v.y, v.z
end

function Vector3.dot(v1, v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z
end

function Vector3.cross(v1, v2, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector3()
	out:set(
		v1.y * v2.z - v1.z * v2.y,
		v1.z * v2.x - v1.x * v2.z,
		v1.x * v2.y - v1.y * v2.x)
	return out
end

local iteraxes_lookup = {
	xy = {"x","y"},
	yx = {"y","x"},
}
local function iteraxes(ordertable, i)
	i = i+1
	if i > 2 then return nil end
	return i, ordertable[i]
end

function Vector3.axes(order)
	return iteraxes, iteraxes_lookup[order or "yx"], 0
end

function Vector3.isVector3(arg)
	return ffi.istype("Vector3", arg)
end

function Vector3.add(v1, v2, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector3()
	out:set(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z)
	return out
end

function Vector3.subtract(v1, v2, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector3()
	Vector3:set(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z)
	return out
end

function Vector3.multiplyPoint(v1, matrixOrQuat, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector3()

	if (math3DTypes.Quat.isQuat(matrixOrQuat)) then
		tempVector3_1.x = matrixOrQuat.x
		tempVector3_1.y = matrixOrQuat.y
		tempVector3_1.z = matrixOrQuat.z

		tempVector3_2:set(tempVector3_1)
		tempVector3_2:cross(v1, true)

		tempVector3_3:set(tempVector3_1)
		tempVector3_3:cross(tempVector3_2, true)

		tempVector3_2:multiply(matrixOrQuat.w, true):add(tempVector3_3, true):multiply(2, true)
		out:set(v1)
		out:add(tempVector3_2, true)
		return out--v1 + ((tempVector3_2 * matrixOrQuat.w) + tempVector3_3) * 2
	end

	tempVector4_1:set(v1.x, v1.y, v1.z, 1)
	tempVector4_1:multiplyMatrix(matrixOrQuat, true)
	out:set(tempVector4_1.x/tempVector4_1.w, tempVector4_1.y/tempVector4_1.w, tempVector4_1.z/tempVector4_1.w)
	return out
end

function Vector3.multiply(v1, op, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v1 or Vector3()
	if  type(op) == "cdata" then
		out:set(v1.x*op.x, v1.y*op.y, v1.z*op.z)
	else
		out:set(v1.x*op, v1.y*op, v1.z*op)
	end
	return out
end

function Vector3.divide(v1, op, mutate)
	if mutate == nil then mutate = true end

	if type(op) ~= "number" then error("must divide by a scalar") end
	local out = mutate and v1 or Vector3()
	out:set(v1.x/op, v1.y/op, v1.z/op)
	return out
end

function Vector3.negate(v, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and v or Vector3()
	out:set(-v.x, -v.y, -v.z)
	return out
end

function Vector3.__add(v1, v2)
	return Vector3.add(v1, v2, false)
end

function Vector3.__sub(v1, v2)
	return Vector3.subtract(v1, v2, false)
end

function Vector3.__mul(v1, op)
	return Vector3.multiply(v1, op, false)
end

function Vector3.__div(v1, op)
	return Vector3.divide(v1, op, false)
end

function Vector3.__unm(v)
	return Vector3.negate(v, false)
end

function Vector3.__eq(v1,v2)
	if (not ffi.istype("Vector3",v2)) or (not ffi.istype("Vector3",v1)) then return false end
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z
end

function Vector3.__tostring(t)
	return string.format("(%.4f, %.4f, %.4f)", t.x, t.y, t.z)
end

function Vector3.__concat(v1, v2)
	return v1 .. tostring(v2)
end

local Vector3_T

function Vector3.__call(t, x, y, z)
	return Vector3_T(x or 0, y or 0, z or 0)--ffi.new("Vector3", x or 0, y or 0, z or 0)
end

function Vector3.initialize(types)
	math3DTypes = types
	tempVector4_1 = types.Vector4()
	tempVector3_1 = types.Vector3()
	tempVector3_2 = types.Vector3()
	tempVector3_3 = types.Vector3()
end

Vector3_T = ffi.metatype("Vector3", Vector3)
Vector3.default = Vector3_T()
Vector3.one = Vector3_T(1, 1, 1)
Vector3.right = Vector3_T(1, 0, 0)
Vector3.left = Vector3_T(-1, 0, 0)
Vector3.up = Vector3_T(0, 1, 0)
Vector3.down = Vector3_T(0, -1, 0)
Vector3.forward = Vector3_T(0, 0, 1)
Vector3.back = Vector3_T(0, 0, -1)

return Vector3_T
