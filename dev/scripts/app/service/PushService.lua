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
	  	self.m_netService:request("logic.playerHandler.setDragonEquipment"
	  		,{dragonType=dragonType,equipmentCategory=equipmentCategory,equipmentName=equipmentName}
	  		, function(success)
	        	cb(success)
			end
			,false
		)
end

function PushService:resetDragonEquipment(dragonType,equipmentCategory,cb)
	if not LuaUtils:isString(dragonType) then cb(false) end
	self.m_netService:request("logic.playerHandler.resetDragonEquipment",{dragonType=dragonType,equipmentCategory=equipmentCategory,equipmentName=equipmentName}, function(success)
	        cb(success)
	end, false)
end

function PushService:enhanceDragonEquipment(dragonType, equipmentCategory, equipments, cb)
	if not LuaUtils:isString(dragonType) then cb(false) end
	self.m_netService:request("logic.playerHandler.enhanceDragonEquipment"
			,{dragonType=dragonType,equipmentCategory=equipmentCategory,equipments=equipments}
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:upgradeDragonStar(dragonType,cb)
	if not LuaUtils:isString(dragonType) then cb(false) end
	self.m_netService:request("logic.playerHandler.upgradeDragonStar"
			,{dragonType=dragonType}
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:upgradeDragonDragonSkill(dragonType, skillLocation, cb)
	if not LuaUtils:isString(dragonType) or string.len(dragonType) == 0 then cb(false) end
	self.m_netService:request("logic.playerHandler.upgradeDragonSkill"
			,{dragonType=dragonType,skillLocation=skillLocation}
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:createAlliance( data,cb )
	for k,v in pairs(data) do
		if not LuaUtils:isString(v) or string.len(v) == 0 then
			cb(false)
			return false
		end
	end
	self.m_netService:request("logic.playerHandler.createAlliance"
			,data
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:searchAllianceByTag( tag,cb )
	if not LuaUtils:isString(tag) or string.len(tag) == 0  then
		cb(false)
		return false
	end
	local data = {tag=tag}
	self.m_netService:request("logic.playerHandler.searchAllianceByTag"
		,data
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:requestToJoinAlliance( allianceId,cb )
	if not LuaUtils:isString(allianceId) or string.len(allianceId) == 0  then
		cb(false)
		return false
	end
	self.m_netService:request("logic.playerHandler.requestToJoinAlliance"
		,{allianceId=allianceId}
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:joinAllianceDirectly( allianceId,cb )
	if not LuaUtils:isString(allianceId) or string.len(allianceId) == 0  then
		cb(false)
		return false
	end
	self.m_netService:request("logic.playerHandler.joinAllianceDirectly"
		,{allianceId=allianceId}
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:cancelJoinAllianceRequest( allianceId,cb )
	if not LuaUtils:isString(allianceId) or string.len(allianceId) == 0  then
		cb(false)
		return false
	end
	self.m_netService:request("logic.playerHandler.cancelJoinAllianceRequest"
		,{allianceId=allianceId}
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:handleJoinAllianceInvite( allianceId,argree,cb )
	if not LuaUtils:isString(allianceId) or string.len(allianceId) == 0 or type(argree)  == 'boolean' then
		cb(false)
		return false
	end
	self.m_netService:request("logic.playerHandler.handleJoinAllianceInvite"
		,{allianceId=allianceId,agree=agree}
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:getCanDirectJoinAlliances(cb)
	self.m_netService:request("logic.playerHandler.getCanDirectJoinAlliances"
		,nil
		,function(success)
			cb(success)
		end
		,true
	)
end

function PushService:getMyAllianceData(cb)
	self.m_netService:request("logic.playerHandler.getMyAllianceData"
		,nil
		,function(success)
			if cb then  
				cb(success)
			end
		end
		,true
	)
	
end

function PushService:quitAlliance(cb)
	self.m_netService:request("logic.playerHandler.quitAlliance"
		,nil
		,function(success)
			if cb then  
				cb(success)
			end
		end
		,true
	)
end

function PushService:editAllianceNotice(description,cb)
	if not LuaUtils:isString(description) then cb(false) return end
	self.m_netService:request("logic.playerHandler.editAllianceDescription"
		,{description=description}
		,function(success)
			if cb then  
				cb(success)
			end
		end
		,true
	)
end

function PushService:editAllianceNotice(notice,cb)
	if not LuaUtils:isString(notice) then cb(false) return end
	self.m_netService:request("logic.playerHandler.editAllianceNotice"
		,{notice=notice}
		,function(success)
			if cb then  
				cb(success)
			end
		end
		,true
	)
end

function PushService:editAllianceBasicInfo(data,cb)
	for k,v in pairs(data) do
		if not LuaUtils:isString(v) or string.len(v) == 0 then
			cb(false)
			return false
		end
	end
	self.m_netService:request("logic.playerHandler.editAllianceBasicInfo"
			,data
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:getPlayerInfo(memberId,cb)
	--TODO:数据校验
	self.m_netService:request("logic.playerHandler.getPlayerInfo"
			,{memberId=memberId}
			,function(success)
				cb(success)
			end
			,true
	)
end

function PushService:kickAllianceMemberOff(memberId, callback)
	self.m_netService:request("logic.playerHandler.kickAllianceMemberOff"
			,{memberId=memberId}
			,function(success)
				callback(success)
			end
			,true
	)
end

function PushService:handOverArchon(memberId, callback)
	self.m_netService:request("logic.playerHandler.handOverArchon"
			,{memberId=memberId}
			,function(success)
				callback(success)
			end
			,true
	)
end

function PushService:modifyAllianceMemberTitle(memberId,title,callback)
	self.m_netService:request("logic.playerHandler.modifyAllianceMemberTitle"
			,{memberId=memberId,title=title}
			,function(success)
				callback(success)
			end
			,true
	)
end