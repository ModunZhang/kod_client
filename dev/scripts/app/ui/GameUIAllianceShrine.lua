--
-- Author: Danny He
-- Date: 2014-11-08 15:13:13
--
local GameUIAllianceShrine = UIKit:createUIClass("GameUIAllianceShrine","GameUIWithCommonHeader")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local StarBar = import(".StarBar")
local UIListView = import(".UIListView")
local AllianceShrine = import("..entity.AllianceShrine")

function GameUIAllianceShrine:ctor()
	GameUIAllianceShrine.super.ctor(self,City,_("联盟圣地"))
	self.my_alliance = Alliance_Manager:GetMyAlliance()
	self.allianceShrine = self.my_alliance:GetAllianceShrine()
	self:GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnPerceotionChanged)
	assert(self.allianceShrine)
end

function GameUIAllianceShrine:OnPerceotionChanged()
	local tag = self.tab_buttons:GetSelectedButtonTag()
	if tag ~= "stage" then return end
	local resource = self:GetAllianceShrine():GetPerceptionResource()
	local display_str = string.format(_("感知力:%s"),resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()) .. "/" .. resource:GetValueLimit())
	if self.stage_ui.insight_label:getString() ~= display_str then
		self.stage_ui.insight_label:setString(display_str)
	end
end

function GameUIAllianceShrine:onMoveOutStage()
	self:GetAllianceShrine():RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnPerceotionChanged)
	GameUIAllianceShrine.super.onMoveOutStage(self)
end

function GameUIAllianceShrine:onEnter()
	GameUIAllianceShrine.super.onEnter(self)
	self.tab_buttons = self:CreateTabButtons(
		{
			{
				label = _("升级"),
	        	tag = "upgrade",
	        	default = true,
	        },
	        {
	        	label = _("联盟危机"),
	        	tag = "stage",
	    	},
	    	{
	        	label = _("战斗事件"),
	        	tag = "fight_event",
	    	},
	    	{
	        	label = _("事件记录"),
	        	tag = "events_history",
	    	},
	    },
		function(tag)
			--call common tabButtons event
			if self["TabEvent_" .. tag] then
				if self.currentContent then
					self.currentContent:hide()
				end
				self.currentContent = self["TabEvent_" .. tag](self)
				assert(self.currentContent)
				self.currentContent:show()
				self:RefreshUI()
			end
		end
	):pos(window.cx, window.bottom + 34)
end

function GameUIAllianceShrine:CreateBetweenBgAndTitle()
	self.main_content = display.newNode():addTo(self):pos(window.left,window.bottom+68)
	self.main_content:setContentSize(cc.size(window.width,window.betweenHeaderAndTab))
end


function GameUIAllianceShrine:RefreshUI()
	local tag = self.tab_buttons:GetSelectedButtonTag()
	if tag == 'stage' then
		self:RefreshStageListView()
	end
end

function GameUIAllianceShrine:GetAllianceShrine()
	return self.allianceShrine
end

function GameUIAllianceShrine:GetStagePage()
	return self.state_page_ or 1
end

function GameUIAllianceShrine:SetStagePage(num)
	self.state_page_ = num
end

function GameUIAllianceShrine:ChangeStagePage(offset)
	local targetPage = self:GetStagePage() + offset 
	if targetPage  > self:GetAllianceShrine():MaxCountOfStage() then
		return
	elseif  targetPage < 1 then
		return
	end
	self:SetStagePage(targetPage)
	self.stage_ui.stage_label:setString(self:GetAllianceShrine():GetMainStageDescName(self:GetStagePage()))
	self:RefreshUI()
end

function GameUIAllianceShrine:TabEvent_stage()
	if self.stage_node then return self.stage_node end
	self:SetStagePage(1)
	self.stage_ui = {}
	local stage_node = display.newNode()
	local insight_bg = display.newScale9Sprite("back_ground_43x43.png")
		:size(44,44):addTo(stage_node)
		:align(display.LEFT_BOTTOM, 40, 20)
	display.newScale9Sprite("insight_icon_45x45.png")
		:size(36,38)
		:addTo(insight_bg,2)
		:align(display.CENTER,22,22)
	local bar_bg = display.newScale9Sprite("insight_bar_bg_530x36.png")
		:align(display.LEFT_BOTTOM,insight_bg:getPositionX()+insight_bg:getContentSize().width-10,insight_bg:getPositionY()+4)
		:addTo(stage_node,-1)
	local progressBar = UIKit:commonProgressTimer("insight_bar_content_530x36.png"):align(display.LEFT_BOTTOM,0,1):addTo(bar_bg,2)
	progressBar:setPercentage(100)
	local resource = self:GetAllianceShrine():GetPerceptionResource()
	local display_str = string.format(_("感知力:%s"),resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()) .. "/" .. resource:GetValueLimit())
	local insight_label = UIKit:ttfLabel({
		text = display_str,
		size = 20,
		color = 0xfff3c7
	}):align(display.LEFT_BOTTOM,15,5):addTo(bar_bg,2)
	self.stage_ui.insight_label = insight_label
	--title

	local title_bg = display.newSprite("shire_stage_title_564x58.png")
		:align(display.LEFT_TOP,40,window.betweenHeaderAndTab - 5)
		:addTo(stage_node)

	local left_button = WidgetPushButton.new(
			{normal = "shrine_page_btn_normal_52x44.png",pressed = "shrine_page_btn_light_52x44.png"},
			{scale9 = false},
			{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}}
		):addTo(title_bg):align(display.LEFT_CENTER,7,29)
		:onButtonClicked(function()
			self:ChangeStagePage(-1)
		end)
	local icon = display.newSprite("shrine_page_control_26x34.png")
	icon:setFlippedX(true)
	icon:addTo(left_button):pos(26,0)


	local right_button = WidgetPushButton.new(
			{normal = "shrine_page_btn_normal_52x44.png",pressed = "shrine_page_btn_light_52x44.png"},
			{scale9 = false},
			{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}}
		):addTo(title_bg):align(display.RIGHT_CENTER,557,29)
		:onButtonClicked(function()
			self:ChangeStagePage(1)
		end)
	display.newSprite("shrine_page_control_26x34.png")
		:addTo(right_button)
		:pos(-26,0)

	local stage_label = UIKit:ttfLabel({
		text = self:GetAllianceShrine():GetMainStageDescName(self:GetStagePage()),
		size = 20,
		color = 0x5d563f
		})
		:align(display.LEFT_BOTTOM,70,15)
		:addTo(title_bg)
	self.stage_ui.stage_label = stage_label
	local star_bar = StarBar.new({
       		max = 1,
       		bg = "Stars_bar_bg.png",
       		fill = "Stars_bar_highlight.png", 
       		num = 1,
       		-- scale = 0.8,
    }):addTo(title_bg):align(display.RIGHT_BOTTOM,430,13)
    local percentLabel = UIKit:ttfLabel({
    	color = 0x5d563f,
    	size = 20,
    	text = "10/15"
    }):align(display.LEFT_BOTTOM,431,15):addTo(title_bg)
    self.stage_list = UIListView.new({
    	viewRect = cc.rect(20,74,600,650),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }):addTo(stage_node)
	self.stage_node = stage_node
	self.stage_node:addTo(self.main_content)
	return self.stage_node
