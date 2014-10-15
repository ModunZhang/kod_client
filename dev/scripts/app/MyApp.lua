
require("config")
require("framework.init")
require("app.utils.PlatformAdapter")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.utils.DataUtils")
require("app.utils.UIKit")
require("app.utils.window")
require("app.ui.GameGlobalUIUtils")
require("app.service.NetManager")
require("app.service.DataManager")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)
import('app.ui.GameGlobalUIUtils')
NOT_HANDLE = function(...) print("net message not handel, please check !") end


local old_ctor = cc.ui.UIPushButton.ctor
function cc.ui.UIPushButton:ctor(...)
    old_ctor(self, ...)
    self:addButtonPressedEventListener(function(event)
        audio.playSound("ui_button_down.wav")
    end)
    self:addButtonReleaseEventListener(function(event)
        audio.playSound("ui_button_up.wav")
    end)
end



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
    audio.stopMusic()
    audio.stopAllSounds()
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
    LuaUtils:outputTable("onEnterBackground", {})
    self:flushIf()
    NetManager:disconnect()
end

function MyApp:onEnterForeground()
    LuaUtils:outputTable("onEnterForeground", {})
    self:retryConnectServer()
end
function MyApp:onEnterPause()
    LuaUtils:outputTable("onEnterPause", {})
end
function MyApp:onEnterResume()
    LuaUtils:outputTable("onEnterResume", {})
end

local lockInputCount = 0
function MyApp:lockInput(b)
    if b then
        lockInputCount = lockInputCount + 1
    else
        lockInputCount = lockInputCount - 1
    end
    if lockInputCount > 0 then
        cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    elseif lockInputCount == 0 then
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    end
end

return MyApp







