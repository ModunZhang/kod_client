local PVEMap = import(".PVEMap")
local PVEDatabase = class("PVEDatabase")

local MAX_FLOOR = 1
function PVEDatabase:ctor(user)
    self.user = user
    self.char_x = 12
    self.char_y = 12
    self.char_floor = 1
    self.next_enemy_step = 10
    self.next_gem_step = 10
    local pve_maps = {}
    for i = 1, MAX_FLOOR do
        pve_maps[i] = PVEMap.new(self, i)
    end
    self.pve_maps = pve_maps
end
function PVEDatabase:OnUserDataChanged(user_data)
    local pve = user_data.pve
    if not pve then return end

    local location = pve.location
    if location then
        self.char_x = location.x
        self.char_y = location.y
        self.char_floor = location.z
    end

    if pve.floors then
        for i, v in ipairs(pve.floors) do
            self.pve_maps[v.level]:Load(v)
        end
    end
end
function PVEDatabase:EncodeLocation()
    return {
        x = self.char_x,
        y = self.char_y,
        z = self.char_floor,
    }
end
function PVEDatabase:Reset()
-- local user_default = cc.UserDefault:getInstance()
-- user_default:setStringForKey("char_x", 12)
-- user_default:setStringForKey("char_y", 12)
-- user_default:setStringForKey("char_floor", 1)
-- for _, v in ipairs(self.pve_maps) do
--     user_default:setStringForKey(string.format("pve_%d", v:GetIndex()), "")
-- end
-- user_default:flush()
end
function PVEDatabase:Load()
-- local user_default = cc.UserDefault:getInstance()

-- local default_x = user_default:getStringForKey("char_x")
-- self.char_x = default_x and tonumber(default_x) or 12

-- local default_y = user_default:getStringForKey("char_y")
-- self.char_y = default_y and tonumber(default_y) or 12

-- local default_floor = user_default:getStringForKey("char_floor")
-- self.char_floor = default_floor and tonumber(default_floor) or 1

-- for _, v in ipairs(self.pve_maps) do
--     v:Load(user_default:getStringForKey(string.format("pve_%d", v:GetIndex())))
-- end
-- return self
end
function PVEDatabase:Dump()
-- local user_default = cc.UserDefault:getInstance()
-- user_default:setStringForKey("char_x", self.char_x)
-- user_default:setStringForKey("char_y", self.char_y)
-- user_default:setStringForKey("char_floor", self.char_floor)
-- for _, v in ipairs(self.pve_maps) do
--     user_default:setStringForKey(string.format("pve_%d", v:GetIndex()), v:Dump())
-- end
-- user_default:flush()
-- return self
end
function PVEDatabase:GetCharPosition()
    return self.char_x, self.char_y, self.char_floor
end
function PVEDatabase:SetCharPosition(x, y, floor)
    self.char_x, self.char_y, self.char_floor = x, y, floor or self.char_floor
end
function PVEDatabase:GetMapByIndex(index)
    return self.pve_maps[index]
end
function PVEDatabase:GetSearchedMapList()
    local searched_list = {}
    for _, v in ipairs(self.pve_maps) do
        if not v:IsSearched() then
            break
        end
        searched_list[#searched_list + 1] = v
    end
    return searched_list
end


return PVEDatabase


