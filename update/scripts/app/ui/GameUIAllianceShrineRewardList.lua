--
-- Author: Danny He
-- Date: 2014-11-12 10:02:15
--
local GameUIAllianceShrineRewardList = UIKit:createUIClass("GameUIAllianceShrineRewardList")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local HEIGHT = 738
local window = import("..utils.window")
local UIListView = import(".UIListView")

function GameUIAllianceShrineRewardList:ctor(shrineStage)
	GameUIAllianceShrineRewardList.super.ctor(self)
	self.shrineStage_ = shrineStage
end

function GameUIAllianceShrineRewardList:onEnter()
	GameUIAllianceShrineRewardList.super.onEnter(self)
	self:BuildUI()
end

function GameUIAllianceShrineRewardList:BuildUI()
	local layer = UIKit:shadowLayer():addTo(self)
	local background = WidgetUIBackGround.new({height = HEIGHT})
		:addTo(layer)
		:pos(window.left+22,window.top - 101 - HEIGHT)
	local title_bar = display.newSprite("title_blue_600x52.png"):align(display.CENTER_BOTTOM, 304,HEIGHT - 15):addTo(background)
	UIKit:ttfLabel({
		text = _("事件完成奖励"),
		size = 22,
		color = 0xffedae
	}):align(display.CENTER,300,21):addTo(title_bar)
	local closeButton = UIKit:closeButton()
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width, 0)
	   	:onButtonClicked(function ()
	   		self:LeftButtonClicked()
	   	end)

	self.rewards_listView = UIListView.new({
        viewRect = cc.rect(7, 100,595, 610),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT,
    }):addTo(background)
	local line = display.newScale9Sprite("dividing_line_594x2.png"):size(590,1):align(display.LEFT_BOTTOM,10,710):addTo(background)
	cc.ui.UIPushButton.new({
		normal = "yellow_btn_up_185x65.png",
		pressed = "yellow_btn_down_185x65.png"
	}):align(display.RIGHT_BOTTOM,580,20):addTo(background)
	:setButtonLabel("normal",UIKit:commonButtonLable({
		text = _("确定")
	}))
	:onButtonClicked(function()
		self:LeftButtonClicked()
	end)
	self:RefreshRewardListView()
end

function GameUIAllianceShrineRewardList:GetListItem(index,data) 
	local node = display.newNode()
	local line = display.newScale9Sprite("dividing_line_594x2.png"):size(595,1):align(display.LEFT_BOTTOM,0,0):addTo(node)
	local iconImage = "GoldKill_icon_66x76.png"
	if index == 1 then
		iconImage = "GoldKill_icon_66x76.png"
	elseif index == 2 then
		iconImage = "SilverKill_icon_66x76.png"
	elseif index == 3 then
		iconImage = "BronzeKill_icon_66x76.png"
	end
	local icon = display.newSprite(iconImage):align(display.LEFT_BOTTOM,20,10):addTo(node)
	local strength_icon = display.newSprite("dragon_strength_27x31.png")
		:align(display.LEFT_BOTTOM,icon:getPositionX()+icon:getContentSize().width+10,icon:getPositionY()+2)
		:addTo(node)
	UIKit:ttfLabel({
		text = data[2],
		size = 22,
		color = 0x403c2f
	}):addTo(node):align(display.LEFT_BOTTOM,strength_icon:getPositionX()+strength_icon:getContentSize().width+5,strength_icon:getPositionY())
	local label = UIKit:ttfLabel({
		text = data[1],
		size = 22,
		color = 0x403c2f
	}):addTo(node):align(display.LEFT_TOP,strength_icon:getPositionX(),icon:getPositionY()+icon:getContentSize().height)
	local x,y = strength_icon:getPositionX()+strength_icon:getContentSize().width+200,label:getPositionY()+10
	for i,v in ipairs(data[3]) do
		local item = display.newSprite("shire_reward_70x70.png")
			:align(display.LEFT_TOP,x,y)
			:addTo(node)
		UIKit:ttfLabel({
			text = "x" .. v.count,
			size = 22,
			color = 0x403c2f
		}):addTo(item):align(display.TOP_CENTER,35,2)
		x = x + 70 + 20
	end
	return node
end

function GameUIAllianceShrineRewardList:GetListData()
	local data = {}
	data[1] = {"奖励等级本地化缺失",string.formatnumberthousands(self:GetShrineStage():GoldKill()),self:GetShrineStage():GoldRewards()}
	data[2] = {"奖励等级本地化缺失",string.formatnumberthousands(self:GetShrineStage():SilverKill()),self:GetShrineStage():SilverRewards()}
	data[3] = {"奖励等级本地化缺失",string.formatnumberthousands(self:GetShrineStage():BronzeKill()),self:GetShrineStage():BronzeRewards()}
	return data
end

function GameUIAllianceShrineRewardList:GetShrineStage()
	return self.shrineStage_
end

function GameUIAllianceShrineRewardList:RefreshRewardListView()
	self.rewards_listView:removeAllItems()
	for i,v in ipairs(self:GetListData()) do
		local item = self.rewards_listView:newItem()
		local content = self:GetListItem(i,v)
		item:addContent(content)
		content:size(595,100)
		item:setItemSize(595,100)
		self.rewards_listView:addItem(item)
	end
	self.rewards_listView:reload()
end

return GameUIAllianceShrineRewardList