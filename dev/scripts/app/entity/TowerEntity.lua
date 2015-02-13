local UpgradeBuilding = import(".UpgradeBuilding")
local TowerEntity = class("TowerEntity", UpgradeBuilding)
local abs = math.abs
function TowerEntity:ctor(building_info)
    TowerEntity.super.ctor(self, building_info)
end
function TowerEntity:UniqueKey()
    return string.format("%s", self:GetType())
end
function TowerEntity:OnUserDataChanged(user_data, current_time)
    local event
    for _,v in ipairs(user_data.buildingEvents or {}) do
        if v.location == 22 then
            event = v
            break
        end
    end
    local finishTime = event == nil and 0 or event.finishTime / 1000
    self:OnEvent(event)
    self:OnHandle(user_data.buildings.location_22.level, finishTime)
end
-- 获取对各兵种攻击力
function TowerEntity:GetAtk()
    local config = self.config_building_function[self:GetType()]
    local level = self.level
    local c = config[level]
    return c.infantry,c.archer,c.cavalry,c.siege
end

return TowerEntity



