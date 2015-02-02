--
-- Author: Danny He
-- Date: 2014-10-28 16:14:06
--
local GameUIDragonEyrieMain = UIKit:createUIClass("GameUIDragonEyrieMain","GameUIUpgradeBuilding")
local window = import("..utils.window")
local cocos_promise = import("..utils.cocos_promise")
local StarBar = import(".StarBar")
local DragonManager = import("..entity.DragonManager")
local WidgetDragons = import("..widget.WidgetDragons")
local DragonSprite = import("..sprites.DragonSprite")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUseItems = import("..widget.WidgetUseItems")

function GameUIDragonEyrieMain:ctor(city,building)
	GameUIDragonEyrieMain.super.ctor(self,city,_("龙巢"),building)
	self.building = building
	self.city = city
	self.dragon_manager = building:GetDragonManager()
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnHPChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventTimer)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonDeathEventChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonDeathEventTimer)
	self.draong_index = 1
end

function GameUIDragonEyrieMain:CreateBetweenBgAndTitle()
	GameUIDragonEyrieMain.super.CreateBetweenBgAndTitle(self)
	self.dragonNode = display.newNode():size(window.width,window.height):addTo(self)
end

-- event
------------------------------------------------------------------
function GameUIDragonEyrieMain:OnHPChanged()
	local dragon = self:GetCurrentDragon()
	if not dragon:Ishated() then return end
	if self.dragon_hp_label and self.dragon_hp_label:isVisible() then
		self.dragon_hp_label:setString(dragon:Hp() .. "/" .. dragon:GetMaxHP())
		self.progress_hated:setPercentage(dragon:Hp()/dragon:GetMaxHP()*100)
	end
end

function GameUIDragonEyrieMain:OnDragonHatched(dragon)
	local dragon_index = DragonManager.DRAGON_TYPE_INDEX[dragon:Type()]
	local localIndex = dragon_index - 1
	local eyrie = self.draongConteNode:GetItemByIndex(localIndex)
	eyrie.dragon_image:setTexture(self:GetDraongIdeImageName(dragon:Type()))
	eyrie.dragon_image:scale(0.7)
	self:RefreshUI()
end
function GameUIDragonEyrieMain:OnBasicChanged()
	self:RefreshUI()
end
------------------------------------------------------------------

function GameUIDragonEyrieMain:onMoveInStage()
	GameUIDragonEyrieMain.super.onMoveInStage(self)
	self:CreateUI()
end

function GameUIDragonEyrieMain:OnDragonEventChanged()
	local dragonEvent = self.dragon_manager:GetDragonEventByDragonType(self:GetCurrentDragon():Type())
 	if dragonEvent then
 		self:RefreshUI()
 	end
end
function GameUIDragonEyrieMain:OnDragonDeathEventChanged()
	local dragonDeathEvent = self.dragon_manager:GetDragonDeathEventByType(self:GetCurrentDragon():Type())
	if dragonDeathEvent then
 		self:RefreshUI()
 	end
end

function GameUIDragonEyrieMain:OnDragonDeathEventTimer(dragonDeathEvent)
	if self:GetCurrentDragon():Type() == dragonDeathEvent:DragonType() 
		and self.progress_content_death  
		and self.progress_content_death:isVisible() 
		then
			self.progress_death:setPercentage(dragonDeathEvent:GetPercent())
			self.dragon_death_label:setString(GameUtils:formatTimeStyleDayHour(dragonDeathEvent:GetTime()))
	end
end

function GameUIDragonEyrieMain:OnDragonEventTimer(dragonEvent)
	if self:GetCurrentDragon():Type() == dragonEvent:DragonType() and self.progress_content_not_hated_timer and self.progress_content_not_hated_timer:isVisible() then
		self.progress_content_not_hated_timer:setString(GameUtils:formatTimeStyleDayHour(dragonEvent:GetTime()))
	end
end

function GameUIDragonEyrieMain:onMoveOutStage()
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnHPChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventTimer)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonDeathEventChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonDeathEventTimer)
	GameUIDragonEyrieMain.super.onMoveOutStage(self)
end

function GameUIDragonEyrieMain:CreateUI()
	self.tabButton = self:CreateTabButtons({
       	{
            label = _("龙"),
            tag = "dragon",
        }
    },
    function(tag)
        self:TabButtonsAction(tag)
    end):pos(window.cx, window.bottom + 34)
