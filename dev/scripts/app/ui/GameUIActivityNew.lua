--
-- Author: Danny He
-- Date: 2015-05-12 10:52:45
--
local GameUIActivityNew = UIKit:createUIClass("GameUIActivityNew","GameUIWithCommonHeader")
local GameUtils = GameUtils
local UILib = import(".UILib")
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local RichText = import("..widget.RichText")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local User = User
local config_day14 = GameDatas.Activities.day14
local config_intInit = GameDatas.PlayerInitData.intInit
local GameUIActivityRewardNew = import(".GameUIActivityRewardNew")

GameUIActivityNew.ITEMS_TYPE = Enum("EVERY_DAY_LOGIN","ONLINE","CONTINUITY","FIRST_IN_PURGURE","PLAYER_LEVEL_UP")

local titles = {
	EVERY_DAY_LOGIN = _("每日登陆奖励"),
	CONTINUITY = _("王城援军"),
	FIRST_IN_PURGURE = _("首次充值奖励"),
	PLAYER_LEVEL_UP = _("新手冲级奖励"),
}

function GameUIActivityNew:ctor(city)
	GameUIActivityNew.super.ctor(self,city, _("活动"))
	local countInfo = User:GetCountInfo()
	self.player_level_up_time = countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60 -- 单位秒
	app.timer:AddListener(self)
end


function GameUIActivityNew:onCleanup()
	app.timer:RemoveListener(self)
	User:RemoveListenerOnType(self,User.LISTEN_TYPE.COUNT_INFO)
	GameUIActivityNew.super.onCleanup(self)
end

function GameUIActivityNew:OnMoveInStage()
	GameUIActivityNew.super.OnMoveInStage(self)
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
        	self:OnTabButtonClicked(tag)
        end
    ):pos(window.cx, window.bottom + 34)
end


function GameUIActivityNew:OnTabButtonClicked(tag)
	local method_name = "CreateTabIf_" .. tag
	if self[method_name] then
		if self.current_content then self.current_content:hide() end
		self.current_content = self[method_name](self)
		self.current_content:show()
	end
end

function GameUIActivityNew:CreateTabIf_activity()
	self.player_level_up_time_residue = self.player_level_up_time - app.timer:GetServerTime()
	if not self.activity_list_view then
		local list = UIListView.new({
	        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
	        viewRect = cc.rect(window.left + 35,window.bottom_top + 20,576,772),
	    }):addTo(self:GetView())
	    list:onTouch(handler(self, self.OnActivityListViewTouch))
	    self.activity_list_view = list
	    self:RefreshActivityListView()
	    User:AddListenOnType(self,User.LISTEN_TYPE.COUNT_INFO)
	end
	self:RefreshActivityListView()
	return self.activity_list_view
end

function GameUIActivityNew:RefreshActivityListView()
	self.activity_list_view:removeAllItems()
	local countInfo = User:GetCountInfo()
	local item = self:GetActivityItem(self.ITEMS_TYPE.EVERY_DAY_LOGIN)
	self.activity_list_view:addItem(item)
	--
	if countInfo.day14RewardsCount < #config_day14 then
		item = self:GetActivityItem(self.ITEMS_TYPE.CONTINUITY)
		self.activity_list_view:addItem(item)	
	end
	if not countInfo.isFirstIAPRewardsGeted then
		item = self:GetActivityItem(self.ITEMS_TYPE.FIRST_IN_PURGURE)
		self.activity_list_view:addItem(item)	
	end
	--TODO:
	item = self:GetActivityItem(self.ITEMS_TYPE.PLAYER_LEVEL_UP)
	self.activity_list_view:addItem(item)
	self.activity_list_view:reload()
end

function GameUIActivityNew:OnCountInfoChanged()
	self:RefreshActivityListView()
end

function GameUIActivityNew:OnTimer(current_time)
	if self.activity_list_view and self.tab_buttons:GetSelectedButtonTag() == 'activity' then
		local item = self.activity_list_view:getItems()[4]
		if current_time <= self.player_level_up_time and item then
			if not item.time_label then return end
			self.player_level_up_time_residue = self.player_level_up_time - current_time
			if self.player_level_up_time_residue > 0 then
				item.time_label:setString(GameUtils:formatTimeStyle1(self.player_level_up_time_residue))
			else
				self.activity_list_view:removeItem(item)
			end
		end
	end
end

function GameUIActivityNew:OnActivityListViewTouch(event)
	if event.name == "clicked" and event.item then
		self:OnSelectActivityAtItem(event.item.item_type)
	end
end

function GameUIActivityNew:OnSelectActivityAtItem(item_type)
	UIKit:newGameUI("GameUIActivityRewardNew",GameUIActivityRewardNew.REWARD_TYPE[self.ITEMS_TYPE[item_type]]):AddToCurrentScene(true)
