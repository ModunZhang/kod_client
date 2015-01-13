--
-- Author: Danny He
-- Date: 2015-01-13 10:22:48
--
local GameUIWatchTowerTroopDetail = UIKit:createUIClass("GameUIWatchTowerTroopDetail")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local Enum = import("..utils.Enum")
GameUIWatchTowerTroopDetail.ITEM_TYPE = Enum("DRAGON_INFO","DRAGON_EQUIPMENT","DRAGON_SKILL","SOLIDERS")
GameUIWatchTowerTroopDetail.DATA_TYPE = Enum("MARCH","HELP_DEFENCE","STRIKE")
function GameUIWatchTowerTroopDetail:ctor(belvedere,data,data_type)
	GameUIWatchTowerTroopDetail.super.ctor(self)
	self.belvedere = belvedere
	self.event_data = data
	self.data_type = data_type
end

function GameUIWatchTowerTroopDetail:GetBelvedere()
	return self.belvedere
end

function GameUIWatchTowerTroopDetail:GetDataType()
	return self.data_type
end

function GameUIWatchTowerTroopDetail:GetEventData()
	return self.event_data
end


function GameUIWatchTowerTroopDetail:onEnter()
	GameUIWatchTowerTroopDetail.super.onEnter(self)
	UIKit:shadowLayer():addTo(self)
	self.backgroundImage = WidgetUIBackGround.new({height=824}):addTo(self)
	self.backgroundImage:pos((display.width - self.backgroundImage:getContentSize().width)/2,window.bottom_top)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(self.backgroundImage)
		:align(display.CENTER_BOTTOM, 304, 810)
	UIKit:closeButton():addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	self.title_label = UIKit:ttfLabel({
		text = _("部队详情"),
		size = 24,
		color = 0xffedae,
	}):align(display.CENTER,title_bar:getContentSize().width/2, title_bar:getContentSize().height/2)
		:addTo(title_bar)

	local listBg = display.newScale9Sprite("alliance_title_list_572x436.png")
		:size(568,754)
		:align(display.CENTER_BOTTOM, self.backgroundImage:getContentSize().width/2, 30)
		:addTo(self.backgroundImage)

	self.listView = UIListView.new {
    	viewRect = cc.rect(10, 12, 548,730),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(listBg)
    self:RefreshListView()
end


function GameUIWatchTowerTroopDetail:RefreshListView()
	dump(self:GetEventData(),"GetEventData--->")
	self.listView:removeAllItems()
	for i = 1,4 do
		local item = self:GetItem()
		self.listView:addItem(item)
	end
	self.listView:reload()
end

function GameUIWatchTowerTroopDetail:GetItem(ITEM_TYPE,data)
	local subline_count = 3
	local item = self.listView:newItem()
	local height = 36 * subline_count
	local bg = display.newScale9Sprite("transparent_1x1.png"):size(548,height + 38)
	display.newSprite("alliance_member_title_548x38.png"):addTo(bg):align(display.LEFT_TOP, 0, height + 38)
	local y = 0
	for i = 1,subline_count do
		self:GetSubItem(ITEM_TYPE,i,nil):addTo(bg):align(display.LEFT_BOTTOM, 0, y)
		y = y + 36
	end
	item:addContent(bg)
	item:setItemSize(548,height + 38)
	return item
end


function GameUIWatchTowerTroopDetail:GetSubItem(ITEM_TYPE,index,item_data)
	local item = display.newScale9Sprite(string.format("resource_item_bg%d.png",(index - 1) % 2)):size(546,36 )
	return item
end

return GameUIWatchTowerTroopDetail