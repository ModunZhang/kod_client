local PeopleSprite = import(".PeopleSprite")
local SoldierSprite = class("SoldierSprite", PeopleSprite)
local soldier_config = {
    ----
    ["swordsman"] = {
        count = 4,
        {"Infantry_1_render", 0, 50, 0.3},
        {"Infantry_1_render", 0, 50, 0.3},
        {"Infantry_1_render", 0, 50, 0.3},
    },
    ["ranger"] = {
        count = 4,
        {"Archer_1_render", 30, 50, 0.3},
        {"Archer_1_render", 30, 50, 0.3},
        {"Archer_1_render", 30, 50, 0.3},
    },
    ["lancer"] = {
        count = 2,
        {"Cavalry_1_render", 20, 50, 0.3},
        {"Cavalry_1_render", 20, 50, 0.3},
        {"Cavalry_1_render", 20, 50, 0.3},
    },
    ["catapult"] = {
        count = 1,
        {"Catapult_1_render", -10, 50, 0.4},
        {"Catapult_1_render", -10, 50, 0.4},
        {"Catapult_1_render", -10, 50, 0.4},
    },

    -----
    ["sentinel"] = {
        count = 4,
        {"Infantry_1_render", 0, 50, 0.3},
        {"Infantry_1_render", 0, 50, 0.3},
        {"Infantry_1_render", 0, 50, 0.3},
    },
    ["crossbowman"] = {
        count = 4,
        {"Archer_1_render", 30, 50, 0.3},
        {"Archer_1_render", 30, 50, 0.3},
        {"Archer_1_render", 30, 50, 0.3},
    },
    ["horseArcher"] = {
        count = 2,
        {"Cavalry_1_render", 20, 50, 0.3},
        {"Cavalry_1_render", 20, 50, 0.3},
        {"Cavalry_1_render", 20, 50, 0.3},
    },
    ["ballista"] = {
        count = 1,
        {"Catapult_1_render", -10, 50, 0.4},
        {"Catapult_1_render", -10, 50, 0.4},
        {"Catapult_1_render", -10, 50, 0.4},
    },
    ----
    ["skeletonWarrior"] = {
        count = 4,
        {"Infantry_1_render", 0, 50, 0.3},
    },
    ["skeletonArcher"] = {
        count = 4,
        {"Archer_1_render", 30, 50, 0.3},
    },
    ["deathKnight"] = {
        count = 2,
        {"Cavalry_1_render", 20, 50, 0.3},
    },
    ["meatWagon"] = {
        count = 1,
        {"Catapult_1_render", -10, 50, 0.4},
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
    self.soldier_star = soldier_star or 1
    SoldierSprite.super.ctor(self, city_layer, x, y)
    self:PlayAnimation("idle_1")
    -- self:GetSprite():setScaleX(1)

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
        ccs.Armature:create(animation):addTo(node):align(display.CENTER, v.x, v.y):scale(s)
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














