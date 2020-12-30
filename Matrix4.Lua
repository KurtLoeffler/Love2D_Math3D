
local ffi = require "ffi"

local cos = math.cos
local sin = math.sin
local tan = math.tan
local rad = math.rad

ffi.cdef[[
typedef struct Matrix4 {
	double m0;
	double m1;
	double m2;
	double m3;
	double m4;
	double m5;
	double m6;
	double m7;
	double m8;
	double m9;
	double m10;
	double m11;
	double m12;
	double m13;
	double m14;
	double m15;
} Matrix4;
]]

local Matrix4 = {}
setmetatable(Matrix4, Matrix4)

local math3DTypes
local tempVector3_1
local tempMatrix

function Matrix4.set(self,
	v0, v1, v2, v3,
	v4, v5, v6, v7,
	v8, v9, v10, v11,
	v12, v13, v14, v15)
	if Matrix4.isMatrix4(v0) then
		ffi.copy(self, v0, ffi.sizeof(self))
	else
		self.m0 = v0 self.m1 = v1 self.m2 = v2 self.m3 = v3
		self.m4 = v4 self.m5 = v5 self.m6 = v6 self.m7 = v7
		self.m8 = v8 self.m9 = v9 self.m10 = v10 self.m11 = v11
		self.m12 = v12 self.m13 = v13 self.m14 = v14 self.m15 = v15
	end
	return self
end

function Matrix4.copy(self)
	local out = Matrix4()
	ffi.copy(out, self, ffi.sizeof(self))
	return out
end

function Matrix4.fillTable(self, t)
	t[1], t[2], t[3], t[4] = self.m0, self.m1, self.m2, self.m3
	t[5], t[6], t[7], t[8] = self.m4, self.m5, self.m6, self.m7
	t[9], t[10], t[11], t[12] = self.m8, self.m9, self.m10, self.m11
	t[13], t[14], t[15], t[16] = self.m12, self.m13, self.m14, self.m15
end

function Matrix4.__index(t, k)
	return rawget(Matrix4, k)
end

function Matrix4.createIdentity()
	local m = Matrix4()
	m.m0 = 1
	m.m5 = 1
	m.m10 = 1
	m.m15 = 1
	return m
end

local tempMultiplyMatrix
function Matrix4.multiply(a, b, mutate)
	if mutate == nil then mutate = true end

	local out = mutate and tempMultiplyMatrix or Matrix4()
	
	out.m0  = a.m0  * b.m0 + a.m1  * b.m4 + a.m2  * b.m8  + a.m3  * b.m12
	out.m1  = a.m0  * b.m1 + a.m1  * b.m5 + a.m2  * b.m9 + a.m3  * b.m13
	out.m2  = a.m0  * b.m2 + a.m1  * b.m6 + a.m2  * b.m10 + a.m3  * b.m14
	out.m3  = a.m0  * b.m3 + a.m1  * b.m7 + a.m2  * b.m11 + a.m3  * b.m15
	out.m4  = a.m4  * b.m0 + a.m5  * b.m4 + a.m6  * b.m8  + a.m7  * b.m12
	out.m5  = a.m4  * b.m1 + a.m5  * b.m5 + a.m6  * b.m9 + a.m7  * b.m13
	out.m6  = a.m4  * b.m2 + a.m5  * b.m6 + a.m6  * b.m10 + a.m7  * b.m14
	out.m7  = a.m4  * b.m3 + a.m5  * b.m7 + a.m6  * b.m11 + a.m7  * b.m15
	out.m8  = a.m8  * b.m0 + a.m9 * b.m4 + a.m10 * b.m8  + a.m11 * b.m12
	out.m9 = a.m8  * b.m1 + a.m9 * b.m5 + a.m10 * b.m9 + a.m11 * b.m13
	out.m10 = a.m8  * b.m2 + a.m9 * b.m6 + a.m10 * b.m10 + a.m11 * b.m14
	out.m11 = a.m8  * b.m3 + a.m9 * b.m7 + a.m10 * b.m11 + a.m11 * b.m15
	out.m12 = a.m12 * b.m0 + a.m13 * b.m4 + a.m14 * b.m8  + a.m15 * b.m12
	out.m13 = a.m12 * b.m1 + a.m13 * b.m5 + a.m14 * b.m9 + a.m15 * b.m13
	out.m14 = a.m12 * b.m2 + a.m13 * b.m6 + a.m14 * b.m10 + a.m15 * b.m14
	out.m15 = a.m12 * b.m3 + a.m13 * b.m7 + a.m14 * b.m11 + a.m15 * b.m15
	
	if mutate == true then
		a:set(out)
		return a
	end
	return out
