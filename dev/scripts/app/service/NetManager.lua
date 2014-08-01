NetManager = {}

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

function NetManager:disconnect()
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
    self:addEventListener("disconnect", function(success, msg)
        device.showAlert(nil, _("和服务器的连接已断开!"), {_("确定")}, function(event)
            app:enterScene("MainScene")
        end)
    end)
end

function NetManager:removeDisConnectEventListener(  )
    self:removeEventListener("disconnect")
end

function NetManager:addKickEventListener()
    self:addEventListener("onKick", function(success, msg)
        device.showAlert(nil, _("和服务器的连接已断开!"), {_("确定")}, function(event)
            app:enterScene("MainScene")
        end)
    end)
end

function NetManager:removeKickEventListener(  )
    self:removeEventListener("onKick")
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

        if success and msg.code == Response.OK then
            self.m_logicServer.host = msg.data.host
            self.m_logicServer.port = msg.data.port
            self.m_logicServer.id = msg.data.id

            self.m_netService:setDeltatime(msg.time - ext.now())

            cb(true)
        else
            cb(false)
        end
    end)
end

function NetManager:connectLogicServer(cb)
    self.m_netService:connect(self.m_logicServer.host, self.m_logicServer.port, function(success)
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
    end)
end

function NetManager:sendChat(chat, cb)
    local from = DataManager:getUserData().name
    self.m_netService:notify("chat.chatHandler.sendChat", {
        from = from,
        text = chat,
    }, function(success)
        cb(success)
    end)
end

function NetManager:getAllChat(cb)
    self.m_netService:request("chat.chatHandler.getAllChat", nil, function(success, msg)
        cb(successm, msg)
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

    if CCFileUtils:sharedFileUtils():isFileExist(filePath) then
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