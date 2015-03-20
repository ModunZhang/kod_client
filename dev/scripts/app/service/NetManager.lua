local promise = import("..utils.promise")
local GameGlobalUIUtils = import("..ui.GameGlobalUIUtils")
local Localize_item = import("..utils.Localize_item")
local cocos_promise = import("..utils.cocos_promise")
local gaozhou
if CONFIG_IS_DEBUG then
    local result
    gaozhou, result = pcall(require, "app.service.gaozhou")
end
NetManager = {}
local SUCCESS_CODE = 200
local FAILED_CODE = 500
local TIME_OUT = 15
--- 解析服务器返回的数据
local unpack = unpack
local ipairs = ipairs
local table = table
local function decodeInUserDataFromDeltaData(userData, deltaData)
    local edit = {}
    for _,v in ipairs(deltaData) do
        local origin_key,value = unpack(v)
        local is_json_null = value == json.null
        local keys = string.split(origin_key, ".")
        if #keys == 1 then
            local k = unpack(keys)
            k = tonumber(k) or k
            if type(k) == "number" then -- 索引更新
                k = k + 1
                if is_json_null then            -- 认为是删除
                    edit[k].remove = edit[k].remove or {}
                    table.insert(edit[k].remove, userData[k])
                elseif userData[k] then         -- 认为更新
                    edit[k].edit = edit[k].edit or {}
                    table.insert(edit[k].edit, value)
                else                            -- 认为添加
                    edit[k].add = edit[k].add or {}
                    table.insert(edit[k].add, value)
                end
            else -- key更新
                edit[k] = value
            end
            userData[k] = value
        else
            local tmp = edit
            local curRoot = userData
            local len = #keys
            for i = 1,len do
                local v = keys[i]
                local k = tonumber(v) or v
                if type(k) == "number" then k = k + 1 end
                local parent_root = tmp
                if i ~= len then
                    curRoot[k] = curRoot[k] or {}
                    curRoot = curRoot[k]
                    tmp[k] = tmp[k] or {}
                    tmp = tmp[k]
                else
                    if type(k) == "number" then
                        if is_json_null then
                            tmp.remove = tmp.remove or {}
                            table.insert(tmp.remove, table.remove(curRoot, k))
                        elseif curRoot[k] then
                            tmp.edit = tmp.edit or {}
                            table.insert(tmp.edit, value)
                            curRoot[k] = value
                        else
                            tmp.add = tmp.add or {}
                            table.insert(tmp.add, value)
                            curRoot[k] = value
                        end
                    else
                        tmp[k] = value
                        curRoot[k] = value
                    end
                end
            end
        end
    end
    return edit
end

-- 过滤器
local function get_response_msg(response)
    dump(response,"get_response_msg---->")
    if response.msg.playerData then
        local user_data = DataManager:getUserData()
        local edit = decodeInUserDataFromDeltaData(user_data, response.msg.playerData)
        DataManager:setUserData(user_data, edit)
        return response
    end

    return response
end
local function get_response_mail_msg(response)
    dump(response,"get_response_mail_msg---->")
    if response.msg.playerData then
        local user_data = DataManager:getUserData()
        LuaUtils:outputTable("response.msg.playerData", response.msg.playerData)
        local mail_response = response.msg.playerData
        for i,v in ipairs(mail_response) do

            print("tolua.type(v)",type(v))

            if type(v) == "table" then
                local keys = string.split(v[1], ".")
                LuaUtils:outputTable("keys", keys)
                local newKey = ""
                local len = #keys
                for i=1,len do
                    local k = tonumber(keys[i]) or keys[i]
                    if type(k) == "number" then
                        local client_index = MailManager:GetMailByServerIndex(k) - 1
                        newKey = newKey..client_index..(i~=len and "." or "")
                    else
                        newKey = newKey..keys[i]..(i~=len and "." or "")
                    end
                end
                print("ta")
                mail_response[i][1] = newKey
            end
        end
        LuaUtils:outputTable("response.msg.playerData", response.msg.playerData)
        print("ta")
        local edit = decodeInUserDataFromDeltaData(user_data, response.msg.playerData)
        DataManager:setUserData(user_data, edit)
        return response
    end

    return response
end

local function get_alliance_response_msg(response)
    print("get_alliance_response_msg--->")
    if response.msg.allianceData then
        local user_alliance_data = DataManager:getUserAllianceData()
        if user_alliance_data == json.null then
            DataManager:setUserAllianceData(response.msg.allianceData)
        else
            local edit = decodeInUserDataFromDeltaData(user_alliance_data,response.msg.allianceData)
            DataManager:setUserAllianceData(user_alliance_data, edit)
        end
        return response
    end
    return response
end

local function check_response(m)
    return function(result)
        if result.success then
            return result
        end
        promise.reject(m, m)
    end
end
local function check_request(m)
    return function(result)
        if not result.success or result.msg.code ~= SUCCESS_CODE then
            if result.msg.code == 0 then
                promise.reject(result.msg.message, "timeout")
            else
                promise.reject(result.msg.message, m)
            end
        end
        return result
    end
