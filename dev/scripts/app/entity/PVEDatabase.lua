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
    elseif pve.__floors then
        for _, v in ipairs(pve.__floors) do
            local type_ = v.type
            if type_ == "add" then
                local data = v.data
                self.pve_maps[data.level]:Load(data)
            elseif type_ == "edit" then
                local data = v.data
                self.pve_maps[data.level]:Load(data)
            elseif type_ == "remove" then
                assert(false)
            end
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