end

function GameUIAllianceShrine:GetStageListItem(stage_obj)
	local bg = display.newScale9Sprite("back_ground_608x227.png"):size(600,210)
	local top = display.newSprite("shrie_state_item_line_606_16.png"):align(display.LEFT_TOP,-5,209):addTo(bg,2)
	local bottom = display.newSprite("shrie_state_item_line_606_16.png")
	bottom:setFlippedY(true)
	bottom:align(display.LEFT_BOTTOM,-5,5):addTo(bg,2)
	local title_bg = display.newScale9Sprite("title_red_588X30.png")
		:size(568,30)
		:align(display.LEFT_TOP,20,top:getPositionY() - top:getContentSize().height)
		:addTo(bg,2)

	UIKit:ttfLabel({
		text = stage_obj:GetDescStageName(),
		size = 22,
		color = 0xffedae
		})
		:align(display.LEFT_CENTER, 10, 15)
		:addTo(title_bg,2)

	local star_bar = StarBar.new({
       		max = 3,
       		bg = "Stars_bar_bg.png",
       		fill = "Stars_bar_highlight.png", 
       		num = stage_obj:Star(),
    }):addTo(title_bg,2):align(display.RIGHT_CENTER,540,15)

	local content_box = UIKit:CreateBoxPanel(137):addTo(bg,2):pos(20,bottom:getPositionY()+bottom:getContentSize().height)
	local soldier_bg = display.newSprite("soldier_bg_118x132.png")
		:addTo(content_box):align(display.LEFT_BOTTOM,5, 2)
	display.newSprite("soldier_swordsman_1.png"):addTo(soldier_bg):pos(59,66):scale(0.6)
	local power_bg = display.newSprite("shrie_power_bg_146x26.png")
		:addTo(content_box)
		:align(display.LEFT_BOTTOM,soldier_bg:getPositionX()+soldier_bg:getContentSize().width+25, soldier_bg:getPositionY()+10)
	display.newSprite("dragon_strength_27x31.png")
		:align(display.LEFT_CENTER,-10,13)
		:addTo(power_bg)
	UIKit:ttfLabel({
		text = string.formatnumberthousands(stage_obj:EnemyPower()),
		size = 20,
		color = 0xfff3c7
	}):align(display.LEFT_CENTER,15,13):addTo(power_bg)
	if not stage_obj:IsLocked() then
		cc.ui.UIPushButton.new({
			normal = "blue_btn_up_142x39.png",
			pressed = "blue_btn_down_142x39.png"
			})
			:setButtonLabel("normal",UIKit:commonButtonLable({
				text = _("调查"),
				size = 20,
				color = 0xfff3c7
			}))
			:onButtonClicked(function(event)
				self:OnResearchButtonClick(stage_obj)
			end)
			:align(display.RIGHT_BOTTOM,540,10)
			:addTo(content_box)
	else
		UIKit:ttfLabel({
			text = _("未解锁"),
			size = 20,
			color = 0x403c2f,
		})
		:align(display.RIGHT_BOTTOM,540,10)
			:addTo(content_box)
	end
	UIKit:ttfLabel({
		text = stage_obj:GetStageDesc(),
		size = 18,
		color = 0x797154,
		dimensions = cc.size(400,72)
	}):align(display.LEFT_TOP,power_bg:getPositionX(),soldier_bg:getPositionY()+soldier_bg:getContentSize().height - 10)
	:addTo(content_box)
	return bg
end

function GameUIAllianceShrine:RefreshStageListView()
	self.stage_list:removeAllItems()
	for i,stage_obj in ipairs(self:GetAllianceShrine():GetSubStagesByMainStage(self:GetStagePage())) do
		local item = self.stage_list:newItem()
		item:addContent(self:GetStageListItem(stage_obj))
		item:setItemSize(600,210)
		self.stage_list:addItem(item)
	end
	self.stage_list:reload()
end

function GameUIAllianceShrine:OnResearchButtonClick(stage_obj)
	UIKit:newGameUI("GameUIAllianceShrineDetail",stage_obj,self:GetAllianceShrine()):addToCurrentScene(true)
end

return GameUIAllianceShrine