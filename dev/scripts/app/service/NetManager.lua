local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local gaozhou
if CONFIG_IS_DEBUG then
    local result
    gaozhou, result = pcall(require, "app.service.gaozhou")
end
NetManager = {}
local SUCCESS_CODE = 200
local FAILED_CODE = 500
local TIME_OUT = 10
-- 过滤器
local function get_response_msg(results)
    return results[2].msg
end
local function check_response(m)
    return function(result)
        if result.success then
            return result
        end
        promise.reject(m)
    end
end
local function check_request(m)
    return function(result)
        if not result.success or result.msg.code ~= SUCCESS_CODE then
            promise.reject(result.msg.message, m)
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
    local p =  cocos_promise.promiseWithTimeOut(get_request_promise(request_route, data, m), TIME_OUT):always(function()
        loading:removeFromParent()
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
    self.m_isDisconnect = true
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
        device.showAlert(nil, _("连接服务器超时!"), {_("确定")}, function(event)
            app:enterScene("MainScene")
        end)
    end)
end

function NetManager:removeTimeoutEventListener(  )
    self:removeEventListener("timeout")
end

function NetManager:addDisconnectEventListener()
-- self:addEventListener("disconnect", function(success, msg)
--     device.showAlert(nil, _("和服务器的连接已断开!"), {_("确定")}, function(event)
--         app:restart()
--     end)
--     print("addDisconnectEventListener----->disconnect")
-- end)
end

function NetManager:removeDisConnectEventListener(  )
    self:removeEventListener("disconnect")
end

function NetManager:addKickEventListener()
    self:addEventListener("onKick", function(success, msg)
        print("addKickEventListener----->onKick")
        device.showAlert(nil, _("和服务器的连接已断开!"), {_("确定")}, function(event)
            LuaUtils:outputTable("msg", msg)
            app:restart()
        end)
    end)
end

function NetManager:removeKickEventListener(  )
    self:removeEventListener("onKick")
end


