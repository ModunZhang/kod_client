--
-- Author: dannyhe
-- Date: 2014-08-05 20:10:36
--
local GameUILogin = UIKit:createUIClass('GameUILogin')

function GameUILogin:ctor()
    GameUILogin.super.ctor(self)
    local bgImage = display.newScale9Sprite("images/spalshbg.png", display.cx, display.cy,cc.size(display.width,display.height))
    bgImage:addTo(self)
end

function GameUILogin:onEnter()
    GameUILogin.super.onEnter(self)
    self:createProgressBar()
    self:createTips()
    self:proLoad()
end


-- Private Methods
function GameUILogin:createProgressBar()
    local bar = display.newSprite("images/splash_process_bg.png"):addTo(self):pos(display.cx,display.bottom+150)
    local progressFill = display.newSprite("images/splash_process_color.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(1)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    ProgressTimer:setPercentage(1)
    display.newSprite("images/splash_process_bound.png"):align(display.LEFT_BOTTOM, -10, -4):addTo(bar)
    local label = ui.newTTFLabel({
        text = "Loading(1/3)...",
        font = UIKit:getFontFilePath(),
        size = 12,
        align = ui.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(575, 33)
    }):addTo(bar):pos(bar:getContentSize().width/2,bar:getContentSize().height/2)
    self.progressTips = label
    self.progressTimer = ProgressTimer
end

function GameUILogin:createTips()
    local bgImage = display.newSprite("images/splash_tips_bg.png"):addTo(self):pos(display.cx,display.bottom+100)
    local label = ui.newTTFLabel({
        text = _("提示:预留一定的空闲城民"),
        font = UIKit:getFontFilePath(),
        size = 18,
        align = ui.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(569, 43),
        color = cc.c3b(255,170,168)
    }):addTo(bgImage):pos(bgImage:getContentSize().width/2,bgImage:getContentSize().height/2)
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
    NetManager:connectGateServer(function(success)
        if not success then
            self:setProgressText(_("连接网关服务器失败!"))
            return
        end
        self:setProgressPercent(70)
        self:getLogicServerInfo()
    end)
end


function GameUILogin:getLogicServerInfo()
    NetManager:getLogicServerInfo(function(success)
        if not success then
            self:setProgressText(_("获取游戏服务器信息失败!"))
            return
        end
        self:setProgressPercent(80)
        self:connectLogicServer()
    end)
end


function GameUILogin:connectLogicServer()
    self:setProgressText(_("连接游戏服务器...."))
    NetManager:connectLogicServer(function(success)
        if not success then
            self:setProgressText(_("连接游戏服务器失败!"))
            return
        end
        self:setProgressPercent(100)
        self:login()
    end)
end

function GameUILogin:login()
    self:setProgressText(_("登陆游戏服务器...."))
    NetManager:login(function ( success, msg )
        if not success then
            self:setProgressText(_("登录游戏失败!"))
            return
        end
    end)
end

return GameUILogin