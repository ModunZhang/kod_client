
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

local GameDefautlt = import("app.utils.GameDefautlt")
local AudioManager = import("app.utils.AudioManager")
local LocalPushManager = import("app.utils.LocalPushManager")
local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self:InitGameBase()
    self:InitI18N()
    NetManager:init()
    self.timer = Timer.new()
end

function MyApp:run()
    self:enterScene('LogoScene')
end

function MyApp:showDebugInfo()
    local __debugVer = require("debug_version")
    return "Client Ver:" .. __debugVer .. "\nPlayerID:" .. DataManager:getUserData()._id .. "\nDeviceID:" .. DataManager:getUserData().countInfo.deviceId
end

function MyApp:restart()
    self:GetAudioManager():StopMusic()
    self:GetAudioManager():StopEffectSound()
    NetManager:disconnect()
    self.timer:Stop()
    if device.platform == 'mac' then
        PlayerProtocol:getInstance():relaunch()
    else    
        ext.restart()
    end
end

function MyApp:InitI18N()
    local currentLanFile = string.format("i18n/%s.mo", self:GetGameLanguage())
    local currentLanFilePath = cc.FileUtils:getInstance():fullPathForFilename(currentLanFile)

    function _(text)
        return text
    end
    if cc.FileUtils:getInstance():isFileExist(currentLanFilePath) then
        _ = require("app.utils.Gettext").gettextFromFile(currentLanFilePath)
    end
end

function MyApp:GetGameLanguage()
    return self.gameLanguage_
end

function MyApp:SetGameLanguage(lang)
    self:GetGameDefautlt():setBasicInfoValueForKey("GAME_LANGUAGE",lang)
    self:GetGameDefautlt():flush()
    self:restart()
end

function MyApp:InitGameBase()
    self.GameDefautlt_ = GameDefautlt.new()
    self.AudioManager_ = AudioManager.new(self:GetGameDefautlt())
    self.LocalPushManager_ = LocalPushManager.new(self:GetGameDefautlt())
    self.gameLanguage_ = self:GetGameDefautlt():getBasicInfoValueForKey("GAME_LANGUAGE",GameUtils:getCurrentLanguage())
end

function MyApp:GetAudioManager()
    return self.AudioManager_
end

function MyApp:GetPushManager()
    return self.LocalPushManager_
end

function MyApp:GetGameDefautlt()
    return self.GameDefautlt_
end
function MyApp:flushIf()
    if self.chatCenter then
        self.chatCenter:flush()
    end
end

function MyApp:retryConnectServer()
    if NetManager.m_logicServer.host and NetManager.m_logicServer.port then
        -- device.showActivityIndicator()
        NetManager:getConnectLogicServerPromise():next(function()
            return NetManager:getLoginPromise()
        end):catch(function(err)
            dump(err:reason())
        end):always(function()
            -- device.hideActivityIndicator()
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
function MyApp:EnterPlayerCityScene(id)
    NetManager:getPlayerCityInfoPromise(id):next(function(city_info)
        app:enterScene("OtherCityScene", {User.new(city_info.basicInfo), City.new(city_info)}, "custom", -1, function(scene, status)
            local manager = ccs.ArmatureDataManager:getInstance()
            if status == "onEnter" then
                manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
                local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
                display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
                    transition.sequence{
                        cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
                        cc.FadeIn:create(0.75),
                        cc.CallFunc:create(function() scene:hideOutShowIn() end),
                        cc.DelayTime:create(0.5),
                        cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
                        cc.FadeOut:create(0.75),
                        cc.CallFunc:create(function() scene:finish() end),
                    }
                )
            elseif status == "onExit" then
                manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            end
        end)
    end)
end


function MyApp:EnterMyCityScene()
   app:enterScene("MyCityScene", {City}, "custom", -1, function(scene, status)
        local manager = ccs.ArmatureDataManager:getInstance()
        if status == "onEnter" then
            manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
            display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
                transition.sequence{
                    cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
                    cc.FadeIn:create(0.75),
                    cc.CallFunc:create(function() scene:hideOutShowIn() end),
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
                    cc.FadeOut:create(0.75),
                    cc.CallFunc:create(function() scene:finish() end),
                }
            )
        elseif status == "onExit" then
            manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
        end
    end)
end
return MyApp