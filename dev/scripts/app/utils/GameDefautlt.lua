--
-- Author: Danny He
-- Date: 2014-12-12 14:53:18
--

local GameDefautlt = class("GameDefautlt")


function GameDefautlt:ctor()
	self.game_base_info = self:getTableForKey("GAME_BASE") or {}
	self.ver_info = self:getStringForKey("GAMEDEFAUTLT_VERSION") == "" and "0.0.1" or self:getStringForKey("GAMEDEFAUTLT_VERSION")
	print("===========================================================================")
	dump(self.game_base_info,"GameDefautlt-->game_base_info")
	dump(self.ver_info,"GameDefautlt-->ver_info")
	print("===========================================================================")
end

function GameDefautlt:flush()
	self:setStringForKey("GAMEDEFAUTLT_VERSION",self.ver_info)
	self:setTableForKey("GAME_BASE",self.game_base_info)
	cc.UserDefault:getInstance():flush()
end

function GameDefautlt:getTableForKey(key)
	local jsonString = self:getStringForKey(key)
	if jsonString and string.len(jsonString) > 0 then
		local t = json.decode(jsonString)
		if type(t) == 'table' then
			return t
		end
	end
	return nil
end

function GameDefautlt:setStringForKey(key,str)
	cc.UserDefault:getInstance():setStringForKey(key, str)
end

function GameDefautlt:getStringForKey(key)
	return cc.UserDefault:getInstance():getStringForKey(key)
end

function GameDefautlt:setTableForKey(key,t)
	local jsonString = json.encode(t)
	self:setStringForKey(key,jsonString)
end

-- basic info
function GameDefautlt:setBasicInfoBoolValueForKey(key,val)
	val = checkbool(val)
	self.game_base_info[key] = val
end

function GameDefautlt:getBasicInfoValueForKey(key,default)
	if self.game_base_info[key] == nil and default ~= nil then
		self.game_base_info[key] = default
		self:flush()
	end
	return self.game_base_info[key]
end

function GameDefautlt:setBasicInfoValueForKey(key,val)
	self.game_base_info[key] = val
end

function GameDefautlt:getGameBasicInfo()
	return self.game_base_info
end

return GameDefautlt