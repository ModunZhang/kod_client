local promise = import("..utils.promise")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
NetManager = {}
local SUCCESS_CODE = 200
local FAILED_CODE = 500

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

function NetManager:connectGateServer(cb)
    self.m_netService:connect(self.m_gateServer.host, self.m_gateServer.port, function(success, msg)
        if success then
            self:addDisconnectEventListener()
            self:addTimeoutEventListener()
            self:addKickEventListener()
            cb(true)
        else
            cb(false)
        end
    end)
end

function NetManager:getLogicServerInfo(cb)
    self.m_netService:request("gate.gateHandler.queryEntry", nil, function(success, msg)
        self:removeTimeoutEventListener()
        self:removeDisConnectEventListener()
        self:removeKickEventListener()
        self.m_netService:disconnect()


        if success and msg.code == 200 then
            self.m_logicServer.host = msg.data.host
            self.m_logicServer.port = msg.data.port
            self.m_logicServer.id = msg.data.id

            cb(true)
        else
            cb(false)
        end
    end, false)
end

function NetManager:connectLogicServer(cb)
    self.m_netService:connect(self.m_logicServer.host, self.m_logicServer.port, function(success)
        if success then
            self:addDisconnectEventListener()
            self:addTimeoutEventListener()
            self:addKickEventListener()
            self:addPlayerDataChangedEventListener()
            self:addLoginEventListener()
            ListenerService:start()
            cb(true)
        else
            cb(false)
        end
    end, false)
end

function NetManager:login(cb)
    local loginInfo = {
        -- deviceId = device.getOpenUDID()
        deviceId = "1"
    }
    self.m_netService:request("logic.entryHandler.login", loginInfo, function(success, msg)
        if success and msg.code == 200 then
            cb(true, msg.data)
        else
            cb(false)
        end
    end, false)
end