-- local event_map = {}
-- function NetManager:addEventHandle(event_name, handle)
--     event_map[event_name] = {handle = handle, callbacks = {}}
--     self:addEventListener("onPlayerDataChanged", function(...)
--         local event = event_map[event_name]
--         handle(...)
--         assert(#event.callbacks <= 1, "重复请求过多了")
--         local callback = event.callbacks[1]
--         if type(callback) == "function" then
--             callback(success, msg)
--         end
--         event.callbacks = {}
--     end)
-- end
-- function NetManager:removeEventHandle(event_name)
--     self:removeEventListener(event_name)
--     event_map[event_name] = nil
-- end

onPlayerDataChanged_callbacks = {}
function NetManager:addPlayerDataChangedEventListener()
    self:addEventListener("onPlayerDataChanged", function(success, msg)
        if success then
            LuaUtils:outputTable("onPlayerDataChanged", msg)
            DataManager:setUserData(msg)
        end
        local callback = onPlayerDataChanged_callbacks[1]
        if type(callback) == "function" then
            callback(success, msg)
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
            LuaUtils:outputTable("onAllianceDataChanged", msg)
            DataManager:setUserAllianceData(msg)
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
            LuaUtils:outputTable("onGetAllianceDataSuccess", msg)
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
function NetManager:addOnGetMailsSuccessListener()
    self:addEventListener("onGetMailsSuccess", function(success, msg)
        if success then
            assert(#onGetMailsSuccess_callbacks <= 1, "重复请求过多了!")

            LuaUtils:outputTable("onGetMailsSuccess", msg)
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
            if app.chatCenter then
                app.chatCenter:handleNetMessage("onChat",msg)
            end
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
            if app.chatCenter then
                app.chatCenter:handleNetMessage("onAllChat",msg)
            end
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
            local buildingName = UIKit:getBuildingLocalizedKeyByBuildingType(msg.buildingType)
            GameGlobalUI:showTips(_("建筑升级完成"),string.format('%s(LV %d)',_(buildingName),msg.level))
        end
    end)
end
function NetManager:addOnHouseLevelUpListener()
    self:addEventListener("onHouseLevelUp", function(success, msg)
        if success then
            local houseName = UIKit:getHouseLocalizedKeyByBuildingType(msg.houseType)
            GameGlobalUI:showTips(_("小屋升级完成"),string.format('%s(LV %d)',_(houseName),msg.level))
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
            local buildingName = UIKit:getBuildingLocalizedKeyByBuildingType(msg.buildingType)
            GameGlobalUI:showTips(_("建筑升级完成"),string.format('%s(LV %d)',_(buildingName),msg.level))
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

------------------------------------------------------------------------------------------------
function NetManager:addLoginEventListener()
    self:addEventListener("onPlayerLoginSuccess", function(success, msg)
        if success then
            if self.m_isDisconnect then
                self.m_netService:setDeltatime(msg.serverTime - ext.now())
                DataManager:setUserData(msg)
            else
                LuaUtils:outputTable("onPlayerLoginSuccess", msg)
                self.m_netService:setDeltatime(msg.serverTime - ext.now())
                local InitGame = import("app.service.InitGame")
                InitGame(msg)
                -- app:enterScene("AllianceScene")
                -- app:enterScene("MyCityScene", {City})
            end
            self.m_isDisconnect = false
        end
    end)
end
function NetManager:removeLoginEventListener(  )
    self:removeEventListener("onPlayerLoginSuccess")
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
        self:addLoginEventListener()

        self:addOnSearchAlliancesSuccessListener()
        self:addOnGetNearedAllianceInfosSuccessListener()
        self:addOnSearchAllianceInfoByTagSuccessListener()
        self:addOnGetCanDirectJoinAlliancesSuccessListener()
        self:addOnGetPlayerInfoSuccessListener()
        self:addOnGetPlayerViewDataSuccess()
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
    end)
end
-- 登录
function NetManager:getLoginPromise()
    local device_id
    if CONFIG_IS_DEBUG then
        if gaozhou then
            device_id = "b"
        else
            device_id = device.getOpenUDID()
        end
    else
        device_id = device.getOpenUDID()
    end
    return get_none_blocking_request_promise("logic.entryHandler.login", {deviceId = device_id})
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

-- 修改城市名字
function NetManager:getEditPlayerCityNamePromise(cityName)
    return promise.all(get_blocking_request_promise("logic.playerHandler.editPlayerCityName", {
        cityName = cityName,
    }, "修改城市名字失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 建造小屋
function NetManager:getCreateHouseByLocationPromise(location, sub_location, building_type)
    return promise.all(get_blocking_request_promise("logic.playerHandler.createHouse", {
        buildingLocation = location,
        houseLocation = sub_location,
        houseType = building_type,
        finishNow = false
    }, "建造小屋失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 拆除小屋
function NetManager:getDestroyHouseByLocationPromise(location, sub_location)
    return promise.all(get_blocking_request_promise("logic.playerHandler.destroyHouse", {
        buildingLocation = location,
        houseLocation = sub_location
    }, "拆除小屋失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 升级小屋
local function get_upgradeHouse_promise(location, sub_location, finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeHouse", {
        buildingLocation = location,
        houseLocation = sub_location,
        finishNow = finish_now or false
    }, "升级小屋失败!")
end
function NetManager:getUpgradeHouseByLocationPromise(location, sub_location)
    return promise.all(get_upgradeHouse_promise(location, sub_location, false), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantUpgradeHouseByLocationPromise(location, sub_location)
    return promise.all(get_upgradeHouse_promise(location, sub_location, true), get_playerdata_callback()):next(get_response_msg)
end
-- 升级功能建筑
local function get_upgradeBuilding_promise(location, finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeBuilding", {
        location = location,
        finishNow = finish_now or false
    }, "升级功能建筑失败!")
end
function NetManager:getUpgradeBuildingByLocationPromise(location)
    return promise.all(get_upgradeBuilding_promise(location, false), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantUpgradeBuildingByLocationPromise(location)
    return promise.all(get_upgradeBuilding_promise(location, true), get_playerdata_callback()):next(get_response_msg)
end
-- 升级防御塔
local function get_upgradeTower_promise(location, finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeTower", {
        location = location,
        finishNow = finish_now or false
    }, "升级防御塔失败!")
end
function NetManager:getUpgradeTowerByLocationPromise(location)
    return promise.all(get_upgradeTower_promise(location, false), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantUpgradeTowerByLocationPromise(location)
    return promise.all(get_upgradeTower_promise(location, true), get_playerdata_callback()):next(get_response_msg)
end
-- 升级城门
local function get_upgradeWall_promise(finish_now)
    return get_blocking_request_promise("logic.playerHandler.upgradeWall", {
        finishNow = finish_now or false
    }, "升级防御塔失败!")
end
function NetManager:getUpgradeWallByLocationPromise()
    return promise.all(get_upgradeWall_promise(false), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantUpgradeWallByLocationPromise()
    return promise.all(get_upgradeWall_promise(true), get_playerdata_callback()):next(get_response_msg)
end
-- 征收税
function NetManager:getImposePromise()
    return promise.all(get_blocking_request_promise("logic.playerHandler.impose", nil,
        "收税失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 制造材料
local function get_makeMaterial_promise(category)
    return get_blocking_request_promise("logic.playerHandler.makeMaterial", {
        category = category,
        finishNow = false
    }, "制造材料失败!")
end
-- 建造建筑材料
function NetManager:getMakeBuildingMaterialPromise()
    return promise.all(get_makeMaterial_promise("building"), get_playerdata_callback()):next(get_response_msg)
end
-- 建造科技材料
function NetManager:getMakeTechnologyMaterialPromise()
    return promise.all(get_makeMaterial_promise("technology"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取材料
local function get_fetchMaterials_promise(category)
    return get_blocking_request_promise("logic.playerHandler.getMaterials", {
        category = category,
    }, "获取材料失败!")
end
-- 获取建筑材料
function NetManager:getFetchBuildingMaterialsPromise()
    return promise.all(get_fetchMaterials_promise("building"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取科技材料
function NetManager:getFetchTechnologyMaterialsPromise()
    return promise.all(get_fetchMaterials_promise("technology"), get_playerdata_callback()):next(get_response_msg)
end
-- 打造装备
local function get_makeDragonEquipment_promise(equipment_name, finish_now)
    return get_blocking_request_promise("logic.playerHandler.makeDragonEquipment", {
        equipmentName = equipment_name,
        finishNow = finish_now or false
    }, "打造装备失败!")
end
function NetManager:getMakeDragonEquipmentPromise(equipment_name)
    return promise.all(get_makeDragonEquipment_promise(equipment_name), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantMakeDragonEquipmentPromise(equipment_name)
    return promise.all(get_makeDragonEquipment_promise(equipment_name, true), get_playerdata_callback()):next(get_response_msg)
end
-- 招募士兵
local function get_recruitNormalSoldier_promise(soldierName, count, finish_now)
    return get_blocking_request_promise("logic.playerHandler.recruitNormalSoldier", {
        soldierName = soldierName,
        count = count,
        finishNow = finish_now or false
    }, "招募普通士兵失败!")
end
function NetManager:getRecruitNormalSoldierPromise(soldierName, count, cb)
    return promise.all(get_recruitNormalSoldier_promise(soldierName, count), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantRecruitNormalSoldierPromise(soldierName, count, cb)
    return promise.all(get_recruitNormalSoldier_promise(soldierName, count, true), get_playerdata_callback()):next(get_response_msg)
end
-- 普通治疗士兵
local function get_treatSoldier_promise(soldiers, finish_now)
    return get_blocking_request_promise("logic.playerHandler.treatSoldier", {
        soldiers = soldiers,
        finishNow = finish_now or false
    }, "普通治疗士兵失败!")
end
function NetManager:getTreatSoldiersPromise(soldiers)
    return promise.all(get_treatSoldier_promise(soldiers), get_playerdata_callback()):next(get_response_msg)
end
function NetManager:getInstantTreatSoldiersPromise(soldiers)
    return promise.all(get_treatSoldier_promise(soldiers), get_playerdata_callback()):next(get_response_msg)
end
-- 孵化
function NetManager:getHatchDragonPromise(dragonType)
    return promise.all(get_blocking_request_promise("logic.playerHandler.hatchDragon", {
        dragonType = dragonType,
    }, "孵化失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 装备
function NetManager:getLoadDragonEquipmentPromise(dragonType, equipmentCategory, equipmentName)
    return promise.all(get_blocking_request_promise("logic.playerHandler.setDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory,
        equipmentName = equipmentName
    }, "装备失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 卸载装备
function NetManager:getResetDragonEquipmentPromise(dragonType, equipmentCategory)
    return promise.all(get_blocking_request_promise("logic.playerHandler.resetDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory
    }, "卸载装备失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 强化装备
function NetManager:getEnhanceDragonEquipmentPromise(dragonType, equipmentCategory, equipments)
    return promise.all(get_blocking_request_promise("logic.playerHandler.enhanceDragonEquipment", {
        dragonType = dragonType,
        equipmentCategory = equipmentCategory,
        equipments = equipments
    }, "强化装备失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 升级龙星
function NetManager:getUpgradeDragonStarPromise(dragonType)
    return promise.all(get_blocking_request_promise("logic.playerHandler.upgradeDragonStar", {
        dragonType = dragonType,
    }, "升级龙星失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 升级龙技能
function NetManager:getUpgradeDragonDragonSkillPromise(dragonType, skillKey)
    return promise.all(get_blocking_request_promise("logic.playerHandler.upgradeDragonSkill", {
        dragonType = dragonType,
        skillKey = skillKey
    }, "升级龙技能失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 发送个人邮件
function NetManager:getSendPersonalMailPromise(memberName, title, content)
    return promise.all(get_blocking_request_promise("logic.playerHandler.sendMail", {
        memberName = memberName,
        title = title,
        content = content,
    }, "发送个人邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取收件箱邮件
function NetManager:getFetchMailsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getMails", {
        fromIndex = fromIndex
    }, "获取收件箱邮件失败!"), get_inboxmails_callback()):next(get_response_msg)
end
-- 阅读邮件
function NetManager:getReadMailsPromise(mailIds)
    return promise.all(get_blocking_request_promise("logic.playerHandler.readMails", {
        mailIds = mailIds
    }, "阅读邮件失败!"))
end
-- 收藏邮件
function NetManager:getSaveMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.saveMail", {
        mailId = mailId
    }, "收藏邮件失败!"))
end
-- 取消收藏邮件
function NetManager:getUnSaveMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.unSaveMail", {
        mailId = mailId
    }, "取消收藏邮件失败!"))
end
-- 获取收藏邮件
function NetManager:getFetchSavedMailsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getSavedMails", {
        fromIndex = fromIndex
    }, "获取收藏邮件失败!"), get_savedmails_callback()):next(get_response_msg)
end
-- 获取已发送邮件
function NetManager:getFetchSendMailsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getSendMails", {
        fromIndex = fromIndex
    }, "获取已发送邮件失败!"), get_sendmails_callback()):next(get_response_msg)
end
-- 删除邮件
function NetManager:getDeleteMailsPromise(mailIds)
    return promise.all(get_blocking_request_promise("logic.playerHandler.deleteMails", {
        mailIds = mailIds
    }, "删除邮件失败!"))
end
-- 发送联盟邮件
function NetManager:getSendAllianceMailPromise(title, content)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.sendAllianceMail", {
        title = title,
        content = content,
    }, "发送联盟邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 阅读战报
function NetManager:getReadReportsPromise(reportIds)
    return promise.all(get_blocking_request_promise("logic.playerHandler.readReports", {
        reportIds = reportIds
    }, "阅读战报失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 收藏战报
function NetManager:getSaveReportPromise(reportId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.saveReport", {
        reportId = reportId
    }, "收藏战报失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 取消收藏战报
function NetManager:getUnSaveReportPromise(reportId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.unSaveReport", {
        reportId = reportId
    }, "取消收藏战报失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取玩家战报
function NetManager:getReportsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getReports", {
        fromIndex = fromIndex
    }, "获取玩家战报失败!"), get_reports_callback()):next(get_response_msg)
end
-- 获取玩家已存战报
function NetManager:getSavedReportsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getSavedReports", {
        fromIndex = fromIndex
    }, "获取玩家已存战报失败!"), get_savedreports_callback()):next(get_response_msg)
end
-- 删除战报
function NetManager:getDeleteReportsPromise(reportIds)
    return promise.all(get_blocking_request_promise("logic.playerHandler.deleteReports", {
        reportIds = reportIds
    }, "删除战报失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 请求加速
function NetManager:getRequestAllianceToSpeedUpPromise(eventType, eventId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.requestAllianceToSpeedUp", {
        eventType = eventType,
        eventId = eventId,
    }, "请求加速失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 免费加速建筑升级
function NetManager:getFreeSpeedUpPromise(eventType, eventId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.freeSpeedUp", {
        eventType = eventType,
        eventId = eventId,
    }, "请求免费加速失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 协助玩家加速
function NetManager:getHelpAllianceMemberSpeedUpPromise(eventId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.helpAllianceMemberSpeedUp", {
        eventId = eventId,
    }, "协助玩家加速失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 协助所有玩家加速
function NetManager:getHelpAllAllianceMemberSpeedUpPromise()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.helpAllAllianceMemberSpeedUp", {}
        , "协助所有玩家加速失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 创建联盟
function NetManager:getCreateAlliancePromise(name, tag, language, terrain, flag)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.createAlliance", {
        name = name,
        tag = tag,
        language = language,
        terrain = terrain,
        flag = flag
    }, "创建联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 退出联盟
function NetManager:getQuitAlliancePromise()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.quitAlliance", nil
        , "退出联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 修改联盟加入条件
function NetManager:getEditAllianceJoinTypePromise(join_type)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceJoinType", {
        joinType = join_type
    }, "修改联盟加入条件失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 拒绝玩家
function NetManager:getRefuseJoinAllianceRequestPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = false
    }, "拒绝玩家失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 接受玩家
function NetManager:getAgreeJoinAllianceRequestPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = true
    }, "接受玩家失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 踢出玩家
function NetManager:getKickAllianceMemberOffPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.kickAllianceMemberOff", {
        memberId = memberId,
    }, "踢出玩家失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 搜索特定标签联盟
function NetManager:getSearchAllianceByTagPromsie(tag)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.searchAllianceByTag", {
        tag = tag
    }, "搜索特定标签联盟失败!"), get_searchalliance_callback()):next(get_response_msg)
end
-- 搜索能直接加入联盟
function NetManager:getFetchCanDirectJoinAlliancesPromise()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.getCanDirectJoinAlliances", nil
        , "搜索直接加入联盟失败!"), get_directjoin_callback()):next(get_response_msg)
end
-- 邀请加入联盟
function NetManager:getInviteToJoinAlliancePromise(memberId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.inviteToJoinAlliance", {
        memberId = memberId
    }, "邀请加入联盟联盟失败!"))
