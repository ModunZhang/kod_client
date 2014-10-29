local promise = import("..utils.promise")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
NetManager = {}
local SUCCESS_CODE = 200
local FAILED_CODE = 500
-- next
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
            promise.reject(m)
        end
        return result
    end
end
-- 返回promise的函数
local function get_blocking_request_promise(request_route, data, m)
    local p = promise.new(check_request(m or ""))
    NetManager.m_netService:request(request_route, data, function(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
local function get_none_blocking_request_promise(request_route, data, m)
    local p = promise.new(check_request(m or ""))
    NetManager.m_netService:request(request_route, data, function(success, msg)
        p:resolve({success = success, msg = msg})
    end, false)
    return p
end
local function get_callback_promise(callbacks, m)
    local p = promise.new(check_response(m or ""))
    table.insert(callbacks, function(success, msg)
        -- dump(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
-- timeout promise
local function get_timeout_promise(time)
    local time = time or 5
    local p = promise.new(function()
        promise.reject("timeout", time)
    end)
    scheduler.performWithDelayGlobal(function()
        p:resolve()
    end, time)
    return p
end
local function wrap_timeout_promise(p, time)
    return promise.any(p, get_timeout_promise(time))
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
        assert(#onPlayerDataChanged_callbacks <= 1, "重复请求过多了!")
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

function NetManager:addLoginEventListener()
    self:addEventListener("onPlayerLoginSuccess", function(success, msg)
        if success then
            if self.m_isDisconnect then
                ListenerService:start()
                self.m_netService:setDeltatime(msg.serverTime - ext.now())
                DataManager:setUserData(msg)
            else
                LuaUtils:outputTable("onPlayerLoginSuccess", msg)
                self.m_netService:setDeltatime(msg.serverTime - ext.now())
                local InitGame = import("app.service.InitGame")
                InitGame(msg)
                -- app:enterScene("AllianceScene")
                app:enterScene("CityScene")
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
    return p
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
    return p
end
function NetManager:getConnectLogicServerPromise()
    return get_connectLogicServer_promise():next(function(result)
        self:addDisconnectEventListener()
        self:addTimeoutEventListener()
        self:addKickEventListener()
        self:addPlayerDataChangedEventListener()
        self:addLoginEventListener()
        ListenerService:start()
    end)
end
-- 登录
function NetManager:getLoginPromise()
    return get_none_blocking_request_promise("logic.entryHandler.login", {
        -- deviceId = device.getOpenUDID()
        deviceId = "1"
    })
end
-- 事件回调promise
local function get_playerdata_callback()
    return get_callback_promise(onPlayerDataChanged_callbacks, "返回玩家数据失败!")
end
local function get_searchalliance_callback()
    return get_callback_promise(onSearchAlliancesSuccess_callbacks, "搜索联盟失败!")
end
local function get_directjoin_callback()
    return get_callback_promise(onGetCanDirectJoinAlliancesSuccess_callbacks, "搜索能直接加入的联盟失败!")
end
local function get_playerinfo_callback()
    return get_callback_promise(onGetPlayerInfoSuccess_callbacks, "查询玩家信息失败!")
end
local function get_alliancedata_callback()
    return get_callback_promise(onAllianceDataChanged_callbacks, "修改联盟信息失败!")
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
    }, "获取收件箱邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 阅读邮件
function NetManager:getReadMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.readMail", {
        mailId = mailId
    }, "阅读邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 收藏邮件
function NetManager:getSaveMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.saveMail", {
        mailId = mailId
    }, "收藏邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 取消收藏邮件
function NetManager:getUnSaveMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.unSaveMail", {
        mailId = mailId
    }, "取消收藏邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取收藏邮件
function NetManager:getFetchSavedMailsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getSavedMails", {
        fromIndex = fromIndex
    }, "获取收藏邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取已发送邮件
function NetManager:getFetchSendMailsPromise(fromIndex)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getSendMails", {
        fromIndex = fromIndex
    }, "获取已发送邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 删除邮件
function NetManager:getDeleteMailPromise(mailId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.deleteMail", {
        mailId = mailId
    }, "删除邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 发送联盟邮件
