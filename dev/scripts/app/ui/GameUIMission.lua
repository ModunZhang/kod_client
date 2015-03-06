--
-- Author: Danny He
-- Date: 2015-03-05 16:11:11
--
local UIKit = UIKit
local GameUIMission = UIKit:createUIClass("GameUIMission","GameUIWithCommonHeader")
local WidgetBackGroundTabButtons = import('..widget.WidgetBackGroundTabButtons')
local window = import("..utils.window")
local Enum = import("..utils.Enum")
local scheduler = import(cc.PACKAGE_NAME .. ".scheduler")
local UIScrollView = import(".UIScrollView")
local WidgetPushButton = import("..widget.WidgetPushButton")

GameUIMission.MISSION_TYPE = Enum("achievement","daily")

function GameUIMission:ctor(city,mission_type)
	GameUIMission.super.ctor(self,city, _("任务"))
	self.init_mission_type = mission_type or self.MISSION_TYPE.achievement
end

function GameUIMission:onEnter()
	GameUIMission.super.onEnter(self)
	self:CreateTabButtons()
end

function GameUIMission:onExit()
	GameUIMission.super.onExit(self)
	if self.___handle___ then
		scheduler.unscheduleGlobal(self.___handle___)
	end
end

function GameUIMission:CreateTabButtons()
	local tab_buttons = WidgetBackGroundTabButtons.new({
        {
            label = _("成就任务"),
            tag = "achievement",
            default = self.init_mission_type == self.MISSION_TYPE.achievement,
        },
        {
            label = _("日常任务"),
            tag = "daily",
            default = self.init_mission_type == self.MISSION_TYPE.daily,
        }
    },
    function(tag)
       self:OnTabButtonClicked(tag)
    end):addTo(self):pos(window.cx, window.bottom + 34)
end

function GameUIMission:OnTabButtonClicked(tag)
	if self.current_ui then
		self.current_ui:hide()
	end
	if self['CreateUIIf_' .. tag] then
		self.current_ui = self['CreateUIIf_' .. tag](self)
		self.current_ui:show()
		self.current_mission_type = self.MISSION_TYPE[tag]
	end
end

function GameUIMission:CurrentIsDailyMission()
	return self.current_mission_type == self.MISSION_TYPE.daily
end
--成就任务
----------------------------------------------------------------------
function GameUIMission:CreateUIIf_achievement()
	if self.achievement_layer then
		--refresh list and recommend mission
		self:RefreshRecommendMissionDesc()
		self:RefreshAchievementList()
		return self.achievement_layer
	end
	local layer = self:GetCommentBgNode():addTo(self.main_ui)
	self.achievement_layer = layer 
	local header_bg = display.newSprite("mission_header_bg_616x184.jpg")
		:align(display.LEFT_TOP, 0, layer:getContentSize().height)
		:addTo(layer)
	header_bg:setTouchEnabled(true)
	header_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        local p = header_bg:convertToNodeSpace(cc.p(event.x, event.y))
        if cc.rectContainsPoint(cc.rect(0,0,172,184),p) then 
        	self:OnRecommendMissionClicked()
        end
        return false
    end)
	self.info_icon = display.newSprite("mission_i_38x42.png")
		:align(display.LEFT_BOTTOM, 10, 128)
		:addTo(header_bg)
	local recommend_contet_bg = display.newSprite("recommend_misson_bg_438x158.png")
		:align(display.LEFT_BOTTOM, 176,12)
		:addTo(header_bg)
	UIKit:ttfLabel({
		text = _("赛琳娜:"),
		size = 24,
		color= 0x403c2f
	}):align(display.LEFT_BOTTOM, 28, 112):addTo(recommend_contet_bg)
	UIKit:ttfLabel({
		text = _("大人,我们现在应该:"),
		size = 20,
		color= 0x403c2f
	}):align(display.LEFT_BOTTOM, 28, 82):addTo(recommend_contet_bg)
	self.recommend_desc_label = UIKit:ttfLabel({
		text = self:GetRecommendMissionDesc(),
		size = 24,
		color= 0x403c2f
	}):align(display.LEFT_BOTTOM, 34, 28):addTo(recommend_contet_bg)
	display.newSprite("mission_header_line_620x56.png")
		:align(display.CENTER_TOP, 308, 14)
		:addTo(header_bg)
	local list,list_node = UIKit:commonListView({
		viewRect = cc.rect(0, 0,558,584),
        direction = UIScrollView.DIRECTION_VERTICAL,
	})
	list:onTouch(handler(self, self.listviewListener))
	self.achievement_list = list
	list_node:addTo(layer):pos((layer:getContentSize().width - 558)/2,14)
	self:SchedulerInfo()
	self:RefreshAchievementList()
	return self.achievement_layer
