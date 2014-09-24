local Observer = import(".Observer")
local DragonEquipManager = class("DragonEquipManager", Observer)

function DragonEquipManager:ctor()
	DragonEquipManager.super.ctor(self)
    self.equip_map = {
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
function DragonEquipManager:GetEquipMap()
	return self.equip_map
end
function DragonEquipManager:GetCountByType(equip_type)
	return self.equip_map[equip_type]
end
function DragonEquipManager:OnUserDataChanged(user_data)
	local new_equipments = user_data.dragonEquipments
	local changed = {}
	for k, v in pairs(self.equip_map) do
		if new_equipments[k] ~= v then
			changed[k] = v
		end
	end
	self.equip_map = new_equipments
	for _, _ in pairs(changed) do
		self:NotifyObservers(function(listener)
			listener:OnEquipCountChanged(self, changed, new_equipments)
		end)
		break
	end
end


return DragonEquipManager
