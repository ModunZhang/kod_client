--
-- Author: Danny He
-- Date: 2015-02-10 17:09:36
--
local GameUIActivity = UIKit:createUIClass("GameUIActivity","GameUIWithCommonHeader")
local window = import("..utils.window")
local UIScrollView = import(".UIScrollView")
local Enum = import("..utils.Enum")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
GameUIActivity.ITEMS_TYPE = Enum("EVERY_DAY_LOGIN","ONLINE","CONTINUITY","FIRST_IN_PURGURE")

local titles = {
	EVERY_DAY_LOGIN = _("每日登陆奖励"),
	ONLINE = _("在线奖励"),
	CONTINUITY = _("王城援军"),
	FIRST_IN_PURGURE = _("首次充值奖励"),
}

function GameUIActivity:ctor(city)
	GameUIActivity.super.ctor(self,city, _("活动"))
end

function GameUIActivity:onEnter()
	GameUIActivity.super.onEnter(self)

	local list,list_node = UIKit:commonListView({
        direction = UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0,0,576,772),
        bgColor = UIKit:hex2c4b(0x7a000000),
    })
    list_node:addTo(self):pos(window.left + 35,window.bottom_top + 20)
    self.list_view = list
	self.tab_buttons = self:CreateTabButtons(
        {
            {
                label = _("活动"),
                tag = "activity",
                default = true,
            },
            {
                label = _("奖励"),
                tag = "award",
            }
        },
        function(tag)

        end
    ):pos(window.cx, window.bottom + 34)
    self:RefreshListView()
end


function GameUIActivity:RefreshListView()
	self.list_view:removeAllItems()
	-- for i=1,10 do
		local item = self:GetItem(self.ITEMS_TYPE.EVERY_DAY_LOGIN)
		self.list_view:addItem(item)
	-- end
	self.list_view:reload()
end

function GameUIActivity:GetItem(item_type)
	local item = self.list_view:newItem()
	local content = WidgetUIBackGround.new({width = 576,height = 149},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
	local title_bg = display.newSprite("activity_title_552x42.png"):align(display.TOP_CENTER,288,144):addTo(content)
	local title_txt = titles[self.ITEMS_TYPE[item_type]]
	UIKit:ttfLabel({
		text = title_txt,
		size = 22,
		color= 0xfed36c
	}):align(display.CENTER,276, 21):addTo(title_bg)
	display.newSprite("activity_box_552x112.png"):align(display.CENTER_BOTTOM,288, 10):addTo(content,2)

	local icon_bg = display.newSprite("activity_icon_box_78x78.png"):align(display.LEFT_BOTTOM, 20, 20):addTo(content)
	display.newSprite("activity_icon_103x93.png", 39, 39):addTo(icon_bg)
	local sub_title = _("免费领取海量道具")
	if item_type == self.ITEMS_TYPE.ONLINE then
		sub_title = string.format(_("今日累计在线%s分钟"),5)
	elseif item_type == self.ITEMS_TYPE.CONTINUITY then
		sub_title = _("连续登陆，获得来自王城的援军")
	end
	local title_label = UIKit:ttfLabel({
		text = sub_title,
		size = 20,
		color= 0x403c2f
	}):align(display.LEFT_BOTTOM,115,67):addTo(content)

	local content_label  = UIKit:ttfLabel({
		text = "今日 已签到",
		size = 20,
		color= 0x403c2f
	}):align(display.LEFT_BOTTOM,115,31):addTo(content)
	content:size(576,149)
	item:addContent(content)
	item:setItemSize(576, 149)
	return item
end


return GameUIActivity