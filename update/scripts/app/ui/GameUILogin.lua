--
-- Author: dannyhe
-- Date: 2014-08-05 20:10:36
--
local UIKitHelper = UIKitHelper
local GameUILogin = UIKitHelper:inheritUIBase('GameUILogin')

function GameUILogin:ctor()
	if not self.super.ctor(self,{ui = 'images/GameUISplash.json'}) then
		printError('Init GameUISplash Failed!')
	end
end

function GameUILogin:onEnter()
	self.super.onEnter(self)
	-- ui
	self.progressBar = self:seekWidgetByName('ProgressBar_Loading')
	self.progressLabel = self:seekWidgetByName('Label_Process')
	self.tipsLabel = self:seekWidgetByName('Label_Tips')
	self.verLabel = self:seekWidgetByName('Label_Version')
	self.verLabel:setVisible(false)
	self.progressBar:setPercent(0)
	self.progressLabel:setText('')
	self:proLoad()
end


-- Private Methods

function GameUILogin:setProgressText(str)
	self.progressLabel:setText(str)
end
function GameUILogin:setProgressPercent(num)
	self.progressBar:setPercent(num)
end

function GameUILogin:proLoad()
	self:setProgressText('载入中...')
	self:setProgressPercent(60)
	self:loginAction()
end

function GameUILogin:loginAction()
	self:setProgressText(_("连接网关服务器...."))
    NetManager:connectGateServer(function(success)
        if not success then
            self:setProgressText(_("连接网关服务器失败!"))
            return
        end
        self:setProgressPercent(70)
        self:setProgressText(_("获取游戏服务器信息...."))
        NetManager:getLogicServerInfo(function(success)
            if not success then
                self:setProgressText(_("获取游戏服务器信息失败!"))
                return
            end
            self:setProgressPercent(80)
            self:setProgressText(_("连接游戏服务器...."))
            NetManager:connectLogicServer(function(success)
                if not success then
                    self:setProgressText(_("连接游戏服务器失败!"))
                    return
                end

                NetManager:login(function ( success, msg )
                    if not success then
                        self:setProgressText(_("登录游戏失败!"))
                        return
                    else
                    	self:setProgressPercent(100)
                        self:setProgressText(_("登录游戏成功!"))
                        LuaUtils:outputTable("userMessage", msg)
                    end
                end)
            end)
        end)
    end)
end

return GameUILogin