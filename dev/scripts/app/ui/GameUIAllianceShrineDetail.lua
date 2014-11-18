--
-- Author: Danny He
-- Date: 2014-11-11 11:39:41
--
local GameUIAllianceShrineDetail = UIKit:createUIClass("GameUIAllianceShrineDetail")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local HEIGHT = 738
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetPushTransparentButton = import("..widget.WidgetPushTransparentButton")
local AllianceShrine = import("..entity.AllianceShrine")

function GameUIAllianceShrineDetail:ctor(shrineStage,allianceShrine,isActivate)
	GameUIAllianceShrineDetail.super.ctor(self)
	self.isActivate_ = isActivate or false
	self.shrineStage_ = shrineStage
	self.allianceShrine_ = allianceShrine
	if self:IsActivate() then
		self:GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnPerceotionChanged)
		self:GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnFightEventTimerChanged)
		self:GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnShrineEventsChanged)
	else
		HEIGHT = 600 -- 修改背景高度
	end
end

function GameUIAllianceShrineDetail:GetAllianceShrine()
	return self.allianceShrine_
end
--是否有激活操作
function GameUIAllianceShrineDetail:IsActivate()
	return self.isActivate_
end

function GameUIAllianceShrineDetail:onMoveOutStage()
	if self:IsActivate() then
		self.allianceShrine_:RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnPerceotionChanged)
		self.allianceShrine_:RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnFightEventTimerChanged)
		self.allianceShrine_:RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnShrineEventsChanged)
	end
	GameUIAllianceShrineDetail.super.onMoveOutStage(self)
end

function GameUIAllianceShrineDetail:OnShrineEventsChanged( change_map )
	self:RefreshStateLable()
end

function GameUIAllianceShrineDetail:RefreshStateLable()
	local event = self:GetAllianceShrine():GetShrineEventByStageName(self:GetShrineStage():StageName())
	if event then
		self.insight_icon:hide()
		self.state_label:setString(_("正在进行") .. "\n" .. GameUtils:formatTimeStyle1(event:GetTime()))
	else
		self.state_label:hide()
	end
end

function GameUIAllianceShrineDetail:OnFightEventTimerChanged(event)
	if event:StageName() == self:GetShrineStage():StageName() then
		if event:GetTime() > 1 then -- 有误差 1s
			self.insight_icon:hide()
			self.state_label:setString(_("正在进行") .. "\n" .. GameUtils:formatTimeStyle1(event:GetTime()))
			self.state_label:show()
		else
			self.insight_icon:show()
			self.state_label:hide()
		end
	end
end

function GameUIAllianceShrineDetail:OnPerceotionChanged()
	local resource = self:GetAllianceShrine():GetPerceptionResource()
	self.event_button:setButtonEnabled(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()) >= self:GetShrineStage():NeedPerception())
end

function GameUIAllianceShrineDetail:onEnter()
	GameUIAllianceShrineDetail.super.onEnter(self)
	self:BuildUI()
end

