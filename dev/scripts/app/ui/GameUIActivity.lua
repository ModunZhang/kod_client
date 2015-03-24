--
-- Author: Danny He
-- Date: 2015-02-10 17:09:36
--
local GameUIActivity = UIKit:createUIClass("GameUIActivity","GameUIWithCommonHeader")
local window = import("..utils.window")
local UIScrollView = import(".UIScrollView")
local Enum = import("..utils.Enum")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIActivityReward = import(".GameUIActivityReward")
local config_online = GameDatas.Activities.online
local config_day14 = GameDatas.Activities.day14
local GameUtils = GameUtils
local RichText = import("..widget.RichText")
local config_intInit = GameDatas.PlayerInitData.intInit
GameUIActivity.ITEMS_TYPE = Enum("EVERY_DAY_LOGIN","ONLINE","CONTINUITY","FIRST_IN_PURGURE","PLAYER_LEVEL_UP")

local titles = {
	EVERY_DAY_LOGIN = _("每日登陆奖励"),
	ONLINE = _("在线奖励"),
	CONTINUITY = _("王城援军"),
	FIRST_IN_PURGURE = _("首次充值奖励"),
	PLAYER_LEVEL_UP = _("新手冲级奖励"),
}

function GameUIActivity:ctor(city)
	GameUIActivity.super.ctor(self,city, _("活动"))
	local countInfo = User:GetCountInfo()
	self.diff_time = (countInfo.todayOnLineTime - countInfo.lastLoginTime) / 1000
	self.player_level_up_time = countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 -- 单位秒
	self.player_level_up_time_residue = self.player_level_up_time - app.timer:GetServerTime() 
end

function GameUIActivity:onEnter()
	GameUIActivity.super.onEnter(self)

	local list,list_node = UIKit:commonListView({
        direction = UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0,0,576,772),
    })
    list_node:addTo(self):pos(window.left + 35,window.bottom_top + 20)
    self.list_view = list
    list:onTouch(handler(self, self.OnListViewTouch))
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
    User:AddListenOnType(self,User.LISTEN_TYPE.COUNT_INFO)
    app.timer:AddListener(self)
end

function GameUIActivity:OnTimer(current_time)
	if self.list_view then
		local item = self.list_view:getItems()[2]
		if not item then return end
		local time = math.floor((self.diff_time + current_time)/60)
		item.title_label:setString(string.format(_("今日累计在线:%s分钟"),time))
	end
	if current_time <= self.player_level_up_time and self.list_view then
		local item = self.list_view:getItems()[5]
		if not item or not item.time_label then return end
		self.player_level_up_time_residue = self.player_level_up_time - current_time
		if self.player_level_up_time_residue > 0 then
			item.time_label:setString(GameUtils:formatTimeStyle1(self.player_level_up_time_residue))
		else
			item.time_desc_label:hide()
			item.time_label:hide()
			item.state_label:show()
		end
	end
end

function GameUIActivity:onExit()
	app.timer:RemoveListener(self)
	User:RemoveListenerOnType(self,User.LISTEN_TYPE.COUNT_INFO)
	GameUIActivity.super.onExit(self)
end

function GameUIActivity:OnCountInfoChanged()
	self:RefreshListView()
end

function GameUIActivity:RefreshListView()
	self.list_view:removeAllItems()
	-- for i=1,10 do
		local item = self:GetItem(self.ITEMS_TYPE.EVERY_DAY_LOGIN)
		self.list_view:addItem(item)
		item = self:GetItem(self.ITEMS_TYPE.ONLINE)
		self.list_view:addItem(item)
		item = self:GetItem(self.ITEMS_TYPE.CONTINUITY)
		self.list_view:addItem(item)	
		item = self:GetItem(self.ITEMS_TYPE.FIRST_IN_PURGURE)
		self.list_view:addItem(item)	
		item = self:GetItem(self.ITEMS_TYPE.PLAYER_LEVEL_UP)
		self.list_view:addItem(item)
	-- end
	self.list_view:reload()
end

