
--初始本地化文件
function __init_localize_file__()
    local default_language = cc.UserDefault:getInstance():getStringForKey("GAME_LANGUAGE")
    local init_language = default_language
    if default_language and string.len(default_language) > 0 then
        init_language = default_language
    else
        init_language = GameUtils:GetAppleLanguageCode()
    end
    local poName,real_language_code = GameUtils:GetPoFileLanguageCode(init_language)
    local currentLanFile = string.format("i18n/%s.mo", poName)
    local currentLanFilePath = cc.FileUtils:getInstance():fullPathForFilename(currentLanFile)
    printLog("I18N","i18n file name:%s",currentLanFilePath)
    if cc.FileUtils:getInstance():isFileExist(currentLanFilePath) then
        _ = require("app.utils.Gettext").gettextFromFile(currentLanFilePath)
        cc.UserDefault:getInstance():setStringForKey("GAME_LANGUAGE", real_language_code)
    end
end

require("config")
require("framework.init")
require("app.Extend")
require("app.utils.PlatformAdapter")
require("app.utils.LuaUtils")
require("app.utils.GameUtils")
__init_localize_file__()
require("app.datas.GameDatas")
require("app.utils.DataUtils")
require("app.utils.UtilsForEvent")
require("app.utils.UtilsForTask")
require("app.utils.UtilsForItem")
require("app.utils.UtilsForTech")
require("app.utils.UtilsForSoldier")
require("app.utils.UtilsForBuilding")
require("app.utils.UtilsForShrine")
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
local AllianceManager_ = import(".entity.AllianceManager")
Alliance_Manager = AllianceManager_.new()
CLOUD_TAG = 1987
local speed = 2
-- local function transition_(scene, status)
--     if status == "onEnter" then
--         local armature = ccs.Armature:create("Cloud_Animation")
--             :addTo(scene,0,CLOUD_TAG):pos(display.cx, display.cy)

--         cc.LayerColor:create(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
--             transition.sequence{
--                 cc.CallFunc:create(function()
--                     armature:getAnimation():stop()
--                     armature:getAnimation():play("Animation1", -1, 0)
--                     armature:getAnimation():setSpeedScale(speed)
--                 end),
--                 cc.FadeIn:create(0.75/speed),
--                 cc.DelayTime:create(0.5/speed),
--                 cc.CallFunc:create(function()
--                     armature:getAnimation():stop()
--                     armature:getAnimation():play("Animation4", -1, 0)
--                     armature:getAnimation():setSpeedScale(speed)
--                 end),
--                 cc.CallFunc:create(function()
--                     if scene.hideOutEnterShow then
--                         scene:hideOutEnterShow()
--                     else
--                         scene:hideOutShowIn()
--                     end
--                 end),
--                 cc.FadeOut:create(0.75/speed),
--                 cc.CallFunc:create(function()
--                     scene:removeChildByTag(CLOUD_TAG)
--                     scene:finish()
--                 end),
--             }
--         )
--     elseif status == "onExit" then
--         scene:removeChildByTag(CLOUD_TAG)
--     end
-- end

local MAX_ZORDER = 999999999
function enter_scene(scene)
    local color_layer = cc.LayerColor:create(cc.c4b(255,255,255,255))
    :addTo(scene,MAX_ZORDER,CLOUD_TAG)
    local onEnterTransitionFinish__ = scene.onEnterTransitionFinish
    if onEnterTransitionFinish__ then
        scene.onEnterTransitionFinish = function(self)
            onEnterTransitionFinish__(self)
            self:performWithDelay(function()
                local armature = ccs.Armature:create("Cloud_Animation")
                    :pos(display.cx, display.cy)
                    :addTo(color_layer,-1)
                local animation = armature:getAnimation()
                animation:play("Animation4", -1, 0)
                animation:setSpeedScale(speed)
            end, 0.01)
            self.onEnterTransitionFinish = onEnterTransitionFinish__
        end
    end
    transition.fadeOut(color_layer, {
        time = 0.75/speed,
        onComplete = function()
            scene:removeChildByTag(CLOUD_TAG)
            app:lockInput(false)
        end
    })
end
function enter_scene_transition(scene_name, ...)
    app:lockInput(true)
    local color_layer = cc.LayerColor:create(cc.c4b(255,255,255,0))
        :addTo(display.getRunningScene(), MAX_ZORDER)

    local animation = ccs.Armature:create("Cloud_Animation")
        :addTo(color_layer,-1)
        :pos(display.cx, display.cy):getAnimation()

    animation:play("Animation1", -1, 0)
    animation:setSpeedScale(speed)

    local args = {...}
    transition.fadeIn(color_layer, {
        time = 0.75/speed,
        onComplete = function()
            local next_scene = app:enterScene(scene_name, args)
            enter_scene(next_scene)
        end
    })
