local Sprite = import(".Sprite")
local CitizenSprite = class("CitizenSprite", Sprite)

local scale = 0.3
function CitizenSprite:ctor(city_layer, city, x, y)
    self.city = city
    self.path = city:FindAPointWayFromTile()
    CitizenSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    self:TurnRight()
    self:PlayAnimation("move_1")
    local start_point = table.remove(self.path, 1)
    self:setPosition(self:GetLogicMap():ConvertToMapPosition(start_point.x, start_point.y))
    self:UpdateVelocityByPoints(start_point, self.path[1])
end
function CitizenSprite:PlayAnimation(animation)
    self.current_animation = animation
    self.sprite:getAnimation():play(animation)
end
function CitizenSprite:CreateSprite()
    local armature = ccs.Armature:create("Infantry_1_render")
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    -- armature:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
    -- self.idle_count = 0
    return armature
end
function CitizenSprite:TurnRight()
    self:GetSprite():setScaleX(scale)
    self:GetSprite():setScaleY(scale)
    return self
end
function CitizenSprite:TurnLeft()
    self:GetSprite():setScaleX(-scale)
    self:GetSprite():setScaleY(scale)
    return self
end
function CitizenSprite:GetSpriteOffset()
    return 0, 15
end
function CitizenSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function CitizenSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
local function wrap_point_in_table(...)
    local arg = {...}
    return {x = arg[1], y = arg[2]}
end
function CitizenSprite:UpdateVelocityByPoints(start_point, end_point)
    local speed = 50
    local logic_map = self:GetLogicMap()
    local spt = wrap_point_in_table(logic_map:ConvertToMapPosition(start_point.x, start_point.y))
    local ept = wrap_point_in_table(logic_map:ConvertToMapPosition(end_point.x, end_point.y))
    local dir = cc.pSub(ept, spt)
    local distance = cc.pGetLength(dir)
    self.speed = {x = speed * dir.x / distance, y = speed * dir.y / distance}
end
function CitizenSprite:Speed()
    return self.speed
end
function CitizenSprite:Update(dt)
    local x, y = self:getPosition()
    local point = self.path[1]
    local ex, ey = self:GetLogicMap():ConvertToMapPosition(point.x, point.y)
    local disSQ = cc.pDistanceSQ({x = x, y = y}, {x = ex, y = ey})
    if disSQ < 10 * 10 then
        if #self.path <= 1 then
            self.path = self.city:FindAPointWayFromPosition(point.x, point.y)
        end
        local path = self.path
        self:UpdateVelocityByPoints(path[1], path[2])
        table.remove(path, 1)
    end
    local speed = self:Speed()
    self:setPosition(x + speed.x * dt, y + speed.y * dt)
end

return CitizenSprite







