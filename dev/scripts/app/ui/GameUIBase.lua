--
-- Author: dannyhe
-- Date: 2014-08-01 16:18:16
-- GameUIBase is a CCLayer  

local GameUIBase = class('GameUIBase', function()
	return display.newLayer()
end)

function GameUIBase:ctor(param)
	self:setNodeEventEnabled(true)
	if param then return self:_initCommonUI(param) end
	return true
end


-- Node Event
--------------------------------------
function GameUIBase:onEnter()
	print("onEnter->")
end

function GameUIBase:onEnterTransitionFinish()
	print("onEnterTransitionFinish->")
end

function GameUIBase:onExitTransitionStart()
	print("onExitTransitionStart->")
end

function GameUIBase:onExit()
	print("onExit->")
end


function GameUIBase:onCleanup()
	print("onCleanup->")
end


-- overwrite in subclass
--------------------------------------
function GameUIBase:rightButtonClicked(sender)
	print("rightButtonClicked->")
end

function GameUIBase:onMovieInStage()
end

function GameUIBase:onMovieOutStage()
end


-- public methods
--------------------------------------

function GameUIBase:leftButtonClicked(sender)
	if self:isVisible() then
		if self.moveInAnima then
			self:UIAnimationMoveOut()
		end
	end
end

function GameUIBase:addToScene(scene,anima)
	print("addToScene->")
	if scene and tolua.type(scene) == 'cc.Scene' then
		scene:addChild(self, 2000)
		self.moveInAnima = anima
		if anima then
		 	self:UIAnimationMoveIn()
		else
			self:onMovieInStage()
		end
	end
	return self
end

function GameUIBase:addToCurrentScene(anima)
	if anima == nil then anima = true end
	return self:addToScene(CCDirector:sharedDirector():getRunningScene(),anima and true or false)
end


-- ui入场动画
function GameUIBase:UIAnimationMoveIn()
	print("UIAnimationMoveIn->")
	-- local panel = self.rootWidget
	-- panel:setPositionY(-panel:getSize().height)
 --    transition.execute(panel, CCMoveTo:create(0.3, CCPoint(0, 0)), 
 --    {
	--     easing = "sineIn",
	--     onComplete = function()
	--     	self:onMovieInStage()
	--     end
 --    })
 --    CCDirector:sharedDirector():getTouchDispatcher():setDispatchEvents(false)
end

-- ui 出场动画
function GameUIBase:UIAnimationMoveOut()
	print("UIAnimationMoveOut->")
	-- local panel = self.rootWidget
 --    transition.execute(panel, CCMoveTo:create(0.3, CCPoint(0, -panel:getSize().height)), 
 --    {
	--     easing = "sineOut",
	--     onComplete = function()
	--     	self:onMovieOutStage()
	--     end
 --    })
 --    CCDirector:sharedDirector():getTouchDispatcher():setDispatchEvents(false)
end

-- Private Methods
--------------------------------------
function GameUIBase:_initCommonUI(param)
	
end


return GameUIBase