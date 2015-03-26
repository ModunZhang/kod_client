
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

local Store = import(".utils.Store")
local GameDefautlt = import("app.utils.GameDefautlt")
local AudioManager = import("app.utils.AudioManager")
local LocalPushManager = import("app.utils.LocalPushManager")
local ChatManager = import("app.entity.ChatManager")
local Timer = import('.utils.Timer')
local User_ = import('.entity.User')
local MyApp = class("MyApp", cc.mvc.AppBase)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local function transition_(scene, status)
    if status == "onEnter" then
        local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
        cc.LayerColor:create(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
            transition.sequence{
                cc.CallFunc:create(function() 
                    armature:getAnimation():stop()
                    armature:getAnimation():play("Animation1", -1, 0) 
                end),
                cc.FadeIn:create(0.75),
                cc.CallFunc:create(function() 
                    if scene.hideOutEnterShow then
                        scene:hideOutEnterShow()
                    else
                        scene:hideOutShowIn()
                    end
                end),
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function() 
                    armature:getAnimation():stop()
                    armature:getAnimation():play("Animation4", -1, 0) 
                end),
                cc.FadeOut:create(0.75),
                cc.CallFunc:create(function() scene:finish() end),
            }
        )
    elseif status == "onExit" then
    end
end

function MyApp:ctor()
    MyApp.super.ctor(self)
    self:InitGameBase()
    self:InitI18N()
    NetManager:init()
    self.timer = Timer.new()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
end

function MyApp:run()
    self:enterScene('LogoScene')
end

function MyApp:showDebugInfo()
    local __debugVer = require("debug_version")
    return "Client Ver:" .. __debugVer .. "\nPlayerID:" .. DataManager:getUserData()._id .. "\nDeviceID:" .. DataManager:getUserData().countInfo.deviceId
end

function MyApp:restart(needDisconnect)
    if needDisconnect == true or type(needDisconnect) == 'nil' then
        NetManager:disconnect()
    end
    --关闭所有状态
    self.timer:Stop()
    self:GetAudioManager():StopAll()
    self:GetChatManager():Reset()
    device.hideActivityIndicator()
    if device.platform == 'mac' then
        PlayerProtocol:getInstance():relaunch()
    else
        ext.restart()
    end
end

function MyApp:InitI18N()
    local currentLanFile = string.format("i18n/%s.mo", self:GetGameLanguage())
    local currentLanFilePath = cc.FileUtils:getInstance():fullPathForFilename(currentLanFile)
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
    self.ChatManager_  = ChatManager.new(self:GetGameDefautlt())
end

function MyApp:GetChatManager()
    return self.ChatManager_
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
    if self:GetGameDefautlt() then
        self:GetGameDefautlt():flush()
    end
end

function MyApp:retryConnectServer()
    if NetManager.m_logicServer.host and NetManager.m_logicServer.port then
        UIKit:WaitForNet()
        scheduler.performWithDelayGlobal(function()
            NetManager:getConnectLogicServerPromise():next(function()
                return NetManager:getLoginPromise()
            end):catch(function(err)
                UIKit:showMessageDialog(_("错误"), _("服务器连接断开,请检测你的网络环境后重试!"), function()
                    app:retryConnectServer()
                end,nil,false)
            end):always(function()
                UIKit:NoWaitForNet()
            end)      
        end,1)
       
    end
end

function MyApp:onEnterBackground()
    LuaUtils:outputTable("onEnterBackground", {})
    NetManager:disconnect()
    self:flushIf()
end

function MyApp:onEnterForeground()
    UIKit:closeAllUI()
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
function MyApp:EnterFriendCityScene(id)
    self:EnterCitySceneByPlayerAndAlliance(id, true)
end
function MyApp:EnterPlayerCityScene(id)
    self:EnterCitySceneByPlayerAndAlliance(id, false)
end
function MyApp:EnterCitySceneByPlayerAndAlliance(id, is_my_alliance)
    NetManager:getPlayerCityInfoPromise(id):next(function(user_data)
        local user = User_.new(user_data):OnUserDataChanged(user_data)
        local city = City.new(user_data):SetUser(user):OnUserDataChanged(user_data)
        if is_my_alliance then
            app:enterScene("FriendCityScene", {user, city}, "custom", -1, transition_)
        else
            app:enterScene("OtherCityScene", {user, city}, "custom", -1, transition_)
        end
    end)
