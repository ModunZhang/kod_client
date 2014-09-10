--
-- Author: Danny He
-- Date: 2014-09-10 21:05:17
--
import('app.utils.Minheap')
local GameGlobalUIUtils = class('GameGlobalUIUtils')

function GameGlobalUIUtils:ctor()
	self.tipsHeap = Minheap.new(function(a,b)
		return a.time < b.time
	end)
end

function GameGlobalUIUtils:showTips(title,content)
	local instance = cc.Director:getInstance():getRunningScene():getChildByTag(1020)
	if not instance then
		self.commonTips = UIKit:newGameUI('GameUICommonTips')
		assert(self.commonTips)
		cc.Director:getInstance():getRunningScene():addChild(self.commonTips, 1000000, 1020)
		self.commonTips:setVisible(false)
	end
	if self.commonTips:isVisible() then
		self.tipsHeap:push({title=title,content = content,time = os.time()})
	else
		self.commonTips:showTips(title,content)
	end
end

function GameGlobalUIUtils:onTipsMoveOut(tipsUI)
	if not self.tipsHeap:empty() then
		local message = self.tipsHeap:pop()
		tipsUI:showTips(message.title,message.content)
	end
end

GameGlobalUI = GameGlobalUIUtils.new()