function NetManager:getSendAllianceMailPromise(title, content)
    return promise.all(get_blocking_request_promise("logic.playerHandler.sendAllianceMail", {
        title = title,
        content = content,
    }, "发送联盟邮件失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 请求加速
function NetManager:getRequestToSpeedUpPromise(eventType, eventId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.requestToSpeedUp", {
        eventType = eventType,
        eventId = eventId,
    }, "请求加速失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 协助玩家加速
function NetManager:getHelpAllianceMemberSpeedUpPromise(eventId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.helpAllianceMemberSpeedUp", {
        eventId = eventId,
    }, "协助玩家加速失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 协助所有玩家加速
function NetManager:getHelpAllAllianceMemberSpeedUpPromise()
    return promise.all(get_blocking_request_promise("logic.playerHandler.helpAllAllianceMemberSpeedUp", {}
        , "协助所有玩家加速失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 创建联盟
function NetManager:getCreateAlliancePromise(name, tag, language, terrain, flag)
    return promise.all(get_blocking_request_promise("logic.playerHandler.createAlliance", {
        name = name,
        tag = tag,
        language = language,
        terrain = terrain,
        flag = flag
    }, "创建联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 退出联盟
function NetManager:getQuitAlliancePromise()
    return promise.all(get_blocking_request_promise("logic.playerHandler.quitAlliance", nil
        , "退出联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 修改联盟加入条件
function NetManager:getEditAllianceJoinTypePromise(join_type)
    return promise.all(get_blocking_request_promise("logic.playerHandler.editAllianceJoinType", {
        joinType = join_type
    }, "修改联盟加入条件失败!"), get_alliancedata_callback()):next(get_response_msg)
end
-- 拒绝玩家
function NetManager:getRefuseJoinAllianceRequestPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = false
    }, "拒绝玩家失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 接受玩家
function NetManager:getAgreeJoinAllianceRequestPromise(memberId, cb)
    return promise.all(get_blocking_request_promise("logic.playerHandler.handleJoinAllianceRequest", {
        memberId = memberId,
        agree = true
    }, "接受玩家失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 搜索特定标签联盟
function NetManager:getSearchAllianceByTagPromsie(tag)
    return promise.all(get_blocking_request_promise("logic.playerHandler.searchAllianceByTag", {
        tag = tag
    }, "搜索特定标签联盟失败!"), get_searchalliance_callback()):next(get_response_msg)
end
-- 搜索能直接加入联盟
function NetManager:getFetchCanDirectJoinAlliancesPromise()
    return promise.all(get_blocking_request_promise("logic.playerHandler.getCanDirectJoinAlliances", nil
        , "搜索直接加入联盟失败!"), get_directjoin_callback()):next(get_response_msg)
end
-- 搜索能直接加入联盟
function NetManager:getInviteToJoinAlliancePromise(memberId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.inviteToJoinAlliance", {
        memberId = memberId
    }, "搜索直接加入联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 直接加入联盟
function NetManager:getJoinAllianceDirectlyPromise(allianceId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.joinAllianceDirectly", {
        allianceId = allianceId
    }, "直接加入联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 请求加入联盟
function NetManager:getRequestToJoinAlliancePromise(allianceId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.requestToJoinAlliance", {
        allianceId = allianceId
    }, "请求加入联盟失败!"), get_playerdata_callback()):next(get_response_msg)
end
-- 获取玩家信息
function NetManager:getPlayerInfoPromise(memberId)
    return promise.all(get_blocking_request_promise("logic.playerHandler.getPlayerInfo", {
        memberId = memberId
    }, "获取玩家信息失败!"), get_playerinfo_callback()):next(get_response_msg)
end
-- 发送聊天信息
function NetManager:sendMsg(text, cb)
    local msg = {
        text=text,
        type="global"
    }
    local from = DataManager:getUserData().name
    self.m_netService:request("chat.chatHandler.send", msg, function(success)
        cb(success)
    end)
end
-- function NetManager:sendPersonalMail(memberName,title,content,cb)
--     local info = {
--         memberName = memberName,
--         title = title,
--         content = content,
--     }
--     self.m_netService:request("logic.playerHandler.sendMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 获取收件箱邮件
-- function NetManager:getMails( fromIndex, cb)
--     local info = {
--         fromIndex = fromIndex
--     }
--     self.m_netService:request("logic.playerHandler.getMails", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 阅读邮件
-- function NetManager:readMail(mailId,cb)
--     local info = {
--         mailId = mailId,
--     }
--     self.m_netService:request("logic.playerHandler.readMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 收藏邮件
-- function NetManager:saveMail(mailId,cb)
--     local info = {
--         mailId = mailId,
--     }
--     self.m_netService:request("logic.playerHandler.saveMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 取消收藏邮件
-- function NetManager:unSaveMail(mailId,cb)
--     local info = {
--         mailId = mailId,
--     }
--     self.m_netService:request("logic.playerHandler.unSaveMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 获取收藏邮件
-- function NetManager:getSavedMails(fromIndex, cb )
--     local info = {
--         fromIndex = fromIndex
--     }
--     self.m_netService:request("logic.playerHandler.getSavedMails", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 获取已发送邮件
-- function NetManager:getSendMails(fromIndex, cb )
--     local info = {
--         fromIndex = fromIndex
--     }
--     self.m_netService:request("logic.playerHandler.getSendMails", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 删除邮件
-- function NetManager:deleteMail(mailId,cb)
--     local info = {
--         mailId = mailId,
--     }
--     self.m_netService:request("logic.playerHandler.deleteMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 发送联盟邮件
-- function NetManager:sendAllianceMail(title, content, cb)
--     local info = {
--         title = title,
--         content = content,
--     }
--     self.m_netService:request("logic.playerHandler.sendAllianceMail", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 请求加速
-- function NetManager:requestToSpeedUp(eventType,eventId,cb)
--     local info = {
--         eventType = eventType,
--         eventId = eventId,
--     }
--     self.m_netService:request("logic.playerHandler.requestToSpeedUp", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end

-- -- 协助玩家加速
-- function NetManager:helpAllianceMemberSpeedUp(eventId,cb)
--     local info = {
--         eventId = eventId,
--     }
--     self.m_netService:request("logic.playerHandler.helpAllianceMemberSpeedUp", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end

-- -- 协助所有玩家加速
-- function NetManager:helpAllAllianceMemberSpeedUp(cb)
--     local info = {
--         }
--     self.m_netService:request("logic.playerHandler.helpAllAllianceMemberSpeedUp", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end

-- -- 修改联盟加入条件
-- function NetManager:editAllianceJoinType(join_type, cb)
--     local info = {
--         joinType = join_type
--     }
--     self.m_netService:request("logic.playerHandler.editAllianceJoinType", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 拒绝玩家
-- function NetManager:refuseJoinAllianceRequest(memberId, cb)
--     local info = {
--         memberId = memberId,
--         agree = false
--     }
--     self.m_netService:request("logic.playerHandler.handleJoinAllianceRequest", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 接受玩家
-- function NetManager:agreeJoinAllianceRequest(memberId, cb)
--     local info = {
--         memberId = memberId,
--         agree = true
--     }
--     self.m_netService:request("logic.playerHandler.handleJoinAllianceRequest", info, function(success, msg)
--         if success and msg.code == SUCCESS_CODE then
--             cb(true)
--         else
--             cb(false)
--         end
--     end)
-- end
-- -- 搜索特定标签联盟
-- function NetManager:searchAllianceByTag( tag,cb )
--     if not LuaUtils:isString(tag) or string.len(tag) == 0  then
--         cb(false)
--         return false
--     end
--     local p1 = promise.new()
--     local p2 = promise.new()
--     promise.all(p1, p2):next(function(results)
--         cb(unpack(results))
--     end)
--     local data = {tag=tag}
--     self.m_netService:request("logic.playerHandler.searchAllianceByTag"
--         ,data
--         ,function(success, msg)
--             p1:resolve(success)
--         end)
--     table.insert(onSearchAlliancesSuccess_callbacks, function(success, msg)
--         p2:resolve(msg)
--     end)
-- end
-- 搜索能直接加入联盟
-- function NetManager:getCanDirectJoinAlliances(cb)
--     local p1 = promise.new()
--     local p2 = promise.new()
--     promise.all(p1, p2):next(function(results)
--         cb(unpack(results))
--     end)
--     self.m_netService:request("logic.playerHandler.getCanDirectJoinAlliances"
--         ,nil
--         ,function(success, msg)
--             p1:resolve(success)
--         end)
--     table.insert(onGetCanDirectJoinAlliancesSuccess_callbacks, function(success, msg)
--         p2:resolve(msg)
--     end)
-- end

-- -- 搜索能直接加入联盟
-- function NetManager:inviteToJoinAlliance(member_id, cb)
--     local p1 = promise.new()
--     local p2 = promise.new()
--     promise.all(p1, p2):next(function(results)
--         cb(unpack(results))
--     end)
--     self.m_netService:request("logic.playerHandler.inviteToJoinAlliance"
--         ,{memberId = member_id}
--         ,function(success, msg)
--             p1:resolve(success)
--         end)
--     table.insert(onPlayerDataChanged_callbacks, function(success, msg)
--         p2:resolve(msg)
--     end)
-- end


-- local function get_playerinfo_promise(member_id)
--     return get_blocking_request_promise("logic.playerHandler.getPlayerInfo", {memberId = member_id})
-- end
-- local function get_playerinfo_callback()
--     return get_callback_promise(onGetPlayerInfoSuccess_callbacks)
-- end
-- function NetManager:getPlayerInfoPromise(member_id)
--     return promise.all(get_playerinfo_promise(member_id), get_playerinfo_callback()):next(handle_request_and_respose)
-- end

--
function NetManager:resetGame()
    -- self:sendMsg("reset", NOT_HANDLE)
    self:sendMsg("gem 10000000", NOT_HANDLE)
end
function NetManager:sendMsg(text, cb)
    local msg = {
        text=text,
        type="global"
    }
    local from = DataManager:getUserData().name
    self.m_netService:request("chat.chatHandler.send", msg, function(success)
        cb(success)
    end)
end

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




























