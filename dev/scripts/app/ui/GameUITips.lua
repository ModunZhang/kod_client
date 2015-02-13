--
-- Author: Danny He
-- Date: 2015-02-10 14:30:55
--
--
local GameUITips = UIKit:createUIClass("GameUITips")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UICanCanelCheckBoxButtonGroup = import(".UICanCanelCheckBoxButtonGroup")
local UICheckBoxButton = import(".UICheckBoxButton")

function GameUITips:ctor(show_never_again)
	GameUITips.super.ctor(self)
	self.show_never_again = type(show_never_again) == 'boolean' and show_never_again or false
	self.never_show_again = false
end


function GameUITips:onEnter()
	GameUITips.super.onEnter(self)
	self:BuildUI()
end


function GameUITips:BuildUI()
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=762}):addTo(shadowLayer)
	bg:pos(((window.width - bg:getContentSize().width)/2),window.bottom_top)
	local titleBar = display.newSprite("alliance_blue_title_600x42.png"):align(display.LEFT_BOTTOM,3,747):addTo(bg)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	UIKit:ttfLabel({
		text = _("帮助"),
		size = 22,
		shadow = true,
		color = 0xffedae
	}):addTo(titleBar):align(display.CENTER,300,24)
	local list_bg = display.newScale9Sprite("box_bg_546x214.png"):size(568,636):addTo(bg):align(display.TOP_CENTER, 304, 732)
	self.info_list = UIListView.new({
        viewRect = cc.rect(11,10, 546, 616),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
	}):addTo(list_bg)
	WidgetPushButton.new({normal = 'yellow_btn_up_185x65.png',pressed = 'yellow_btn_down_185x65.png'})
		:setButtonLabel('normal', UIKit:commonButtonLable({
			text = _("我知道了!")
		}))
		:addTo(bg):pos(500,50)
		:onButtonClicked(function()
			self:leftButtonClicked()
		end)
	local checkbox_image = {
	        off = "checkbox_unselected.png",
	        off_pressed = "checkbox_unselected.png",
	        off_disabled = "checkbox_unselected.png",
	        on = "checkbox_selectd.png",
	        on_pressed = "checkbox_selectd.png",
	        on_disabled = "checkbox_selectd.png",

	}
	if self.show_never_again then
			UICanCanelCheckBoxButtonGroup.new()
		        :addButton(UICheckBoxButton.new(checkbox_image)
		            :setButtonLabel(UIKit:ttfLabel({text = _("不再显示"),size = 22,color = 0x514d3e}))
		            :setButtonLabelOffset(30, 0)
		            :align(display.LEFT_CENTER)
		            :onButtonClicked(function(event)
		            	local target = event.target
		            	self.never_show_again = target:isButtonSelected()
		            end)
		         )
		        :setIsSwitchModel(true)
		        :addTo(bg):pos(15,25)
	end
	self:RefreshListView()
end

function GameUITips:Tips()
	local tips = {
		{title = "1.建造住宅",image = 'dwelling_2_128x144.png',text = '建造和升级住宅能提升城民数量，生产资源的小屋需要占用城民',scale = 0.8},
		{title = "2.获取资源",image = 'quarrier_1_118x112.png',text = '建造和升级木工小屋，石匠小屋，旷工小屋，农夫小屋获得更多资源',scale = 0.9},
		{title = "3.升级主城堡",image = 'keep_1_420x390.png',text = '升级城堡能够提升建筑的等级上限，解锁更多的地块和新的建筑',scale = 0.25},
		{title = "4.招募部队",image = 'barracks_252x240.png',text = '在兵营招募部队，招募出的部队会持续消耗粮食，请务必保证自己的粮食产量充足',scale = 0.45},
		{title = "5.飞艇探索",image = 'airship.png',text = '使用飞艇，带领部队探索外域，获得资源还能增长巨龙等级，提升带兵总量',scale = 0.35},
		{title = "6.加入联盟",image = 'palace_421x481.png',text = '解锁联盟领地，参加联盟会战，并解锁更多新奇的玩法',scale = 0.25},
	}
	return tips
end

function GameUITips:RefreshListView()
	local data = self:Tips()
	for index,v in ipairs(data) do
		local item = self:GetItem(index,v.image,v.title,v.text,v.scale)
		self.info_list:addItem(item)
	end
	self.info_list:reload()
end

function GameUITips:GetItem(index,image,title,text,scale)
	local item = self.info_list:newItem()
	local content = display.newScale9Sprite(string.format("resource_item_bg%d.png",index % 2)):size(548,122)
	local image = display.newSprite(image):align(display.LEFT_CENTER, 10, 61):addTo(content):scale(scale)
	local title_label = UIKit:ttfLabel({
		text = title,
		color= 0x514d3e,
		size = 22
	}):align(display.LEFT_TOP,130,115):addTo(content)
	UIKit:ttfLabel({
		text = text,
		color= 0x797154,
		size = 20,
		dimensions = cc.size(410, 65)
	}):align(display.LEFT_TOP,130,title_label:getPositionY() - 30):addTo(content)

	item:addContent(content)
	item:setItemSize(548,122)
	return item
end

function GameUITips:leftButtonClicked()
	if self.never_show_again then
		--如果不再显示
	end
	GameUITips.super.leftButtonClicked(self)
end

return GameUITips