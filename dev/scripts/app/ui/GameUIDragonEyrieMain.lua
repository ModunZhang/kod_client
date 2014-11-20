--
-- Author: Danny He
-- Date: 2014-10-28 16:14:06
--
local GameUIDragonEyrieMain = UIKit:createUIClass("GameUIDragonEyrieMain","GameUIUpgradeBuilding")
local window = import("..utils.window")
local StarBar = import(".StarBar")
local TAG_OF_CONTENT = 100
local DragonManager = import("..entity.DragonManager")

function GameUIDragonEyrieMain:ctor(city,building)
	GameUIDragonEyrieMain.super.ctor(self,city,_("龙巢"),building)
	self.building = building
	self.city = city
	self.dragon_manager = building:GetDragonManager()
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnHPChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
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

function GameUIDragonEyrieMain:OnDragonHatched()
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

function GameUIDragonEyrieMain:onMoveOutStage()
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnHPChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
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
	if not self:GetCurrentDragon():Ishated() then
		self.dragon_info:hide()
		self.progress_content_not_hated:show()
		self.progress_content_hated:hide()
		self.progress_not_hated:setPercentage(dragon:TotalVitality()/100*100) -- 充能
		self.strength_val_label:setString("0")
		self.vitality_val_label:setString("0")
	else
		self.dragon_info:show()
		self.draong_info_lv_label:setString("LV " .. dragon:Level() .. "/" .. dragon:GetMaxLevel())
		self.draong_info_xp_label:setString(dragon:Exp() .. "/" .. dragon:GetMaxExp())
		self.progress_content_not_hated:hide()
		self.progress_content_hated:show()
		self.strength_val_label:setString(dragon:Strength())
		self.vitality_val_label:setString(dragon:Vitality())
		self.dragon_hp_label:setString(dragon:Hp() .. "/" .. dragon:GetMaxHP())
		self.progress_hated:setPercentage(dragon:Hp()/dragon:GetMaxHP()*100)
	end
	self.nameLabel:setString(dragon:GetLocalizedName())
	self.state_label:setString(dragon:Status())
	self.star_bar:setNum(dragon:Star())
end

function GameUIDragonEyrieMain:CreateProgressTimer(tag)
	local bg,progressTimer = nil,nil
	if "hated" ~= tag then
		bg = display.newSprite("dragon_energy_bar_bg_366x40.png")
		progressTimer = UIKit:commonProgressTimer("dragon_energy_bar_366x40.png"):align(display.LEFT_BOTTOM,0,0):addTo(bg)
		progressTimer:setPercentage(0)
		display.newSprite("dragon_energy_bar_box_366x40.png"):align(display.LEFT_BOTTOM,0,0):addTo(bg)
	else
		bg = display.newSprite("drgon_lvbar_bg.png"):scale(0.9)
    	progressTimer = UIKit:commonProgressTimer("drgon_lvbar_color.png"):addTo(bg):align(display.LEFT_BOTTOM,0,0)
    	progressTimer:setPercentage(0)
    	local iconbg = display.newSprite("drgon_process_icon_bg.png")
     		:addTo(bg)
     		:align(display.LEFT_BOTTOM, -13,-5)
    	display.newSprite("dragon_lv_icon.png")
     		:addTo(iconbg)
     		:pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)
     	self.dragon_hp_label = UIKit:ttfLabel({
     		 text = "120/360",
     		 color = 0xfff3c7,
     		 shadow = true,
     		 size = 20
     	}):addTo(bg):align(display.LEFT_BOTTOM, 40, 5)

     	UIKit:ttfLabel({
     		 text = "+" .. self.building:GetHPRecoveryPerHour() .. "/h",
     		 color = 0xfff3c7,
     		 shadow = true,
     		 size = 20
     	}):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width - 50, 5)
     	local add_button = cc.ui.UIPushButton.new({normal = "dragon_add_button_normal.png",pressed = "dragon_add_button_highlight.png"})
     		:addTo(bg)
     		:align(display.TOP_RIGHT,bg:getContentSize().width,bg:getContentSize().height)
	end
	bg:setTag(TAG_OF_CONTENT)
	return bg,progressTimer
