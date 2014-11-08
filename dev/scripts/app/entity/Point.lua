--
-- Author: Danny He
-- Date: 2014-11-08 10:09:39
--
local Point = class("Point")

function Point:ctor(location)
	self.x = location.x or 0
	self.y = location.y or 0
end

function Point:Set(location)
	self.x = location.x or self.x
	self.y = location.y or self.y
end

function Point:SetX(x)
	self.x = x or self.x 
end

function Point:SetY(y)
	self.y = y or self.y 
end

function Point:Get()
	return self.x,self.y
end

function Point:GetX()
	return self.x
end

function Point:GetY()
	return self.y
end

return Point