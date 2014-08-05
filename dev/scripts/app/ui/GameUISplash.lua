--
-- Author: dannyhe
-- Date: 2014-08-05 17:29:19
--
local UIKitHelper = UIKitHelper
local GameUISplash = UIKitHelper:inheritUIBase('GameUISplash')

function GameUISplash:ctor()
	if not self.super.ctor(self,{ui = 'images/GameUISplash.json'}) then
		printError('Init GameUISplash Failed!')
	end
	-- data
	self.m_localJson = nil
    self.m_serverJson = nil
    self.m_jsonFileName = "fileList.json"
    self.m_totalSize = 0
    self.m_currentSize = 0

end

function GameUISplash:onEnter()
	self.super.onEnter(self)
	-- ui
	self.progressBar = self:seekWidgetByName('ProgressBar_Loading')
	self.progressLabel = self:seekWidgetByName('Label_Process')
	self.tipsLabel = self:seekWidgetByName('Label_Tips')
	self.verLabel = self:seekWidgetByName('Label_Version')
	self.progressBar:setPercent(0)
	self.progressLabel:setText('')

	self:showVersion()
	self:loadLocalJson()
	self:loadServerJson()

end

-- Private Methods

function GameUISplash:setProgressText(str)
	self.progressLabel:setText('')
end
function GameUISplash:setProgressPercent(num)
	self.progressBar:setPercent(num)
end

-- Auto Update

function GameUISplash:showVersion()
    local jsonPath = CCFileUtils:sharedFileUtils():fullPathForFilename("fileList.json")
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()

    local tag = json.decode(jsonString).tag
    local version =string.format("Version:%s(%s)", CONFIG_APP_VERSION, tag)
  	self.verLabel:setText(version)
end

function GameUISplash:loadLocalJson()
    local jsonPath = CCFileUtils:sharedFileUtils():fullPathForFilename(self.m_jsonFileName)
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()
    self.m_localJson = jsonString
end

function GameUISplash:loadServerJson()
    self:setProgressText(_("检查游戏更新...."))

    NetManager:getUpdateFileList(function(success, msg)
        if not success then
            device.showAlert(nil, _("检查游戏更新失败!"), { _("确定") })
            return
        end

        self.m_serverJson = msg
        self:getUpdateFileList()
    end)
end

function GameUISplash:getUpdateFileList()
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
    	print('进入游戏！！！')
        self:performWithDelay(function (  )
			app:enterScene('MainScene')
		end, 0)
		-- app:enterScene('MainScene')
    end
end

function GameUISplash:downloadFiles(files)
    if #files > 0 then
        local file = files[1]
        table.remove(files, 1)

        local fileTotal = 0
        local fileCurrent = 0
        local percent = nil
        NetManager:downloadFile(file, function(success)
            if not success then
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
                self:setProgressPercent(percent)
                self:setProgressText(string.format(_("下载进度:%d/%d"), percent, 100))
            end
        end)
    else
        self:saveServerJson()
        app:restart()
    end
end

function GameUISplash:saveServerJson()
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

return GameUISplash