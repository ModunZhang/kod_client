--
-- Author: dannyhe
-- Date: 2014-08-05 20:10:36
--
local GameUILogin = UIKit:createUIClass('GameUILogin','GameUISplash')
local WidgetPushButton = import("..widget.WidgetPushButton")
local gaozhou
if CONFIG_IS_DEBUG then
    local result
    gaozhou, result = pcall(require, "app.service.gaozhou")
end
function GameUILogin:ctor()
    GameUILogin.super.ctor(self)
end

function GameUILogin:onEnter()
    GameUILogin.super.onEnter(self)
    assert(self.ui_layer)
    self:createProgressBar()
    self:createTips()
    self:createStartGame()
    self:createVerLabel()
end


function GameUILogin:OnMoveInStage()
    self:showVersion()
    self:proLoad()
end

-- Private Methods
function GameUILogin:createProgressBar()
    local bar = display.newSprite("images/splash_process_bg.png"):addTo(self.ui_layer):pos(display.cx,display.bottom+150)
    local progressFill = display.newSprite("images/splash_process_color.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    ProgressTimer:setPercentage(1)
    display.newSprite("images/splash_process_bound.png"):align(display.LEFT_BOTTOM, -10, -4):addTo(bar)
    local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "Loading(1/3)...",
        font = UIKit:getFontFilePath(),
        size = 12,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xf3f0b6),
        valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
    }):addTo(bar):align(display.CENTER,bar:getContentSize().width/2,bar:getContentSize().height/2)
    self.progressTips = label
    self.progressTimer = ProgressTimer
    self.progress_bar = bar
end

function GameUILogin:createTips()
    local bgImage = display.newSprite("images/splash_tips_bg.png"):addTo(self.ui_layer):pos(display.cx,display.bottom+100)
    local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("提示:预留一定的空闲城民,兵营将他们训练成士兵"),
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xaaa87f),
    }):addTo(bgImage):align(display.CENTER,bgImage:getContentSize().width/2,bgImage:getContentSize().height/2)
    self.tips_ui = bgImage
end

function GameUILogin:createStartGame()
    local button = WidgetPushButton.new({
         normal = "start_game_481x31.png"
    },nil,nil,{down = "SPLASH_BUTTON_START"}):addTo(self.ui_layer):pos(display.cx,display.bottom+150):hide()
    :onButtonClicked(function()
        local sp = cc.Spawn:create(cc.ScaleTo:create(1,1.5),cc.FadeOut:create(1))
        local seq = transition.sequence({sp,cc.CallFunc:create(function()
                self:sendApnIdIf()
                app:EnterMyCityScene()
            end)})
            self.start_ui:runAction(seq)
        end)
    self.start_ui = button
end

function GameUILogin:sendApnIdIf()
    local token = ext.getDeviceToken() or ""
    if string.len(token) > 0 and token ~= User:ApnId() then 
        token = string.sub(token,2,string.len(token)-1)
        token = string.gsub(token," ","")
        NetManager:getSetApnIdPromise(token)
    end
end

function GameUILogin:setProgressText(str,retryLogin)
    if type(retryLogin) ~= 'boolean' then
        retryLogin = false
    end
    self.progressTips:setString(str)
    if retryLogin then
        self:ReTryLogin(str)
    end
end
function GameUILogin:setProgressPercent(num,animac)
    animac = animac or false
    if animac then
        local progressTo = cc.ProgressTo:create(1,num)
        self.progressTimer:runAction(progressTo)
    else
        self.progressTimer:setPercentage(num)
    end
end

function GameUILogin:proLoad()
    self:setProgressPercent(60)
    self:loginAction()
end

function GameUILogin:loginAction()
    self:setProgressText(_("连接网关服务器...."))
    self:connectGateServer()
end

function GameUILogin:connectGateServer()
    NetManager:getConnectGateServerPromise():next(function()
        self:setProgressPercent(70)
        self:getLogicServerInfo()
    end):catch(function(err)
        dump(err:reason())
        self:setProgressText(_("连接网关服务器失败!"),true)
    end)
end
function GameUILogin:getLogicServerInfo()
    NetManager:getLogicServerInfoPromise():next(function()
        self:setProgressPercent(80)
        self:connectLogicServer()
    end):catch(function(err)
        dump(err:reason())
        self:setProgressText(_("获取游戏服务器信息失败!"),true)
    end)
end


function GameUILogin:connectLogicServer()
    self:setProgressText(_("连接游戏服务器...."))
    NetManager:getConnectLogicServerPromise():next(function()
        self:setProgressPercent(100)
        self:login()
    end):catch(function(err)
        self:setProgressText(_("连接游戏服务器失败!"),true)
    end)

end

function GameUILogin:login()
    self:setProgressText(_("登陆游戏服务器...."))
    NetManager:getLoginPromise():next(function(response)
        self:setProgressText(_("登录游戏成功!"))
        ext.market_sdk.onPlayerLogin(User:Id(),User:Name(),User:ServerName())
        ext.market_sdk.onPlayerLevelUp(User:Level())
        self:performWithDelay(function()
            self.progress_bar:hide()
            self.tips_ui:hide()
            self.start_ui:show()
        end, 0.5) 
    end):catch(function(err)
        dump(err:reason())
        self:setProgressText(_("登录游戏失败!"),true)
    end):done(function()
        if CONFIG_IS_DEBUG then
            if gaozhou then
                return app:EnterMyCityScene()
            end
        end
    end)
end

function GameUILogin:showVersion()
    if not CONFIG_IS_DEBUG then
        local jsonPath = cc.FileUtils:getInstance():fullPathForFilename("fileList.json")
        local file = io.open(jsonPath)
        local jsonString = file:read("*a")
        file:close()

        local tag = json.decode(jsonString).tag
        local version =string.format(_("版本:%s(%s)"), CONFIG_APP_VERSION, tag)
        self.verLabel:setString(version)
    else
        local __debugVer = require("debug_version")
        self.verLabel:setString(string.format(_("版本:%s(%s)"), CONFIG_APP_VERSION, __debugVer))
    end
end

function GameUILogin:createVerLabel()
    self.verLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "版本:1.0.0(ddf3d)",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = cc.c3b(0,0,0),
    }):addTo(self.ui_layer,2)
    :align(display.RIGHT_BOTTOM,display.right-2,display.bottom)
end

function GameUILogin:ReTryLogin(msg)
    msg = msg or ""
    local str = string.format("%s,%s",msg,_("点击执行重新登陆,或稍后再试."))
    UIKit:showMessageDialog(_("提示"),str, function()
        app:restart()
    end, nil, false)
end

return GameUILogin