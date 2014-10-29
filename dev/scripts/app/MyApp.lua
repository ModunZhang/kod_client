
require("config")
require("framework.init")
require("app.Extend")
require("app.utils.PlatformAdapter")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.utils.DataUtils")
require("app.utils.UIKit")
require("app.utils.window")
require("app.service.NetManager")
require("app.service.DataManager")
import('app.ui.GameGlobalUIUtils')
import('app.service.ListenerService')
import('app.service.PushService')

local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)


function MyApp:ctor()
    self:initI18N()
    NetManager:init()
    MyApp.super.ctor(self)
    self.timer = Timer.new()
    local fileutils = cc.FileUtils:getInstance()
    if device.platform == "ios" then
        -- fileutils:addSearchPath("res/")
        -- fileutils:addSearchPath("res/images/")
    elseif device.platform == "mac" then
        fileutils:addSearchPath("dev/res/")
        fileutils:addSearchPath("dev/res/images/")
        fileutils:addSearchPath("dev/res/fonts/")
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
        NetManager:getConnectLogicServerPromise():next(function()
            NetManager:getLoginPromise():catch(function(err)
                dump(err:reason())
            end)
        end):catch(function(err)
            dump(err:reason())
        end):always(function()
            device.hideActivityIndicator()
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