end
function MyApp:EnterMyCityScene()
    app:enterScene("MyCityScene", {City}, "custom", -1, transition_)
end
function MyApp:EnterMyAllianceSceneWithTips(tips)
    UIKit:showMessageDialog(nil,tips,function()
        self:EnterMyAllianceScene()
    end):VisibleXButton(false)
end
function MyApp:EnterMyAllianceScene()
    if Alliance_Manager:GetMyAlliance():IsDefault() then
        UIKit:showMessageDialog(_("提示"),_("未加入联盟!"),function()end)
        return
    end

    local alliance_name = "AllianceScene"
    local my_status = Alliance_Manager:GetMyAlliance():Status()
    if my_status == "prepare" or  my_status == "fight" then
        alliance_name = "AllianceBattleScene"
    end
    app:enterScene(alliance_name, nil, "custom", -1, transition_)
end
function MyApp:EnterPVEScene(level)
    User:GotoPVEMapByLevel(level)
    app:enterScene("PVEScene", {User}, "custom", -1, transition_)
end

function MyApp:pushScene(sceneName, args, transitionType, time, more)
    local scenePackageName = "app.scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.pushScene(scene, transitionType, time, more)
end

function MyApp:getSupportMailFormat(category)
    
    local UTCTime    = "UTC Time:" .. os.date('!%Y-%m-%d %H:%M:%S', self.timer:GetServerTime())
    local GameName   = "Game:" .. "Kod"
    local Version    = "Version:" .. CONFIG_APP_VERSION
    local Username   = "User ID:" .. DataManager:getUserData()._id
    local Server     = "Server:" .. "World"
    local OpenUDID   = "Open UDID:" .. device.getOpenUDID()
    local Category   = "Category:" .. category or ""
    local Language   = "Language:" .. self:GetGameLanguage()
    local DeviceType = "Device Type:" ..ext.getDeviceModel()
    local OSVersion  = "OS Version:" .. ext.getOSVersion()

    local format_str = "\n\n\n\n\n---------------%s---------------\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"
    local result_str = string.format(format_str,_("不要删除"),UTCTime,GameName,Version,Username,Server,OpenUDID,Category,Language,DeviceType,OSVersion)
    return "[KoD]" .. category ,result_str
end

function MyApp:EnterViewModelAllianceScene(alliance_id)
    NetManager:getFtechAllianceViewDataPromose(alliance_id):next(function(msg)
        local alliance = Alliance_Manager:DecodeAllianceFromJson(msg)
        app:enterScene("OtherAllianceScene", {alliance}, "custom", -1,transition_)
    end)
end
-- Store
------------------------------------------------------------------------------------------------------------------
function MyApp:getStore()
    if not cc.storeProvider then
        Store.init(handler(self, self.transactionObserver))
    end
    return Store
end

function MyApp:transactionObserver(event)
    local transaction = event.transaction
    local transaction_state = transaction.state
    if transaction_state == 'restored' then
        device.showAlert("提示","已为你恢复以前的购买",{_("确定")})
        Store.finishTransaction(transaction)
        device.hideActivityIndicator()
    elseif transaction_state == 'purchased' then
        local rewards_msg,info = DataUtils:getIapRewardMessage(transaction.productIdentifier)
        ext.market_sdk.onPlayerChargeRequst(transaction.transactionIdentifier,transaction.productIdentifier,info.price,info.gem,"USD")
        NetManager:getVerifyIAPPromise(transaction.transactionIdentifier,transaction.receipt):next(function(response)
            device.hideActivityIndicator()
            local msg = response.msg
            if msg.transactionId then
                GameGlobalUI:showTips(_("提示"),rewards_msg)
                Store.finishTransaction(transaction)
                ext.market_sdk.onPlayerChargeSuccess(transaction.transactionIdentifier)
            end
        end):catch(function(err)
            device.hideActivityIndicator()
            local msg,code_type = err:reason()
            local code = msg.code
            if code_type ~= "syntaxError" then
                if code == 612 or code == 613 or code == 614 then
                    Store.finishTransaction(transaction)
                end
            end
        end)
    elseif transaction_state == 'purchasing' then
        --不作任何处理
        device.hideActivityIndicator()
    else
        device.showAlert(_("提示"),transaction.errorString,{_("确定")})
        Store.finishTransaction(transaction)
        device.hideActivityIndicator()
    end
end
return MyApp


