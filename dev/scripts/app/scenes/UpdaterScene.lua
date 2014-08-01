local UpdaterScene = class("UpdaterScene", function()
    return display.newScene("UpdaterScene")
end)

function UpdaterScene:ctor()
	self.m_currentLabel = nil
    self.m_localJson = nil
    self.m_serverJson = nil
    self.m_jsonFileName = "fileList.json"
    self.m_totalSize = 0
    self.m_currentSize = 0
end

function UpdaterScene:onEnter()
    self:createBgLayer()
    self:showVersion()
    self:loadLocalJson()
    self:loadServerJson()
end

function UpdaterScene:onExit()
end

function UpdaterScene:createBgLayer()
    display.newSprite("images/bg.png", display.cx, display.cy):addTo(self)
end

function UpdaterScene:showText(text)
    self:removeText()

    local label = ui.newTTFLabel({
        text = text,
        font = "fonts/Arial.ttf",
        size = 30,
        aligh = ui.TEXT_ALIGN_CENTER,
        valigh = ui.TEXT_VALIGN_CENTER,
        color = ccc3(255, 255, 255)
    })
    label:setPosition(display.cx, display.cy)
    label:addTo(self)

    self.m_currentLabel = label
end

function UpdaterScene:removeText()
    if self.m_currentLabel then
        self.m_currentLabel:removeSelf()
        self.m_currentLabel = nil
    end
end

function UpdaterScene:loadLocalJson()
    local jsonPath = CCFileUtils:sharedFileUtils():fullPathForFilename(self.m_jsonFileName)
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()
    self.m_localJson = jsonString
end

function UpdaterScene:loadServerJson()
    self:showText(_("检查游戏更新...."))

    NetManager:getUpdateFileList(function(success, msg)
        self:removeText()
        if not success then
            device.showAlert(nil, _("检查游戏更新失败!"), { _("确定") })
            return
        end

        self.m_serverJson = msg
        self:getUpdateFileList()
    end)
end

function UpdaterScene:getUpdateFileList()
    self.m_totalSize = 0
    self.m_currentSize = 0
    local localFileList = json.decode(self.m_localJson)
    local serverFileList = json.decode(self.m_serverJson)
    local localAppVersion = CONFIG_APP_VERSION
    local serverAppVersion = serverFileList.appVersion
    if localAppVersion < serverAppVersion then
        device.showAlert(nil, _("游戏版本过低,请更新!"), { _("确定") }, function(event)
            device.openURL("https://dl.dropboxusercontent.com/s/wsmk4zf0zjh2fs6/build-index.html")
        end)
        return
    end

    local updateFileList = {}
    for k, v in pairs(serverFileList.files) do
        local localFile = localFileList.files[k]
        if not localFile or localFile.tag ~= v.tag or localFile.crc32 ~= v.crc32 then
            v.path = k
            table.insert(updateFileList, v)
        end
    end
    if #updateFileList > 0 then
        LuaUtils:outputTable("updateFileList", updateFileList)
        for _, v in ipairs(updateFileList) do
            self.m_totalSize = self.m_totalSize + v.size
        end

        self:downloadFiles(updateFileList)
    else
        -- app:enterScene("MainScene")
    end
end

function UpdaterScene:downloadFiles(files)
    if #files > 0 then
        local file = files[1]
        table.remove(files, 1)

        local fileTotal = 0
        local fileCurrent = 0
        local percent = nil
        NetManager:downloadFile(file, function(success)
            if not success then
                self:removeText()
                device.showAlert(nil, _("文件下载失败!"), { _("确定") })
                return
            end
            self.m_currentSize = self.m_currentSize + fileTotal
            self:downloadFiles(files)
        end, function(total, current)
            fileTotal = total
            current = current
            local currentPercent = (self.m_currentSize + current) / self.m_totalSize * 100
            if (percent ~= currentPercent) then
                percent = currentPercent
                self:showText(string.format(_("下载进度:%d/%d"), percent, 100))
            end
        end)
    else
        self:saveServerJson()
        app:restart()
    end
end

function UpdaterScene:saveServerJson()
    local resPath = GameUtils:getUpdatePath() .. "res/"
    local filePath = resPath .. self.m_jsonFileName
    local file = io.open(filePath, "w")
    if not file then
        device.showAlert(nil, _("文件下载失败!"), { _("确定") })
        return
    end
    file:write(self.m_serverJson)
    file:close()
end

function UpdaterScene:showVersion()
    local jsonPath = CCFileUtils:sharedFileUtils():fullPathForFilename("fileList.json")
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()

    local tag = json.decode(jsonString).tag
    local version =string.format("Version:%s(%s)", CONFIG_APP_VERSION, tag)
    local label = ui.newTTFLabel({
        text = version,
        font = "fonts/Arial.ttf",
        size = 18,
        aligh = ui.TEXT_ALIGN_RIGHT,
        valigh = ui.TEXT_VALIGN_CENTER,
        color = ccc3(255, 255, 255)
    })

    label:setPosition(display.right - label:getContentSize().width / 2, display.bottom + label:getContentSize().height / 2)
    label:addTo(self)
end

return UpdaterScene