local Enum = import("..utils.Enum")
local Observer = import(".Observer")
local MaterialManager = class("MaterialManager", Observer)
MaterialManager.MATERIAL_TYPE = Enum("BUILD", "TECHNOLOGY","DRAGON", "SOLDIER", "EQUIPMENT")
local MATERIAL_TYPE = MaterialManager.MATERIAL_TYPE
local BUILD = MATERIAL_TYPE.BUILD
local TECHNOLOGY = MATERIAL_TYPE.TECHNOLOGY
local DRAGON = MATERIAL_TYPE.DRAGON
local SOLDIER = MATERIAL_TYPE.SOLDIER
local EQUIPMENT = MATERIAL_TYPE.EQUIPMENT

local dragonEquipments = GameDatas.DragonEquipments.equipments
local soldierMaterials = GameDatas.PlayerInitData.soldierMaterials
local dragonMaterials = GameDatas.PlayerInitData.dragonMaterials
function MaterialManager:ctor()
    MaterialManager.super.ctor(self)
    self.material_map = {}
    self.material_map[BUILD] = {
        ["tiles"] = 0,
        ["pulley"] = 0,
        ["tools"] = 0,
        ["blueprints"] = 0,
    }
    self.material_map[TECHNOLOGY] = {
        ["saddle"] = 0,
        ["bowTarget"] = 0,
        ["ironPart"] = 0,
        ["trainingFigure"] = 0,
    }
    self.material_map[DRAGON] = self:GetTableFromKey__(dragonMaterials)
    self.material_map[SOLDIER] = self:GetTableFromKey(soldierMaterials)
    self.material_map[EQUIPMENT] = self:GetTableFromKey(dragonEquipments)
end
function MaterialManager:GetTableFromKey(t)
    local r = {}
    for k,_ in pairs(t) do
        if k ~= "level" then
            r[k] = 0
        end
    end
    return r
end
function MaterialManager:GetTableFromKey__(t)
    local r = {}
    for _,v in pairs(t) do
        for k,_ in pairs(v) do
            if  k ~= "level" then
                r[k] = 0
            end
        end
    end
    return r
end
function MaterialManager:GetMaterialMap()
    return self.material_map
end
function MaterialManager:GetMaterialsByType(material_type)
    return self.material_map[material_type]
end
function MaterialManager:IteratorBuildMaterialsByType(func)
    self:IteratorMaterialsByType(BUILD, func)
end
function MaterialManager:IteratorDragonMaterialsByType(func)
    self:IteratorMaterialsByType(DRAGON, func)
end
function MaterialManager:IteratorSoldierMaterialsByType(func)
    self:IteratorMaterialsByType(SOLDIER, func)
end
function MaterialManager:IteratorEquipmentMaterialsByType(func)
    self:IteratorMaterialsByType(EQUIPMENT, func)
end
function MaterialManager:IteratorMaterialsByType(material_type, func)
    for k, v in pairs(self.material_map[material_type]) do
        func(k, v)
    end
end
function MaterialManager:OnUserDataChanged(user_data)
    local user_map = {
        [BUILD] = "buildingMaterials",
        [TECHNOLOGY] = "technologyMaterials",
        [DRAGON] = "dragonMaterials",
        [SOLDIER] = "soldierMaterials",
        [EQUIPMENT] = "dragonEquipments",
    }
    for i, v in ipairs(user_map) do
        if user_data[v] then
            self:OnMaterialsComing(i, user_data[v])
        end
    end
end
function MaterialManager:OnMaterialsComing(material_type, materials)
    local changed = {}
    local old_materials = self.material_map[material_type]
    for k, old in pairs(old_materials) do
        local new = materials[k]
        if new and old ~= new then
            old_materials[k] = new
            changed[k] = {old = old, new = new}
        end
    end
    -- for k, new in pairs(materials) do
    --     local old = old_materials[k]
    --     if new ~= old then
    --         old_materials[k] = new
    --         changed[k] = {old = old, new = new}
    --     end
    -- end
    for _, _ in pairs(changed) do
        self:NotifyObservers(function(listener)
            listener:OnMaterialsChanged(self, material_type, changed)
        end)
        break
    end
end

return MaterialManager










