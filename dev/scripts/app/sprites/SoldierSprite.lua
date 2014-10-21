local PeopleSprite = import(".PeopleSprite")
local SoldierSprite = class("SoldierSprite", PeopleSprite)
local soldier_config = {
    {
        ["swordsman"] = {
            animation = "Infantry_1_render", count = 4, scale = 0.5, offset = {x = 0, y = 50}
        },
        ["archer"] = {
            animation = "Archer_1_render", count = 4, scale = 0.5, offset = {x = 30, y = 50}
        },
        ["lancer"] = {
            animation = "Cavalry_1_render", count = 2, scale = 0.5, offset = {x = 20, y = 50}
        },
        ["catapult"] = {
            animation = "Catapult_1_render", count = 1, scale = 0.7, offset = {x = -20, y = 80}
        },
        ["sentinel"] = {
            animation = "Infantry_1_render", count = 4, scale = 0.5, offset = {x = 0, y = 50}
        },
        ["crossbowman"] = {
            animation = "Archer_1_render", count = 4, scale = 0.5, offset = {x = 30, y = 50}
        },
        ["horseArcher"] = {
            animation = "Cavalry_1_render", count = 2, scale = 0.5, offset = {x = 20, y = 50}
        },
        ["ballista"] = {
            animation = "Catapult_1_render", count = 1, scale = 0.7, offset = {x = -20, y = 80}
        },
    },
}
local position_map = {
	[1] = {
		{x = 0, y = 0}
	},
	[2] = {
		{x = 30, y = 15},
		{x = 0, y = -15},
	},
	[4] = {
		{x = 0, y = 30},
		{x = -30, y = 0},
		{x = 30, y = 0},
		{x = 0, y = -30},
	}
}
function SoldierSprite:ctor(city_layer, soldier_type, x, y)
    assert(soldier_type)
    self.soldier_type = soldier_type
    SoldierSprite.super.ctor(self, city_layer, x, y)
    -- ui.newTTFLabel({text = soldier_type, size = 20, x = 0, y = 100}):addTo(self, 10)
    self:PlayAnimation("idle_1")
    -- self:CreateBase()
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
    local soldier_type = self.soldier_type
    local config = self:GetConfig()
    local animation = config.animation
    local count = config.count
    local scale = self:RealScale()
    for i, v in ipairs(position_map[count]) do
    	ccs.Armature:create(animation):scale(scale):addTo(node):align(display.CENTER, v.x, v.y)
    end
    return node
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