end

function GameUIActivityNew:GetFirstPurgureTips()
	local str = _("首次充值%s金额")
	local s,e = string.find(str,"%%s")
	return string.format("[{\"type\":\"text\", \"value\":\"%s\"},{\"type\":\"text\",\"color\":0x489200,\"size\":22,\"value\":\"%s\"},{\"type\":\"text\", \"value\":\"%s\"}]",
		string.sub(str,1,s - 1),_("任意"),string.sub(str,e+1))
end

function GameUIActivityNew:GetActivityItem(item_type)
	local countInfo = User:GetCountInfo()
	local item = self.activity_list_view:newItem()
	item.item_type = item_type
	local bg = WidgetUIBackGround.new({width = 576,height = 190},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
	local title_bg = display.newSprite("activity_title_552x36.png"):align(display.TOP_CENTER,288,180):addTo(bg)
	local title_txt = titles[self.ITEMS_TYPE[item_type]]
	UIKit:ttfLabel({
		text = title_txt,
		size = 22,
		color= 0xfed36c
	}):align(display.CENTER,276, 21):addTo(title_bg)
	local content = display.newSprite(UILib.activity_image_config[self.ITEMS_TYPE[item_type]]):align(display.CENTER_TOP,288, 144):addTo(bg)
	if item_type ~= self.ITEMS_TYPE.EVERY_DAY_LOGIN then
		local size = content:getContentSize()
		content:scale(550/math.max(size.width,size.height))
	end
	display.newSprite("activity_box_552x130.png"):align(display.CENTER_TOP,288, 144):addTo(bg)
	display.newSprite("activity_next_32x37.png"):align(display.LEFT_CENTER, 528, 80):addTo(bg)

	if item_type == self.ITEMS_TYPE.EVERY_DAY_LOGIN then
		local title_label = UIKit:ttfLabel({
			text = _("免费领取海量道具"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_BOTTOM,310,80):addTo(bg)
		local content_label = UIKit:ttfLabel({
			text = countInfo.day60 > countInfo.day60RewardsCount and _("今日未签到") or _("今日已签到"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_BOTTOM,310,42):addTo(bg)
	elseif item_type == self.ITEMS_TYPE.CONTINUITY then
		local title_label = UIKit:ttfLabel({
			text = _("连续登陆，获得来自王城的援军"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_BOTTOM,214,90):addTo(bg)

		local day_bg = display.newSprite("activity_day_bg_104x34.png"):align(display.LEFT_BOTTOM,214,45):addTo(bg)
		UIKit:ttfLabel({
			text = string.format(_("%d/%d天"),countInfo.day14,#config_day14),
			size = 18,
			color= 0xffedae,
			shadow= true,
			align = cc.TEXT_ALIGNMENT_CENTER,
		}):addTo(day_bg):align(display.CENTER, 52, 17)
		local content_label = UIKit:ttfLabel({
			text = countInfo.day14 > countInfo.day14RewardsCount and _("今日未领取") or _("今日已领取"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_CENTER,330,62):addTo(bg)
	elseif item_type == self.ITEMS_TYPE.FIRST_IN_PURGURE then
		local title_label = RichText.new({width = 400,size = 20,color = 0xffedae,shadow = true})
		local str = self:GetFirstPurgureTips()
		title_label:Text(str):align(display.LEFT_BOTTOM,262,82):addTo(bg)
		-- 
		local content_label = UIKit:ttfLabel({
			text = _("永久获得第二条建筑队列"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_CENTER,262,62):addTo(bg)
	elseif item_type == self.ITEMS_TYPE.PLAYER_LEVEL_UP then
		local title_label = UIKit:ttfLabel({
			text = _("活动时间类，升级智慧中心，获得丰厚奖励"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true,
			dimensions = cc.size(272, 0)
		}):align(display.LEFT_TOP,260,126):addTo(bg)

		local time_desc_label = UIKit:ttfLabel({
			text = _("倒计时:"),
			size = 20,
			color= 0xffedae,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_BOTTOM,260,40):addTo(bg)
		local time_label = UIKit:ttfLabel({
			text = GameUtils:formatTimeStyle1(self.player_level_up_time_residue),
			size = 20,
			color= 0x489200,
			align = cc.TEXT_ALIGNMENT_LEFT,
			shadow= true
		}):align(display.LEFT_BOTTOM,260 + time_desc_label:getContentSize().width + 10,40):addTo(bg)
		item.time_label = time_label
	end
	bg:size(576,190)
	item:addContent(bg)
	item:setItemSize(576, 190)
	return item
end

return GameUIActivityNew