end
-- 直接加入联盟
function NetManager:getJoinAllianceDirectlyPromise(allianceId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.joinAllianceDirectly", {
        allianceId = allianceId
    }, "直接加入联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 请求加入联盟
function NetManager:getRequestToJoinAlliancePromise(allianceId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.requestToJoinAlliance", {
        allianceId = allianceId
    }, "请求加入联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取玩家信息
function NetManager:getPlayerInfoPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getPlayerInfo", {
        memberId = memberId
    }, "获取玩家信息失败!"), get_playerinfo_callback()):next(get_response_msg)
end
-- 获取玩家城市信息
function NetManager:getPlayerCityInfoPromise(targetPlayerId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getPlayerViewData", {
        targetPlayerId = targetPlayerId
    }, "获取玩家城市信息失败!"), get_cityinfo_callback()):next(get_response_msg)
end
-- 移交萌主
function NetManager:getHandOverAllianceArchonPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.handOverAllianceArchon", {
        memberId = memberId,
    }, "移交萌主失败!"), get_playerinfo_callback()):next(get_response_msg)
end
-- 修改成员职位
function NetManager:getEditAllianceMemberTitlePromise(memberId, title)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceMemberTitle", {
        memberId = memberId,
        title = title
    }, "修改成员职位失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 修改联盟公告
