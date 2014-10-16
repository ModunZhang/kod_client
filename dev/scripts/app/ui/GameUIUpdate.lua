--
-- Author: Danny He
-- Date: 2014-09-18 20:25:09
--
local GameUIUpdate = UIKit:createUIClass("GameUIUpdate","GameUILogin")

function GameUIUpdate:ctor()
	GameUIUpdate.super.ctor(self)
	-- data
	self.m_localJson = nil
    self.m_serverJson = nil
    self.m_jsonFileName = "fileList.json"
    self.m_totalSize = 0
    self.m_currentSize = 0
end


function GameUIUpdate:onEnter()
	GameUIUpdate.super.onEnter(self)
	self:createVerLabel()
end


function GameUIUpdate:createVerLabel()
	self.verLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "版本:1.0.0(ddf3d)",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        -- dimensions = cc.size(569, 43),
        color = UIKit:hex2c3b(0xaaa87f),
    }):addTo(self,2)
    :align(display.RIGHT_BOTTOM,display.right-2,display.bottom)
end

-- 复写UILogin方法
function GameUIUpdate:onMovieInStage()
	self:showVersion()
	self:loadLocalJson()
	self:loadServerJson()
end
-- auto update



-- Auto Update

function GameUIUpdate:showVersion()
	local jsonPath = cc.FileUtils:getInstance():fullPathForFilename("fileList.json")
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()

    local tag = json.decode(jsonString).tag
    local version =string.format(_("版本:%s(%s)"), CONFIG_APP_VERSION, tag)
  	self.verLabel:setString(version)
end

function GameUIUpdate:loadLocalJson()
    local jsonPath = cc.FileUtils:getInstance():fullPathForFilename(self.m_jsonFileName)
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()
    self.m_localJson = jsonString
end

function GameUIUpdate:loadServerJson()
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

function GameUIUpdate:getUpdateFileList()
    self.m_totalSize = 0
    self.m_currentSize = 0
    local localFileList = json.decode(self.m_localJson)
    local serverFileList = json.decode(self.m_serverJson)
    local localAppVersion = CONFIG_APP_VERSION
    local serverAppVersion = serverFileList.appVersion
    if localAppVersion < serverAppVersion then
        device.showAlert(nil, _("游戏版本过低,请更新!"), { _("确定") }, function(event)
            device.openURL("https://dl.dropboxusercontent.com/s/n1b75nkamnjh9qx/build-index.html")
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
    	self:setProgressPercent(100)
        self:performWithDelay(function()
            app:enterScene('MainScene')
        end, 1)
    end
end

function GameUIUpdate:downloadFiles(files)
    if #files > 0 then
        local file = files[1]
        table.remove(files, 1)

        local fileTotal = 0
        local fileCurrent = 0
        local percent = nil
        NetManager:downloadFile(file, function(success)
            if not success then
                device.showAlert(nil, _("文件下载失败!"), { _("确定") },function()
                    app:restart()
                end)
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
                self:setProgressText(string.format(_("更新进度:%d%%"), percent))
            end
        end)
    else
        self:saveServerJson()
        app:restart()
    end
end

function GameUIUpdate:saveServerJson()
    local resPath = GameUtils:getUpdatePath() .. "res/"
    local filePath = resPath .. self.m_jsonFileName
    local file = io.open(filePath, "w")
    if not file then
        device.showAlert(nil, _("文件下载失败!"), { _("确定")},function()
            app:restart()
        end)
        return
    end
    file:write(self.m_serverJson)
    file:close()
end
return GameUIUpdate