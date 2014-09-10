
require("config")
require("framework.init")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.service.NetManager")
require("app.utils.UIKit")
require("app.utils.PlatformAdapter") -- adapter for platform ios/android
local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)
import('app.ui.GameGlobalUIUtils')
function MyApp:ctor()
    self:initI18N()
    NetManager:init()
    MyApp.super.ctor(self)
    self.timer = Timer.new()
    local fileutils = cc.FileUtils:getInstance()
    if device.platform == "ios" then
        fileutils:addSearchPath("res/images/")
    elseif device.platform == "mac" then
        fileutils:addSearchPath("dev/res/")
    end
end

function MyApp:enterScene(...)
    self._runningScene = MyApp.super.enterScene(self,...)
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

return MyApp

