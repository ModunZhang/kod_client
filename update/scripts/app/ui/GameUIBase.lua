--
-- Author: dannyhe
-- Date: 2014-08-01 16:18:16
-- GameUIBase is a CCLayer  

local GameUIBase = class('GameUIBase', function()
	return display.newLayer()
end)

function GameUIBase:ctor(params)
	assert(type(params) == 'table')
	self.title = params.title
	self.ui = params.ui
	self:setNodeEventEnabled(true)
	return true
end


-- Node Event
--------------------------------------
function GameUIBase:onEnter()
	self:_initUI(self.ui)
end

function GameUIBase:onEnterTransitionFinish()
end

function GameUIBase:onExitTransitionStart()
end

function GameUIBase:onExit()
end


function GameUIBase:onCleanup()
end


-- overwrite in subclass
--------------------------------------
function GameUIBase:rightButtonClicked(sender)
end

function GameUIBase:onMovieInStage()
	
end

function GameUIBase:onMovieOutStage()

end


-- public methods
--------------------------------------

function GameUIBase:getLayer()
	return self.uiLayer
end

function GameUIBase:setLayer(layer)
	if self.uiLayer then
		self:removeAllChildrenWithCleanup(true)
		self.uiLayer = nil
	end
	self.uiLayer = layer 
	self:addChild(self.uiLayer)
	return self
end

function GameUIBase:leftButtonClicked(sender)
	if self:isVisible() then
		if self.moveInAnima then
			self:UIAnimationMoveOut()
		end
	end
end

function GameUIBase:addToScene(scene,anima)
	if scene and tolua.type(scene) == 'CCScene' then
		scene:addChild(self)
		self.moveInAnima = anima
		if anima then
		 	self:UIAnimationMoveIn()
		end
	end
	return self
end

function GameUIBase:addToCurrentScene(finishFunc,anima)
	if anima == nil then anima = true end
	return self:addToScene(CCDirector:sharedDirector():getRunningScene(),anima and true or false)
end

function GameUIBase:seekWidgetByName(widgetName)
	return  UIHelper:seekWidgetByName(self.rootWidget, widgetName)
end
--[[ 
-- table names for tableviews
	
	local tableview1,tableview2 = self:seekPanel2Table('Panel_Table1','Panel_Table2')
	tableview1:registerScriptHandler(function(table, cell)
        print("cell touched at index: " .. cell:getIdx())
    end, CCTableView.kTableCellTouched)
    ...
	...

]]--
function GameUIBase:seekPanel2Table(...)
	local args = {...}
	if #args == 0 then return end
	local tableviews = {}
	for _,v in ipairs(args) do
		local tmpPanel = self:seekWidgetByName(v)
		local tableview = CCTableView:create(cc.t2size(tmpPanel:getContentSize()))
		tableview:setPosition(cc.p(0,0))
		tableview:setTouchPriority(-1)
    	tableview:setDirection(kCCScrollViewDirectionVertical) -- table is vertiacl
		tmpPanel:addNode(tableview)
		table.insert(tableviews,tableview)
	end
	return unpack(tableviews)
end

-- ui入场动画
function GameUIBase:UIAnimationMoveIn()
	local panel = self.rootWidget
	panel:setPositionY(-panel:getSize().height)
    transition.execute(panel, CCMoveTo:create(0.3, CCPoint(0, 0)), 
    {
	    easing = "sineIn",
	    onComplete = function()
	    	self:onMovieInStage()
	    end
    })
end

-- ui 出场动画
function GameUIBase:UIAnimationMoveOut()
	local panel = self.rootWidget
    transition.execute(panel, CCMoveTo:create(0.3, CCPoint(0, -panel:getSize().height)), 
    {
	    easing = "sineOut",
	    onComplete = function()
	    	self:onMovieOutStage()
	    end
    })
end

--[[
local cb = function(button)
	if button._name_ == 'Button_1' then
		print('hello' .. button._idx_)
	end
end 
--]]
function GameUIBase:seekAndBindEvent4SegmentButtons(cb,...)
	local SegmentConntain = {}
	local buttons 		= {}
	local handler =  function(button,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			for i,v in ipairs(buttons) do
				button:setVisible(i == button._idx_)
			end
			cb(button)
		end
	end
	for i,v in ipairs({...}) do
		local button = self:seekWidgetByName(v)
		if button then
			button._idx_  =  i
			button._name_ = v
			button:addTouchEventListener(handler)
		 	table.insert(buttons,button) 
		end
	end
end


-- Private Methods
--------------------------------------
function GameUIBase:_initUI( jsonFile )
	self.uiLayer = TouchGroup:create() -- uiLayer is a TouchGroup(UILayer)
	self:addChild(self.uiLayer)
	if jsonFile then
		self.rootWidget = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
		self.uiLayer:addWidget(self.rootWidget)
		self.leftButton = self:seekWidgetByName('Sys_Button_Home')
		if self.leftButton then
	    	self.leftButton:addTouchEventListener(function(sender,event)
		    	if event == TOUCH_EVENT_ENDED then
		    		self:leftButtonClicked(sender)
		    	end
	    	end)
	    end
    	self.rightButton =  self:seekWidgetByName('Sys_Button_Shop')
    	if self.leftButton then
	    	self.rightButton:addTouchEventListener(function(sender,event)
		    	if event == TOUCH_EVENT_ENDED then
		    		self:rightButtonClicked(sender)
		    	end
	    	end)
	    end
    	self.titleLabel = self:seekWidgetByName('Sys_Label_Title')
    	if self.titleLabel then
    		self.titleLabel:setText(self.title or "")
    	end
	end
	return self.rootWidget
end

return GameUIBase