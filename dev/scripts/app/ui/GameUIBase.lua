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
	print("onExit--->")
end


function GameUIBase:onCleanup()
	print("onCleanup->")
end


-- overwrite in subclass
--------------------------------------
function GameUIBase:rightButtonClicked()
end

function GameUIBase:onMovieInStage()
end

function GameUIBase:onMovieOutStage()
	self:removeFromParent(true)
end


-- public methods
--------------------------------------

function GameUIBase:leftButtonClicked()
	if self:isVisible() then
		if self.moveInAnima then
			self:UIAnimationMoveOut()
		else
			self:removeFromParent(true) -- 没有动画就直接删除
		end
	end
end

function GameUIBase:addToScene(scene,anima)
	print("addToScene->",tolua.type(scene))
	if scene and tolua.type(scene) == 'cc.Scene' then
		scene:addChild(self, 2000)
		self.moveInAnima = anima == nil and false or anima
		if self.moveInAnima then
		 	self:UIAnimationMoveIn()
		else
			self:onMovieInStage()
		end
	end
	return self
end



-- ui入场动画
function GameUIBase:UIAnimationMoveIn()
	self:pos(0,-self:getContentSize().height)
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, 0)), 
    {
	    easing = "sineIn",
	    onComplete = function()
	    	self:onMovieInStage()
	    end
    })
end

-- ui 出场动画
function GameUIBase:UIAnimationMoveOut()
	print("UIAnimationMoveOut->",self,tolua.type(self))
	transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, -self:getContentSize().height)), 
    {
	    easing = "sineIn",
	    onComplete = function()
	    	self:onMovieOutStage()
	    end
    })
end

-- Private Methods
--------------------------------------
function GameUIBase:_initCommonUI(param)
	
end


return GameUIBase