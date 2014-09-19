
require("config")
require("framework.init")
require("app.utils.PlatformAdapter")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.utils.DataUtils")
require("app.service.NetManager")
require("app.service.DataManager")
require("app.utils.UIKit")
require("app.ui.GameGlobalUIUtils")

local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)
import('app.ui.GameGlobalUIUtils')
NOT_HANDLE = function(...) print("net message not handel, please check !") end
function MyApp:ctor()
    self:initI18N()
    NetManager:init()
    MyApp.super.ctor(self)
    self.timer = Timer.new()
    local fileutils = cc.FileUtils:getInstance()
    if device.platform == "ios" then
        fileutils:addSearchPath("res/")
        fileutils:addSearchPath("res/audios/")
        fileutils:addSearchPath("res/images/")
        fileutils:addSearchPath("res/cocostudio/ui/")
        fileutils:addSearchPath("res/cocostudio/scenes/")
        fileutils:addSearchPath("res/cocostudio/scenes/kod/")
    elseif device.platform == "mac" then
        fileutils:addSearchPath("dev/res/")
        fileutils:addSearchPath("dev/res/audios/")
        fileutils:addSearchPath("dev/res/images/")
        fileutils:addSearchPath("dev/res/cocostudio/ui/")
        fileutils:addSearchPath("dev/res/cocostudio/scenes/")
        fileutils:addSearchPath("dev/res/cocostudio/scenes/kod/")
    end
end

function MyApp:run()
    self:enterScene('LogoScene')
end

function MyApp:restart()
    NetManager:disconnect()
    self.timer:Stop()
    ext.restart()
end

function MyApp:initI18N()
    local currentLanFile = string.format("i18n/%s.mo", GameUtils:getCurrentLanguage())
    local currentLanFilePath = cc.FileUtils:getInstance():fullPathForFilename(currentLanFile)

    function _(text)
        return text
    end
    if cc.FileUtils:getInstance():isFileExist(currentLanFilePath) then
        _ = require("app.utils.Gettext").gettextFromFile(currentLanFilePath)
    end
end

function MyApp:flushIf()
    if self.chatCenter then
        self.chatCenter:flush()
    end
end

function MyApp:retryConnectServer()
    if NetManager.m_logicServer.host and NetManager.m_logicServer.port then
        device.showActivityIndicator()
        NetManager:connectLogicServer(function(success)
            if success then
                NetManager:login(function(success)
                    device.hideActivityIndicator()
                end)
            else
                device.hideActivityIndicator()
            end

        end)
    end
end

function MyApp:onEnterBackground()
    MyApp.super.onEnterBackground(self)
    self:flushIf()
    NetManager:disconnect()
end

function MyApp:onEnterForeground()
    self:retryConnectServer()
    MyApp.super.onEnterForeground(self)
end

function MyApp:lockInput(b)
    cc.Director:getInstance():getEventDispatcher():setEnabled(b)
end

return MyApp

