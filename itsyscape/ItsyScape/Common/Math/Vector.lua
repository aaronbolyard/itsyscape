--------------------------------------------------------------------------------
-- ItsyScape/Common/Math/Vector.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

local Class = require "ItsyScape.Common.Class"

-- Three-dimensional vector type.
local Vector, Metatable = Class()

-- Constructs a new three-dimensional vector from the provided components.
--
-- Values default to x. If x is not provided, values default to 0.
--
-- Thus Vector(1) gives { 1, 1, 1 }, Vector() gives { 0, 0, 0 },
-- and Vector(1, 2) gives { 1, 2, 1 }.
function Vector:new(x, y, z)
	self.x = x or 0
	self.y = y or x or 0
	self.z = z or x or 0
end

-- Calculates and returns the dot product of two vectors.
function Vector:dot(other)
	return self.x * other.x + self.y * other.y + self.z * other.z
end

-- Calculates the cross product of two vectors.
function Vector:cross(other)
	local s = self.y * other.z - self.z * other.y
	local t = self.z * other.x - self.x * other.z
	local r = self.x * other.y - self.y * other.x

	return Vector(s, t, r)
end

-- Gets the length (i.e., magnitude) of the vector, squared.
function Vector:getLengthSquared()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

-- Gets the length (i.e., magnitude) of the vector.
function Vector:getLength()
	return math.sqrt(self:getLengthSquared())
end

-- Returns a normal of the vector.
function Vector:getNormal()
	local length = self:getLength()
	if length == 0 then
		return self
	else
		return self / self:getLength()
	end
end

-- Adds two vectors or a vector and a scalar.
--
-- If 'a' is a scalar, 'a' added to each component of 'b' and vice versa for
-- 'b'.
function Metatable.__add(a, b)
	local result = Vector()

	if type(a) == 'number' then
		result.x = a + b.x
		result.y = a + b.y
		result.z = a + b.z
	elseif type(b) == 'number' then
		result.x = a.x + b
		result.y = a.y + b
		result.z = a.z + b
	else
		result.x = a.x + b.x
		result.y = a.y + b.y
		result.z = a.z + b.z
	end

	return result
end

-- Subtructs a vector or a vector and a scalar.
--
-- If 'a' is a scalar, the returned vector is { a, a, a } - { b.x, b.y, b.z }
-- and vice versa for 'b'.
function Metatable.__sub(a, b)
	local result = Vector()

	if type(a) == 'number' then
		result.x = a - b.x
		result.y = a - b.y
		result.z = a - b.z
	elseif type(b) == 'number' then
		result.x = a.x - b
		result.y = a.y - b
		result.z = a.z - b
	else
		result.x = a.x - b.x
		result.y = a.y - b.y
		result.z = a.z - b.z
	end

	return result
end

-- Multiplies two vectors or a vector and a scalar.
--
-- If 'a' is a scalar, 'a' multiplied with each component of 'b' and vice versa
-- for 'b'.
function Metatable.__mul(a, b)
	local result = Vector()

	if type(a) == 'number' then
		result.x = a * b.x
		result.y = a * b.y
		result.z = a * b.z
	elseif type(b) == 'number' then
		result.x = a.x * b
		result.y = a.y * b
		result.z = a.z * b
	else
		result.x = a.x * b.x
		result.y = a.y * b.y
		result.z = a.z * b.z
	end

	return result
end


-- Divides a vector or a vector and a scalar.
--
-- If 'a' is a scalar, the returned vector is { a, a, a } / { b.x, b.y, b.z }
-- and vice versa for 'b'.
function Metatable.__div(a, b)
	local result = Vector()

	if type(a) == 'number' then
		result.x = a / b.x
		result.y = a / b.y
		result.z = a / b.z
	elseif type(b) == 'number' then
		result.x = a.x / b
		result.y = a.y / b
		result.z = a.z / b
	else
		result.x = a.x / b.x
		result.y = a.y / b.y
		result.z = a.z / b.z
	end

	return result
end

-- Negates a vector.
--
-- Returns { -x, -y, -z }.
function Metatable.__unm(a)
	return Vector(-a.x, -a.y, -a.z)
end

return Vector