end

local tempInvertMatrix
function Matrix4.invert(a, mutate)
	if mutate == nil then mutate = true end
	
	local out = mutate and tempInvertMatrix or Matrix4()
	
	out.m0  =  a.m5 * a.m10 * a.m15 - a.m5 * a.m11 * a.m14 - a.m9 * a.m6 * a.m15 + a.m9 * a.m7 * a.m14 + a.m13 * a.m6 * a.m11 - a.m13 * a.m7 * a.m10
	out.m1  = -a.m1 * a.m10 * a.m15 + a.m1 * a.m11 * a.m14 + a.m9 * a.m2 * a.m15 - a.m9 * a.m3 * a.m14 - a.m13 * a.m2 * a.m11 + a.m13 * a.m3 * a.m10
	out.m2  =  a.m1 * a.m6  * a.m15 - a.m1 * a.m7  * a.m14 - a.m5  * a.m2 * a.m15 + a.m5  * a.m3 * a.m14 + a.m13 * a.m2 * a.m7  - a.m13 * a.m3 * a.m6
	out.m3  = -a.m1 * a.m6  * a.m11 + a.m1 * a.m7  * a.m10 + a.m5  * a.m2 * a.m11 - a.m5  * a.m3 * a.m10 - a.m9 * a.m2 * a.m7  + a.m9 * a.m3 * a.m6
	out.m4  = -a.m4 * a.m10 * a.m15 + a.m4 * a.m11 * a.m14 + a.m8  * a.m6 * a.m15 - a.m8  * a.m7 * a.m14 - a.m12 * a.m6 * a.m11 + a.m12 * a.m7 * a.m10
	out.m5  =  a.m0 * a.m10 * a.m15 - a.m0 * a.m11 * a.m14 - a.m8  * a.m2 * a.m15 + a.m8  * a.m3 * a.m14 + a.m12 * a.m2 * a.m11 - a.m12 * a.m3 * a.m10
	out.m6  = -a.m0 * a.m6  * a.m15 + a.m0 * a.m7  * a.m14 + a.m4  * a.m2 * a.m15 - a.m4  * a.m3 * a.m14 - a.m12 * a.m2 * a.m7  + a.m12 * a.m3 * a.m6
	out.m7  =  a.m0 * a.m6  * a.m11 - a.m0 * a.m7  * a.m10 - a.m4  * a.m2 * a.m11 + a.m4  * a.m3 * a.m10 + a.m8  * a.m2 * a.m7  - a.m8  * a.m3 * a.m6
	out.m8  =  a.m4 * a.m9 * a.m15 - a.m4 * a.m11 * a.m13 - a.m8  * a.m5 * a.m15 + a.m8  * a.m7 * a.m13 + a.m12 * a.m5 * a.m11 - a.m12 * a.m7 * a.m9
	out.m9 = -a.m0 * a.m9 * a.m15 + a.m0 * a.m11 * a.m13 + a.m8  * a.m1 * a.m15 - a.m8  * a.m3 * a.m13 - a.m12 * a.m1 * a.m11 + a.m12 * a.m3 * a.m9
	out.m10 =  a.m0 * a.m5  * a.m15 - a.m0 * a.m7  * a.m13 - a.m4  * a.m1 * a.m15 + a.m4  * a.m3 * a.m13 + a.m12 * a.m1 * a.m7  - a.m12 * a.m3 * a.m5
	out.m11 = -a.m0 * a.m5  * a.m11 + a.m0 * a.m7  * a.m9 + a.m4  * a.m1 * a.m11 - a.m4  * a.m3 * a.m9 - a.m8  * a.m1 * a.m7  + a.m8  * a.m3 * a.m5
	out.m12 = -a.m4 * a.m9 * a.m14 + a.m4 * a.m10 * a.m13 + a.m8  * a.m5 * a.m14 - a.m8  * a.m6 * a.m13 - a.m12 * a.m5 * a.m10 + a.m12 * a.m6 * a.m9
	out.m13 =  a.m0 * a.m9 * a.m14 - a.m0 * a.m10 * a.m13 - a.m8  * a.m1 * a.m14 + a.m8  * a.m2 * a.m13 + a.m12 * a.m1 * a.m10 - a.m12 * a.m2 * a.m9
	out.m14 = -a.m0 * a.m5  * a.m14 + a.m0 * a.m6  * a.m13 + a.m4  * a.m1 * a.m14 - a.m4  * a.m2 * a.m13 - a.m12 * a.m1 * a.m6  + a.m12 * a.m2 * a.m5
	out.m15 =  a.m0 * a.m5  * a.m10 - a.m0 * a.m6  * a.m9 - a.m4  * a.m1 * a.m10 + a.m4  * a.m2 * a.m9 + a.m8  * a.m1 * a.m6  - a.m8  * a.m2 * a.m5

	local det = a.m0 * out.m0 + a.m1 * out.m4 + a.m2 * out.m8 + a.m3 * out.m12

	if det == 0 then return a end

	det = 1 / det

	out.m0, out.m1, out.m2, out.m3 = out.m0*det, out.m1*det, out.m2*det, out.m3*det
	out.m4, out.m5, out.m6, out.m7 = out.m4*det, out.m5*det, out.m6*det, out.m7*det
	out.m8, out.m9, out.m10, out.m11 = out.m8*det, out.m9*det, out.m10*det, out.m11*det
	out.m12, out.m13, out.m14, out.m15 = out.m12*det, out.m13*det, out.m14*det, out.m15*det

	if mutate == true then
		a:set(out)
		return a
	end
	return out
