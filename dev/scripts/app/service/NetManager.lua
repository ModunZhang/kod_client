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

function NetManager:addPlayerDataChangedEventListener()
    self:addEventListener("onPlayerDataChanged", function(success, msg)
        if success then
            LuaUtils:outputTable("onPlayerDataChanged", msg)
            DataManager:setUserData(msg)
        end
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
        deviceId = device.getOpenUDID()
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