end

function GameUIDragonEyrieMain:TabButtonsAction(tag)
	if tag == 'dragon' then
		self:CreateDragonAnimateNodeIf()
		self:RefreshUI()
		self.dragonNode:show()
	else
		self.dragonNode:hide()
	end
end

function GameUIDragonEyrieMain:RefreshUI()
	local dragon = self:GetCurrentDragon()
	if not self.dragon_info then return end
	if not self:GetCurrentDragon():Ishated() then
		self.dragon_info:hide()
		self.death_speed_button:hide()
		self.progress_content_death:hide()
		local dragonEvent = self.dragon_manager:GetDragonEventByDragonType(self:GetCurrentDragon():Type())
 		if dragonEvent then
			self.progress_content_not_hated:show()
			self.progress_content_not_hated_timer:show()
 			self.progress_content_not_hated:setString(_("正在孵化,剩余时间"))
 			self.progress_content_not_hated_timer:setString(GameUtils:formatTimeStyleDayHour(dragonEvent:GetTime()))
 		else
 			self.progress_content_not_hated:show()
 			self.progress_content_not_hated:setString(_("未孵化"))
 			self.progress_content_not_hated_timer:hide()
 		end
		self.progress_content_hated:hide()
		self.strength_val_label:setString("0")
		self.vitality_val_label:setString("0")
		self.leadership_val_label:setString("0")
		self.state_label:setString(_("未孵化"))
	else
		if dragon:IsDead() then
			local dragonDeathEvent = self.dragon_manager:GetDragonDeathEventByType(self:GetCurrentDragon():Type())
			if dragonDeathEvent then
				self.progress_death:setPercentage(dragonDeathEvent:GetPercent())
				self.dragon_death_label:setString(GameUtils:formatTimeStyleDayHour(dragonDeathEvent:GetTime()))
			end
			self.death_speed_button:show()
			self.progress_content_death:show()
			self.progress_content_not_hated_timer:hide()
			self.progress_content_not_hated:hide()
			self.progress_content_hated:hide()
			self.state_label:setString(_("死亡"))
		else
			self.progress_content_not_hated_timer:show()
			self.dragon_info:show()
			self.draong_info_lv_label:setString("LV " .. dragon:Level() .. "/" .. dragon:GetMaxLevel())
			self.draong_info_xp_label:setString(dragon:Exp() .. "/" .. dragon:GetMaxExp())
			self.progress_content_not_hated:hide()
			self.progress_content_not_hated_timer:hide()
			self.progress_content_hated:show()
			self.strength_val_label:setString(dragon:TotalStrength())
			self.vitality_val_label:setString(dragon:TotalVitality())
			self.leadership_val_label:setString(dragon:TotalLeadership())
			self.dragon_hp_label:setString(dragon:Hp() .. "/" .. dragon:GetMaxHP())
			self.progress_hated:setPercentage(dragon:Hp()/dragon:GetMaxHP()*100)
			self.state_label:setString(Localize.dragon_status[dragon:Status()])
			self.death_speed_button:hide()
			self.progress_content_death:hide()
		end
	end
	self.nameLabel:setString(dragon:GetLocalizedName())
	
	self.star_bar:setNum(dragon:Star())
end

function GameUIDragonEyrieMain:CreateProgressTimer()
	local bg,progressTimer = nil,nil
	bg = display.newSprite("process_bar_540x40.png")
	progressTimer = UIKit:commonProgressTimer("progress_bar_540x40_2.png"):addTo(bg):align(display.LEFT_CENTER,0,20)
	progressTimer:setPercentage(0)
	local iconbg = display.newSprite("drgon_process_icon_bg.png")
 		:addTo(bg)
 		:align(display.LEFT_BOTTOM, -13,-2)
	display.newSprite("dragon_lv_icon.png")
 		:addTo(iconbg)
 		:pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)
 	self.dragon_hp_label = UIKit:ttfLabel({
 		 text = "120/360",
 		 color = 0xfff3c7,
 		 shadow = true,
 		 size = 20
 	}):addTo(bg):align(display.LEFT_CENTER, 40, 20)

 	UIKit:ttfLabel({
 		 text = "+" .. self.building:GetHPRecoveryPerHour() .. "/h",
 		 color = 0xfff3c7,
 		 shadow = true,
 		 size = 20
 	}):addTo(bg):align(display.RIGHT_CENTER, bg:getContentSize().width - 50, 20)
 	local add_button = cc.ui.UIPushButton.new({normal = "add_button_normal_50x50.png",pressed = "add_button_light_50x50.png"})
 		:addTo(bg)
 		:align(display.CENTER_RIGHT,bg:getContentSize().width+10,20)
 		:onButtonClicked(function()
 			self:OnHpItemUseButtonClicked()
 		end)
	return bg,progressTimer