function NetManager:getEditAllianceNoticePromise(notice)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceNotice", {
        notice = notice
    }, "修改联盟公告失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 修改联盟描述
function NetManager:getEditAllianceDescriptionPromise(description)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceDescription", {
        description = description
    }, "修改联盟描述失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 修改职位名字
function NetManager:getEditAllianceTitleNamePromise(title, titleName)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceTitleName", {
        title = title,
        titleName = titleName
    }, "修改职位名字失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 发送秘籍
function NetManager:getSendGlobalMsgPromise(text)
    return promise.all(get_blocking_request_promise("chat.chatHandler.send", {
        ["text"] = text,
        ["type"] = "global"
    }, "发送世界聊天信息失败!"))
end
--发送聊天信息
function NetManager:getSendChatPromise(type,text)
    return promise.all(get_none_blocking_request_promise("chat.chatHandler.send", {
        ["text"] = text,
        ["type"] = type
    }, "发送聊天信息失败!"),get_sendchat_callback())
end
--获取所有聊天信息
function NetManager:getFetchChatPromise()
    return promise.all(get_none_blocking_request_promise("chat.chatHandler.getAll",nil, "获取聊天信息失败!"),get_fetchchat_callback())
end
--处理联盟的对玩家的邀请
local function getHandleJoinAllianceInvitePromise(allianceId, agree)
    return get_blocking_request_promise("logic.allianceHandler.handleJoinAllianceInvite", {
        ["allianceId"] = allianceId,
        ["agree"] = agree,
    }, "处理联盟的对玩家的邀请失败!")
