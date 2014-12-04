--
-- Author: dannyhe
-- Date: 2014-08-05 20:10:36
--
local GameUILogin = UIKit:createUIClass('GameUILogin','GameUISplash')

function GameUILogin:ctor()
    GameUILogin.super.ctor(self)
    -- local bg = display.newScale9Sprite("spalshbg.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(self)
    -- bg:size(display.width,bg:getContentSize().height)
    -- display.newSprite("gameName.png"):pos(display.cx,display.top-150):addTo(self)
end

function GameUILogin:onEnter()
    GameUILogin.super.onEnter(self)
    assert(self.ui_layer)
    self:createProgressBar()
    self:createTips()
end


function GameUILogin:onMoveInStage()
    -- self:proLoad()
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
end

function GameUILogin:setProgressText(str)
    self.progressTips:setString(str)
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
        self:setProgressText(_("连接网关服务器失败!"))
    end)
end
function GameUILogin:getLogicServerInfo()
    NetManager:getLogicServerInfoPromise():next(function()
        self:setProgressPercent(80)
        self:connectLogicServer()
    end):catch(function(err)
        dump(err:reason())
        self:setProgressText(_("获取游戏服务器信息失败!"))
    end)
end


function GameUILogin:connectLogicServer()
    self:setProgressText(_("连接游戏服务器...."))
    NetManager:getConnectLogicServerPromise():next(function()
        self:setProgressPercent(100)
        self:login()
    end):catch(function(err)
        self:setProgressText(_("连接游戏服务器失败!"))
    end)

end

function GameUILogin:login()
    self:setProgressText(_("登陆游戏服务器...."))
    NetManager:getLoginPromise():catch(function(err)
        dump(err:reason())
        self:setProgressText(_("登录游戏失败!"))
    end)
end

return GameUILogin



