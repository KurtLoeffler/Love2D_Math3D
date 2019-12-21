local currentDir = (...) and (...):gsub('%.init$', '').."." or ""

local result = {
    Vector3 = require(currentDir.."Vector3"),
    Vector4 = require(currentDir.."Vector4"),
    Quat = require(currentDir.."Quat"),
    Matrix4 = require(currentDir.."Matrix4"),
}

result.Vector3.initialize(result)
result.Vector4.initialize(result)
result.Quat.initialize(result)
result.Matrix4.initialize(result)

return result
