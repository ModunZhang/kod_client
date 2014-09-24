local Enum = import("..utils.Enum")
local Observer = import(".Observer")
local MaterialsManager = class("MaterialsManager", Observer)


MaterialsManager.MATERIAL_TYPE = Enum("materials", "dragonEquipments", "dragonMaterials", "soldierMaterials")

function MaterialsManager:ctor()
    MaterialsManager.super.ctor(self)

    self.material_map = {
        ["materials"] = {
            ["tiles"] = 0,
            ["saddle"] = 0,
            ["bowTarget"] = 0,
            ["pulley"] = 0,
            ["blueprints"] = 0,
            ["ironPart"] = 0,
            ["tools"] = 0,
            ["trainingFigure"] = 0,
        },

        ["dragonEquipments"] = {
            ["fireSuppressChest"] = 0,
            ["rageSting"] = 0,
            ["frostChest"] = 0,
            ["moltenArmguard"] = 0,
            ["eternitySting"] = 0,
            ["rageArmguard"] = 0,
            ["poisonChest"] = 0,
            ["blizzardArmguard"] = 0,
            ["infernoCrown"] = 0,
            ["fireSuppressCrown"] = 0,
            ["frostCrown"] = 0,
            ["glacierCrown"] = 0,
            ["eternityCrown"] = 0,
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
            ["windSuppressCrown"] = 0,
            ["giantChest"] = 0,
            ["fireSuppressOrb"] = 0,
            ["eternityChest"] = 0,
            ["infernoSting"] = 0,
            ["giantCrown"] = 0,
            ["warsongCrown"] = 0,
            ["blizzardOrb"] = 0,
            ["infernoChest"] = 0,
            ["infernoOrb"] = 0,
            ["chargedCrown"] = 0,
            ["dolanOrb"] = 0,
            ["giantOrb"] = 0,
            ["infernoArmguard"] = 0,
            ["eternityArmguard"] = 0,
            ["fireSuppressSting"] = 0,
            ["windSuppressSting"] = 0,
            ["rageOrb"] = 0,
            ["warsongArmguard"] = 0,
            ["coldSuppressChest"] = 0,
            ["coldSuppressCrown"] = 0,
            ["warsongOrb"] = 0,
            ["glacierArmguard"] = 0,
            ["poisonOrb"] = 0,
            ["coldSuppressOrb"] = 0,
            ["blizzardCrown"] = 0,
            ["frostArmguard"] = 0,
            ["dolanSting"] = 0,
            ["coldSuppressSting"] = 0,
            ["poisonSting"] = 0,
            ["frostSting"] = 0,
            ["rageCrown"] = 0,
            ["chargedArmguard"] = 0,
            ["windSuppressArmguard"] = 0,
            ["blizzardChest"] = 0,
        },


        ["dragonMaterials"] = {
            ["moltenCore"] = 0,
            ["chargedMagnet"] = 0,
            ["dolanRune"] = 0,
            ["infernoSoul"] = 0,
            ["forestSoul"] = 0,
            ["guardRune"] = 0,
            ["steelIngot"] = 0,
            ["moltenShard"] = 0,
            ["moltenMagnet"] = 0,
            ["lavaSoul"] = 0,
            ["glacierMagnet"] = 0,
            ["rageRune"] = 0,
            ["giantRune"] = 0,
            ["arcaniteIngot"] = 0,
            ["moltenShiver"] = 0,
            ["infernoRune"] = 0,
            ["chargedShiver"] = 0,
            ["blizzardSoul"] = 0,
            ["ironIngot"] = 0,
            ["mithrilIngot"] = 0,
            ["blackIronIngot"] = 0,
            ["glacierCore"] = 0,
            ["wispOfFire"] = 0,
            ["suppressRune"] = 0,
            ["wispOfWind"] = 0,
            ["arcanaRune"] = 0,
            ["glacierShard"] = 0,
            ["eternityRune"] = 0,
            ["wispOfCold"] = 0,
            ["chargedShard"] = 0,
            ["warsongRune"] = 0,
            ["poisonRune"] = 0,
            ["challengeRune"] = 0,
            ["chargedCore"] = 0,
            ["glacierShiver"] = 0,
            ["fairySoul"] = 0,
            ["iceSoul"] = 0,
        },

        ["soldierMaterials"] = {
            ["heroBones"] = 0,
            ["confessionHood"] = 0,
            ["holyBook"] = 0,
            ["brightRing"] = 0,
            ["soulStone"] = 0,
            ["deathHand"] = 0,
            ["brightAlloy"] = 0,
            ["magicBox"] = 0,
        },
    }
end
function MaterialsManager:GetMaterialMap()
	return self.material_map
end
function MaterialsManager:GetMaterialByType(RESOURCE_TYPE,RESOURCE_NAME)
    return self.material_map[RESOURCE_TYPE][RESOURCE_NAME]
end


function MaterialsManager:OnUserDataChanged(user_data)
    local changed = {}
    for i,v in pairs(MaterialsManager.MATERIAL_TYPE) do
    	self.material_map[i] = user_data[i]
        for k,v in pairs(user_data[i]) do
            if self.material_map[i][k]~=v then
                table.insert(changed, i..":"..k)
            end
        end
    end
    if #changed > 0 then
        self:NotifyObservers(function(listener)
            listener:OnSoliderCountChanged(self, changed)
        end)
    end
end

return MaterialsManager