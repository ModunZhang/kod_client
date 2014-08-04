--
-- Author: dannyhe
-- Date: 2014-08-01 16:18:16
-- BaseView is a CCLayer  
local GameUIBase = class('GameUIBase', function()
	return display.newLayer()
end)

function GameUIBase:ctor(params)
	assert(type(params) == 'table')
	self.title = params.title
	return self:_initUI(params.ui)
end

function GameUIBase:getLayer()
	return self.uiLayer
end

function GameUIBase:setLayer(view)
	if self.uiLayer then
		self:removeAllChildrenWithCleanup(true)
		self.uiLayer = nil
	end
	self.uiLayer = view 
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

-- overwrite in subclass
------------
function GameUIBase:rightButtonClicked(sender)
end

function GameUIBase:onAddToScene()
	print('GameUIBase:onAddToScene')
end

function GameUIBase:onEraseFromScene()
	self:removeFromParentAndCleanup(true) -- subclass must call this methods
end
------------
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
	    	self:onAddToScene()
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
	    	self:onEraseFromScene()
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


-- private methods
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