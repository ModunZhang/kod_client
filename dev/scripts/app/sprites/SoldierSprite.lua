local PeopleSprite = import(".PeopleSprite")
local SoldierSprite = class("SoldierSprite", PeopleSprite)
local soldier_config = {
    ["swordsman"] = {
        count = 4,
        {"bubing_1", 10, 50, 1},
        {"bubing_2", 0, 40, 1},
        {"bubing_3", 0, 40, 1},
    },
    ["ranger"] = {
        count = 4,
        {"gongjianshou_1", 10, 50, 1},
        {"gongjianshou_1", 0, 40, 1},
        {"gongjianshou_1", 0, 40, 1},
    },
    ["lancer"] = {
        animation = "Cavalry_1_render", count = 2, scale = 0.3, offset = {x = 20, y = 50}
    },
    ["catapult"] = {
        animation = "Catapult_1_render", count = 1, scale = 0.4, offset = {x = -10, y = 50}
    },
    --
    ["sentinel"] = {
        animation = "Infantry_1_render", count = 4, scale = 0.3, offset = {x = 0, y = 50}
    },
    ["crossbowman"] = {
        animation = "Archer_1_render", count = 4, scale = 0.3, offset = {x = 30, y = 50}
    },
    ["horseArcher"] = {
        animation = "Cavalry_1_render", count = 2, scale = 0.3, offset = {x = 20, y = 50}
    },
    ["ballista"] = {
        animation = "Catapult_1_render", count = 1, scale = 0.4, offset = {x = -10, y = 50}
    },

    --
    ["skeletonWarrior"] = {
        animation = "Infantry_1_render", count = 4, scale = 0.3, offset = {x = 0, y = 50}
    },
    ["skeletonArcher"] = {
        animation = "Archer_1_render", count = 4, scale = 0.3, offset = {x = 30, y = 50}
    },
    ["deathKnight"] = {
        animation = "Cavalry_1_render", count = 2, scale = 0.3, offset = {x = 20, y = 50}
    },
    ["meatWagon"] = {
        animation = "Catapult_1_render", count = 1, scale = 0.4, offset = {x = -10, y = 50}
    },
}
local position_map = {
    [1] = {
        {x = 0, y = 0}
    },
    [2] = {
        {x = 10, y = -10},
        {x = -15, y = -25},
    },
    [4] = {
        {x = 0, y = -5},
        {x = -25, y = -20},
        {x = 25, y = -20},
        {x = 0, y = -35},
    }
}
function SoldierSprite:ctor(city_layer, soldier_type, x, y)
    assert(soldier_type)
    self.soldier_type = soldier_type
    self.soldier_star = soldier_star or 3
    SoldierSprite.super.ctor(self, city_layer, x, y)
    self:PlayAnimation("idle_45")

    self:CreateBase()
    -- ui.newTTFLabel({text = soldier_type, size = 20, x = 0, y = 100}):addTo(self, 10)
end
function SoldierSprite:CreateSprite()
    local node = display.newNode()
    function node:getAnimation()
        return self
    end
    function node:play(...)
        local args = {...}
        table.foreach(self:getChildren(), function(_, v)
            v:getAnimation():play(unpack(args))
        end)
    end
    function node:stop(...)
        local args = {...}
        table.foreach(self:getChildren(), function(_, v)
            v:getAnimation():stop(unpack(args))
        end)
    end
    function node:getCurrentMovementID(...)
        local args = {...}
        local ani_name
        table.foreach(self:getChildren(), function(_, v)
            ani_name = v:getAnimation():getCurrentMovementID(unpack(args))
            return true
        end)
        return ani_name
    end
    function node:setMovementEventCallFunc(...)
        local args = {...}
        table.foreach(self:getChildren(), function(_, v)
            v:getAnimation():setMovementEventCallFunc(unpack(args))
        end)
    end
    local animation,_,_,s = unpack(self:GetConfig()[self.soldier_star])
    for _,v in ipairs(position_map[self:GetConfig().count]) do
        local armature = ccs.Armature:create(animation):addTo(node):align(display.CENTER, v.x, v.y)
        armature:setScaleX(-s)
        armature:setScaleY(s)
    end
    return node
end
function SoldierSprite:GetLogicPosition()
    return self.x, self.y
end
function SoldierSprite:GetSpriteOffset()
    local _,x,y,_ = unpack(self:GetConfig()[self.soldier_star])
    return x, y
end
function SoldierSprite:CreateBase()
    self:GenerateBaseTiles(2, 2)
end
function SoldierSprite:GetSoldierType()
    return self.soldier_type
end
function SoldierSprite:GetConfig()
    return soldier_config[self.soldier_type]
end

return SoldierSprite














