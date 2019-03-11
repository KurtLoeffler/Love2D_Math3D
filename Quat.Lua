
local ffi = require "ffi"
ffi.cdef[[
typedef struct Quat {
	double x;
	double y;
	double z;
	double w;
} Quat;
]]

local Quat = {}
setmetatable(Quat, Quat)

local math3DTypes
local tempVector4_1
local tempVector3_1
local tempVector3_2
local tempVector3_3
local tempQuat

function Quat.set(self, x, y, z, w)
	if Quat.isQuat(x) then
		ffi.copy(self, x, ffi.sizeof(self))
	else
		self.x = x self.y = y self.z = z self.z = z self.w = w
	end
	return self
end

function Quat.copy(v)
	out = Quat()
	ffi.copy(out, v, ffi.sizeof(v))
	return out
end

function Quat.__index(t, k)
	if k == "length" then
		return Quat.getLength(t)
	elseif k == "normalized" then
		return Quat.getNormalized(t)
	elseif k == "squaredLength" then
		return Quat.getLengthSquared(t)
	end
	return rawget(Quat, k)
end

function Quat.getLength(v)
	return math.sqrt(v.x*v.x+v.y*v.y+v.z*v.z*v.w)
end

function Quat.getLengthSquared(v)
	return v.x*v.x+v.y*v.y+v.z*v.z*v.w
end

function Quat.getNormalized(v)
	local out = v:copy()
	out:normalize()
	return out
end

function Quat.normalize(v)
	if v == Quat.default then
		return
	end
	local length = v.length
	v:multiply(1/v.length, true)
end

function Quat.__newindex(t, k, v)
	if k == "length" then
		local res = t.normalized*v
		t.x = res.x
		t.y = res.y
		t.z = res.z
		return
	end
	if type(t) == "cdata" then
		error("Cannot assign a new property '" .. k .. "' to a Quat") 
	else
		rawset(t,k,v)
	end
end

function Quat.unpack(v)
	return v.x, v.y, v.z, v.w
end

function Quat.dot(v1, v2)
	return v1.x*v2.x+v1.y*v2.y+v1.z*v2.z+v1.w*v2.w
end

function Quat.isQuat(arg)
	return ffi.istype("Quat", arg)
end

function Quat.toAngleAxis(self)
	
	if self.w > 1 or self.w < -1 then
		self = tempVector3_1:set(self)
		self:normalize()
	end

	local x, y, z
	local angle = 2 * acos(self.w)
	local s     = sqrt(1 - self.w * self.w)

	if s < 2.2204460492503131e-16 then
		x = self.x
		y = self.y
		z = self.z
	else
		x = self.x / s
		y = self.y / s
		z = self.z / s
	end

	return angle, x, y, z
end

function Quat.setFromAngles(self, x, y, z)
	if x and y and z then
		self:setFromAngleAxis(y, math3DTypes.Vector3.up)
		tempQuat:setFromAngleAxis(x, math3DTypes.Vector3.right)
		self:multiply(tempQuat, true)
		tempQuat:setFromAngleAxis(z, math3DTypes.Vector3.forward)
		self:multiply(tempQuat, true)
		return self
	end
	return self:setFromAngles(angle, x.x, x.y, x.z)
end

function Quat.fromAngles(x, y, z)
	local out = Quat()
	out:setFromAngles(x, y, z)
	return out
end

function Quat.setFromAngleAxis(self, angle, axisOrX, y, z)
	if axisOrX and y and z then
		local s = math.sin(angle * 0.5)
		local c = math.cos(angle * 0.5)
		self:set(axisOrX * s, y * s, z * s, c)
		return self
	end
	return self:setFromAngleAxis(angle, axisOrX.x, axisOrX.y, axisOrX.z)
end

function Quat.fromAngleAxis(angle, axisOrX, y, z)
	local out = Quat()
	out:setFromAngleAxis(angle, axisOrX, y, z)
	return out
end

function Quat.setFromDirection(self, normal, up)
	tempVector3_1:set(normal)
	tempVector3_1:normalize()
	tempVector3_2:set(up)
	tempVector3_2:cross(tempVector3_1, true)
	local d = u:dot(tempVector3_1)
	self:set(tempVector3_2.x, tempVector3_2.y, tempVector3_2.z, d + 1)
	return self
end

function Quat.fromDirection(normal, up)
	local out = Quat()
	out:setFromDirection(normal, up)
	return out
end

function Quat.conjugate(self, inline)
	local out = inline and self or Quat()
	return out:set(-self.x, -self.y, -self.z, self.w)
end

function Quat.add(v1, v2, inline)
	local out = inline and v1 or Quat()
	out:set(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z, v1.w+v2.w)
	return out
end

function Quat.subtract(v1, v2, inline)
	local out = inline and v1 or Quat()
	out:set(v1.x-v2.x, v1.y-v2.y, v1.z-v2.z, v1.w-v2.w)
	return out
end

function Quat.multiply(v1, op, inline)
	local out = inline and v1 or Quat()
	if type(v1) == "number" then
		out:set(op.x*v1, op.y*v1, op.z*v1)
	elseif  Quat.isQuat(op) then
		out:set(
		v1.x * op.w + v1.w * op.x + v1.y * op.z - v1.z * op.y,
		v1.y * op.w + v1.w * op.y + v1.z * op.x - v1.x * op.z,
		v1.z * op.w + v1.w * op.z + v1.x * op.y - v1.y * op.x,
		v1.w * op.w - v1.x * op.x - v1.y * op.y - v1.z * op.z)
	else
		out:set(v1.x*op, v1.y*op, v1.z*op)
	end
	return out
end

function Quat.divide(v1, op, inline)
	if type(op) ~= "number" then error("must divide by a scalar") end
	local out = inline and v1 or Quat()
	out:set(v1.x/op, v1.y/op, v1.z/op, v1.w/op)
	return out
end

function Quat.negate(v, inline)
	local out = inline and v or Quat()
	out:set(-v.x, -v.y, -v.z, -v.w)
	return out
end

function Quat.__add(v1, v2)
	return Quat.add(v1, v2)
end

function Quat.__sub(v1, v2)
	return Quat.subtract(v1, v2)
end

function Quat.__mul(v1, op)
	return Quat.multiply(v1, op)
end

function Quat.__div(v1, op)
	return Quat.divide(v1, op)
end

function Quat.__unm(v)
	return Quat.negate(v)
end

function Quat.__eq(v1,v2)
	if (not ffi.istype("Quat",v2)) or (not ffi.istype("Quat",v1)) then return false end
	return v1.x == v2.x and v1.y == v2.y and v1.z == v2.z and v1.w == v2.w
end

function Quat.__tostring(t)
	return string.format("(%.4f, %.4f, %.4f, %.4f)", t.x, t.y, t.z, t.w)
end

function Quat.__concat(v1, v2)
	return v1 .. tostring(v2)
end

local Quat_T

function Quat.__call(t, x, y, z, w)
	return Quat_T(x or 0, y or 0, z or 0, w or 0)--ffi.new("Quat", x or 0, y or 0, z or 0)
end

function Quat.initialize(types)
	math3DTypes = types
	tempVector4_1 = types.Vector4()
	tempVector3_1 = types.Vector3()
	tempVector3_2 = types.Vector3()
	tempVector3_3 = types.Vector3()
	tempQuat = types.Quat()
end



Quat_T = ffi.metatype("Quat", Quat)
Quat.default = Quat_T()
Quat.identity = Quat_T(0, 0, 0, 1)

return Quat_T