end

function GameUIDragonEyrieMain:CreateDeathEventProgressTimer()
	local bg,progressTimer = nil,nil
	bg = display.newSprite("progress_bar_364x40_1.png")
	progressTimer = UIKit:commonProgressTimer("progress_bar_yellow_364x40.png"):addTo(bg):align(display.LEFT_CENTER,0,20)
	progressTimer:setPercentage(0)
	local icon_bg = display.newSprite("progress_bg_head_43x43.png"):align(display.LEFT_CENTER, -20, 20):addTo(bg)
	display.newSprite("hourglass_39x46.png"):align(display.CENTER, 22, 22):addTo(icon_bg):scale(0.8)
	self.dragon_death_label = UIKit:ttfLabel({
		text = "",
		size = 22,
		color= 0xfff3c7,
		shadow= true
	}):addTo(bg):align(display.LEFT_CENTER, 50,20)
	return bg,progressTimer
end

function GameUIDragonEyrieMain:CreateDragonAnimateNodeIf()
	if not self.draongConteNode then
		local dragonAnimateNode,draongConteNode = self:CreateDragonAnimateNode()
		self.draongConteNode = draongConteNode
		dragonAnimateNode:addTo(self.dragonNode):pos(window.cx - 310,window.top_bottom - 576)
		--info
		local info_bg = display.newSprite("dragon_info_bg_290x92.png")
			:align(display.BOTTOM_CENTER, 309, 50)
			:addTo(dragonAnimateNode)
		local lv_bg = display.newSprite("dragon_lv_bg_270x30.png")
			:addTo(info_bg)
			:align(display.TOP_CENTER,info_bg:getContentSize().width/2,info_bg:getContentSize().height-10)
		self.dragon_info = info_bg
		self.draong_info_lv_label = UIKit:ttfLabel({
			text = "LV " .. self:GetCurrentDragon():Level() .. "/" .. self:GetCurrentDragon():GetMaxLevel(),
			color = 0xb1a475,
			size = 22
		}):addTo(lv_bg):align(display.CENTER,lv_bg:getContentSize().width/2,lv_bg:getContentSize().height/2)
		local expIcon = display.newSprite("dragonskill_xp_51x63.png")
			:addTo(info_bg)
			:scale(0.7)
			:align(display.BOTTOM_LEFT, 90,10)
		self.draong_info_xp_label = UIKit:ttfLabel({
			text = self:GetCurrentDragon():Exp() .. "/" .. self:GetCurrentDragon():GetMaxExp(),
			color = 0x403c2f,
			size = 20
		}):align(display.LEFT_BOTTOM, expIcon:getPositionX()+expIcon:getContentSize().width*0.7+10, 20)
		:addTo(info_bg)
		-- info end
		self.nextButton = cc.ui.UIPushButton.new({
			normal = "dragon_next_icon_28x31.png"
			})
			:addTo(dragonAnimateNode)
			:align(display.BOTTOM_CENTER, 306+170,80)
			:onButtonClicked(function()
				self:ChangeDragon('next')
			end)
		self.preButton = cc.ui.UIPushButton.new({
			normal = "dragon_next_icon_28x31.png"
			})
			:addTo(dragonAnimateNode)
			:align(display.TOP_CENTER, 306-170,80)
			:onButtonClicked(function()
				self:ChangeDragon('pre')
			end)
		self.preButton:setRotation(180)

		local info_layer = UIKit:shadowLayer():size(619,40):pos(window.left+10,dragonAnimateNode:getPositionY()):addTo(self.dragonNode)
		display.newSprite("dragon_main_line_624x58.png"):align(display.LEFT_TOP,0,20):addTo(info_layer)
		local nameLabel = UIKit:ttfLabel({
			text = "",
			color = 0xffedae,
			size  = 24
		}):addTo(info_layer):align(display.LEFT_CENTER,20, 20)
		local star_bar = StarBar.new({
       		max = self:GetCurrentDragon():MaxStar(),
       		bg = "Stars_bar_bg.png",
       		fill = "Stars_bar_highlight.png", 
       		num = self:GetCurrentDragon():Star(),
       		margin = 0,
    	}):addTo(info_layer):align(display.RIGHT_CENTER, 610,20)
    	self.nameLabel = nameLabel
    	self.star_bar = star_bar
    	--
    	self.progress_content_hated,self.progress_hated = self:CreateProgressTimer()
    	self.progress_content_hated:align(display.CENTER_TOP,window.cx,info_layer:getPositionY()-18):addTo(self.dragonNode)
    	-- 
    	self.progress_content_death,self.progress_death = self:CreateDeathEventProgressTimer()
    	self.progress_content_death:align(display.LEFT_TOP,60,info_layer:getPositionY()-20):addTo(self.dragonNode)

    	self.death_speed_button = WidgetPushButton.new({normal = 'green_btn_up_148x58.png',pressed = 'green_btn_down_148x58.png'})
    		:setButtonLabel("normal",UIKit:commonButtonLable({
    			text = _("加速")
    		})):addTo(self.dragonNode)
    			:align(display.LEFT_TOP,self.progress_content_death:getPositionX()+self.progress_content_death:getContentSize().width+18,
    			 self.progress_content_death:getPositionY()+12)
		local info_panel = UIKit:CreateBoxPanel9({width = 548, height = 114})
			:addTo(self.dragonNode)
			:align(display.CENTER_TOP,window.cx,self.progress_content_hated:getPositionY() - self.progress_content_hated:getContentSize().height - 32)
		self.progress_content_not_hated,self.progress_content_not_hated_timer = self:GetHateLabel()
		self.progress_content_not_hated:align(display.CENTER_TOP,window.cx,info_layer:getPositionY()-10):addTo(self.dragonNode)
		self.progress_content_not_hated_timer:align(display.CENTER_TOP,window.cx,info_layer:getPositionY()-36):addTo(self.dragonNode)
    	local strength_title_label =  UIKit:ttfLabel({
			text = _("力量"),
			color = 0x797154,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM,10,45)
		self.strength_val_label =  UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM, 100, 45)

		local vitality_title_label =  UIKit:ttfLabel({
			text = _("活力"),
			color = 0x797154,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM,10,10)

		self.vitality_val_label =  UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM, 100, 10)

		local leadership_title_label =  UIKit:ttfLabel({
			text = _("领导力"),
			color = 0x797154,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM,10,80)

		self.leadership_val_label =  UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(info_panel):align(display.LEFT_BOTTOM, 100, 80)

		self.state_label = UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(info_panel):align(display.CENTER_BOTTOM,540 - 92,75)

		local detailButton = WidgetPushButton.new({
			normal = "dragon_yellow_button.png",pressed = "dragon_yellow_button_h.png"
		}):setButtonLabel("normal",UIKit:ttfLabel({
			text = _("详情"),
			size = 24,
			color = 0xffedae,
			shadow = true
		})):addTo(info_panel):align(display.RIGHT_BOTTOM,540,5):onButtonClicked(function()
			UIKit:newGameUI("GameUIDragonEyrieDetail",self.city,self.building,self:GetCurrentDragon():Type()):addToCurrentScene(true)
		end)
		self.detailButton = detailButton
		self.draongConteNode:OnEnterIndex(math.abs(0))
	end

end

function GameUIDragonEyrieMain:GetHateLabel()
	local label_1 = UIKit:ttfLabel({text = "正在孵化,剩余时间",size = 20,color = 0x403c2f})
	local label_2 = UIKit:ttfLabel({text = "00:20:00",size = 22,color = 0x068329})
	return label_1,label_2
end

function GameUIDragonEyrieMain:GetCurrentDragon()
	-- index 1~3
	local dragon = self.dragon_manager:GetDragonByIndex(self.draong_index)
	return dragon
end

function GameUIDragonEyrieMain:CreateDragonAnimateNode()
	local clipNode = display.newClippingRegionNode(cc.rect(0,0,620,600))
	local contenNode = WidgetDragons.new(
		{
			OnFilterChangedEvent = handler(self, self.OnFilterChangedEvent),
			OnLeaveIndexEvent = handler(self, self.OnLeaveIndexEvent),
			OnEnterIndexEvent = handler(self, self.OnEnterIndexEvent),
		}
	):addTo(clipNode):pos(310,300)
	for i,v in ipairs(contenNode:GetItems()) do
		local dragon = self.dragon_manager:GetDragonByIndex(i)
		if dragon:Ishated() then
			local dragon_type = dragon:Type()
			local image_name = self:GetDraongIdeImageName(dragon_type)
			local dragon_image = display.newSprite(image_name, nil, nil, {class=cc.FilteredSpriteWithOne})
				:align(display.CENTER, 330,355)
				:addTo(v)
			dragon_image:scale(0.7)
			v.dragon_image = dragon_image
    		dragon_image.resolution = {dragon_image:getContentSize().width,dragon_image:getContentSize().height}
		else
			local dragon_image = display.newSprite("dragon_egg_139x187.png", nil, nil, {class=cc.FilteredSpriteWithOne})
				:align(display.CENTER, 290,355)
				:addTo(v)
			v.dragon_image = dragon_image
    		dragon_image.resolution = {dragon_image:getContentSize().width,dragon_image:getContentSize().height}
		end
		local dragon_armature = DragonSprite.new(display.getRunningScene():GetSceneLayer(),dragon:GetTerrain())
			:addTo(v)
			:align(display.CENTER, 290,420)
			:hide()
		v.armature = dragon_armature
	end
	return clipNode,contenNode
end

function GameUIDragonEyrieMain:GetDraongIdeImageName(dragon_type)
	local image_name = ""
	if dragon_type == "redDragon" then
		image_name = "red_dragon_ide_475x369.png"
	elseif dragon_type == "greenDragon" then
		image_name = "green_dragon_ide_482x378.png"
	elseif dragon_type == "blueDragon" then
		image_name = "blue_dragon_ide_4480x373.png"
	end
	return image_name
end

function GameUIDragonEyrieMain:OnEnterIndexEvent(index)
	if self.draongConteNode then
		self.draong_index = index + 1
		self:RefreshUI()
		local eyrie = self.draongConteNode:GetItemByIndex(index)
		if not self:GetCurrentDragon():Ishated() then return end
		eyrie.dragon_image:hide()
		eyrie.armature:show()
		eyrie.armature:PlayAnimation("Idle")
	end
end

function GameUIDragonEyrieMain:OnLeaveIndexEvent(index)
	if self.draongConteNode then
		local eyrie = self.draongConteNode:GetItemByIndex(index)
		if not self:GetCurrentDragon():Ishated() then return end
		eyrie.armature:GetSprite():stop()
		eyrie.armature:hide()
		eyrie.dragon_image:show()
	end
end

function GameUIDragonEyrieMain:OnFilterChangedEvent(eyrie,b,i)
	if eyrie.dragon_image then
		local filter_ = filter.newFilter("CUSTOM",
            json.encode({
                frag = "shaders/blur.fs",
                shaderName = "dragon_image"..i,
                resolution = eyrie.dragon_image.resolution,
                blurRadius = b,
                sampleNum = 2
            })
        )
		eyrie.dragon_image:setFilter(filter_)
	end
end

function GameUIDragonEyrieMain:ChangeDragon(direction)
	if self.isChanging  then return end
	self.isChanging = true
	if direction == 'next' then
		if self.draong_index + 1 > 3 then
			self.draong_index = 1
		else
			self.draong_index = self.draong_index + 1
		end
		self.draongConteNode:Next()
		self.isChanging = false
	else
		if self.draong_index - 1 == 0 then
			self.draong_index = 3
		else
			self.draong_index = self.draong_index - 1
		end
		self.draongConteNode:Before()
		self.isChanging = false
	end
end
function GameUIDragonEyrieMain:OnHpItemUseButtonClicked()
	local widgetUseItems = WidgetUseItems.new({
		item_type = WidgetUseItems.USE_TYPE.DRAGON_EXP,
		dragon = self:GetCurrentDragon()
	})
end

--fte
function GameUIDragonEyrieMain:Find(type_)
	if type_ == "dragon" then
		return cocos_promise.defer(function()
            return self.tabButton:GetTabByTag("dragon")
        end)
	end
    return cocos_promise.defer(function()
        return self.detailButton
    end)
end
function GameUIDragonEyrieMain:WaitTag(type_)
    return self.tabButton:PromiseOfTag(type_):next(function()
        return self
    end)
end
return GameUIDragonEyrieMain