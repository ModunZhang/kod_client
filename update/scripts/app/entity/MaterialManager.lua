local Enum = import("..utils.Enum")
local Observer = import(".Observer")
local MaterialManager = class("MaterialManager", Observer)
MaterialManager.MATERIAL_TYPE = Enum("BUILD", "DRAGON", "SOLDIER", "EQUIPMENT")
local MATERIAL_TYPE = MaterialManager.MATERIAL_TYPE
local BUILD = MATERIAL_TYPE.BUILD
local DRAGON = MATERIAL_TYPE.DRAGON
local SOLDIER = MATERIAL_TYPE.SOLDIER
local EQUIPMENT = MATERIAL_TYPE.EQUIPMENT
function MaterialManager:ctor()
    MaterialManager.super.ctor(self)
    self.material_map = {}
    self.material_map[MaterialManager.MATERIAL_TYPE.BUILD] = {
        ["tiles"] = 0,
        ["saddle"] = 0,
        ["bowTarget"] = 0,
        ["pulley"] = 0,
        ["tools"] = 0,
        ["ironPart"] = 0,
        ["blueprints"] = 0,
        ["trainingFigure"] = 0,
    }
    self.material_map[MaterialManager.MATERIAL_TYPE.DRAGON] = {
        ["moltenCore"] = 0,
        ["chargedMagnet"] = 0,
        ["dolanRune"] = 0,
        ["infernoSoul"] = 0,
        ["warsongRune"] = 0,
        ["challengeRune"] = 0,
        ["steelIngot"] = 0,
        ["moltenShard"] = 0,
        ["moltenMagnet"] = 0,
        ["lavaSoul"] = 0,
        ["glacierMagnet"] = 0,
        ["rageRune"] = 0,
        ["giantRune"] = 0,
        ["arcaniteIngot"] = 0,
        ["moltenShiver"] = 0,
        ["fairySoul"] = 0,
        ["chargedShiver"] = 0,
        ["blizzardSoul"] = 0,
        ["mithrilIngot"] = 0,
        ["blackIronIngot"] = 0,
        ["wispOfCold"] = 0,
        ["wispOfFire"] = 0,
        ["ironIngot"] = 0,
        ["guardRune"] = 0,
        ["wispOfWind"] = 0,
        ["forestSoul"] = 0,
        ["poisonRune"] = 0,
        ["eternityRune"] = 0,
        ["chargedShard"] = 0,
        ["arcanaRune"] = 0,
        ["glacierShard"] = 0,
        ["glacierCore"] = 0,
        ["infernoRune"] = 0,
        ["suppressRune"] = 0,
        ["glacierShiver"] = 0,
        ["chargedCore"] = 0,
        ["iceSoul"] = 0,
    }
    self.material_map[MaterialManager.MATERIAL_TYPE.SOLDIER] = {
        ["heroBones"] = 0,
        ["magicBox"] = 0,
        ["holyBook"] = 0,
        ["brightAlloy"] = 0,
        ["soulStone"] = 0,
        ["deathHand"] = 0,
        ["confessionHood"] = 0,
        ["brightRing"] = 0,
    }
    self.material_map[MaterialManager.MATERIAL_TYPE.EQUIPMENT] = {
        ["fireSuppressChest"] = 0,
        ["rageSting"] = 0,
        ["frostChest"] = 0,
        ["moltenArmguard"] = 0,
        ["eternitySting"] = 0,
        ["rageArmguard"] = 0,
        ["poisonChest"] = 0,
        ["blizzardArmguard"] = 0,
        ["infernoCrown"] = 0,
        ["dolanSting"] = 0,
        ["frostCrown"] = 0,
        ["glacierCrown"] = 0,
        ["windSuppressSting"] = 0,
        ["warsongChest"] = 0,
        ["frostOrb"] = 0,
        ["poisonArmguard"] = 0,
        ["coldSuppressArmguard"] = 0,
        ["eternityOrb"] = 0,
        ["rageChest"] = 0,
        ["fireSuppressArmguard"] = 0,
        ["windSuppressChest"] = 0,
        ["windSuppressOrb"] = 0,
        ["blizzardSting"] = 0,
        ["giantSting"] = 0,
        ["warsongSting"] = 0,
        ["dolanChest"] = 0,
        ["giantArmguard"] = 0,
        ["poisonCrown"] = 0,
        ["moltenCrown"] = 0,
        ["dolanArmguard"] = 0,
        ["dolanCrown"] = 0,
        ["blizzardCrown"] = 0,
        ["giantChest"] = 0,
        ["fireSuppressOrb"] = 0,
        ["eternityChest"] = 0,
        ["infernoSting"] = 0,
        ["giantCrown"] = 0,
        ["warsongCrown"] = 0,
        ["blizzardOrb"] = 0,
        ["coldSuppressOrb"] = 0,
        ["infernoOrb"] = 0,
        ["fireSuppressCrown"] = 0,
        ["dolanOrb"] = 0,
        ["giantOrb"] = 0,
        ["chargedCrown"] = 0,
        ["eternityArmguard"] = 0,
        ["rageOrb"] = 0,
        ["frostArmguard"] = 0,
        ["warsongOrb"] = 0,
        ["warsongArmguard"] = 0,
        ["glacierArmguard"] = 0,
        ["coldSuppressCrown"] = 0,
        ["windSuppressCrown"] = 0,
        ["coldSuppressChest"] = 0,
        ["fireSuppressSting"] = 0,
        ["poisonOrb"] = 0,
        ["infernoChest"] = 0,
        ["coldSuppressSting"] = 0,
        ["infernoArmguard"] = 0,
        ["eternityCrown"] = 0,
        ["chargedArmguard"] = 0,
        ["frostSting"] = 0,
        ["rageCrown"] = 0,
        ["blizzardChest"] = 0,
        ["windSuppressArmguard"] = 0,
        ["poisonSting"] = 0,
    }
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
        [BUILD] = "materials",
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