end

function Matrix4.setFromQuat(self, quat)
	return self:setFromAngleAxis(quat:toAngleAxis())
end

function Matrix4.fromQuat(quat)
	local out = Matrix4()
	out:setFromQuat(quat)
	return out
end

function Matrix4.translate(self, x, y, z)
	tempMatrix:setFromTranslation(x, y, z)
	self:multiply(tempMatrix, true)
	return self
end

function Matrix4.setTranslation(self, x, y, z)
	if math3DTypes.Vector3.isVector3(x) then
		x, y, z = x:unpack()
	end

	self.m12 = x
	self.m13 = y
	self.m14 = z
	
	return self
end

function Matrix4.setFromTranslation(self, x, y, z)
	self:set(Matrix4.identity)
	self:setTranslation(x, y, z)
	return self
end

function Matrix4.fromTranslation(x, y, z)
	local m = Matrix4()
	m:setFromTranslation(x, y, z)
	return m
end

function Matrix4.rotate(self, angle, x, y, z)
	tempMatrix:setFromAngleAxis(angle, x, y, z)
	self:multiply(tempMatrix, true)
	return self
end

function Matrix4.setFromAngleAxis(self, angle, x, y, z)
	if math3DTypes.Vector3.isVector3(x) then
		local axis = x
		local l = axis:getLength()

		self:set(Matrix4.identity)
		
		if l == 0 then
			return self
		end
		
		local x, y, z = axis.x / l, axis.y / l, axis.z / l
		local c = cos(angle)
		local s = sin(angle)
		
		self.m0  = x * x * (1 - c) + c
		
		self.m1  = y * x * (1 - c) + z * s
		self.m2  = x * z * (1 - c) - y * s
		self.m4  = x * y * (1 - c) - z * s
		self.m5  = y * y * (1 - c) + c
		self.m6  = y * z * (1 - c) + x * s
		self.m8  = x * z * (1 - c) + y * s
		self.m9 = y * z * (1 - c) - x * s
		self.m10 = z * z * (1 - c) + c
		
		return self
	end
	tempVector3_1:set(x, y, z)
	return self:setFromAngleAxis(angle, tempVector3_1)
