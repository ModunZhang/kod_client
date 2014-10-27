--
-- Author: dannyhe
-- Date: 2014-08-25 18:03:52
--
ListenerService = {}
local CURRENT_MODULE_NAME = ...
setmetatable(ListenerService, {__index=NetManager})
local ListenEventDispather = class("ListenEventDispather")

function ListenEventDispather:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end


-----------------------------------------------------
local ChatCenter = import('..entity.ChatCenter')


local events_to_listen = {
    'onBuildingLevelUp','onHouseLevelUp','onTowerLevelUp','onWallLevelUp', --升级提示相关
    'onChat','onAllChat', -- 聊天相关
    'onNewMailReceived','onGetMailsSuccess','onGetSavedMailsSuccess','onGetSendMailsSuccess','onSendMailSuccess', -- 邮件
    'onSearchAlliancesSuccess',"onGetCanDirectJoinAlliancesSuccess","onGetAllianceDataSuccess","onAllianceDataChanged","onAllianceNewEventReceived",-- 联盟
    'onAllianceMemberDataChanged','onAllianceBasicInfoAndMemberDataChanged',
    'onGetPlayerInfoSuccess',
}


function ListenerService:OnListenEvnet(eventName,tag,callback)
    self.dispather_:addEventListener(eventName,callback,tag)
end

function ListenerService:RemoveEventByTag( tag )
    self.dispather_:removeEventListenersByTag(tag)
end

function ListenerService:_initOrNot()
    if not app.chatCenter  then
        local chatCenter = ChatCenter.new()
        app.chatCenter = chatCenter
    end
    -- app.chatCenter:requestAllMessage()
end

onSearchAlliancesSuccess_callbacks = {}
onGetCanDirectJoinAlliancesSuccess_callbacks = {}
function ListenerService:_listenNetMessage()
    for _,v in ipairs(events_to_listen) do
        if type(v) == 'string' and string.len(v) ~= 0 then
            NetManager:addEventListener(v,function( success,msg )
                if success then
                    LuaUtils:outputTable(v, msg)
                    self:_handleNetMessage(v, msg)
                end
                -- 搜索回调
                if v == "onSearchAlliancesSuccess" then
                    assert(#onSearchAlliancesSuccess_callbacks <= 1, "重复请求过多了!")
                    local callback = onSearchAlliancesSuccess_callbacks[1]
                    if type(callback) == "function" then
                        callback(success, msg)
                    end
                    onSearchAlliancesSuccess_callbacks = {}
                elseif  v == "onGetCanDirectJoinAlliancesSuccess" then
                    assert(#onGetCanDirectJoinAlliancesSuccess_callbacks <= 1, "重复请求过多了!")
                    local callback = onGetCanDirectJoinAlliancesSuccess_callbacks[1]
                    if type(callback) == "function" then
                        callback(success, msg)
                    end
                    onGetCanDirectJoinAlliancesSuccess_callbacks = {}
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
    self.dispather_ = ListenEventDispather.new()
    self:_initOrNot()
    self:_listenNetMessage()
end

-- listener Method

--Tips
-------------------------------------------------------------------------
function ListenerService:ls_onBuildingLevelUp(msg)
    local buildingName = UIKit:getBuildingLocalizedKeyByBuildingType(msg.buildingType)
    GameGlobalUI:showTips(_("建筑升级完成"),string.format('%s(LV %d)',_(buildingName),msg.level))
end

function ListenerService:ls_onHouseLevelUp(msg)
    local houseName = UIKit:getHouseLocalizedKeyByBuildingType(msg.houseType)
    GameGlobalUI:showTips(_("小屋升级完成"),string.format('%s(LV %d)',_(houseName),msg.level))
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

-- Alliance
-------------------------------------------------------------------------
--data to alliance
-- function ListenerService:dispatchEventToAllianceManager_(msg,eventName)
-- 	local allianceManager = DataManager:GetManager("AllianceManager")
-- 	if allianceManager then
-- 		allianceManager:dispatchAlliceServerData(eventName,msg)
-- 	end
-- end

function ListenerService:ls_onGetCanDirectJoinAlliancesSuccess(msg,eventName)
-- self:dispatchEventToAllianceManager_(msg,eventName)
end

function ListenerService:ls_onSearchAlliancesSuccess(msg,eventName)
-- self:dispatchEventToAllianceManager_(msg,eventName)
end

function ListenerService:ls_onAllianceDataChanged(msg,eventName)
    -- self:dispatchEventToAllianceManager_(msg,eventName)
    Alliance_Manager:OnAllianceDataChanged(msg)
end

function ListenerService:ls_onGetAllianceDataSuccess(msg,eventName)
    -- self:dispatchEventToAllianceManager_(msg,eventName)
    Alliance_Manager:OnAllianceDataChanged(msg)
end


function ListenerService:ls_onAllianceNewEventReceived(msg,eventName)
-- self:dispatchEventToAllianceManager_(msg,eventName)
end

function ListenerService:ls_onAllianceMemberDataChanged(msg,eventName)
-- self:dispatchEventToAllianceManager_(msg,eventName)
end

function ListenerService:ls_onAllianceBasicInfoAndMemberDataChanged(msg,eventName)
    -- self:dispatchEventToAllianceManager_(msg,eventName)
    dump(msg)
    Alliance_Manager:OnAllianceBasicInfoAndMemberDataChanged(msg)
end

function ListenerService:ls_onGetPlayerInfoSuccess( msg,eventName )
-- self.dispather_:dispatchEvent({name = eventName,
--         data = msg
--     })
end

function ListenerService:ls_onAllianceHelpEventChanged(msg,eventName)
    -- self:dispatchEventToAllianceManager_(msg,eventName)
    Alliance_Manager:OnAllianceHelpDataChanged(msg)
end


-- Mails
-------------------------------------------------------------------------
function ListenerService:dispatchEventToMailManager_(msg,eventName)
    local mailManager = DataManager:GetManager("MailManager")
    if mailManager then
        mailManager:dispatchMailServerData(eventName,msg)
    end
end
function ListenerService:ls_onNewMailReceived( msg,eventName )
    self:dispatchEventToMailManager_(msg,eventName)
end
function ListenerService:ls_onGetMailsSuccess( msg,eventName )
    self:dispatchEventToMailManager_(msg,eventName)
end
function ListenerService:ls_onGetSavedMailsSuccess( msg,eventName )
    self:dispatchEventToMailManager_(msg,eventName)
end
function ListenerService:ls_onGetSendMailsSuccess( msg,eventName )
    self:dispatchEventToMailManager_(msg,eventName)
end
function ListenerService:ls_onSendMailSuccess( msg,eventName )
    self:dispatchEventToMailManager_(msg,eventName)
end