end
function NetManager:getHandleJoinAllianceInvitePromise(allianceId, agree)
    return promise.all(getHandleJoinAllianceInvitePromise(allianceId, agree))
end
function NetManager:getAgreeJoinAllianceInvitePromise(allianceId)
    return getHandleJoinAllianceInvitePromise(allianceId, true)
end
function NetManager:getDisagreeJoinAllianceInvitePromise(allianceId)
    return promise.all(getHandleJoinAllianceInvitePromise(allianceId, false))
end
--取消申请联盟
function NetManager:getCancelJoinAlliancePromise(allianceId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.cancelJoinAllianceRequest", {
        ["allianceId"] = allianceId,
    }, "取消申请联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
--修改联盟基本信息
function NetManager:getEditAllianceBasicInfoPromise(name, tag, language, flag)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.editAllianceBasicInfo", {
        name = name,
        tag = tag,
        language = language,
        flag = flag
    }, "修改联盟基本信息失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 移动联盟建筑
function NetManager:getMoveAllianceBuildingPromise(buildingName, locationX, locationY)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.moveAllianceBuilding", {
        buildingName = buildingName,
        locationX = locationX,
        locationY = locationY
    }, "移动联盟建筑失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 移动玩家城市
function NetManager:getMoveAllianceMemberPromise(locationX, locationY)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.moveAllianceMember", {
        locationX = locationX,
        locationY = locationY
    }, "移动玩家城市失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 拆除装饰物