end

local is_debug_cloud = true

local enter_next_scene = function(new_scene_name, ...)
    print("enter_next_scene=",new_scene_name,...)
    if is_debug_cloud then
        enter_scene_transition(new_scene_name, ...)
    else
        app:enterScene(new_scene_name, {...}, "custom", -1, transition_)
    end
end

function MyApp:enterScene(sceneName, args, transitionType, time, more)
    local scenePackageName = self.packageRoot .. ".scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.replaceScene(scene, transitionType, time, more)
    return scene
end

function MyApp:ctor()
    MyApp.super.ctor(self)
    self:InitGameBase()
    NetManager:init()
    self.timer = Timer.new()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo(DEBUG_GET_ANIMATION_PATH("animations/Cloud_Animation.ExportJson"))

    -- 当前音乐播放完成回调(只播放一次的音乐)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local customListenerBg = cc.EventListenerCustom:create("APP_BACKGROUND_MUSIC_COMPLETION",handler(self, self.onBackgroundMusicCompletion))
    eventDispatcher:addEventListenerWithFixedPriority(customListenerBg, 1)
end

function MyApp:run()
    cc.Director:getInstance():setProjection(0)
    self:enterScene('LogoScene')
end

function MyApp:showDebugInfo()
    local __debugVer = require("debug_version")
    return "Client Ver:" .. __debugVer .. "\nPlayerID:" .. DataManager:getUserData()._id
end

function MyApp:restart(needDisconnect)
    if needDisconnect == true or type(needDisconnect) == 'nil' then
        NetManager:disconnect()
    end
    --关闭所有状态
    self:EndCheckGameCenterIf()
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

function MyApp:GetGameLanguage()
    return self.gameLanguage_
end

function MyApp:sendPlayerLanguageCodeIf()
    if self:GetGameLanguage() ~= User.basicInfo.language then
        NetManager:getSetPlayerLanguagePromise(self:GetGameLanguage())
    end
end

function MyApp:SetGameLanguage(lang)
    print("SetGameLanguage----->",lang)
    cc.UserDefault:getInstance():setStringForKey("GAME_LANGUAGE", lang)
    cc.UserDefault:getInstance():flush()
    self:restart()
end

function MyApp:InitGameBase()
    self.GameDefautlt_ = GameDefautlt.new()
    self.AudioManager_ = AudioManager.new(self:GetGameDefautlt())
    self.LocalPushManager_ = LocalPushManager.new(self:GetGameDefautlt())
    self.gameLanguage_ = cc.UserDefault:getInstance():getStringForKey("GAME_LANGUAGE")
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

function MyApp:retryConnectGateServer()
    UIKit:WaitForNet(0)
    NetManager:getConnectGateServerPromise():catch(function(err)
        UIKit:NoWaitForNet()
        UIKit:showKeyMessageDialog(_("错误"), _("服务器连接断开,请检测你的网络环境后重试!"), function()
            app:retryConnectServer(true)
        end)
    end):done(function()
        NetManager:getLogicServerInfoPromise():done(function()
            UIKit:NoWaitForNet()
            self:retryLoginGame()
        end):catch(function(err)
            UIKit:NoWaitForNet()
            local content, title = err:reason()
            if title == 'timeout' then
                UIKit:showKeyMessageDialog(_("错误"), _("服务器连接断开,请检测你的网络环境后重试!"), function()
                    app:retryConnectServer(true)
                end)
            else
                UIKit:showKeyMessageDialog(_("错误"), UIKit:getErrorCodeData(content.code).message, function()
                    app:restart(true)
                end)
            end
        end)
    end)
end