end

function GameUIMission:GetCommentBgNode()
	local layer = display.newNode():pos(window.left + 12,window.bottom_top + 5)
	layer:size(window.width - 24,window.betweenHeaderAndTab + 15)
	return layer
end

function GameUIMission:CreateBetweenBgAndTitle()
	GameUIMission.super.CreateBetweenBgAndTitle(self)
	local layer = display.newNode():pos(0,0):addTo(self)
	layer:size(window.width,window.height)
	self.main_ui = layer
end

function GameUIMission:SchedulerInfo()
	self:ShakeInfoIcon()
	self.___handle___ = scheduler.scheduleGlobal(handler(self, self.ShakeInfoIcon),5)
end

function GameUIMission:ShakeInfoIcon()
	local action = self:GetShakeAction()
	self.info_icon:runAction(action)
end

function GameUIMission:GetShakeAction()
	local t = 0.025
    local r = 5
	local action = transition.sequence({
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
    })
    return action
end
function GameUIMission:RefreshAchievementList()
	self.achievement_list:removeAllItems()
	local header = self:GetGetAchievementListHeaderItem(true)
	self.achievement_list:addItem(header)
	local finished_mission = self:GetAchievementMissionData(true)
	for __,v in ipairs(finished_mission) do
		local item = self:GetAchievementListItem(true,v)
		self.achievement_list:addItem(item)
	end
	header = self:GetGetAchievementListHeaderItem(false)
	self.achievement_list:addItem(header)
	local todo_mission = self:GetAchievementMissionData(false)
	for __,v in ipairs(todo_mission) do
		local item = self:GetAchievementListItem(false,v)
		self.achievement_list:addItem(item)
	end
	self.achievement_list:reload()
end

function GameUIMission:GetAchievementListItem(isFinished,data)
	local item = self.achievement_list:newItem()
	local content = UIKit:CreateBoxWithoutContent()
	UIKit:ttfLabel({
		text = data,
		size = 22,
		color= 0x403c2f
	}):align(display.LEFT_CENTER, 5, 33):addTo(content)
	if not isFinished then
		display.newSprite("activity_next_32x37.png"):align(display.RIGHT_CENTER, 548, 33):addTo(content)
	else
		local button = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
			:align(display.RIGHT_CENTER, 552, 33)
			:addTo(content)
			:setButtonLabel("normal", UIKit:commonButtonLable({
				text = _("领取")
			}))
			:onButtonClicked(function()
				self:OnGetAchievementRewardButtonClicked(data)
			end)
	end
	item:addContent(content)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 5})
	item:setItemSize(558,66,false)
	return item
end

function GameUIMission:GetGetAchievementListHeaderItem(isFinished)
	local item = self.achievement_list:newItem()
	local content = display.newSprite(isFinished and "title_green_558x34.png" or "title_blue_558x34.png")
	UIKit:ttfLabel({
		text = isFinished and _("已完成任务") or _("成就任务"),
		size = 22,
		color= 0xffedae
	}):align(display.CENTER, 279, 17):addTo(content)
	item:addContent(content)
	item:setMargin({left = 0, right = 0, top = 5, bottom = 10})
	item:setItemSize(558, 34,false)
	return item
end

function GameUIMission:listviewListener(event)
    local listView = event.listView
    if "clicked" == event.name then
    	local pos = event.itemPos
    	--这里减掉两个标题item
    	local really_pos = pos - 2 - #self:GetAchievementMissionData(true)
    	if really_pos > 0 then
    		local data = self:GetAchievementMissionData(false)[really_pos]
    		self:OnTodoAchievementMissionClicked(data)
    	end
    end
end

function GameUIMission:RefreshRecommendMissionDesc()
	if self.recommend_desc_label then
		self.recommend_desc_label:setString(self:GetRecommendMissionDesc())
	end 
end

-- TODO:
function GameUIMission:GetRecommendMissionDesc()
	return "将城堡升级到 LV 2"
end

function GameUIMission:GetAchievementMissionData(isFinish)
	isFinish = type(isFinish) == 'boolean' and isFinish or false
	if isFinish then
		return {
			"将城堡升级到 LV 2","将城堡升级到 LV 2","将城堡升级到 LV 2"
		}
	else
		return {"城市建设(20%)","城市建设(20%)"}
	end
end

function GameUIMission:OnGetAchievementRewardButtonClicked(data)
	dump(data)
end

function GameUIMission:OnTodoAchievementMissionClicked(data)
	dump(data)
end

function GameUIMission:OnRecommendMissionClicked()
	print("OnRecommendMissionClicked--->")
end

--日常任务
----------------------------------------------------------------------
return GameUIMission