function NetManager:getDistroyAllianceDecoratePromise(decorateId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.distroyAllianceDecorate", {
        decorateId = decorateId
    }, "拆除装饰物失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 激活联盟事件
function NetManager:getActivateAllianceShrineStagePromise(stageName)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.activateAllianceShrineStage", {
        stageName = stageName
    }, "激活联盟事件失败!"),get_alliancedata_callback()):next(get_response_msg)
end
-- 升级联盟建筑
function NetManager:getUpgradeAllianceBuildingPromise(buildingName)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.upgradeAllianceBuilding", {
        buildingName = buildingName
    }, "升级联盟建筑失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 联盟捐赠
function NetManager:getDonateToAlliancePromise(donateType)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.donateToAlliance", {
        donateType = donateType
    }, "联盟捐赠失败!"), get_alliancedata_callback()):next(get_response_msg)
end
function NetManager:getMarchToShrinePromose(shrineEventId,dragonType,soldiers)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.marchToShrine", {
        dragonType = dragonType,
        shrineEventId = shrineEventId,
        soldiers = soldiers
    }, "圣地派兵失败!"), get_alliancedata_callback()):next(get_response_msg)
end
--查找合适的联盟进行战斗
function NetManager:getFindAllianceToFightPromose()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.findAllianceToFight",
        {}, "查找合适的联盟进行战斗失败!"), get_alliancedata_callback()):next(get_response_msg)