function MyApp:retryLoginGame()
    local debug_info = debug.traceback("", 2)
    if NetManager.m_logicServer.host and NetManager.m_logicServer.port then
        UIKit:WaitForNet(0)
        NetManager:getConnectLogicServerPromise():next(function()
            print("MyApp:debug--->2")
            return NetManager:getLoginPromise()
        end):catch(function(err)
            dump(err)
            NetManager:disconnect()
            print("MyApp:debug--->3")
            local content, title = err:reason()
            if title == 'timeout' then
                print("MyApp:debug--->4")
                UIKit:showKeyMessageDialog(_("错误"), _("服务器连接断开,请检测你的网络环境后重试!"), function()
                    app:retryLoginGame(false)
                end)
            elseif title == 'syntaxError' then
                UIKit:showMessageDialog(_("错误"), content,function()
                    app:restart(false)
                end,nil,false)
            else
                if UIKit:getErrorCodeKey(content.code) == 'playerAlreadyLogin' then
                    print("MyApp:debug--->5")
                    UIKit:showKeyMessageDialog(_("错误"), UIKit:getErrorCodeData(content.code).message, function()
                        app:restart(false)
                    end)
                    if checktable(ext.market_sdk) and ext.market_sdk.onPlayerEvent then
                        ext.market_sdk.onPlayerEvent("LUA_ERROR_RETRYLOGIN", debug_info)
                    end
                else
                    print("MyApp:debug--->6")
                    UIKit:showKeyMessageDialog(_("错误"), UIKit:getErrorCodeData(content.code).message, function()
                        app:retryLoginGame(false)
                    end)
                end
            end
        end):done(function()
            print("MyApp:debug--->fetchChats")
            app:GetChatManager():FetchChatWhenReLogined()
        end):always(function()
            print("MyApp:debug--->7")
            UIKit:NoWaitForNet()
        end)
    else
        app:retryConnectServer(false)
    end
end

function MyApp:retryConnectServer(need_disconnect)
    print(debug.traceback("", 2),"retryConnectServer---->0")
    if need_disconnect or type(need_disconnect) == "nil" or not NetManager:isConnected() then
        if MailManager then
            MailManager:Reset()
        end
        NetManager:disconnect()
        print("MyApp:debug--->1")
    end
    if UIKit:isKeyMessageDialogShow() then return end
    --如果在登录界面并且未进入游戏忽略
    if display.getRunningScene().__cname == 'MainScene' then
        if not display.getRunningScene().startGame then
            return
        end
    end
    NetManager.m_logicServer.host = nil 
    NetManager.m_logicServer.port = nil
    self:retryConnectGateServer()
end
function MyApp:ReloadGame()
    self:onEnterBackground()
    scheduler.performWithDelayGlobal(function()
        self:onEnterForeground()
    end, 2)
end

function MyApp:onEnterBackground()
    dump("onEnterBackground------>")
    if MailManager then
        MailManager:Reset()
    end
    NetManager:disconnect()
    self:flushIf()
end

function MyApp:onBackgroundMusicCompletion()
    self:GetAudioManager():OnBackgroundMusicCompletion()
end

function MyApp:onEnterForeground()
    UIKit:closeAllUI()
    dump("onEnterForeground------>")
    local scene = display.getRunningScene()
    if scene.__cname == "LogoScene" then
        return
    end
    if scene.__cname == "MyCityScene" then
        if not Alliance_Manager:HasBeenJoinedAlliance() then
            scene:GetHomePage():PromiseOfFteAlliance()
        end
    end
    if scene.__cname == "MainScene" then
        if (self:GetGameDefautlt():IsPassedSplash() 
        or scene.ui.passed_splash)
        and not scene.ui.enter_next_scene then
            return scene.ui:loginAction()
        else
            return
        end
    end
    self:retryConnectServer(false)
end
function MyApp:onEnterPause()
    LuaUtils:outputTable("onEnterPause", {})
end
function MyApp:onEnterResume()
    LuaUtils:outputTable("onEnterResume", {})
end

-- local lockInputCount = 0
function MyApp:lockInput(b)
    -- if b then
    --     lockInputCount = lockInputCount + 1
    -- else
    --     lockInputCount = lockInputCount - 1
    -- end
    -- if lockInputCount > 0 then
    cc.Director:getInstance():getEventDispatcher():setEnabled(not b)
    -- elseif lockInputCount == 0 then
    -- cc.Director:getInstance():getEventDispatcher():setEnabled(not b)
    -- end
end
function MyApp:EnterFriendCityScene(id, location)
    self:EnterCitySceneByPlayerAndAlliance(id, true, location)
end
function MyApp:EnterPlayerCityScene(id, location)
    self:EnterCitySceneByPlayerAndAlliance(id, false, location)
end
function MyApp:EnterCitySceneByPlayerAndAlliance(id, is_my_alliance, location)
    NetManager:getPlayerCityInfoPromise(id):done(function(response)
        local user_data = response.msg.playerViewData
        local user = User_.new(user_data):OnUserDataChanged(user_data)
        local city = City.new(user):InitWithJsonData(user_data)
            :OnUserDataChanged(user_data, app.timer:GetServerTime())
        if is_my_alliance then
            enter_next_scene("FriendCityScene", user, city, location)
        else
            enter_next_scene("OtherCityScene", user, city, location)
        end
    end)
end
function MyApp:EnterMyCityFteScene()
    -- app:enterScene("MyCityFteScene", {City}, "custom", -1, transition_)
    enter_next_scene("MyCityFteScene", City)