end

function Matrix4.fromAngleAxis(angle, x, y, z)
	local out = Matrix4()
	out:setFromAngleAxis(angle, x, y, z)
	return out
end

function Matrix4.scale(self, x, y, z)
	tempMatrix:setFromScale(x, y, z)
	self:multiply(tempMatrix, true)
	return self
end

function Matrix4.setScale(self, x, y, z)
	if math3DTypes.Vector3.isVector3(x) then
		x, y, z = x:unpack()
	end
	self.m0 = x
	self.m5 = y
	self.m10 = z
	return self
end

function Matrix4.setFromScale(self, x, y, z)
	self:set(Matrix4.identity)
	self:setScale(x, y, z)
	return self
end

function Matrix4.fromScale(x, y, z)
	local m = Matrix4()
	m:setFromScale(x, y, z)
	return m
end

function Matrix4.setPerspective(self, fovy, aspect, near, far)
	assert(aspect ~= 0)
	assert(near   ~= far)

	local t = tan(rad(fovy) / 2)
	self:set(Matrix4.default)
	self.m0 =  1 / (t * aspect)
	self.m5 =  1 / t
	self.m10 = -(far + near) / (far - near)
	self.m11 = -1
	self.m14 = -(2 * far * near) / (far - near)
	self.m15 =  0

	return self
end

function Matrix4.perspective(fovy, aspect, near, far)
	local m = Matrix4()
	m:setPerspective(fovy, aspect, near, far)
	return m
end

function Matrix4.unpack(v)
	return
	v.m0, v.m1, v.m2, v.m3,
	v.m4, v.m5, v.m6, v.m7,
	v.m8, v.m9, v.m10, v.m11,
	v.m12, v.m13, v.m14, v.m15
end

function Matrix4.isMatrix4(arg)
	return ffi.istype("Matrix4", arg)
end

function Matrix4.__mul(v1, v2)
	return Matrix4.multiply(v1, v2, false)
end

function Matrix4.__eq(v1, v2)
	if (not ffi.istype("Matrix4",v2)) or (not ffi.istype("Matrix4",v1)) then return false end
	return
	v1.m0 == v2.m0 and v1.m1 == v2.m1 and v1.m2 == v2.m2 and v1.m3 == v2.m3 and
	v1.m4 == v2.m4 and v1.m5 == v2.m5 and v1.m6 == v2.m6 and v1.m7 == v2.m7 and
	v1.m8 == v2.m8 and v1.m9 == v2.m9 and v1.m10 == v2.m10 and v1.m11 == v2.m11 and
	v1.m12 == v2.m12 and v1.m13 == v2.m13 and v1.m14 == v2.m14 and v1.m15 == v2.m15
end

function Matrix4.__tostring(t)
	return string.format(
		"(%.4f, %.4f, %.4f, %.4f\n%.4f, %.4f, %.4f, %.4f\n%.4f, %.4f, %.4f, %.4f\n%.4f, %.4f, %.4f, %.4f)",
		t.m0, t.m1, t.m2, t.m3,
		t.m4, t.m5, t.m6, t.m7,
		t.m8, t.m9, t.m10, t.m11,
		t.m12, t.m13, t.m14, t.m15)
end

function Matrix4.__concat(v1, v2)
	return v1 .. tostring(v2)
end

local Matrix4_T

function Matrix4.__call()
	return Matrix4_T()
end

function Matrix4.initialize(types)
	math3DTypes = types
	tempVector3_1 = types.Vector3()
	tempMatrix = types.Matrix4()
	tempMultiplyMatrix = types.Matrix4()
	tempInvertMatrix = types.Matrix4()
end

Matrix4_T = ffi.metatype("Matrix4", Matrix4)

Matrix4.identity = Matrix4_T.createIdentity()
Matrix4.default = Matrix4_T()

return Matrix4_T