end
--行军到月门
function NetManager:getMarchToMoonGatePromose(dragonType,soldiers)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.marchToMoonGate",
        {dragonType = dragonType,
            soldiers = soldiers}, "行军到月门失败!"), get_alliancedata_callback()):next(get_response_msg)
end
--获取对手联盟数据
function NetManager:getFtechAllianceViewDataPromose(targetAllianceId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.getAllianceViewData",
        {targetAllianceId = targetAllianceId,
            includeMoonGateData = true
        },"获取对手联盟数据失败!"),get_fetchallianceview_callback()):next(get_response_msg)
end
--从月门撤兵
function NetManager:getRetreatFromMoonGatePromose()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.retreatFromMoonGate",{},
        "从月门撤兵失败!"),get_alliancedata_callback()):next(get_response_msg)
end
--联盟战月门挑战
function NetManager:getChallengeMoonGateEnemyTroopPromose()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.challengeMoonGateEnemyTroop",{},
        "联盟战月门挑战失败!"),get_alliancedata_callback()):next(get_response_msg)
end
--请求联盟进行联盟战
function NetManager:getRequestAllianceToFightPromose()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.requestAllianceToFight",{},
        "请求联盟进行联盟战失败!"),get_alliancedata_callback()):next(get_response_msg)
end

--协防
function NetManager:getHelpAllianceMemberDefencePromise(dragonType, soldiers, targetPlayerId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.helpAllianceMemberDefence",
        {
            dragonType = dragonType,
            soldiers   = soldiers,
            targetPlayerId = targetPlayerId,
        },
        "协防玩家失败!"),get_alliancedata_callback()):next(get_response_msg)
end
--撤销协防
function NetManager:getRetreatFromHelpedAllianceMemberPromise(targetPlayerId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.retreatFromHelpedAllianceMember",
        {
            targetPlayerId = targetPlayerId,
        },
        "撤销协防失败!"),get_alliancedata_callback()):next(get_response_msg)
end
--复仇其他联盟
function NetManager:getRevengeAlliancePromise(reportId)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.revengeAlliance",
        {
            reportId = reportId,
        },
        "复仇其他联盟失败!"),get_alliancedata_callback()):next(get_response_msg)
end
--查看战力相近的高低3个联盟的数据
function NetManager:getNearedAllianceInfosPromise()
    return promise.all(get_blocking_request_promise("logic.allianceHandler.getNearedAllianceInfos",
        {},
        "查看战力相近的高低3个联盟的数据失败!"),get_nearedallianceinfos_callback()):next(get_response_msg)
end
--根据Tag搜索联盟战斗数据
function NetManager:getSearchAllianceInfoByTagPromise(tag)
    return promise.all(get_blocking_request_promise("logic.allianceHandler.searchAllianceInfoByTag",
        {tag=tag},
        "根据Tag搜索联盟战斗数据失败!"),get_searchallianceinfobytag_callback()):next(get_response_msg)
end
--突袭玩家城市
function NetManager:getStrikePlayerCityPromise(dragonType,enemyPlayerId)
    return promise.all(get_none_blocking_request_promise("logic.allianceHandler.strikePlayerCity",
        {dragonType=dragonType,enemyPlayerId=enemyPlayerId},
        "突袭玩家城市失败!"),get_playerdata_callback()):next(get_response_msg)
end
--设置驻防使用的龙
function NetManager:getSetDefenceDragonPromise(dragonType)
    return promise.all(get_none_blocking_request_promise("logic.playerHandler.setDefenceDragon",
        {dragonType=dragonType},
        "设置驻防使用的龙失败!"),get_playerdata_callback()):next(get_response_msg)
end

--
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