end
function MyApp:EnterMyCityScene(isFromFte)
    -- app:enterScene("MyCityScene", {City,isFromFte}, "custom", -1, transition_)
    enter_next_scene("MyCityScene", City, isFromFte)
end
function MyApp:EnterFteScene()
    -- app:enterScene("FteScene", nil, "custom", -1, transition_)
    enter_next_scene("FteScene")
end
function MyApp:EnterMyAllianceScene(location)
    if Alliance_Manager:GetMyAlliance():IsDefault() then
        UIKit:showMessageDialog(_("提示"),_("加入联盟后开放此功能!"),function()end)
        return
    end

    local alliance_name = "AllianceDetailScene"
    local my_status = Alliance_Manager:GetMyAlliance().basicInfo.status
    if my_status == "prepare" or  my_status == "fight" then
        alliance_name = "AllianceDetailScene"
    end
    -- app:enterScene(alliance_name, {location}, "custom", -1, transition_)
    enter_next_scene(alliance_name, location)
end
function MyApp:EnterMyAllianceSceneOrMyCityScene(location)
    if not Alliance_Manager:GetMyAlliance():IsDefault() then
        local my_status = Alliance_Manager:GetMyAlliance().basicInfo.status
        local alliance_name = "AllianceScene"
        if my_status == "prepare" or  my_status == "fight" then
            alliance_name = "AllianceBattleScene"
        end
        -- app:enterScene(alliance_name, {location}, "custom", -1, transition_)
        enter_next_scene(alliance_name, location)
    else
        -- app:enterScene("MyCityScene", {City}, "custom", -1, transition_)
        enter_next_scene("MyCityScene", City)
    end
end
function MyApp:EnterPVEScene(level)
    enter_next_scene("PVESceneNew", User, level)
end
function MyApp:EnterPVEFteScene(level)
    enter_next_scene("PVESceneNewFte", User, level)
end
function MyApp:EnterWorldScene()
    enter_next_scene("WorldScene")
end

function MyApp:pushScene(sceneName, args, transitionType, time, more)
    local scenePackageName = "app.scenes." .. sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.pushScene(scene, transitionType, time, more)
end
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function MyApp:EnterUserMode()
    GLOBAL_FTE = false
    if DataManager.handle__ then
        scheduler.unscheduleGlobal(DataManager.handle__)
        DataManager.handle__ = nil
    end
    if DataManager.handle_soldier__ then
        scheduler.unscheduleGlobal(DataManager.handle_soldier__)
        DataManager.handle_soldier__ = nil
    end
    if DataManager.handle_treat__ then
        scheduler.unscheduleGlobal(DataManager.handle_treat__)
        DataManager.handle_treat__ = nil
    end
    if DataManager.handle_tech__ then
        scheduler.unscheduleGlobal(DataManager.handle_tech__)
        DataManager.handle_tech__ = nil
    end
    local InitGame = import("app.service.InitGame")
    assert(DataManager:hasUserData())
    InitGame(DataManager:getUserData())
    DataManager:setUserAllianceData(DataManager.allianceData)
    -- DataManager:setEnemyAllianceData(DataManager.enemyAllianceData)
end

function MyApp:getSupportMailFormat(category,logMsg)

    local UTCTime    = "UTC Time:" .. os.date('!%Y-%m-%d %H:%M:%S', self.timer:GetServerTime())
    local GameName   = "Game:" .. "Dragonfall"
    local Version    = "Version:" .. ext.getAppVersion()
    local UserID   = "User ID:" .. DataManager:getUserData()._id
    local Username   = "User name:" .. DataManager:getUserData().basicInfo.name
    local Server     = "Server:" .. "World"
    local OpenUDID   = "Open UDID:" .. device.getOpenUDID()
    local Category   = "Category:" .. category or ""
    local Language   = "Language:" .. self:GetGameLanguage()
    local DeviceType = "Device Type:" ..ext.getDeviceModel()
    local OSVersion  = "OS Version:" .. ext.getOSVersion()

    local format_str = "\n\n\n\n\n---------------%s---------------\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s"
    local result_str = string.format(format_str,_("不能删除"),UTCTime,GameName,Version,Username,UserID,Server,OpenUDID,Category,Language,DeviceType,OSVersion)
    if logMsg then
        result_str = string.format("%s\n---------------Log---------------\n%s",result_str,logMsg)
    end
    return "[Dragonfall]" .. category ,result_str
end