end
-- 返回promise的函数
local function get_request_promise(request_route, data, m)
    local p = promise.new(check_request(m or ""))
    NetManager.m_netService:request(request_route, data, function(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
local function get_blocking_request_promise(request_route, data, m,need_catch)
    --默认后面的处理需要主动catch错误
    need_catch = type(need_catch) == 'boolean' and need_catch or true
    local loading = UIKit:newGameUI("GameUIWatiForNetWork"):addToCurrentScene(true)
    if loading then
        loading:setLocalZOrder(2001)
    end
    local p =  cocos_promise.promiseWithTimeOut(get_request_promise(request_route, data, m), TIME_OUT):always(function()
        if loading then
            loading:removeFromParent()
        end
    end)
    return cocos_promise.promiseFilterNetError(p,need_catch)
end
local function get_none_blocking_request_promise(request_route, data, m)
    return cocos_promise.promiseWithTimeOut(get_request_promise(request_route, data, m), TIME_OUT)
end
local function get_callback_promise(callbacks, m)
    local p = promise.new(check_response(m or ""))
    table.insert(callbacks, 1, function(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
------------------------
--
function NetManager:init()

    self.m_netService = import"app.service.NetService"
    self.m_netService:init()

    self.m_updateServer = {
        host = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.update.host or CONFIG_REMOTE_SERVER.update.host,
        port = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.update.port or CONFIG_REMOTE_SERVER.update.port,
        name = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.update.name or CONFIG_REMOTE_SERVER.update.name,
    }
    self.m_gateServer = {
        host = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.gate.host or CONFIG_REMOTE_SERVER.gate.host,
        port = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.gate.port or CONFIG_REMOTE_SERVER.gate.port,
        name = CONFIG_IS_LOCAL and CONFIG_LOCAL_SERVER.gate.name or CONFIG_REMOTE_SERVER.gate.name,
    }
    self.m_logicServer = {
        id = nil,
        host = nil,
        port = nil,
    }
end

function NetManager:getServerTime()
    return self.m_netService:getServerTime()
end

function NetManager:disconnect()
    self.m_was_inited_game = true
    self:removeDisConnectEventListener()
    self.m_netService:disconnect()
end

function NetManager:addEventListener(event, cb)
    self.m_netService:addListener(event, function(success, msg)
        cb(success, msg)
    end)
end

function NetManager:removeEventListener(event)
    self.m_netService:removeListener(event)
end

function NetManager:addTimeoutEventListener()
    self:addEventListener("timeout", function(success, msg)
        -- print("addTimeoutEventListener----->timeout")
        end)
end

function NetManager:removeTimeoutEventListener()
    -- print("removeTimeoutEventListener----->timeout")
    self:removeEventListener("timeout")
end

function NetManager:addDisconnectEventListener()
    self:addEventListener("disconnect", function(success, msg)
        if self.m_netService:isConnected() then
            UIKit:showMessageDialog(_("错误"), _("连接服务器失败,请检测你的网络环境!"), function()
                app:retryConnectServer()
            end,nil,false)
        end
    end)
end

function NetManager:removeDisConnectEventListener(  )
    self:removeEventListener("disconnect")
end

function NetManager:addKickEventListener()
    self:addEventListener("onKick", function(success, msg)
        self:disconnect()
        UIKit:showMessageDialog(_("提示"), _("你与服务器的连接已断开!"), function()
            app:restart()
        end,nil,false)
    end)
end

function NetManager:removeKickEventListener(  )
    self:removeEventListener("onKick")
end

onPlayerDataChanged_callbacks = {}
function NetManager:addPlayerDataChangedEventListener()
    self:addEventListener("onPlayerDataChanged", function(success, response)
        if success then
            -- LuaUtils:outputTable("onPlayerDataChanged", response)
            local user_data = DataManager:getUserData()
            local edit = decodeInUserDataFromDeltaData(user_data, response)
            DataManager:setUserData(user_data, edit)
        end
        local callback = onPlayerDataChanged_callbacks[1]
        if type(callback) == "function" then
            callback(success, response)
        end
        onPlayerDataChanged_callbacks = {}
    end)
end
function NetManager:removePlayerDataChangedEventListener(  )
    self:removeEventListener("onPlayerDataChanged")
end

onAllianceDataChanged_callbacks = {}
function NetManager:addAllianceDataChangedEventListener()
    self:addEventListener("onAllianceDataChanged", function(success, msg)
        if success then
            -- LuaUtils:outputTable("onAllianceDataChanged", msg)
            -- DataManager:setUserAllianceData(msg)
            local user_alliance_data = DataManager:getUserAllianceData()
            local edit = decodeInUserDataFromDeltaData(user_alliance_data,msg)
            DataManager:setUserAllianceData(user_alliance_data, edit)
        end
        local callback = onAllianceDataChanged_callbacks[1]
        if type(callback) == "function" then
            callback(success, msg)
        end
        onAllianceDataChanged_callbacks = {}
    end)
end
function NetManager:removeAllianceDataChangedEventListener(  )
    self:removeEventListener("onAllianceDataChanged")
end
---
onSearchAlliancesSuccess_callbacks = {}
onGetNearedAllianceInfosSuccess_callbacks = {}
onSearchAllianceInfoByTagSuccess_callbacks = {}
onGetCanDirectJoinAlliancesSuccess_callbacks = {}
onGetPlayerInfoSuccess_callbacks = {}
onGetMailsSuccess_callbacks = {}
onGetSavedMailsSuccess_callbacks = {}
onGetSendMailsSuccess_callbacks = {}
onGetReportsSuccess_callbacks = {}
onGetSavedReportsSuccess_callbacks = {}
onSendChatSuccess_callbacks = {}
onGetAllChatSuccess_callbacks = {}
onFetchAllianceViewData_callbacks = {}
onGetPlayerViewDataSuccess_callbacks = {}
onGetStrikeMarchEventDetail_callbacks = {}
onGetAttackMarchEventDetail_callbacks = {}
onGetHelpDefenceMarchEventDetail_callbacks = {}
onGetHelpDefenceTroopDetail_callbacks = {}
onGetSellItemsSuccess_callbacks = {}
onAddPlayerBillingDataSuccess_callbacks = {}
function NetManager:addOnSearchAlliancesSuccessListener()
    self:addEventListener("onSearchAlliancesSuccess", function(success, msg)
        if success then
            local callback = onSearchAlliancesSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onSearchAlliancesSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetNearedAllianceInfosSuccessListener()
    self:addEventListener("onGetNearedAllianceInfosSuccess", function(success, msg)
        if success then
            local callback = onGetNearedAllianceInfosSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetNearedAllianceInfosSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnSearchAllianceInfoByTagSuccessListener()
    self:addEventListener("onSearchAllianceInfoByTagSuccess", function(success, msg)
        if success then
            local callback = onSearchAllianceInfoByTagSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onSearchAllianceInfoByTagSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetCanDirectJoinAlliancesSuccessListener()
    self:addEventListener("onGetCanDirectJoinAlliancesSuccess", function(success, msg)
        if success then
            local callback = onGetCanDirectJoinAlliancesSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetCanDirectJoinAlliancesSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetAllianceDataSuccess()
    self:addEventListener("onGetAllianceDataSuccess", function(success, msg)
        if success then
            -- LuaUtils:outputTable("onGetAllianceDataSuccess", msg)
            DataManager:setUserAllianceData(msg)
        end
    end)
end
function NetManager:addOnGetPlayerInfoSuccessListener()
    self:addEventListener("onGetPlayerInfoSuccess", function(success, msg)
        if success then
            local callback = onGetPlayerInfoSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetPlayerInfoSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetPlayerViewDataSuccess()
    self:addEventListener("onGetPlayerViewDataSuccess", function(success, msg)
        if success then
            local callback = onGetPlayerViewDataSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetPlayerViewDataSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetSellItemsSuccess()
    self:addEventListener("onGetSellItemsSuccess", function(success, msg)
        if success then
            local callback = onGetSellItemsSuccess_callbacks[1]
            -- LuaUtils:outputTable("onGetSellItemsSuccess", msg)
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetSellItemsSuccess_callbacks = {}
        end
    end)
end

function NetManager:addOnGetMailsSuccessListener()
    self:addEventListener("onGetMailsSuccess", function(success, msg)
        if success then
            assert(#onGetMailsSuccess_callbacks <= 1, "重复请求过多了!")

            dump(msg, "onGetMailsSuccess")
            MailManager:dispatchMailServerData( "onGetMailsSuccess",msg )
            local callback = onGetMailsSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetMailsSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetSavedMailsSuccessListener()
    self:addEventListener("onGetSavedMailsSuccess", function(success, msg)
        if success then
            assert(#onGetSavedMailsSuccess_callbacks <= 1, "重复请求过多了!")
            MailManager:dispatchMailServerData( "onGetSavedMailsSuccess",msg )
            local callback = onGetSavedMailsSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetSavedMailsSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetSendMailsSuccessListener()
    self:addEventListener("onGetSendMailsSuccess", function(success, msg)
        if success then
            assert(#onGetSendMailsSuccess_callbacks <= 1, "重复请求过多了!")
            MailManager:dispatchMailServerData( "onGetSendMailsSuccess",msg )
            local callback = onGetSendMailsSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetSendMailsSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetReportsSuccessListener()
    self:addEventListener("onGetReportsSuccess", function(success, msg)
        if success then
            assert(#onGetReportsSuccess_callbacks <= 1, "重复请求过多了!")
            MailManager:dispatchMailServerData( "onGetReportsSuccess",msg )
            local callback = onGetReportsSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetReportsSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnGetSavedReportsSuccessListener()
    self:addEventListener("onGetSavedReportsSuccess", function(success, msg)
        if success then
            assert(#onGetSavedReportsSuccess_callbacks <= 1, "重复请求过多了!")
            MailManager:dispatchMailServerData( "onGetSavedReportsSuccess",msg )
            local callback = onGetSavedReportsSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetSavedReportsSuccess_callbacks = {}
        end
    end)
end


function NetManager:addOnChatListener()
    self:addEventListener("onChat", function(success, msg)
        if success then
            app:GetChatManager():HandleNetMessage("onChat",msg)
            assert(#onSendChatSuccess_callbacks <= 1, "重复请求过多了!")
            local callback = onSendChatSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onSendChatSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnAllChatListener()
    self:addEventListener("onAllChat", function(success, msg)
        if success then
            assert(#onGetAllChatSuccess_callbacks <= 1, "重复请求过多了!")
            local callback = onGetAllChatSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetAllChatSuccess_callbacks = {}
        end
    end)
end
function NetManager:addOnBuildingLevelUpListener()
    self:addEventListener("onBuildingLevelUp", function(success, msg)
        if success then
            GameGlobalUI:showBuildingLevelUp(msg)
        end
    end)
end
function NetManager:addOnHouseLevelUpListener()
    self:addEventListener("onHouseLevelUp", function(success, msg)
        if success then
            GameGlobalUI:showHouseLevelUp(msg)
        end
    end)
end
function NetManager:addOnTowerLevelUpListener()
    self:addEventListener("onTowerLevelUp", function(success, msg)
        if success then
            GameGlobalUI:showTips(_("城墙升级完成"),string.format('LV %d',msg.level))
        end
    end)
end
function NetManager:addOnWallLevelUp()
    self:addEventListener("onWallLevelUp", function(success, msg)
        if success then
            GameGlobalUI:showWallLevelUp(msg)
        end
    end)
end
function NetManager:addOnFetchAllianceViewSuccess()
    self:addEventListener("onGetAllianceViewDataSuccess", function(success, msg)
        if success then
            assert(#onFetchAllianceViewData_callbacks <= 1, "重复fetchAllianceView请求过多了!")
            local callback = onFetchAllianceViewData_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onFetchAllianceViewData_callbacks = {}
        end
    end)
end
function NetManager:addOnGetStrikeMarchEventDetail()
    self:addEventListener("onGetStrikeMarchEventDetail", function(success, msg)
        if success then
            assert(#onGetStrikeMarchEventDetail_callbacks <= 1, "重复getStrikeMarchEventDetail请求过多了!")
            local callback = onGetStrikeMarchEventDetail_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetStrikeMarchEventDetail_callbacks = {}
        end
    end)
end
function NetManager:addOnGetAttackMarchEventDetail()
    self:addEventListener("onGetAttackMarchEventDetail", function(success, msg)
        if success then
            assert(#onGetAttackMarchEventDetail_callbacks <= 1, "重复getAttackMarchEventDetail请求过多了!")
            local callback = onGetAttackMarchEventDetail_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetAttackMarchEventDetail_callbacks = {}
        end
    end)
end
function NetManager:addOnGetHelpDefenceMarchEventDetail()
    self:addEventListener("onGetHelpDefenceMarchEventDetail", function(success, msg)
        if success then
            assert(#onGetHelpDefenceMarchEventDetail_callbacks <= 1, "重复getHelpDefenceMarchEventDetail请求过多了!")
            local callback = onGetHelpDefenceMarchEventDetail_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetHelpDefenceMarchEventDetail_callbacks = {}
        end
    end)
end
function NetManager:addOnGetHelpDefenceTroopDetail()
    self:addEventListener("onGetHelpDefenceTroopDetail", function(success, msg)
        if success then
            assert(#onGetHelpDefenceTroopDetail_callbacks <= 1, "重复getHelpDefenceTroopDetail请求过多了!")
            local callback = onGetHelpDefenceTroopDetail_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onGetHelpDefenceTroopDetail_callbacks = {}
        end
    end)
end
function NetManager:addOnAddPlayerBillingDataSuccess()
    self:addEventListener("onAddPlayerBillingDataSuccess", function(success, msg)
        if success then
            assert(#onAddPlayerBillingDataSuccess_callbacks <= 1, "重复addPlayerBillingData请求过多了!")
            local callback = onAddPlayerBillingDataSuccess_callbacks[1]
            if type(callback) == "function" then
                callback(success, msg)
            end
            onAddPlayerBillingDataSuccess_callbacks = {}
        end
    end)
end



--连接网关服务器
local function get_connectGateServer_promise()
    local p = promise.new(check_request("连接网关服务器失败!"))
    NetManager.m_netService:connect(NetManager.m_gateServer.host, NetManager.m_gateServer.port, function(success)
        p:resolve({success = success, msg = {code = SUCCESS_CODE}})
    end)
    return cocos_promise.promiseWithTimeOut(p, TIME_OUT)
end
function NetManager:getConnectGateServerPromise()
    return get_connectGateServer_promise():next(function(result)
        self:addDisconnectEventListener()
        self:addTimeoutEventListener()
        self:addKickEventListener()
    end)
end
-- 获取服务器列表
function NetManager:getLogicServerInfoPromise()
    return get_none_blocking_request_promise("gate.gateHandler.queryEntry", nil, "获取逻辑服务器失败")
        :next(function(result)
            self:removeTimeoutEventListener()
            self:removeDisConnectEventListener()
            self:removeKickEventListener()
            self.m_netService:disconnect()
            self.m_logicServer.host = result.msg.data.host
            self.m_logicServer.port = result.msg.data.port
            self.m_logicServer.id = result.msg.data.id
        end)
end
-- 连接逻辑服务器
local function get_connectLogicServer_promise()
    local p = promise.new(check_request("连接逻辑服务器失败!"))
    NetManager.m_netService:connect(NetManager.m_logicServer.host, NetManager.m_logicServer.port, function(success)
        p:resolve({success = success, msg = {code = SUCCESS_CODE}})
    end)
    return cocos_promise.promiseWithTimeOut(p, TIME_OUT)
end
function NetManager:getConnectLogicServerPromise()
    return get_connectLogicServer_promise():next(function(result)
        self:addDisconnectEventListener()
        self:addTimeoutEventListener()
        self:addKickEventListener()
        self:addPlayerDataChangedEventListener()
        self:addAllianceDataChangedEventListener()

        self:addOnSearchAlliancesSuccessListener()
        self:addOnGetNearedAllianceInfosSuccessListener()
        self:addOnSearchAllianceInfoByTagSuccessListener()
        self:addOnGetCanDirectJoinAlliancesSuccessListener()
        self:addOnGetPlayerInfoSuccessListener()
        self:addOnGetPlayerViewDataSuccess()
        self:addOnGetSellItemsSuccess()
        self:addOnGetMailsSuccessListener()
        self:addOnGetSavedMailsSuccessListener()
        self:addOnGetSendMailsSuccessListener()
        self:addOnGetReportsSuccessListener()
        self:addOnGetSavedReportsSuccessListener()
        self:addOnChatListener()
        self:addOnAllChatListener()
        self:addOnGetAllianceDataSuccess()

        self:addOnBuildingLevelUpListener()
        self:addOnHouseLevelUpListener()
        self:addOnTowerLevelUpListener()
        self:addOnWallLevelUp()
        self:addOnFetchAllianceViewSuccess()
        self:addOnGetStrikeMarchEventDetail()
        self:addOnGetAttackMarchEventDetail()
        self:addOnGetHelpDefenceMarchEventDetail()
        self:addOnGetHelpDefenceTroopDetail()
        self:addOnAddPlayerBillingDataSuccess()
    end)
end
local function getOpenUDID()
    local device_id
    local udid = cc.UserDefault:getInstance():getStringForKey("udid")
    if udid and #udid > 0 then
        device_id = udid
    else
        device_id = device.getOpenUDID()
    end
    return device_id
end
-- 登录
function NetManager:getLoginPromise(deviceId)
    local device_id
    if CONFIG_IS_DEBUG then
        if gaozhou then
            device_id = getOpenUDID()
            -- device_id = "1"
        else
            device_id = getOpenUDID()
        end
    else
        device_id = device.getOpenUDID()
    end
    return get_none_blocking_request_promise("logic.entryHandler.login", {deviceId = deviceId or device_id}):next(function(response)
        if response.success then
            app:GetPushManager():CancelAll()
            local playerData = response.msg.playerData
            local user_alliance_data = response.msg.allianceData
            if self.m_was_inited_game then
                self.m_netService:setDeltatime(playerData.serverTime - ext.now())
                DataManager:setUserData(playerData)
                DataManager:setUserAllianceData(user_alliance_data)
            else
                -- LuaUtils:outputTable("logic.entryHandler.login", response)
                self.m_netService:setDeltatime(playerData.serverTime - ext.now())
                local InitGame = import("app.service.InitGame")
                InitGame(playerData)
                DataManager:setUserAllianceData(user_alliance_data)
            end
            self.m_was_inited_game = false
        end
    end)
end
-- 事件回调promise
local function get_playerdata_callback()
    return get_callback_promise(onPlayerDataChanged_callbacks, "返回玩家数据失败!")
end
local function get_searchalliance_callback()
    return get_callback_promise(onSearchAlliancesSuccess_callbacks, "搜索联盟失败!")
end
local function get_nearedallianceinfos_callback()
    return get_callback_promise(onGetNearedAllianceInfosSuccess_callbacks, "查看战力相近的3个联盟的数据失败!")
end
local function get_searchallianceinfobytag_callback()
    return get_callback_promise(onSearchAllianceInfoByTagSuccess_callbacks, "根据Tag搜索联盟战斗数据失败!")
end
local function get_directjoin_callback()
    return get_callback_promise(onGetCanDirectJoinAlliancesSuccess_callbacks, "搜索能直接加入的联盟失败!")
end
local function get_playerinfo_callback()
    return get_callback_promise(onGetPlayerInfoSuccess_callbacks, "查询玩家信息失败!")
end
local function get_cityinfo_callback()
    return get_callback_promise(onGetPlayerViewDataSuccess_callbacks, "查询玩家城市信息失败!")
end
local function get_sellitems_callback()
    return get_callback_promise(onGetSellItemsSuccess_callbacks, "获取出售列表失败!")
end
local function get_alliancedata_callback()
    return get_callback_promise(onAllianceDataChanged_callbacks, "修改联盟信息失败!")
end
local function get_inboxmails_callback()
    return get_callback_promise(onGetMailsSuccess_callbacks, "获取收件箱邮件失败!")
end
local function get_savedmails_callback()
    return get_callback_promise(onGetSavedMailsSuccess_callbacks, "获取收藏邮件失败!")
end
local function get_sendmails_callback()
    return get_callback_promise(onGetSendMailsSuccess_callbacks, "获取发件箱邮件失败!")
end
local function get_reports_callback()
    return get_callback_promise(onGetReportsSuccess_callbacks, "获取玩家失败!")
end
local function get_savedreports_callback()
    return get_callback_promise(onGetSavedReportsSuccess_callbacks, "获取玩家收藏战报失败!")
end
local function get_sendchat_callback()
    return get_callback_promise(onSendChatSuccess_callbacks, "发送聊天失败!")
end
local function get_fetchchat_callback()
    return get_callback_promise(onGetAllChatSuccess_callbacks, "获取聊天失败!")
end
local function get_fetchallianceview_callback()
    return  get_callback_promise(onFetchAllianceViewData_callbacks, "获取对方联盟数据失败!")
end
local function get_strikemarcheventdetail_callback()
    return  get_callback_promise(onGetStrikeMarchEventDetail_callbacks, "获取突袭事件数据失败!")
end
local function get_attackmarcheventdetail_callback()
    return  get_callback_promise(onGetAttackMarchEventDetail_callbacks, "获取行军事件数据失败!")
end
local function get_gethelpdefencemarcheventdetail_callback()
    return  get_callback_promise(onGetHelpDefenceMarchEventDetail_callbacks, "获取协防事件数据失败!")
end
local function get_gethelpdefencetroopdetail_callback()
    return  get_callback_promise(onGetHelpDefenceTroopDetail_callbacks, "获取协防事件数据失败!")
end

local function get_addplayerbillingdata_callback()
    return  get_callback_promise(onAddPlayerBillingDataSuccess_callbacks, "上传IAP信息失败!")
end
-- 个人修改地形
local function get_changeTerrain_promise(terrain)
    return get_blocking_request_promise("logic.playerHandler.setTerrain", {
        terrain = terrain
    }, "修改地形失败!")
end
function NetManager:getChangeToGrassPromise()
    return get_changeTerrain_promise("grassLand"):next(get_response_msg)
end
function NetManager:getChangeToDesertPromise()
    return get_changeTerrain_promise("desert"):next(get_response_msg)
end
function NetManager:getChangeToIceFieldPromise()
    return get_changeTerrain_promise("iceField"):next(get_response_msg)
end
-- 建造小屋
function NetManager:getCreateHouseByLocationPromise(location, sub_location, building_type)
    return get_blocking_request_promise("logic.playerHandler.createHouse", {
        buildingLocation = location,
        houseLocation = sub_location,
        houseType = building_type,
        finishNow = false
    }, "建造小屋失败!"):next(get_response_msg)
end
-- 拆除小屋
function NetManager:getDestroyHouseByLocationPromise(location, sub_location)
    return get_blocking_request_promise("logic.playerHandler.destroyHouse", {
        buildingLocation = location,
        houseLocation = sub_location
    }, "拆除小屋失败!"):next(get_response_msg)
end
-- 升级小屋
local function get_upgradeHouse_promise(location, sub_location, finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeHouse", {
        buildingLocation = location,
        houseLocation = sub_location,
        finishNow = finish_now or false
    }, "升级小屋失败!"):next(get_response_msg)
end
function NetManager:getUpgradeHouseByLocationPromise(location, sub_location)
    return get_upgradeHouse_promise(location, sub_location, false)
end
function NetManager:getInstantUpgradeHouseByLocationPromise(location, sub_location)
    return get_upgradeHouse_promise(location, sub_location, true)
end
-- 升级功能建筑
local function get_upgradeBuilding_promise(location, finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeBuilding", {
        location = location,
        finishNow = finish_now or false
    }, "升级功能建筑失败!"):next(get_response_msg)
end
function NetManager:getUpgradeBuildingByLocationPromise(location)
    return get_upgradeBuilding_promise(location, false)
end
function NetManager:getInstantUpgradeBuildingByLocationPromise(location)
    return get_upgradeBuilding_promise(location, true)
end
-- 升级防御塔
function NetManager:getUpgradeTowerPromise()
    return NetManager:getUpgradeBuildingByLocationPromise(22)
end
function NetManager:getInstantUpgradeTowerPromise()
    return NetManager:getInstantUpgradeBuildingByLocationPromise(22)
end
-- 升级城门
function NetManager:getUpgradeWallByLocationPromise()
    return NetManager:getUpgradeBuildingByLocationPromise(21)
end
function NetManager:getInstantUpgradeWallByLocationPromise()
    return NetManager:getInstantUpgradeBuildingByLocationPromise(21)
end
--转换生产建筑类型
function NetManager:getSwitchBuildingPromise(buildingLocation,newBuildingName)
    return get_blocking_request_promise("logic.playerHandler.switchBuilding", {
        buildingLocation = buildingLocation,
        newBuildingName = newBuildingName
    },
    "转换生产建筑类型失败!"):next(get_response_msg)
end


-- 制造材料
local function get_makeMaterial_promise(category)
    return get_blocking_request_promise("logic.playerHandler.makeMaterial", {
        category = category,
        finishNow = false
    }, "制造材料失败!"):next(get_response_msg)
end
-- 建造建筑材料
function NetManager:getMakeBuildingMaterialPromise()
    return get_makeMaterial_promise("buildingMaterials")
end
-- 建造科技材料
function NetManager:getMakeTechnologyMaterialPromise()
    return get_makeMaterial_promise("technologyMaterials")
end
-- 获取材料
function NetManager:getFetchMaterialsPromise(id)
    return get_blocking_request_promise("logic.playerHandler.getMaterials", {
        eventId = id,
    }, "获取材料失败!"):next(get_response_msg)
end
-- 打造装备
local function get_makeDragonEquipment_promise(equipment_name, finish_now)
    return get_blocking_request_promise("logic.playerHandler.makeDragonEquipment", {
        equipmentName = equipment_name,
        finishNow = finish_now or false
    }, "打造装备失败!"):next(get_response_msg)
end
function NetManager:getMakeDragonEquipmentPromise(equipment_name)
    return get_makeDragonEquipment_promise(equipment_name)
end
function NetManager:getInstantMakeDragonEquipmentPromise(equipment_name)
    return get_makeDragonEquipment_promise(equipment_name, true)
end
-- 招募士兵
local function get_recruitNormalSoldier_promise(soldierName, count, finish_now)
    return get_blocking_request_promise("logic.playerHandler.recruitNormalSoldier", {
        soldierName = soldierName,
        count = count,
        finishNow = finish_now or false
    }, "招募普通士兵失败!"):next(get_response_msg)
end
function NetManager:getRecruitNormalSoldierPromise(soldierName, count, cb)
    return get_recruitNormalSoldier_promise(soldierName, count)
end
function NetManager:getInstantRecruitNormalSoldierPromise(soldierName, count, cb)
    return get_recruitNormalSoldier_promise(soldierName, count, true)
end
-- 招募特殊士兵
local function get_recruitSpecialSoldier_promise(soldierName, count, finish_now)
    return get_blocking_request_promise("logic.playerHandler.recruitSpecialSoldier", {
        soldierName = soldierName,
        count = count,
        finishNow = finish_now or false
    }, "招募特殊士兵失败!"):next(get_response_msg)
end
function NetManager:getRecruitSpecialSoldierPromise(soldierName, count)
    return get_recruitSpecialSoldier_promise(soldierName, count)
end
function NetManager:getInstantRecruitSpecialSoldierPromise(soldierName, count)
    return get_recruitSpecialSoldier_promise(soldierName, count, true)
end
-- 普通治疗士兵
local function get_treatSoldier_promise(soldiers, finish_now)
    return get_blocking_request_promise("logic.playerHandler.treatSoldier", {
        soldiers = soldiers,
        finishNow = finish_now or false
    }, "普通治疗士兵失败!"):next(get_response_msg)
end
function NetManager:getTreatSoldiersPromise(soldiers)
    return get_treatSoldier_promise(soldiers)
end
function NetManager:getInstantTreatSoldiersPromise(soldiers)
    return get_treatSoldier_promise(soldiers, true)
end
-- 孵化
function NetManager:getHatchDragonPromise(dragonType)
    return get_blocking_request_promise("logic.playerHandler.hatchDragon", {
        dragonType = dragonType,
    }, "孵化失败!"):next(get_response_msg)
end
-- 装备
function NetManager:getLoadDragonEquipmentPromise(dragonType, equipmentCategory, equipmentName)
    return get_blocking_request_promise("logic.playerHandler.setDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory,
        equipmentName = equipmentName
    }, "装备失败!"):next(get_response_msg)
end
-- 卸载装备
function NetManager:getResetDragonEquipmentPromise(dragonType, equipmentCategory)
    return get_blocking_request_promise("logic.playerHandler.resetDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory
    }, "卸载装备失败!"):next(get_response_msg)
end
-- 强化装备
function NetManager:getEnhanceDragonEquipmentPromise(dragonType, equipmentCategory, equipments)
    return get_blocking_request_promise("logic.playerHandler.enhanceDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory,
        equipments = equipments
    }, "强化装备失败!"):next(get_response_msg)
end
-- 升级龙星
function NetManager:getUpgradeDragonStarPromise(dragonType)
    return get_blocking_request_promise("logic.playerHandler.upgradeDragonStar", {
        dragonType = dragonType,
    }, "升级龙星失败!"):next(get_response_msg)
end
-- 升级龙技能
function NetManager:getUpgradeDragonDragonSkillPromise(dragonType, skillKey)
    return get_blocking_request_promise("logic.playerHandler.upgradeDragonSkill", {
        dragonType = dragonType,
        skillKey = skillKey
    }, "升级龙技能失败!"):next(get_response_msg)
end
-- 获取每日任务列表
function NetManager:getDailyQuestsPromise()
    return get_blocking_request_promise("logic.playerHandler.getDailyQuests", {},
        "获取每日任务列表失败!"):next(get_response_msg)
end
-- 为每日任务中某个任务增加星级
function NetManager:getAddDailyQuestStarPromise(questId)
    return get_blocking_request_promise("logic.playerHandler.addDailyQuestStar",
        {
            questId = questId
        },
        "为每日任务中某个任务增加星级失败!"):next(get_response_msg)
end
-- 开始一个每日任务
function NetManager:getStartDailyQuestPromise(questId)
    return get_blocking_request_promise("logic.playerHandler.startDailyQuest",
        {
            questId = questId
        },
        "开始一个每日任务失败!"):next(get_response_msg)
end
-- 领取每日任务奖励
function NetManager:getDailyQeustRewardPromise(questEventId)
    return get_blocking_request_promise("logic.playerHandler.getDailyQeustReward",
        {
            questEventId = questEventId
        },
        "领取每日任务奖励失败!"):next(get_response_msg)
end
-- 发送个人邮件
function NetManager:getSendPersonalMailPromise(memberId, title, content)
    return get_blocking_request_promise("logic.playerHandler.sendMail", {
        memberId = memberId,
        title = title,
        content = content,
    }, "发送个人邮件失败!"):next(get_response_msg)
end
-- 获取收件箱邮件
function NetManager:getFetchMailsPromise(fromIndex)
    return get_blocking_request_promise("logic.playerHandler.getMails", {
        fromIndex = fromIndex
    }, "获取收件箱邮件失败!"):next(function (response)
        if response.msg.mails then
            local user_data = DataManager:getUserData()
            local fetch_mails = {}
            for i,v in ipairs(response.msg.mails) do
                table.insert(user_data.mails, v)
                MailManager:AddMailsToEnd(v)
                table.insert(fetch_mails, v)
            end
            return fetch_mails
        end
    end)
end
-- 阅读邮件
function NetManager:getReadMailsPromise(mailIds)
    return get_none_blocking_request_promise("logic.playerHandler.readMails", {
        mailIds = mailIds
    }, "阅读邮件失败!"):next(get_response_mail_msg)
end
-- 收藏邮件
function NetManager:getSaveMailPromise(mailId)
    return get_blocking_request_promise("logic.playerHandler.saveMail", {
        mailId = mailId
    }, "收藏邮件失败!")
end
-- 取消收藏邮件
function NetManager:getUnSaveMailPromise(mailId)
    return get_blocking_request_promise("logic.playerHandler.unSaveMail", {
        mailId = mailId
    }, "取消收藏邮件失败!")
end
-- 获取收藏邮件
function NetManager:getFetchSavedMailsPromise(fromIndex)
    return get_blocking_request_promise("logic.playerHandler.getSavedMails", {
        fromIndex = fromIndex
    }, "获取收藏邮件失败!"):next(get_response_msg)
end
-- 获取已发送邮件
function NetManager:getFetchSendMailsPromise(fromIndex)
    return get_blocking_request_promise("logic.playerHandler.getSendMails", {
        fromIndex = fromIndex
    }, "获取已发送邮件失败!"):next(get_response_msg)
end
-- 删除邮件
function NetManager:getDeleteMailsPromise(mailIds)
    return get_blocking_request_promise("logic.playerHandler.deleteMails", {
        mailIds = mailIds
    }, "删除邮件失败!"):next(get_response_mail_msg)
end
-- 发送联盟邮件
function NetManager:getSendAllianceMailPromise(title, content)
    return get_blocking_request_promise("logic.allianceHandler.sendAllianceMail", {
        title = title,
        content = content,
    }, "发送联盟邮件失败!"):next(get_response_msg)
end
-- 阅读战报
function NetManager:getReadReportsPromise(reportIds)
    return get_none_blocking_request_promise("logic.playerHandler.readReports", {
        reportIds = reportIds
    }, "阅读战报失败!"):next(get_response_msg)
end
-- 收藏战报
function NetManager:getSaveReportPromise(reportId)
    return get_blocking_request_promise("logic.playerHandler.saveReport", {
        reportId = reportId
    }, "收藏战报失败!"):next(get_response_msg)
end
-- 取消收藏战报
function NetManager:getUnSaveReportPromise(reportId)
    return get_blocking_request_promise("logic.playerHandler.unSaveReport", {
        reportId = reportId
    }, "取消收藏战报失败!"):next(get_response_msg)
end
-- 获取玩家战报
function NetManager:getReportsPromise(fromIndex)
    return get_blocking_request_promise("logic.playerHandler.getReports", {
        fromIndex = fromIndex
    }, "获取玩家战报失败!"):next(get_response_msg)
end
-- 获取玩家已存战报
function NetManager:getSavedReportsPromise(fromIndex)
    return get_blocking_request_promise("logic.playerHandler.getSavedReports", {
        fromIndex = fromIndex
    }, "获取玩家已存战报失败!"):next(get_response_msg)
end
-- 删除战报
function NetManager:getDeleteReportsPromise(reportIds)
    return get_blocking_request_promise("logic.playerHandler.deleteReports", {
        reportIds = reportIds
    }, "删除战报失败!"):next(get_response_msg)
end
-- 请求加速
function NetManager:getRequestAllianceToSpeedUpPromise(eventType, eventId)
    return get_blocking_request_promise("logic.allianceHandler.requestAllianceToSpeedUp", {
        eventType = eventType,
        eventId = eventId,
    }, "请求加速失败!"):next(get_response_msg)
end
-- 免费加速建筑升级
function NetManager:getFreeSpeedUpPromise(eventType, eventId)
    return get_blocking_request_promise("logic.playerHandler.freeSpeedUp", {
        eventType = eventType,
        eventId = eventId,
    }, "请求免费加速失败!")
end
-- 协助玩家加速
function NetManager:getHelpAllianceMemberSpeedUpPromise(eventId)
    return get_blocking_request_promise("logic.allianceHandler.helpAllianceMemberSpeedUp", {
        eventId = eventId,
    }, "协助玩家加速失败!"):next(get_response_msg)
end
-- 协助所有玩家加速
function NetManager:getHelpAllAllianceMemberSpeedUpPromise()
    return get_blocking_request_promise("logic.allianceHandler.helpAllAllianceMemberSpeedUp", {}
        , "协助所有玩家加速失败!"):next(get_response_msg)
end
-- 创建联盟
function NetManager:getCreateAlliancePromise(name, tag, language, terrain, flag)
    return get_blocking_request_promise("logic.allianceHandler.createAlliance", {
        name = name,
        tag = tag,
        language = language,
        terrain = terrain,
        flag = flag
    }, "创建联盟失败!"):next(get_response_msg):next(get_alliance_response_msg)
end
-- 退出联盟
function NetManager:getQuitAlliancePromise()
    return get_blocking_request_promise("logic.allianceHandler.quitAlliance", nil
        , "退出联盟失败!"):next(get_response_msg)
end
-- 修改联盟加入条件
function NetManager:getEditAllianceJoinTypePromise(join_type)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceJoinType", {
        joinType = join_type
    }, "修改联盟加入条件失败!"):next(get_response_msg)
end
-- 拒绝玩家
function NetManager:getRefuseJoinAllianceRequestPromise(memberId)
    return get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = false
    }, "拒绝玩家失败!"):next(get_response_msg)
end
-- 接受玩家
function NetManager:getAgreeJoinAllianceRequestPromise(memberId)
    return get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = true
    }, "接受玩家失败!"):next(get_response_msg)
end
-- 踢出玩家
function NetManager:getKickAllianceMemberOffPromise(memberId)
    return get_blocking_request_promise("logic.allianceHandler.kickAllianceMemberOff", {
        memberId = memberId,
    }, "踢出玩家失败!"):next(get_response_msg)
end
-- 搜索特定标签联盟
function NetManager:getSearchAllianceByTagPromsie(tag)
    return get_blocking_request_promise("logic.allianceHandler.searchAllianceByTag", {
        tag = tag
    }, "搜索特定标签联盟失败!"):next(get_response_msg)
end
-- 搜索能直接加入联盟
function NetManager:getFetchCanDirectJoinAlliancesPromise()
    return get_blocking_request_promise("logic.allianceHandler.getCanDirectJoinAlliances", nil
        , "搜索直接加入联盟失败!"):next(get_response_msg)
end
-- 邀请加入联盟
function NetManager:getInviteToJoinAlliancePromise(memberId)
    return get_blocking_request_promise("logic.allianceHandler.inviteToJoinAlliance", {
        memberId = memberId
    }, "邀请加入联盟联盟失败!")
end
-- 直接加入联盟
function NetManager:getJoinAllianceDirectlyPromise(allianceId)
    return get_blocking_request_promise("logic.allianceHandler.joinAllianceDirectly", {
        allianceId = allianceId
    }, "直接加入联盟失败!"):next(get_response_msg)
end
-- 请求加入联盟
function NetManager:getRequestToJoinAlliancePromise(allianceId)
    return get_blocking_request_promise("logic.allianceHandler.requestToJoinAlliance", {
        allianceId = allianceId
    }, "请求加入联盟失败!"):next(get_response_msg)
end
-- 获取玩家信息
function NetManager:getPlayerInfoPromise(memberId)
    return get_blocking_request_promise("logic.playerHandler.getPlayerInfo", {
        memberId = memberId
    }, "获取玩家信息失败!"):next(get_response_msg)
end
-- 获取玩家城市信息
function NetManager:getPlayerCityInfoPromise(targetPlayerId)
    return get_blocking_request_promise("logic.playerHandler.getPlayerViewData", {
        targetPlayerId = targetPlayerId
    }, "获取玩家城市信息失败!"):next(get_response_msg)
end
-- 移交萌主
function NetManager:getHandOverAllianceArchonPromise(memberId)
    return get_blocking_request_promise("logic.allianceHandler.handOverAllianceArchon", {
        memberId = memberId,
    }, "移交萌主失败!"):next(get_response_msg)
end
-- 修改成员职位
function NetManager:getEditAllianceMemberTitlePromise(memberId, title)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceMemberTitle", {
        memberId = memberId,
        title = title
    }, "修改成员职位失败!"):next(get_response_msg)
end
-- 修改联盟公告
function NetManager:getEditAllianceNoticePromise(notice)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceNotice", {
        notice = notice
    }, "修改联盟公告失败!"):next(get_response_msg)
end
-- 修改联盟描述
function NetManager:getEditAllianceDescriptionPromise(description)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceDescription", {
        description = description
    }, "修改联盟描述失败!"):next(get_response_msg)
end
-- 修改职位名字
function NetManager:getEditAllianceTitleNamePromise(title, titleName)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceTitleName", {
        title = title,
        titleName = titleName
    }, "修改职位名字失败!"):next(get_response_msg)
end
-- 发送秘籍
function NetManager:getSendGlobalMsgPromise(text)
    return get_blocking_request_promise("chat.chatHandler.send", {
        ["text"] = text,
        ["channel"] = "global"
    }, "发送世界聊天信息失败!")
end
--发送聊天信息
function NetManager:getSendChatPromise(channel,text)
    return get_none_blocking_request_promise("chat.chatHandler.send", {
        ["text"] = text,
        ["channel"] = channel
    }, "发送聊天信息失败!")
end
--获取所有聊天信息
function NetManager:getFetchChatPromise()
    return get_none_blocking_request_promise("chat.chatHandler.getAll",nil, "获取聊天信息失败!")
end
--处理联盟的对玩家的邀请
local function getHandleJoinAllianceInvitePromise(allianceId, agree)
    return get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceInvite", {
        ["allianceId"] = allianceId,
        ["agree"] = agree,
    }, "处理联盟的对玩家的邀请失败!")
end
function NetManager:getHandleJoinAllianceInvitePromise(allianceId, agree)
    return getHandleJoinAllianceInvitePromise(allianceId, agree)
end
function NetManager:getAgreeJoinAllianceInvitePromise(allianceId)
    return getHandleJoinAllianceInvitePromise(allianceId, true)
end
function NetManager:getDisagreeJoinAllianceInvitePromise(allianceId)
    return getHandleJoinAllianceInvitePromise(allianceId, false)
end
--取消申请联盟
function NetManager:getCancelJoinAlliancePromise(allianceId)
    return get_blocking_request_promise("logic.allianceHandler.cancelJoinAllianceRequest", {
        ["allianceId"] = allianceId,
    }, "取消申请联盟失败!"):next(get_response_msg)
end
--修改联盟基本信息
function NetManager:getEditAllianceBasicInfoPromise(name, tag, language, flag)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceBasicInfo", {
        name = name,
        tag = tag,
        language = language,
        flag = flag
    }, "修改联盟基本信息失败!"):next(get_response_msg)
end
-- 移动联盟建筑
function NetManager:getMoveAllianceBuildingPromise(buildingName, locationX, locationY)
    return get_blocking_request_promise("logic.allianceHandler.moveAllianceBuilding", {
        buildingName = buildingName,
        locationX = locationX,
        locationY = locationY
    }, "移动联盟建筑失败!"):next(get_response_msg)
end
-- 移动玩家城市
function NetManager:getMoveAllianceMemberPromise(locationX, locationY)
    return get_blocking_request_promise("logic.allianceHandler.moveAllianceMember", {
        locationX = locationX,
        locationY = locationY
    }, "移动玩家城市失败!"):next(get_response_msg)
end
-- 拆除装饰物
function NetManager:getDistroyAllianceDecoratePromise(decorateId)
    return get_blocking_request_promise("logic.allianceHandler.distroyAllianceDecorate", {
        decorateId = decorateId
    }, "拆除装饰物失败!"):next(get_response_msg)
end
-- 激活联盟事件
function NetManager:getActivateAllianceShrineStagePromise(stageName)
    return get_blocking_request_promise("logic.allianceHandler.activateAllianceShrineStage", {
        stageName = stageName
    }, "激活联盟事件失败!"):next(get_response_msg)
end
-- 升级联盟建筑
function NetManager:getUpgradeAllianceBuildingPromise(buildingName)
    return get_blocking_request_promise("logic.allianceHandler.upgradeAllianceBuilding", {
        buildingName = buildingName
    }, "升级联盟建筑失败!"):next(get_response_msg)
end
-- 升级联盟村落
function NetManager:getUpgradeAllianceVillagePromise(villageType)
    return get_blocking_request_promise("logic.allianceHandler.upgradeAllianceVillage", {
        villageType = villageType
    }, "升级联盟村落失败!"):next(get_response_msg)
end
-- 联盟捐赠
function NetManager:getDonateToAlliancePromise(donateType)
    return get_blocking_request_promise("logic.allianceHandler.donateToAlliance", {
        donateType = donateType
    }, "联盟捐赠失败!"):next(get_response_msg)
end
-- 编辑联盟地形
function NetManager:getEditAllianceTerrianPromise(terrain)
    return get_blocking_request_promise("logic.allianceHandler.editAllianceTerrian", {
        terrain = terrain
    }, "编辑联盟地形失败!")
end

function NetManager:getMarchToShrinePromose(shrineEventId,dragonType,soldiers)
    return get_blocking_request_promise("logic.allianceHandler.attackAllianceShrine", {
        dragonType = dragonType,
        shrineEventId = shrineEventId,
        soldiers = soldiers
    }, "圣地派兵失败!"):next(get_response_msg)
end
--查找合适的联盟进行战斗
function NetManager:getFindAllianceToFightPromose()
    return get_blocking_request_promise("logic.allianceHandler.findAllianceToFight",
        {}, "查找合适的联盟进行战斗失败!"):next(get_response_msg)
end
--行军到月门
function NetManager:getMarchToMoonGatePromose(dragonType,soldiers)
    return get_blocking_request_promise("logic.allianceHandler.marchToMoonGate",
        {dragonType = dragonType,
            soldiers = soldiers}, "行军到月门失败!"):next(get_response_msg)
end
--获取对手联盟数据
function NetManager:getFtechAllianceViewDataPromose(targetAllianceId)
    return get_blocking_request_promise("logic.allianceHandler.getAllianceViewData",
        {targetAllianceId = targetAllianceId,
            includeMoonGateData = true
        },"获取对手联盟数据失败!"):next(get_response_msg)
end
--从月门撤兵
function NetManager:getRetreatFromMoonGatePromose()
    return get_blocking_request_promise("logic.allianceHandler.retreatFromMoonGate",{},
        "从月门撤兵失败!"):next(get_response_msg)
end
--联盟战月门挑战
function NetManager:getChallengeMoonGateEnemyTroopPromose()
    return get_blocking_request_promise("logic.allianceHandler.challengeMoonGateEnemyTroop",{},
        "联盟战月门挑战失败!"):next(get_response_msg)
end
--请求联盟进行联盟战
function NetManager:getRequestAllianceToFightPromose()
    return get_blocking_request_promise("logic.allianceHandler.requestAllianceToFight",{},
        "请求联盟进行联盟战失败!"):next(get_response_msg)
end

--协防
function NetManager:getHelpAllianceMemberDefencePromise(dragonType, soldiers, targetPlayerId)
    return get_blocking_request_promise("logic.allianceHandler.helpAllianceMemberDefence",
        {
            dragonType = dragonType,
            soldiers   = soldiers,
            targetPlayerId = targetPlayerId,
        },
        "协防玩家失败!"):next(get_response_msg)
end
--撤销协防
function NetManager:getRetreatFromHelpedAllianceMemberPromise(beHelpedPlayerId)
    return get_blocking_request_promise("logic.allianceHandler.retreatFromBeHelpedAllianceMember",
        {
            beHelpedPlayerId = beHelpedPlayerId,
        },
        "撤销协防失败!"):next(get_response_msg)
end
--复仇其他联盟
function NetManager:getRevengeAlliancePromise(reportId)
    return get_blocking_request_promise("logic.allianceHandler.revengeAlliance",
        {
            reportId = reportId,
        },
        "复仇其他联盟失败!"):next(get_response_msg)
end
--查看战力相近的高低3个联盟的数据
function NetManager:getNearedAllianceInfosPromise()
    return get_blocking_request_promise("logic.allianceHandler.getNearedAllianceInfos",
        {},
        "查看战力相近的高低3个联盟的数据失败!"):next(get_response_msg)
end
--根据Tag搜索联盟战斗数据
function NetManager:getSearchAllianceInfoByTagPromise(tag)
    return get_blocking_request_promise("logic.allianceHandler.searchAllianceInfoByTag",
        {tag=tag},
        "根据Tag搜索联盟战斗数据失败!"):next(get_response_msg)
end
--突袭玩家城市
function NetManager:getStrikePlayerCityPromise(dragonType,defencePlayerId)
    return get_blocking_request_promise("logic.allianceHandler.strikePlayerCity",
        {dragonType=dragonType,defencePlayerId=defencePlayerId},
        "突袭玩家城市失败!"):next(get_response_msg)
end
--攻打玩家城市
function NetManager:getAttackPlayerCityPromise(dragonType, soldiers,defencePlayerId)
    return get_blocking_request_promise("logic.allianceHandler.attackPlayerCity",
        {defencePlayerId=defencePlayerId,dragonType=dragonType,soldiers = soldiers},"攻打玩家城市失败!"):next(get_response_msg)
end

--设置驻防使用的龙
function NetManager:getSetDefenceDragonPromise(dragonType)
    return get_none_blocking_request_promise("logic.playerHandler.setDefenceDragon",
        {dragonType=dragonType},
        "设置驻防使用的龙失败!"):next(get_response_msg)
end
--取消龙驻防
function NetManager:getCancelDefenceDragonPromise()
    return get_none_blocking_request_promise("logic.playerHandler.cancelDefenceDragon",
        nil,
        "取消龙驻防失败!"):next(get_response_msg)
end
--攻击村落
function NetManager:getAttackVillagePromise(dragonType,soldiers,defenceAllianceId,defenceVillageId)
    return get_blocking_request_promise("logic.allianceHandler.attackVillage",
        {defenceVillageId = defenceVillageId,defenceAllianceId=defenceAllianceId,dragonType=dragonType,soldiers = soldiers},"攻打村落失败!"):next(get_response_msg)
end
--从村落撤退
function NetManager:getRetreatFromVillagePromise(allianceId,eventId)
    return get_blocking_request_promise("logic.allianceHandler.retreatFromVillage",
        {villageEventId = eventId},"村落撤退失败!"):next(get_response_msg)
end
--突袭村落
function NetManager:getStrikeVillagePromise(dragonType,defenceAllianceId,defenceVillageId)
    return get_blocking_request_promise("logic.allianceHandler.strikeVillage",
        {dragonType = dragonType,defenceAllianceId = defenceAllianceId,defenceVillageId=defenceVillageId},"突袭村落失败!"):next(get_response_msg)
end
--查看敌方进攻行军事件详细信息
function NetManager:getAttackMarchEventDetailPromise(eventId)
    return get_blocking_request_promise("logic.allianceHandler.getAttackMarchEventDetail",
        {eventId = eventId},"获取行军事件数据失败!"):next(get_response_msg)
end
--查看敌方突袭行军事件详细信息
function NetManager:getStrikeMarchEventDetailPromise(eventId)
    return get_blocking_request_promise("logic.allianceHandler.getStrikeMarchEventDetail",
        {eventId = eventId},"获取突袭事件数据失败!"):next(get_response_msg)
end
--查看协助部队行军事件详细信息
function NetManager:getHelpDefenceMarchEventDetailPromise(eventId)
    return get_blocking_request_promise("logic.allianceHandler.getHelpDefenceMarchEventDetail",
        {eventId = eventId},"获取协防事件数据失败!"):next(get_response_msg)
end
--查看协防部队详细信息
function NetManager:getHelpDefenceTroopDetailPromise(playerId,helpedByPlayerId)
    return get_blocking_request_promise("logic.allianceHandler.getHelpDefenceTroopDetail",
        {playerId = playerId,helpedByPlayerId = helpedByPlayerId},"查看协防部队详细信息失败!"):next(get_response_msg)
end
-- 出售商品
function NetManager:getSellItemPromise(type,name,count,price)
    return get_blocking_request_promise("logic.playerHandler.sellItem", {
        type = type,
        name = name,
        count = count,
        price = price,
    }, "出售商品失败!"):next(get_response_msg)
end
-- 获取商品列表
function NetManager:getGetSellItemsPromise(type,name)
    return get_blocking_request_promise("logic.playerHandler.getSellItems", {
        type = type,
        name = name,
    }, "获取商品列表失败!"):next(get_response_msg)
end
-- 购买出售的商品
function NetManager:getBuySellItemPromise(itemId)
    return get_blocking_request_promise("logic.playerHandler.buySellItem", {
        itemId = itemId
    }, "购买出售的商品失败!"):next(get_response_msg)
end
-- 获取出售后赚取的银币
function NetManager:getGetMyItemSoldMoneyPromise(itemId)
    return get_blocking_request_promise("logic.playerHandler.getMyItemSoldMoney", {
        itemId = itemId
    }, "获取出售后赚取的银币失败!"):next(get_response_msg)
end
-- 下架商品
function NetManager:getRemoveMySellItemPromise(itemId)
    return get_blocking_request_promise("logic.playerHandler.removeMySellItem", {
        itemId = itemId
    }, "下架商品失败!"):next(get_response_msg)
end
--升级生产科技
function NetManager:getUpgradeProductionTechPromise(techName,finishNow)
    return get_blocking_request_promise("logic.playerHandler.upgradeProductionTech", {
        techName = techName,
        finishNow = finishNow,
    }, "升级生产科技失败!"):next(get_response_msg)
end
-- 升级军事科技
local function upgrade_military_tech_promise(techName,finishNow)
    return get_blocking_request_promise("logic.playerHandler.upgradeMilitaryTech", {
        techName = techName,
        finishNow = finishNow,
    }, "升级军事科技失败!"):next(get_response_msg)
end


function NetManager:getInstantUpgradeMilitaryTechPromise(techName)
    return upgrade_military_tech_promise(techName,true)
end
function NetManager:getUpgradeMilitaryTechPromise(techName)
    return upgrade_military_tech_promise(techName,false)
end
-- 士兵晋级
local function upgrade_soldier_star_promise(soldierName,finishNow)
    return get_blocking_request_promise("logic.playerHandler.upgradeSoldierStar", {
        soldierName = soldierName,
        finishNow = finishNow,
    }, "士兵晋级失败!"):next(get_response_msg)
end
function NetManager:getInstantUpgradeSoldierStarPromise(soldierName)
    return upgrade_soldier_star_promise(soldierName,true)
end
function NetManager:getUpgradeSoldierStarPromise(soldierName)
    return upgrade_soldier_star_promise(soldierName,false)
end
--设置pve数据
function NetManager:getSetPveDataPromise(pveData)
    return get_blocking_request_promise("logic.playerHandler.setPveData",
        pveData, "设置pve数据失败!"):next(get_response_msg)
end
--为联盟成员添加荣耀值
function NetManager:getGiveLoyaltyToAllianceMemberPromise(memberId,count)
    return get_blocking_request_promise("logic.allianceHandler.giveLoyaltyToAllianceMember",
        {
            memberId=memberId,
            count=count
        },
        "为联盟成员添加荣耀值失败!"):next(get_response_msg)
end
--购买道具
function NetManager:getBuyItemPromise(itemName,count)
    return get_blocking_request_promise("logic.playerHandler.buyItem", {
        itemName = itemName,
        count = count,
    }, "购买道具失败!"):next(get_response_msg):done(function ()
        ext.market_sdk.onPlayerBuyGameItems(itemName,count,DataUtils:GetItemPriceByItemName(itemName))
    end)
end
--使用道具
function NetManager:getUseItemPromise(itemName,params)
    return get_blocking_request_promise("logic.playerHandler.useItem", {
        itemName = itemName,
        params = params,
    }, "使用道具失败!"):next(get_response_msg):done(function ()
        ext.market_sdk.onPlayerUseGameItems(itemName,1)
    end)
end
--购买并使用道具
function NetManager:getBuyAndUseItemPromise(itemName,params)
    return get_blocking_request_promise("logic.playerHandler.buyAndUseItem", {
        itemName = itemName,
        params = params,
    }, "购买并使用道具失败!"):next(get_response_msg):done(function()
        GameGlobalUI:showTips(_("提示"),string.format('使用%s道具成功',Localize_item.item_name[itemName]))
        ext.market_sdk.onPlayerBuyGameItems(itemName,1,DataUtils:GetItemPriceByItemName(itemName))
        ext.market_sdk.onPlayerUseGameItems(itemName,1)
    end)
end

--联盟商店补充道具
function NetManager:getAddAllianceItemPromise(itemName,count)
    return get_blocking_request_promise("logic.allianceHandler.addItem",
        {
            itemName = itemName,
            count = count,
        },
        "联盟商店补充道具失败!"):next(get_response_msg)
end
--购买联盟商店的道具
function NetManager:getBuyAllianceItemPromise(itemName,count)
    return get_blocking_request_promise("logic.allianceHandler.buyItem",
        {
            itemName = itemName,
            count = count,
        },
        "购买联盟商店的道具失败!"):next(get_response_msg)
end
--玩家内购
--TODO:
function NetManager:getVerifyIAPPromise(transactionId,receiptData)
    return get_none_blocking_request_promise("logic.playerHandler.addPlayerBillingData",
        {
            transactionId=transactionId,receiptData=receiptData
        }
        ,"玩家内购失败"):next(get_response_msg)
end
--获得每日登陆奖励
function NetManager:getDay60RewardPromise()
    return get_blocking_request_promise("logic.playerHandler.getDay60Reward",
        nil,
        "获得每日登陆奖励失败!"):next(get_response_msg)
end

-- 获取每日在线奖励
function NetManager:getOnlineRewardPromise(timePoint)
    return get_blocking_request_promise("logic.playerHandler.getOnlineReward",
        {timePoint = timePoint},
        "获取每日在线奖励失败!"):next(get_response_msg)
end

-- 获取在线天数奖励
function NetManager:getDay14RewardPromise()
    return get_blocking_request_promise("logic.playerHandler.getDay14Reward",
        nil,
        "获取在线天数奖励失败!"):next(get_response_msg)
end
-- 首充奖励
function NetManager:getFirstIAPRewardsPromise()
    return get_blocking_request_promise("logic.playerHandler.getFirstIAPRewards",
        nil,
        "获取首充奖励失败!"):next(get_response_msg)
end

-- 新手冲级奖励
function NetManager:getLevelupRewardPromise(levelupIndex)
    return get_blocking_request_promise("logic.playerHandler.getLevelupReward",
        {levelupIndex = levelupIndex},
        "获取新手冲级奖励失败!"):next(get_response_msg)
end
-- 普通gacha
function NetManager:getNormalGachaPromise()
    return get_blocking_request_promise("logic.playerHandler.gacha",
        {type = "normal"},
        "普通gacha失败!"):next(get_response_msg)
end
-- 高级gacha
function NetManager:getAdvancedGachaPromise()
    return get_blocking_request_promise("logic.playerHandler.gacha",
        {type = "advanced"},
        "高级gacha失败!"):next(get_response_msg)
end


-- 通过Selina的考验
function NetManager:getPassSelinasTestPromise()
    return get_blocking_request_promise("logic.playerHandler.passSelinasTest",
        nil,
        "通过Selina的考验!"):next(get_response_msg)
end
-- 获取成就任务奖励
function NetManager:getGrowUpTaskRewardsPromise(taskType, taskId)
    return get_blocking_request_promise("logic.playerHandler.getGrowUpTaskRewards",{
        taskType = taskType,
        taskId = taskId
    }, "领取奖励失败!"):next(get_response_msg)
end

-- 领取日常任务奖励
function NetManager:getDailyTaskRewards(taskType)
    return get_blocking_request_promise("logic.playerHandler.getDailyTaskRewards",
        {taskType = taskType},
        "领取日常任务奖励!"):next(get_response_msg)
end
----------------------------------------------------------------------------------------------------------------
function NetManager:getUpdateFileList(cb)
    local updateServer = self.m_updateServer.host .. ":" .. self.m_updateServer.port .. "/update/res/fileList.json"
    self.m_netService:get(updateServer, nil, function(success, statusCode, msg)
        cb(success and statusCode == 200, msg)
    end)
end
function NetManager:downloadFile(fileInfo, cb, progressCb)
    local downloadUrl = self.m_updateServer.host .. ":" .. self.m_updateServer.port .. "/update/" .. fileInfo.path
    local filePath = GameUtils:getUpdatePath() .. fileInfo.path
    local docPath = LuaUtils:getDocPathFromFilePath(filePath)
    if not ext.isDirectoryExist(docPath) then
        if not ext.createDirectory(docPath) then
            cb(false)
            return
        end
    end

    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local crc32 = ext.crc32(filePath)
        if crc32 == fileInfo.crc32 then
            local file = io.open(filePath, "rb")
            if not file then
                cb(false)
                return
            end
            local fileLength = file:seek("end")
            file:close()
            progressCb(fileLength, fileLength)
            cb(true)
            return
        end
    end

    self.m_netService:get(downloadUrl, nil, function(success, statusCode, msg)
        if success and statusCode == 200 then
            local file = io.open(filePath, "w")
            if not file then
                cb(false)
                return
            end
            file:write(msg)
            file:close()
            local fileLength = string.len(msg)
            progressCb(fileLength, fileLength)
            cb(true)
        else
            cb(false)
        end
    end, function(totalSize, currentSize)
        progressCb(totalSize, currentSize)
    end)
end




