end

function GameUIDragonEyrieMain:CreateDragonAnimateNodeIf()
	if not self.dragonAnimateNode then
		local dragonAnimateNode = display.newSprite("dragon_node_619x715.png")
			:addTo(self.dragonNode)
			:align(display.TOP_CENTER,window.cx,window.top)
		self.dragonAnimateNode = dragonAnimateNode
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

		local box = display.newSprite("dragon_main_box_624x226.png")
			:align(display.LEFT_BOTTOM, window.left+10,window.bottom+66)
			:addTo(self.dragonNode)
		local nameLabel = UIKit:ttfLabel({
			text = "",
			color = 0xffedae,
			size  = 24
		}):addTo(box):align(display.LEFT_TOP,70, box:getContentSize().height - 10)
		local star_bar = StarBar.new({
       		max = self:GetCurrentDragon():MaxStar(),
       		bg = "Stars_bar_bg.png",
       		fill = "Stars_bar_highlight.png", 
       		num = self:GetCurrentDragon():Star(),
       		margin = 0,
    	}):addTo(box):align(display.RIGHT_BOTTOM, 570,box:getContentSize().height - 40)
    	self.content_bg = box
    	self.nameLabel = nameLabel
    	self.star_bar = star_bar

    	self.progress_content_hated,self.progress_hated = self:CreateProgressTimer("hated")
    	self.progress_content_hated:align(display.CENTER_BOTTOM,box:getContentSize().width/2,120):addTo(box)

    	self.progress_content_not_hated,self.progress_not_hated = self:CreateProgressTimer()
    	self.progress_content_not_hated:align(display.CENTER_BOTTOM,box:getContentSize().width/2,120):addTo(box)

    	local strength_title_label =  UIKit:ttfLabel({
			text = _("力量"),
			color = 0x797154,
			size  = 20
		}):addTo(box):align(display.LEFT_BOTTOM,50,80)
		self.strength_val_label =  UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(box):align(display.LEFT_BOTTOM, 130, 80)

		local vitality_title_label =  UIKit:ttfLabel({
			text = _("活力"),
			color = 0x797154,
			size  = 20
		}):addTo(box):align(display.LEFT_BOTTOM,50,40)

		self.vitality_val_label =  UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(box):align(display.LEFT_BOTTOM, 130, 40)

		self.state_label = UIKit:ttfLabel({
			text = "",
			color = 0x403c2f,
			size  = 20
		}):addTo(box):align(display.RIGHT_BOTTOM,540,80)

		local detailButton = cc.ui.UIPushButton.new({
			normal = "dragon_yellow_button.png",pressed = "dragon_yellow_button_h.png"
		}):setButtonLabel("normal",UIKit:ttfLabel({
			text = _("详情"),
			size = 24,
			color = 0xffedae,
			shadow = true
		})):addTo(box):align(display.RIGHT_BOTTOM,590,15):onButtonClicked(function()
			UIKit:newGameUI("GameUIDragonEyrieDetail",self.city,self.building,self:GetCurrentDragon():Type()):addToCurrentScene(true)
		end)
	end

end

function GameUIDragonEyrieMain:GetCurrentDragon()
	-- index 1~3
	local dragon = self.dragon_manager:GetDragonByIndex(self.draong_index)
	return dragon
end

function GameUIDragonEyrieMain:ChangeDragon(direction)
	if direction == 'next' then
		if self.draong_index + 1 > 3 then
			self.draong_index = 1
		else
			self.draong_index = self.draong_index + 1
		end
	else
		if self.draong_index - 1 == 0 then
			self.draong_index = 3
		else
			self.draong_index = self.draong_index - 1
		end
	end
	self:RefreshUI()
end
return GameUIDragonEyrieMain