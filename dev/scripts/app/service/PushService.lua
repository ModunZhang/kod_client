--
-- Author: Danny He
-- Date: 2014-09-20 10:15:40
--
PushService = {}
local CURRENT_MODULE_NAME = ...
setmetatable(PushService, {__index=NetManager})
-----------------------------------------------------
--龙
function PushService:HatchDragon(dragonType,cb)
	if LuaUtils:isString(dragonType) then
	    self.m_netService:request("logic.playerHandler.hatchDragon",{dragonType=dragonType}, function(success)
	        cb(success)
	    end, false)
	else
		cb(false)
	end
end

function PushService:setDragonEquipment(dragonType,equipmentCategory,equipmentName,cb)
	if not LuaUtils:isString(dragonType) then cb(false) end
	  self.m_netService:request("logic.playerHandler.setDragonEquipment",{dragonType=dragonType,equipmentCategory=equipmentCategory,equipmentName=equipmentName}, function(success)
	        cb(success)
	end, false)
end

function PushService:resetDragonEquipment(dragonType,equipmentCategory,cb)
	if not LuaUtils:isString(dragonType) then cb(false) end
	self.m_netService:request("logic.playerHandler.resetDragonEquipment",{dragonType=dragonType,equipmentCategory=equipmentCategory,equipmentName=equipmentName}, function(success)
	        cb(success)
	end, false)
end