function GameUIActivity:GetItem(item_type)
	local countInfo = User:GetCountInfo()
	local item = self.list_view:newItem()
	item.item_type = item_type
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
	local next_y = item_type == self.ITEMS_TYPE.ONLINE and icon_bg:getPositionY() + 49 or icon_bg:getPositionY() + 39
	display.newSprite("activity_next_32x37.png", 540, next_y):addTo(content)
	display.newSprite("activity_icon_103x93.png", 39, 39):addTo(icon_bg)
	local sub_title = _("免费领取海量道具")
	if item_type == self.ITEMS_TYPE.ONLINE then
		sub_title = string.format(_("今日累计在线:%s分钟"),DataUtils:getPlayerOnlineTimeMinutes())
	elseif item_type == self.ITEMS_TYPE.PLAYER_LEVEL_UP then
		sub_title = _("活动时间类，升级智慧中心，获得丰厚奖励")
	elseif item_type == self.ITEMS_TYPE.CONTINUITY then
		sub_title = _("连续登陆，获得来自王城的援军")
	end
	local title_label
	if item_type ~= self.ITEMS_TYPE.FIRST_IN_PURGURE then
		title_label = UIKit:ttfLabel({
			text = sub_title,
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_BOTTOM,115,67):addTo(content)
	else
		title_label = RichText.new({width = 400,size = 20,color = 0x403c2f})
		local str = "[{\"type\":\"text\", \"value\":\"首次充值\"},{\"type\":\"text\",\"color\":0x489200,\"value\":\"任意\"},{\"type\":\"text\", \"value\":\"金额\"}]"
		title_label:Text(str):align(display.LEFT_BOTTOM,115,67):addTo(content)
	end
	if item_type == self.ITEMS_TYPE.EVERY_DAY_LOGIN then
		local desc_text = countInfo.day60 > countInfo.day60RewardsCount and _("今日未签到") or _("今日已签到")
		local content_label = UIKit:ttfLabel({
			text = desc_text,
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_BOTTOM,115,31):addTo(content)
	elseif item_type == self.ITEMS_TYPE.ONLINE then
		local time_point_data = self:GetOnLineTimePointData()
		local x = 115
		for __,v in ipairs(time_point_data) do
			local text,isSelected = unpack(v)
			local check_state = self:GetOnLineCheckSprite(text,isSelected)
			check_state:align(display.LEFT_BOTTOM,x,15):addTo(content)
			x = x + 105
		end
	elseif item_type == self.ITEMS_TYPE.FIRST_IN_PURGURE then
		local content_label = UIKit:ttfLabel({
			text = _("永久获得第二条建筑队列"),
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_BOTTOM,115,31):addTo(content)
	elseif item_type == self.ITEMS_TYPE.CONTINUITY then
		local day_bg = display.newSprite("activity_online_bg_104x34.png"):align(display.LEFT_BOTTOM,115,15):addTo(content)
		UIKit:ttfLabel({
			text = countInfo.day14 .. "/" .. #config_day14 .. _("天"),
			size = 20,
			color= 0x403c2f
		}):align(display.CENTER, 52, 17):addTo(day_bg)
		local desc_text = countInfo.day14 > countInfo.day14RewardsCount and _("今日未领取") or _("今日已领取")
		UIKit:ttfLabel({
			text = desc_text,
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_CENTER,239,32):addTo(content)
	elseif item_type == self.ITEMS_TYPE.PLAYER_LEVEL_UP then
		local time_desc_label = UIKit:ttfLabel({
			text = _("倒计时:"),
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_BOTTOM,115,31):addTo(content)
		local time_label = UIKit:ttfLabel({
			text = GameUtils:formatTimeStyle1(self.player_level_up_time_residue),
			size = 20,
			color= 0x489200
		}):align(display.LEFT_BOTTOM,115 + time_desc_label:getContentSize().width + 10,31):addTo(content)
		local state_label = UIKit:ttfLabel({
			text = _("已失效"),
			size = 20,
			color= 0x403c2f
		}):align(display.LEFT_BOTTOM,115,31):addTo(content)

		item.time_desc_label = time_desc_label
		item.time_label = time_label	
		item.state_label = state_label	
		if self.player_level_up_time_residue > 0 then
			state_label:hide()
		else
			time_desc_label:hide()
			time_label:hide()
		end
	end
	item.title_label = title_label
	content:size(576,149)
	item:addContent(content)
	item:setItemSize(576, 149)
	return item
end

function GameUIActivity:GetOnLineCheckSprite(text,checked)
	local bg = display.newSprite("activity_online_bg_104x34.png")
	local check_bg = display.newSprite("activity_check_bg_34x34.png"):align(display.RIGHT_CENTER,100,17):addTo(bg)
	bg.ck_body = display.newSprite("activity_check_body_34x34.png"):addTo(check_bg):pos(17,17)
	bg.ck_body:setVisible(checked)
	UIKit:ttfLabel({
		text = text,
		size = 18,
		color= 0x514d3e
	}):align(display.LEFT_CENTER, 2, 17):addTo(bg)
	return bg
end

function GameUIActivity:OnListViewTouch(event)
	if event.name == "clicked" and event.item then
		self:OnSelectAtItem(event.item.item_type)
	end
end

function GameUIActivity:OnSelectAtItem(item_type)
	UIKit:newGameUI("GameUIActivityReward",GameUIActivityReward.REWARD_TYPE[self.ITEMS_TYPE[item_type]]):AddToCurrentScene(true)
end

function GameUIActivity:GetOnLineTimePointData()
	local r = {}
	local max_point = self:GetMaxOnLineTimePointRewards()
	for __,v in ipairs(config_online) do
		table.insert(r,{string.format(_("%s分钟"),v.onLineMinutes),v.timePoint <= max_point})
	end
	return r
end

function GameUIActivity:GetMaxOnLineTimePointRewards()
	local countInfo = User:GetCountInfo()
	local maxPoint = 0
	for __,v in ipairs(countInfo.todayOnLineTimeRewards) do
		if v > maxPoint then
			maxPoint = v
		end
	end
	return maxPoint 
end

return GameUIActivity