-- 城建
function NetManager:createHouseByLocation(location, sub_location, building_type, cb)
    local build_info = {
        buildingLocation = location,
        houseType = building_type,
        houseLocation = sub_location,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.createHouse", build_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:destroyHouseByLocation(location, sub_location, cb)
    local build_info = {
        buildingLocation = location,
        houseLocation = sub_location
    }
    self.m_netService:request("logic.playerHandler.destroyHouse", build_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:upgradeHouseByLocation(location, sub_location, cb)
    local build_info = {
        buildingLocation = location,
        houseLocation = sub_location,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.upgradeHouse", build_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantUpgradeHouseByLocation(location, sub_location, cb)
    local build_info = {
        buildingLocation = location,
        houseLocation = sub_location,
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.upgradeHouse", build_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:speedupHouseBuildByLocation(location, sub_location, cb)
    local build_info = {
        buildingLocation = location,
        houseLocation = sub_location,
    }
    self.m_netService:request("logic.playerHandler.speedupHouseBuild", build_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantUpgradeBuildingByLocation(location, cb)
    local building_info = {
        location = location,
        finishNow = true,
    }
    self.m_netService:request("logic.playerHandler.upgradeBuilding", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:upgradeBuildingByLocation(location, cb)
    local building_info = {
        location = location,
        finishNow = false,
    }
    self.m_netService:request("logic.playerHandler.upgradeBuilding", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:speedUpBuildingByLocation(location, cb)
    local building_info = {
        location = location,
    }
    self.m_netService:request("logic.playerHandler.speedupBuildingBuild", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:upgradeTowerByLocation(location, cb)
    local building_info = {
        location = location,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.upgradeTower", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantUpgradeTowerByLocation(location, cb)
    local building_info = {
        location = location,
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.upgradeTower", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:upgradeWallByLocation(cb)
    local building_info = {
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.upgradeWall", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantUpgradeWallByLocation(cb)
    local building_info = {
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.upgradeWall", building_info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

--
function NetManager:impose(cb)
    self.m_netService:request("logic.playerHandler.impose", nil, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end


-- 建造材料
function NetManager:makeBuildingMaterial(cb)
    local info = {
        category = "building",
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.makeMaterial", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantMakeBuildingMaterial(cb)
    local info = {
        category = "building",
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.makeMaterial", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:getBuildingMaterials(cb)
    local info = {
        category = "building",
    }
    self.m_netService:request("logic.playerHandler.getMaterials", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:makeTechnologyMaterial(cb)
    local info = {
        category = "technology",
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.makeMaterial", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantMakeTechnologyMaterial(cb)
    local info = {
        category = "technology",
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.makeMaterial", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:getTechnologyMaterials(cb)
    local info = {
        category = "technology",
    }
    self.m_netService:request("logic.playerHandler.getMaterials", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 打造装备
function NetManager:makeDragonEquipment(equipment_name, cb)
    local info = {
        equipmentName = equipment_name,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.makeDragonEquipment", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantMakeDragonEquipment(equipment_name, cb)
    local info = {
        equipmentName = equipment_name,
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.makeDragonEquipment", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 招募士兵
function NetManager:recruitNormalSoldier(soldierName, count, cb)
    local info = {
        soldierName = soldierName,
        count = count,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.recruitNormalSoldier", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
function NetManager:instantRecruitNormalSoldier(soldierName, count, cb)
    local info = {
        soldierName = soldierName,
        count = count,
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.recruitNormalSoldier", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 普通治疗士兵
function NetManager:treatSoldiers(soldiers, cb)
    local info = {
        soldiers = soldiers,
        finishNow = false
    }
    self.m_netService:request("logic.playerHandler.treatSoldier", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 立即治疗士兵
function NetManager:instantTreatSoldiers(soldiers, cb)
    local info = {
        soldiers = soldiers,
        finishNow = true
    }
    self.m_netService:request("logic.playerHandler.treatSoldier", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 发送个人邮件
function NetManager:sendPersonalMail(memberName,title,content,cb)
    local info = {
        memberName = memberName,
        title = title,
        content = content,
    }
    self.m_netService:request("logic.playerHandler.sendMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 获取收件箱邮件
function NetManager:getMails( fromIndex, cb)
    local info = {
        fromIndex = fromIndex
    }
    self.m_netService:request("logic.playerHandler.getMails", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 阅读邮件
function NetManager:readMail(mailId,cb)
    local info = {
        mailId = mailId,
    }
    self.m_netService:request("logic.playerHandler.readMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 收藏邮件
function NetManager:saveMail(mailId,cb)
    local info = {
        mailId = mailId,
    }
    self.m_netService:request("logic.playerHandler.saveMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 取消收藏邮件
function NetManager:unSaveMail(mailId,cb)
    local info = {
        mailId = mailId,
    }
    self.m_netService:request("logic.playerHandler.unSaveMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 获取收藏邮件
function NetManager:getSavedMails(fromIndex, cb )
    local info = {
        fromIndex = fromIndex
    }
    self.m_netService:request("logic.playerHandler.getSavedMails", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 获取已发送邮件
function NetManager:getSendMails(fromIndex, cb )
    local info = {
        fromIndex = fromIndex
    }
    self.m_netService:request("logic.playerHandler.getSendMails", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 删除邮件
function NetManager:deleteMail(mailId,cb)
    local info = {
        mailId = mailId,
    }
    self.m_netService:request("logic.playerHandler.deleteMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 发送联盟邮件
function NetManager:sendAllianceMail(title, content, cb)
    local info = {
        title = title,
        content = content,
    }
    self.m_netService:request("logic.playerHandler.sendAllianceMail", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 请求加速
function NetManager:requestToSpeedUp(eventType,eventId,cb)
    local info = {
        eventType = eventType,
        eventId = eventId,
    }
    self.m_netService:request("logic.playerHandler.requestToSpeedUp", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 协助玩家加速
function NetManager:helpAllianceMemberSpeedUp(eventId,cb)
    local info = {
        eventId = eventId,
    }
    self.m_netService:request("logic.playerHandler.helpAllianceMemberSpeedUp", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 协助所有玩家加速
function NetManager:helpAllAllianceMemberSpeedUp(cb)
    local info = {
        }
    self.m_netService:request("logic.playerHandler.helpAllAllianceMemberSpeedUp", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end

-- 修改联盟加入条件
function NetManager:editAllianceJoinType(join_type, cb)
    local info = {
        joinType = join_type
    }
    self.m_netService:request("logic.playerHandler.editAllianceJoinType", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 拒绝玩家
function NetManager:refuseJoinAllianceRequest(memberId, cb)
    local info = {
        memberId = memberId,
        agree = false
    }
    self.m_netService:request("logic.playerHandler.handleJoinAllianceRequest", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 接受玩家
function NetManager:agreeJoinAllianceRequest(memberId, cb)
    local info = {
        memberId = memberId,
        agree = true
    }
    self.m_netService:request("logic.playerHandler.handleJoinAllianceRequest", info, function(success, msg)
        if success and msg.code == SUCCESS_CODE then
            cb(true)
        else
            cb(false)
        end
    end)
end
-- 搜索特定标签联盟
function NetManager:searchAllianceByTag( tag,cb )
    if not LuaUtils:isString(tag) or string.len(tag) == 0  then
        cb(false)
        return false
    end
    local p1 = promise.new()
    local p2 = promise.new()
    promise.all(p1, p2):next(function(results)
        cb(unpack(results))
    end)
    local data = {tag=tag}
    self.m_netService:request("logic.playerHandler.searchAllianceByTag"
        ,data
        ,function(success, msg)
            p1:resolve(success)
        end)
    table.insert(onSearchAlliancesSuccess_callbacks, function(success, msg)
        p2:resolve(msg)
    end)
end
-- 搜索能直接加入联盟
function NetManager:getCanDirectJoinAlliances(cb)
    local p1 = promise.new()
    local p2 = promise.new()
    promise.all(p1, p2):next(function(results)
        cb(unpack(results))
    end)
    self.m_netService:request("logic.playerHandler.getCanDirectJoinAlliances"
        ,nil
        ,function(success, msg)
            p1:resolve(success)
        end)
    table.insert(onGetCanDirectJoinAlliancesSuccess_callbacks, function(success, msg)
        p2:resolve(msg)
    end)
end

-- 搜索能直接加入联盟
function NetManager:inviteToJoinAlliance(member_id, cb)
    local p1 = promise.new()
    local p2 = promise.new()
    promise.all(p1, p2):next(function(results)
        cb(unpack(results))
    end)
    self.m_netService:request("logic.playerHandler.inviteToJoinAlliance"
        ,{memberId = member_id}
        ,function(success, msg)
            p1:resolve(success)
        end)
    table.insert(onPlayerDataChanged_callbacks, function(success, msg)
        p2:resolve(msg)
    end)
end



-- 获取玩家信息,返回promise对象
local function get_request_promise(request_route, data)
    local p = promise.new()
    NetManager.m_netService:request(request_route, data, function(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
local function get_callback_promise(callbacks)
    local p = promise.new()
    table.insert(callbacks, function(success, msg)
        p:resolve({success = success, msg = msg})
    end)
    return p
end
local function get_playerinfo_promise(member_id)
    return get_request_promise("logic.playerHandler.getPlayerInfo", {memberId = member_id})
end
local function get_playerinfo_callback()
    return get_callback_promise(onGetPlayerInfoSuccess_callbacks)
end
local function wrap_time_out_with(p, time)
    local time = time or 5
    local time_out = false
    local t = promise.new(function()
        time_out = true
    end)
    scheduler.performWithDelayGlobal(function()
        t:resolve()
    end, time)
    return promise.any(p, t):next(function(result)
        if time_out then
            promise.reject("timeout", time)
        end
        return result
    end)
end
function NetManager:getPlayerInfoPromise(member_id)
    return wrap_time_out_with(promise.all(get_playerinfo_promise(member_id), get_playerinfo_callback())):next(function(results)
        local request = results[1]
        local response = results[2]
        if not request.success then
            promise.reject("请求失败!", request.msg)
        end
        if not response.success then
            promise.reject("响应失败!", response.msg)
        end
        return response.msg
    end)
end

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








