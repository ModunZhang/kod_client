local PeopleSprite = import(".PeopleSprite")
local SoldierSprite = class("SoldierSprite", PeopleSprite)
local soldier_config = {
    {
        ["swordsman"] = {
            animation = "Infantry_1_render", scale = 0.5, offset = {x = 0, y = 50}
        },
        ["archer"] = {
            animation = "Archer_1_render", scale = 0.5, offset = {x = 30, y = 50}
        },
        ["lancer"] = {
            animation = "Cavalry_1_render", scale = 0.5, offset = {x = 20, y = 50}
        },
        ["catapult"] = {
            animation = "Catapult_1_render", scale = 0.7, offset = {x = -20, y = 80}
        },
        ["sentinel"] = {
            animation = "Infantry_1_render", scale = 0.5, offset = {x = 0, y = 50}
        },
        ["crossbowman"] = {
            animation = "Archer_1_render", scale = 0.5, offset = {x = 30, y = 50}
        },
        ["horseArcher"] = {
            animation = "Cavalry_1_render", scale = 0.5, offset = {x = 20, y = 50}
        },
        ["ballista"] = {
            animation = "Catapult_1_render", scale = 0.7, offset = {x = -20, y = 80}
        },
    },
}
function SoldierSprite:ctor(city_layer, soldier_type, x, y)
    assert(soldier_type)
    self.soldier_type = soldier_type
    SoldierSprite.super.ctor(self, city_layer, x, y)
    -- ui.newTTFLabel({text = soldier_type, size = 20, x = 0, y = 100}):addTo(self, 10)
    self:PlayAnimation("idle_1")
end
function SoldierSprite:CreateSprite()
    local armature = ccs.Armature:create(self:GetConfig().animation)
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:setScale(self:RealScale())
    return armature
end
function SoldierSprite:GetSpriteOffset()
    local offset = self:GetConfig().offset
    return offset.x, offset.y
end
function SoldierSprite:CreateBase()
    self:GenerateBaseTiles(2, 2)
end
function SoldierSprite:GetSoldierType()
    return self.soldier_type
end
function SoldierSprite:RealScale()
    return self:GetConfig().scale
end
function SoldierSprite:GetConfig()
    return soldier_config[1][self.soldier_type]
end

return SoldierSprite







