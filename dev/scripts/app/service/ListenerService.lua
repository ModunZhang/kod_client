--
-- Author: dannyhe
-- Date: 2014-08-25 18:03:52
--
ListenerService = {}
local CURRENT_MODULE_NAME = ...
setmetatable(ListenerService, {__index=NetManager})
-----------------------------------------------------
local ChatCenter = import('..entity.ChatCenter')


local events = {
	'onBuildingLevelUp','onHouseLevelUp','onTowerLevelUp','onWallLevelUp', --升级提示相关
	'onChat','onAllChat', -- 聊天相关
}

function ListenerService:_initOrNot()
	if not app.chatCenter  then
		local chatCenter = ChatCenter.new()
    	app.chatCenter = chatCenter
    end
    app.chatCenter:requestAllMessage()
end

function ListenerService:_listenNetMessage()
	for _,v in ipairs(events) do
		if type(v) == 'string' and string.len(v) ~= 0 then
			NetManager:addEventListener(v,function( success,msg )
				if success then
					self:_handleNetMessage(v, msg)
				end
			end)
		end
	end
end


function ListenerService:_handleNetMessage(eventName,msg )
	if not GameGlobalUI then
		import('app.ui.GameGlobalUIUtils',CURRENT_MODULE_NAME)
	end
	if ListenerService['ls_' .. tostring(eventName)] then
		ListenerService['ls_' .. tostring(eventName)](self,msg,eventName)
	else
		printLog("ListenerService",'ls_' .. tostring(eventName) .. " not found")
	end
end

function ListenerService:start()
	self:_initOrNot()
	self:_listenNetMessage()
end

-- listener Method

--Tips
-------------------------------------------------------------------------
function ListenerService:ls_onBuildingLevelUp(msg)
	-- local buildingName = UIKitHelper:getBuildingLocalizedKeyByBuildingType(msg.buildingType)
	-- GameGlobalUI:showTips(_("建筑升级完成"),string.format('%s(LV %d)',_(buildingName),msg.level))
end

function ListenerService:ls_onHouseLevelUp(msg)
	-- local houseName = UIKitHelper:getHouseLocalizedKeyByBuildingType(msg.houseType)
	-- GameGlobalUI:showTips(_("小屋升级完成"),string.format('%s(LV %d)',_(houseName),msg.level))
end

function ListenerService:ls_onTowerLevelUp(msg)
	GameGlobalUI:showTips(_("防御塔升级完成"),string.format('LV %d',msg.level))
end


function ListenerService:ls_onWallLevelUp(msg)
	GameGlobalUI:showTips(_("城墙升级完成"),string.format('LV %d',msg.level))
end

--Chat Center
-------------------------------------------------------------------------
function ListenerService:ls_onChat(msg,eventName)
	local chatCenter = app.chatCenter
	if chatCenter then
		chatCenter:handleNetMessage(eventName,msg)
	end
end

function ListenerService:ls_onAllChat(msg,eventName)
	self:ls_onChat(msg,eventName)
end


