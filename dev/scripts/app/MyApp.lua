
require("config")
require("framework.init")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.service.NetManager")
require("app.service.DataManager")
require("app.utils.UIKit")
require("app.utils.PlatformAdapter") -- adapter for platform ios/android
local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)
import('app.ui.GameGlobalUIUtils')
NOT_HANDLE = function(...) end
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
        print("currentLanFilePath---->",currentLanFilePath)
        _ = require("app.utils.Gettext").gettextFromFile(currentLanFilePath)
    end
end

return MyApp

