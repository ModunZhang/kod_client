
require("config")
require("framework.init")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.service.NetManager")
require("app.service.DataManager")
require("app.datas.GameDatas")
import('.utils.UIKitHelper')

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    self:initI18N()
    NetManager:init()
    MyApp.super.ctor(self)
end

function MyApp:run()
    self:enterScene('LogoScene')
end

function MyApp:restart()
    NetManager:disconnect()
    audio.stopAllSounds()
    audio.stopMusic()
    ext.restart()
end

function MyApp:initI18N()
    local mapping = {
        "en_US",
        "zh_Hans",
        "fr",
        "it",
        "de",
        "es",
        "ru",
        "ko",
        "ja",
        "hu",
        "pt",
        "ar",
    }

    local currentLan = CCApplication:sharedApplication():getCurrentLanguage()
    local currentLanFile = string.format("i18n/%s.mo", mapping[currentLan + 1])
    local currentLanFilePath = CCFileUtils:sharedFileUtils():fullPathForFilename(currentLanFile)

    function _(text)
        return text
    end
    if CCFileUtils:sharedFileUtils():isFileExist(currentLanFilePath) then
        _ = require("app.utils.Gettext").gettextFromFile(currentLanFilePath)
    end
end

return MyApp