function GameUIAllianceShrineDetail:BuildUI()
	local layer = UIKit:shadowLayer():addTo(self)
	local background = WidgetUIBackGround.new({height = HEIGHT})
		:addTo(layer)
		:pos(window.left+22,window.top - 101 - HEIGHT)
	local title_bar = display.newSprite("red_title_600x42.png"):align(display.LEFT_BOTTOM, 0,HEIGHT - 15):addTo(background)
	UIKit:ttfLabel({
		text = self:GetShrineStage():GetStageDesc(),
		size = 22,
		color = 0xffedae
	}):align(display.CENTER,300,21):addTo(title_bar)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	--ui
	if self:IsActivate() then
		local desc_label = UIKit:ttfLabel({
			text = _("注:一场战斗中,每名玩家只能派出一支部队"),
			size = 20,
			color = 0x980101
		}):align(display.BOTTOM_CENTER,304,20):addTo(background)
		local event_button = WidgetPushButton.new({
			normal = "yellow_btn_up_185x65.png",
			pressed = "yellow_btn_down_185x65.png",
		},{scale9 = false},{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
			:align(display.RIGHT_BOTTOM, 570,desc_label:getPositionY() + 50)
			:addTo(background)
			:setButtonLabel("normal", UIKit:commonButtonLable({
				text = _("激活事件"),
				color = 0xfff3c7
			}))
			:onButtonClicked(function()
				self:OnEventButtonClicked()
			end)
		self.event_button = event_button
		local resource = self:GetAllianceShrine():GetPerceptionResource()
		event_button:setButtonEnabled(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()) >= self:GetShrineStage():NeedPerception())
		local insight_icon = display.newSprite("insight_icon_45x45.png")
			:align(display.RIGHT_BOTTOM,570 - event_button:getCascadeBoundingBox().width - 120,desc_label:getPositionY() + 60)
			:addTo(background)
		local need_insight_title_label = UIKit:ttfLabel({
			text = _("需要感知力"),
			size = 18,
			color = 0x6d6651
		}):addTo(insight_icon):align(display.LEFT_TOP,insight_icon:getContentSize().width,45)

		local need_insight_val_title = UIKit:ttfLabel({
			text = string.formatnumberthousands(self:GetShrineStage():NeedPerception()),
			color = 0x403c2f,
			size  = 24
		}):addTo(insight_icon):align(display.LEFT_BOTTOM,insight_icon:getContentSize().width, -5)
		self.insight_icon = insight_icon
		self.state_label = UIKit:ttfLabel({
			text = _("正在进行") .. "\n" .. "00:01:55",
			size = 24,
			color = 0x288400,
		}):align(display.RIGHT_BOTTOM,event_button:getPositionX() - event_button:getCascadeBoundingBox().width - 20,event_button:getPositionY())
			:addTo(background)
		self:RefreshStateLable()
	end
	--begin listview
	local items_box_x,items_box_y = 0,0
	if self:IsActivate() then
		items_box_x,items_box_y = 25,self.event_button:getPositionY()+self.event_button:getCascadeBoundingBox().height+30
	else
		items_box_x,items_box_y = 25,20
	end
	local items_box = UIKit:CreateBoxPanel(172)
		:addTo(background)
		:pos(items_box_x,items_box_y)
	local bar = display.newSprite("blue_bar_548x30.png"):align(display.LEFT_TOP,2,169):addTo(items_box)
	local label = UIKit:ttfLabel({
		text = _("事件完成奖励"),
		size = 20,
		color = 0xffedae
	}):align(display.CENTER,274,15):addTo(bar)
	WidgetPushTransparentButton.new(cc.rect(0,0,548,30)):addTo(bar):onButtonClicked(function()
		self:ShowRewardsButtonClicked()
	end):align(display.LEFT_BOTTOM, 0, 0)
	display.newSprite("info_16x33.png"):align(display.LEFT_CENTER,label:getPositionX()+label:getContentSize().width/2 + 5,15):addTo(bar):scale(0.8)
	self.item_list = UIListView.new({
        viewRect = cc.rect(10,10, 536, 120),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
	}):addTo(items_box)
	self:RefreshItemListView()
	local soldier_box = display.newSprite("box_border_580x370.png")
		:addTo(background)
		:align(display.LEFT_BOTTOM,14,items_box:getPositionY()+172+10)
	local info_box = display.newScale9Sprite("box_bg_546x214.png"):align(display.LEFT_BOTTOM,5,5):addTo(soldier_box):size(568,142)
	self.info_list = UIListView.new({
        viewRect = cc.rect(11,10, 546, 122),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
	}):addTo(info_box,2)
	self:RefreshInfoListView()
	UIKit:ttfLabel({
		text = _("敌方部队阵容"),
		size = 20,
		color = 0x403c2f
	}):align(display.TOP_CENTER,290,370):addTo(soldier_box)
	self.soldier_list =  UIListView.new({
        viewRect = cc.rect(info_box:getPositionX(),info_box:getPositionY()+info_box:getContentSize().height+20, info_box:getContentSize().width, 180),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
	}):addTo(soldier_box)
	self:RefreshSoldierListView()
end

function GameUIAllianceShrineDetail:GetInfoData()
	local stage = self:GetShrineStage()
	local r = {}
	r[1] = {"dragon_strength_27x31.png",_("敌方总战斗力"),stage:EnemyPower()}
	r[2] = {"population.png",_("建议玩家数量"),stage:SuggestPlayer()}
	r[3] = {"dragon_strength_27x31.png",_("建议部队战斗力"),"> " .. stage:SuggestPower()}
	return r
end

function GameUIAllianceShrineDetail:GetInfoListItem(index,image,title,val)
	local bg = display.newScale9Sprite(string.format("box_bg_item_520x48_%d.png",index%2)):size(544,40)
	local icon = display.newSprite(image):align(display.LEFT_CENTER,5,20):addTo(bg,2)
	if index == 2 then
		icon:scale(0.7)
	end
	UIKit:ttfLabel({
	 	text = title,
	 	color = 0x5d563f,
	 	size = 20
	 }):align(display.LEFT_CENTER, 40, 20):addTo(bg,2)

	UIKit:ttfLabel({
	 	text = val,
	 	color = 0x403c2f,
	 	size = 20,
	 	align = cc.TEXT_ALIGNMENT_RIGHT,
	 }):align(display.RIGHT_CENTER, 540, 20):addTo(bg,2)
	 return bg
end

function GameUIAllianceShrineDetail:RefreshInfoListView()
	self.info_list:removeAllItems()

	for i,v in ipairs(self:GetInfoData()) do
		local item = self.info_list:newItem()
		local content = self:GetInfoListItem(i,v[1],v[2],v[3])
		item:addContent(content)
		item:setItemSize(544,40)
		self.info_list:addItem(item)
	end
	self.info_list:reload()
end


--TODO:显示关卡的所有装备奖励 配置表还未配置
function GameUIAllianceShrineDetail:RefreshItemListView()	
	self.item_list:removeAllItems()
	for i=1,3 do
		local item = self.item_list:newItem()
		local content = display.newScale9Sprite("tool_box_red.png"):size(118,120)
		display.newSprite("glacierShard_92x92.png"):align(display.CENTER,59,60):addTo(content,2):scale(0.98)
		item:addContent(content)
		item:setMargin({left = 20, right = 60, top = 0, bottom = 0})
		item:setItemSize(118,120,false)

		self.item_list:addItem(item)
	end
	self.item_list:reload()
end


function GameUIAllianceShrineDetail:RefreshSoldierListView()
	self.soldier_list:removeAllItems()
	for _,v in ipairs(self:GetShrineStage():Troops()) do
		local item = self.soldier_list:newItem()
		local content = WidgetSoldierBox.new("",function()end)
		content:SetSoldier(v.type,v.star)
		content:SetNumber(v.count)
		item:addContent(content)
		item:setItemSize(content:getCascadeBoundingBox().width+20,content:getCascadeBoundingBox().height)
		self.soldier_list:addItem(item)
	end
	self.soldier_list:reload()
end

function GameUIAllianceShrineDetail:GetShrineStage()
	return self.shrineStage_
end

function GameUIAllianceShrineDetail:ShowRewardsButtonClicked()
	UIKit:newGameUI("GameUIAllianceShrineRewardList",self:GetShrineStage()):addToCurrentScene(true)
end

function GameUIAllianceShrineDetail:OnEventButtonClicked()
	NetManager:getActivateAllianceShrineStagePromise(self:GetShrineStage():StageName()):catch(function(err)
		dump(err:reason())
	end)
end

return GameUIAllianceShrineDetail