function MyApp:EnterViewModelAllianceScene(alliance_id)
    NetManager:getFtechAllianceViewDataPromose(alliance_id):done(function(response)
        local alliance = Alliance_Manager:DecodeAllianceFromJson(response.msg.allianceViewData)
        -- app:enterScene("OtherAllianceScene", {alliance}, "custom", -1, transition_)
        enter_next_scene("OtherAllianceScene", alliance)
    end)
end

function MyApp:sendApnIdIf()
    local token = ext.getDeviceToken() or ""
    if string.len(token) > 0 then
        token = string.sub(token,2,string.len(token)-1)
        token = string.gsub(token," ","")
    end
    if token ~= User.apnId and string.len(token) > 0 then
        NetManager:getSetApnIdPromise(token)
    end
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
        local info = DataUtils:getIapInfo(transaction.productIdentifier)
        ext.market_sdk.onPlayerChargeRequst(transaction.transactionIdentifier,transaction.productIdentifier,info.price,info.gem,"USD")
        NetManager:getVerifyIAPPromise(transaction.transactionIdentifier,transaction.receipt):next(function(response)
            device.hideActivityIndicator()
            local msg = response.msg
            if msg.transactionId then
                local openRewardIf = function()
                    local GameUIActivityRewardNew_instance = UIKit:GetUIInstance("GameUIActivityRewardNew")
                    if User and not GameUIActivityRewardNew_instance then
                        local countInfo = User.countInfo
                        if countInfo.iapCount > 0 and not countInfo.isFirstIAPRewardsGeted then
                            UIKit:newGameUI("GameUIActivityRewardNew",4):AddToCurrentScene(true) -- 如果首充 弹出奖励界面
                        end
                    end
                end
                UIKit:showMessageDialog(_("恭喜"), 
                    string.format("您已获得%s,到物品里面查看",
                    UIKit:getIapPackageName(transaction.productIdentifier)),
                    openRewardIf)
                Store.finishTransaction(transaction)
                ext.market_sdk.onPlayerChargeSuccess(transaction.transactionIdentifier)
            end
        end):catch(function(err)
            device.hideActivityIndicator()
            local msg,code_type = err:reason()
            local code = msg.code
            if code_type ~= "syntaxError" then
                local code_key = UIKit:getErrorCodeKey(code)
                if code_key == 'duplicateIAPTransactionId' or code_key == 'iapProductNotExist' or code_key == 'iapValidateFaild' then
                    Store.finishTransaction(transaction)
                end
            end
        end)
    elseif transaction_state == 'purchasing' then
        --不作任何处理
        device.hideActivityIndicator()
    else
        Store.finishTransaction(transaction)
        device.hideActivityIndicator()
    end
end
-- GameCenter
------------------------------------------------------------------------------------------------------------------
function MyApp:StarCheckGameCenterIf()
    if not self.___handle___ then
        self.___handle___ = scheduler.scheduleGlobal(handler(self, self.__checkGameCenter),5)
    end
end
function MyApp:EndCheckGameCenterIf()
    if self.___handle___ then
        scheduler.unscheduleGlobal(self.___handle___)
    end
    self.___handle___ = nil
end

function MyApp:__checkGameCenter()
    if not NetManager:IsLogin() then return end
    if ext.gamecenter.isAuthenticated() then
        local __,gcId = ext.gamecenter.getPlayerNameAndId()
        if string.len(gcId) > 0 and NetManager:isConnected() and User and not User:IsBindGameCenter() then
            NetManager:getGcBindStatusPromise(gcId):done(function(response)
                if not response.msg.isBind then
                    NetManager:getBindGcIdPromise(gcId):done(function()
                        app:EndCheckGameCenterIf()
                    end)
                else
                    app:EndCheckGameCenterIf()
                end
                ext.gamecenter.gc_bind = response.msg.isBind
            end)
        end
    end
end

-- 如果登陆成功 函数将会被回调
function __G__GAME_CENTER_CALLBACK(gc_name,gc_id)
    app:StarCheckGameCenterIf()
    --如果玩家当前未绑定gc并且当前的gc未绑定任何账号 执行自动绑定
    if gc_name and gc_id and NetManager:isConnected() and NetManager:IsLogin() then
        NetManager:getGcBindStatusPromise(gc_id):done(function(response)
            if User and not User:IsBindGameCenter() then
                if not response.msg.isBind then
                    NetManager:getBindGcIdPromise(gc_id):done(function()
                        app:EndCheckGameCenterIf()
                    end)
                else
                    app:EndCheckGameCenterIf()
                end
            end
            ext.gamecenter.gc_bind = response.msg.isBind
        end)
    end
end


my_print = function(...)
    LuaUtils:outputTable({...})
end

return MyApp






