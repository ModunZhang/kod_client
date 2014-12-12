
require("config")
require("framework.init")
require("app.Extend")
require("app.utils.PlatformAdapter")
require("app.utils.AudioManager")
require("app.datas.GameDatas")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
require("app.utils.DataUtils")
require("app.utils.UIKit")
require("app.utils.window")
require("app.service.NetManager")
require("app.service.DataManager")
import('app.ui.GameGlobalUIUtils')

local Timer = import('.utils.Timer')
local MyApp = class("MyApp", cc.mvc.AppBase)


function MyApp:ctor()
    self:initI18N()
    NetManager:init()
    MyApp.super.ctor(self)
    AudioManager:Init()
    self.timer = Timer.new()
    local fileutils = cc.FileUtils:getInstance()
    if device.platform == "ios" then
        
    elseif device.platform == "mac" then
        fileutils:addSearchPath("dev/res/")
        fileutils:addSearchPath("dev/res/fonts/")
        fileutils:addSearchPath("dev/res/images/")
        fileutils:addSearchPath("dev/res/fonts/")
    end
end

function MyApp:run()
    self:enterScene('LogoScene')
end

function MyApp:showDebugInfo( ... )
    local __debugVer = require("debug_version")
    local notifiy_Layer = display.newLayer()
    UIKit:ttfLabel({
        text = "Ver:" .. __debugVer .. "\nID:" .. DataManager:getUserData()._id,
        size = 15,
        -- color = 0xc600ff
    }):addTo(notifiy_Layer):align(display.RIGHT_TOP,display.right, display.top)
    cc.Director:getInstance():setNotificationNode(notifiy_Layer)
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












