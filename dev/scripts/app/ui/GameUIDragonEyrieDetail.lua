--
-- Author: Danny He
-- Date: 2014-10-31 15:08:59
--
local GameUIDragonEyrieDetail = UIKit:createUIClass("GameUIDragonEyrieDetail","GameUIWithCommonHeader")
local window = import('..utils.window')
local StarBar = import(".StarBar")
local DragonSprite = import("..sprites.DragonSprite")
local GameUIDragonEyrieMain = import(".GameUIDragonEyrieMain")
local WidgetPushButton = import("..widget.WidgetPushButton")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local DragonManager = import("..entity.DragonManager")
local WidgetDragonTabButtons = import("..widget.WidgetDragonTabButtons")
local Dragon = import("..entity.Dragon")
local UIListView = import(".UIListView")
local Localize = import("..utils.Localize")

-- building = DragonEyrie
function GameUIDragonEyrieDetail:ctor(city,building,dragon_type)
	GameUIDragonEyrieDetail.super.ctor(self,city,_("龙巢"))
	self.building = building
	self.dragon_manager = building:GetDragonManager()
	self.dragon = self.dragon_manager:GetDragon(dragon_type)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
end

function GameUIDragonEyrieDetail:CreateBetweenBgAndTitle()
	self.content_node = display.newNode():addTo(self)
	self.dragon_base = display.newSprite("dragon_eyrie_base_614x519.png")
		:align(display.CENTER_TOP, window.cx,window.top)
		:addTo(self.content_node)
	self:BuildDragonContent()
	local star_bg = display.newSprite("dragon_title_bg_534x16.png")
		:align(display.CENTER_TOP,window.cx,window.top - 100)
		:addTo(self.content_node)
	local nameLabel = UIKit:ttfLabel({
		text = self:GetDragon():GetLocalizedName(),
		color = 0xebdba0,
		size = 28
	}):align(display.LEFT_CENTER, 50,star_bg:getContentSize().height/2)
		:addTo(star_bg)
	local star_bar = StarBar.new({
       		max = self:GetDragon():MaxStar(),
       		bg = "Stars_bar_bg.png",
       		fill = "Stars_bar_highlight.png", 
       		num = self:GetDragon():Star(),
    }):addTo(star_bg):align(display.RIGHT_BOTTOM,480,5)
	self.star_bar = star_bar
    self.dragon_button_line = display.newSprite("dragon_line_620x27.png")
    	:align(display.CENTER_BOTTOM,307,0)
    	:addTo(self.dragon_base)

    self.back_button = cc.ui.UIPushButton.new({
    	normal = "draong_back_button_normal_122x54.png",
    	pressed = "draong_back_button_light_122x54.png"
    }):align(display.LEFT_BOTTOM,20, 2)
      :addTo(self.dragon_button_line)
      :onButtonClicked(function(event)
      		self:leftButtonClicked()
      end)
    local back_icon = display.newSprite("dragon_next_icon_28x31.png"):addTo(self.back_button):pos(61,27)
	back_icon:setRotation(180)
	self.tab_buttons = WidgetDragonTabButtons.new(function(tag)
		self:OnTabButtonClicked(tag)
	end):addTo(self.dragon_button_line):pos(self.back_button:getPositionX()+97,2)
end

function GameUIDragonEyrieDetail:onMoveInStage()
	GameUIDragonEyrieDetail.super.onMoveInStage(self)
	self:BuildUI()
end

function GameUIDragonEyrieDetail:onMoveOutStage()
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
	self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
	GameUIDragonEyrieDetail.super.onMoveOutStage(self)
end

function GameUIDragonEyrieDetail:BuildUI()
	if self:GetDragon():Ishated() then
		self.tab_buttons:show()
		self.tab_buttons:SelectButtonByTag("equipment")
	else -- 未孵化
		self.tab_buttons:hide()
		self:CreateHateUIIf()
	end
end

function GameUIDragonEyrieDetail:BuildDragonContent()
	local dragon_content = self.dragon_base:getChildByTag(101)
	if dragon_content then dragon_content:removeFromParent() end
	if self:GetDragon():Ishated() then
		local dragon = DragonSprite.new(display.getRunningScene():GetSceneLayer(),self:GetDragon():GetTerrain())
			:addTo(self.dragon_base)
			:align(display.CENTER, 307,250)
		dragon:setTag(101)
	else
		local dragon = display.newSprite("dragon_egg_139x187.png")
			:align(display.CENTER, 307,180)
			:addTo(self.dragon_base)
		dragon:setTag(101)
	end
end
--孵化界面
function GameUIDragonEyrieDetail:CreateHateUIIf()
	if self.hate_node then
		self.hate_node:show()
		return
	end
	local hate_node = display.newNode():addTo(self)
	local hate_bg = UIKit:CreateBoxPanel(162)
		:addTo(hate_node)
		:pos(window.left+45,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height - 20 - 162)
	UIKit:ttfLabel({
		text = _("消耗能量，为龙蛋补充活力，活力补充道100时，可以获得巨龙"),
		size = 20,
		color = 0x403c2f
	}):addTo(hate_node):align(display.CENTER,window.cx,hate_bg:getPositionY() - 40)

	UIKit:ttfLabel({
		text = _("孵化巨龙"),
		size = 22,
		color = 0x403c2f,
	}):addTo(hate_bg):align(display.CENTER,276,140)
	local bg,progressTimer = GameUIDragonEyrieMain.CreateProgressTimer()
	bg:addTo(hate_bg):align(display.LEFT_BOTTOM,10,20)
	self.hate_progressTimer = progressTimer
	progressTimer:setPercentage(self:GetDragon():Hp()/100)
	local big_enery_icon = display.newSprite("dragon_energy_45x38.png")
		:addTo(hate_bg)
		:align(display.LEFT_BOTTOM,10,bg:getPositionY()+bg:getContentSize().height+20)
	self.hate_nextEneryLabel = UIKit:ttfLabel({
		size = 20,
		color = 0x403c2f,
		text  = self:GetHatchEneryLabelString()
	}):addTo(hate_bg)
	:align(display.LEFT_CENTER, big_enery_icon:getPositionX()+big_enery_icon:getContentSize().width+10, big_enery_icon:getPositionY()+big_enery_icon:getContentSize().height/2)

	local cost_enery_bg = display.newSprite("LV_background.png")
		:align(display.RIGHT_CENTER,552-20,self.hate_nextEneryLabel:getPositionY())
		:addTo(hate_bg)
	local small_enery_icon = display.newSprite("dragon_energy_45x38.png"):scale(0.8)
		:addTo(cost_enery_bg):align(display.LEFT_CENTER, 0, cost_enery_bg:getContentSize().height/2)

	WidgetPushButton.new({
		normal = "yellow_button_146x42.png",
		pressed = "yellow_button_highlight_146x42.png"
	},{scale9 = true})
		:align(display.RIGHT_BOTTOM,552-10, bg:getPositionY())
		:addTo(hate_bg)
		:setButtonLabel("normal", UIKit:commonButtonLable({
			text = _("充能")
		}))
		:onButtonClicked(function(event)
			self:OnEnergyButtonClicked()
		end)
	UIKit:ttfLabel({
		text = self.dragon_manager:GetEnergyCost(),
		size = 18,
		color = 0x403c2f,
	}):align(display.LEFT_CENTER, small_enery_icon:getPositionX()+small_enery_icon:getContentSize().width*0.8+10,small_enery_icon:getPositionY()):addTo(cost_enery_bg)
	self.hate_node = hate_node
	self:RefreshUI()
	return self.hate_node
end

--计算获取下一点能量的剩余时间
function GameUIDragonEyrieDetail:GetHatchEneryLabelString()
    local energy = City.resource_manager:GetEnergyResource()
    local __,decimals = math.modf(energy:GetReallyTotalResource())
    local string = string.format(_("%s 下一点能量 %s"),
            energy:GetResourceValueByCurrentTime(app.timer:GetServerTime()) .. "/" .. energy:GetValueLimit(),
            GameUtils:formatTimeStyle1((1-decimals)*self.building:GetTimePerEnergy()))
    if decimals == 0 then 
        string = string.format(_("%s 能量已满"),energy:GetResourceValueByCurrentTime(app.timer:GetServerTime()) .. "/" .. energy:GetValueLimit())
    end
    return string
end

function GameUIDragonEyrieDetail:OnResourceChanged(resource_manager)
    GameUIDragonEyrieDetail.super.OnResourceChanged(self,resource_manager)
    if self:GetDragon():Ishated() then return end
    if self.hate_node and self.hate_node:isVisible() then
    	self.hate_nextEneryLabel:setString(self:GetHatchEneryLabelString())
    end
    if self.skill_node and self.skill_node:isVisible() then
    	
    	self.skill_ui.timeLabel:setString(self:GetHatchEneryLabelString())
    end
end

function GameUIDragonEyrieDetail:GetDragon()
	return self.dragon
end
--充能
function GameUIDragonEyrieDetail:OnEnergyButtonClicked()
	local energy =  City.resource_manager:GetEnergyResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    if energy < self.dragon_manager:GetEnergyCost() then 
        local dialog = FullScreenPopDialogUI.new()
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(_("能量不足!"))
        dialog:AddToCurrentScene()
        return 
    end
    local dragon = self:GetDragon()
    NetManager:getHatchDragonPromise(dragon:Type()):catch(function(err)
    	dump(err:reason())
    end)
end

function GameUIDragonEyrieDetail:RefreshUI()
	local dragon = self:GetDragon()
	if not dragon:Ishated() then
		if not self.hate_node then return end
		print("GameUIDragonEyrieDetail:RefreshUI----->",dragon:Hp())
		self.hate_progressTimer:setPercentage(dragon:Hp()/100*100)
	else
		-- 已孵化的界面
		assert(self.tab_buttons)
		local button_tag = self.tab_buttons:GetCurrentTag() 
		if button_tag == 'equipment' then
			self:HandleEquipments(dragon)
			self.equipment_ui.strength_label:setString(string.formatnumberthousands(dragon:Strength()))
			self.equipment_ui.vitality_label:setString(string.formatnumberthousands(dragon:Vitality()))
			self.equipment_ui.promotionLevel_label:setString(string.format(_("晋级需要龙的等级达到%d级，集全全套装备，并全部强化到%d星"),dragon:GetPromotionLevel(),dragon:Star()))
		elseif button_tag == 'skill' then
			self:RefreshSkillList()
			self.skill_ui.blood_label:setString(City:GetResourceManager():GetBloodResource():GetValue())
			self.skill_ui.magic_bottle:setPositionX(self.skill_ui.blood_label:getPositionX() - self.skill_ui.blood_label:getContentSize().width)
		else
			self:RefreshInfoListView()
		end
		self.lv_label:setString("LV " .. dragon:Level() .. "/" .. dragon:GetMaxLevel())
	end
	self.star_bar:setNum(dragon:Star())
end

function GameUIDragonEyrieDetail:OnDragonHatched()
	if self.hate_node then
		self.hate_node:removeFromParent()
	end
	self:BuildDragonContent()
	self:BuildUI()
	self.tab_buttons:SelectButtonByTag("equipment")
	self:RefreshUI()
end
--装备
function GameUIDragonEyrieDetail:CreateNodeIf_equipment()
	if self.equipment_node then return self.equipment_node end
	local equipment_node = display.newNode():addTo(self)
	self.equipment_ui = {}
	--lv label 是公用
	self.lv_label = UIKit:ttfLabel({
		text = "LV 22/50",
		size = 22,
		color = 0x403c2f
	}):align(display.BOTTOM_CENTER,window.cx,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height - 35)
	:addTo(self)
	self.equipment_ui.promotionLevel_label =  UIKit:ttfLabel({
		text = "晋级需要龙的等级达到16 级，集全全套装备，并全部强化到2星",
		size = 20,
		color = 0x403c2f
	}):align(display.BOTTOM_CENTER,window.cx,window.bottom+100):addTo(equipment_node)
	local content_box = UIKit:CreateBoxPanel(235)
		:addTo(equipment_node)
		:pos(window.left+45,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height  - 235 - 40)

	local equipment_box = display.newNode()
	equipment_box:addTo(content_box):pos(8,5)
	self.equipment_ui.equipment_box = equipment_box
	UIKit:ttfLabel({
		text = _("力量"),
		size = 20,
		color = 0x6d6651
	}):addTo(content_box):align(display.TOP_LEFT,350, 220)
	self.equipment_ui.strength_label = UIKit:ttfLabel({
		text = "400000",
		size = 24,
		color = 0x403c2f
	}):addTo(content_box):align(display.TOP_LEFT, 350, 195)

	UIKit:ttfLabel({
		text = _("活力"),
		size = 20,
		color = 0x6d6651
	}):addTo(content_box):align(display.TOP_LEFT,350, 140)

	self.equipment_ui.vitality_label = UIKit:ttfLabel({
		text = "400000",
		size = 24,
		color = 0x403c2f
	}):addTo(content_box):align(display.TOP_LEFT, 350, 115)
	WidgetPushButton.new({
		normal = "yellow_btn_up_185x65.png",
		pressed = "yellow_btn_down_185x65.png"
	}):setButtonLabel("normal", UIKit:commonButtonLable({
		text = _("晋级")
	})):align(display.BOTTOM_LEFT, 350, 10)
	   :addTo(content_box)
	   :onButtonClicked(function()
	   		self:UpgradeDragonStar()
		end)
	self.equipment_node = equipment_node
	return self.equipment_node
end


function GameUIDragonEyrieDetail:UpgradeDragonStar()
    local dragon = self:GetDragon()
    if not dragon:IsReachPromotionLevel() then
        local dialog = FullScreenPopDialogUI.new()
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(_("龙未达到晋级等级!"))
        dialog:AddToCurrentScene()
        return
    end

    if not dragon:EquipmentsIsReachMaxStar() then
        local dialog = FullScreenPopDialogUI.new()
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(_("所有装备未达到最高星级!"))
        dialog:AddToCurrentScene()
        return
    end
    
    NetManager:getUpgradeDragonStarPromise(dragon:Type()):catch(function(err)
    	dump(err:reason())
    end)
end

function GameUIDragonEyrieDetail:HandleEquipments(dragon)
	self.equipment_ui.equipment_box:removeAllChildren()
	local eqs = self.equipment_ui.equipment_box
	for i=1,6 do
        local equipment = self:GetEquipmentItem(dragon:GetEquipmentByBody(i),true)
        if i < 4 then
            local x = (i - 1)*(equipment:getContentSize().width*equipment:getScale() + 0)
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p(x,equipment:getContentSize().height*equipment:getScale() + 0))
            equipment:addTo(eqs)
        else
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p((i - 4)*(equipment:getContentSize().width*equipment:getScale() + 0),0))
            equipment:addTo(eqs)
        end
        i = i + 1 
    end     

end

function GameUIDragonEyrieDetail:GetEquipmentItem(equipment_obj,needInfoIcon)
	needInfoIcon = needInfoIcon or false
	local bgImage,bodyImage,equipmentImage = self:GetEquipmentItemImageInfo(equipment_obj)
	local equipment_node = display.newSprite(bgImage):scale(0.753)
	if equipment_obj:IsLocked() then
		equipment_node = display.newSprite(bgImage):scale(0.753)
		local icon = display.newFilteredSprite(bodyImage,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(equipment_node):pos(73,73)
		icon:setOpacity(25)
		display.newSprite("eq_lock_119x146.png", 73, 73):addTo(equipment_node):scale(0.9)

	else
		equipment_node:setTouchEnabled(true)
        equipment_node:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
         	local name, x, y = event.name, event.x, event.y
         	if name == "ended" and equipment_node:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
                self:HandleClickedOnEquipmentItem(equipment_obj)
            end
            return equipment_node:getCascadeBoundingBox():containsPoint(cc.p(x,y))
        end)
		if equipment_obj:IsLoaded() then
			display.newSprite(equipmentImage):addTo(equipment_node):pos(73,73)
			local bg = display.newSprite("dragon_star_eq_bg_28x128.png"):addTo(equipment_node):align(display.RIGHT_BOTTOM, equipment_node:getContentSize().width-10,10)
			StarBar.new({
                max = equipment_obj:MaxStar(),
                bg = "Stars_bar_bg.png",
                fill = "Stars_bar_highlight.png", 
                num = equipment_obj:Star(),
                margin = 0,
                direction = StarBar.DIRECTION_VERTICAL,
                scale = 0.6,
         	}):addTo(bg):align(display.LEFT_BOTTOM,5,24)
         	if needInfoIcon then
         		display.newSprite("draong_eq_i_25x25.png"):align(display.LEFT_BOTTOM,0, 0):addTo(bg)
         	end
		else
			local icon = display.newFilteredSprite(bodyImage,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(equipment_node):pos(73,73)
			icon:setOpacity(30)
			
		end
	end
	return equipment_node
end

--返回装备图片信息 return 背景图 身体部位图 装备图(暂时用身体图)
function GameUIDragonEyrieDetail:GetEquipmentItemImageInfo(equipment_obj)
    --装备5个星级背景
    local bgImages = {"eq_bg_1_146x146.png","eq_bg_2_146x146.png","eq_bg_3_146x146.png","eq_bg_4_146x146.png","eq_bg_5_146x146.png"}
    --表示身体部位的图
    local body = {
    	armguardLeft="armguard_1.png",armguardRight="armguard_1.png",
    	crown="crown_1.png",orb="orb_1.png",chest="chest_1.png",sting="sting_1.png"
    }
    local bg_index = equipment_obj:Star()
    if bg_index == 0 then
    	bg_index = 1
    end
    return bgImages[bg_index],body[equipment_obj:Body()],body[equipment_obj:Body()]
end

function GameUIDragonEyrieDetail:OnBasicChanged()
	self:RefreshUI()
end

function GameUIDragonEyrieDetail:OnTabButtonClicked(tag)
	if not self:GetDragon():Ishated() then return end
	if self['CreateNodeIf_' .. tag] then
		if self.current_node then 
			self.current_node:hide()
		end
		self.current_node = self['CreateNodeIf_' .. tag](self)
		self:RefreshUI()
		self.current_node:show()
	end
end

function GameUIDragonEyrieDetail:HandleClickedOnEquipmentItem(equipment_obj)
	UIKit:newGameUI("GameUIDragonEquipment",self.building,self:GetDragon(),equipment_obj):addToCurrentScene(true)
end

--技能
function GameUIDragonEyrieDetail:CreateNodeIf_skill()
	if self.skill_node then return self.skill_node end
	self.skill_ui = {}
	local skill_node = display.newNode():addTo(self)

	local list_bg = UIKit:CreateBoxPanel(320)
		:addTo(skill_node)
		:pos(window.left+45,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height - 320 - 65)

	local list = UIListView.new {
        viewRect = cc.rect(8,8, 552, 304),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT      
    }:addTo(list_bg)

    self.skill_ui.listView = list
    local star = display.newSprite("dragon_star.png")
    	:addTo(skill_node)
    	:align(display.LEFT_BOTTOM,window.left+45,list_bg:getPositionY()+320+5)
    local timeLabel = UIKit:ttfLabel({
    		text = self:GetHatchEneryLabelString(),
    		size = 20,
    		color = 0x403c2f
    	})
    	:align(display.LEFT_BOTTOM,star:getPositionX()+star:getContentSize().width+2,star:getPositionY())
    	:addTo(skill_node)
    self.skill_ui.timeLabel  = timeLabel

    local blood_label = UIKit:ttfLabel({
    		text = "",
    		size = 20,
    		color = 0x403c2f,
    		align = cc.TEXT_ALIGNMENT_LEFT
    	})
    	:addTo(skill_node)
    	:align(display.RIGHT_BOTTOM,window.right - 50,star:getPositionY())

    self.skill_ui.blood_label = blood_label
    local magic_bottle = display.newSprite("dragon_magic_bottle.png")
     	:align(display.RIGHT_BOTTOM,blood_label:getPositionX()-100, timeLabel:getPositionY()-2)
     	:addTo(skill_node)
    self.skill_ui.magic_bottle = magic_bottle
	self.skill_node = skill_node
	return self.skill_node
end

function GameUIDragonEyrieDetail:GetSkillListItem(skill)
    local bg = WidgetPushButton.new({normal = "dragon_skill_item_bg_176x116.png"}, {scale9 = false})
    bg:setAnchorPoint(cc.p(0,0))

    UIKit:ttfLabel({
    		text = Localize.dragon_skill[skill:Name()],
    		size = 18,
    		color = 0xebdba0,
    		align = cc.TEXT_ALIGNMENT_CENTER
    	})
    	:align(display.CENTER_TOP,88,115)
    	:addTo(bg)
   local box = display.newSprite("dragon_skill_box_84x84.png"):addTo(bg):align(display.LEFT_BOTTOM,5,5)
   UIKit:ttfLabel({
    		text = _("等级"),
    		size = 20,
    		color = 0x68634f,
    		align = cc.TEXT_ALIGNMENT_LEFT
    	})
   		:align(display.LEFT_CENTER,110,58)
   		:addTo(bg)

    UIKit:ttfLabel({
    		text = skill:Level(),
    		size = 24,
    		color = 0x403c2f,
    		align = cc.TEXT_ALIGNMENT_CENTER
    	})
   		:align(display.LEFT_CENTER,110,35)
   		:addTo(bg)
    --TODO:技能的图片
    if skill:IsLocked() then
    	display.newFilteredSprite("dragon_skill_70x70.png","GRAY", {0.2,0.5,0.1,0.1}):addTo(box):pos(43,41):scale(1.1)
    	display.newSprite("skill_lock_32x50.png",42,42):addTo(box)
    else
    	display.newSprite("dragon_skill_70x70.png", 43, 41):addTo(box):scale(1.1)
    end
    return bg
end

--根据skill 的key排序 并分页
function GameUIDragonEyrieDetail:GetSkillListData(perLineCount,page)
    local skills = self:GetDragon():Skills()
    local keys = table.keys(skills)
    table.sort( keys, function(a,b) return a<b end )
    local skills_local = {}

    for i,v in ipairs(keys) do
    	table.insert(skills_local,skills[v])
    end
    local pageCount =  math.ceil(#skills_local/perLineCount)
    if not page then return pageCount end
    return LuaUtils:table_slice(skills_local,1+(page - 1)*perLineCount,perLineCount*page)
end


function GameUIDragonEyrieDetail:RefreshSkillList()
	self.skill_ui.listView:removeAllItems()

   for i=1,self:GetSkillListData(3) do
        local item = self.skill_ui.listView:newItem()
        local content = display.newNode()
        local lineData = self:GetSkillListData(3,i)
        for j=1,#lineData do
            local skillData = lineData[j]
            local oneSkill = self:GetSkillListItem(skillData)
            oneSkill:addTo(content)
            local x = (j-1) * (oneSkill:getCascadeBoundingBox().width + 3)
            oneSkill:pos(x,0)
            oneSkill:onButtonClicked(function(event)
                self:SkillListItemClicked(skillData)
            end)
        end    
        item:addContent(content)
        item:setItemSize(content:getCascadeBoundingBox().width,120)
        self.skill_ui.listView:addItem(item)
    end
    self.skill_ui.listView:reload()
end

function GameUIDragonEyrieDetail:SkillListItemClicked(skill)
	if skill:IsLocked() then return end
	UIKit:newGameUI("GameUIDragonSkill",self.building,skill):addToCurrentScene(true)
end

--信息
function GameUIDragonEyrieDetail:CreateNodeIf_info()
	if self.info_node then return self.info_node end
	local info_node = display.newNode():addTo(self)
	local list_bg = display.newScale9Sprite("box_bg_546x214.png")
		:addTo(info_node)
		:align(display.LEFT_BOTTOM, window.left+45,self.lv_label:getPositionY() - 212 - 20)
		:size(546, 212)
	self.info_list = UIListView.new({
        viewRect = cc.rect(13,10, 520, 192),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT      
    })
    :addTo(list_bg,2)
	self.info_node = info_node
	return self.info_node
end

function GameUIDragonEyrieDetail:RefreshInfoListView()
	dump(self:GetInfomationData())
	self.info_list:removeAllItems()
	for index,v in ipairs(self:GetInfomationData()) do
		 local item = self.info_list:newItem()
		 local content = self:GetInfoListItem(index,v[1],v[2])
		 item:addContent(content)
		 item:setItemSize(520, 48)
		 self.info_list:addItem(item)
	end
	self.info_list:reload()
end

function GameUIDragonEyrieDetail:GetInfomationData()
	local r = {}
	local dragon = self:GetDragon()
	for __,v in ipairs(dragon:GetAllEquipmentBuffEffect()) do
		table.insert(r,{Localize.dragon_buff_effection[v[1]],v[2]*100})
	end

	for __,v in ipairs(dragon:GetAllSkillBuffEffect()) do
		table.insert(r,{Localize.dragon_skill_effection[v[1]],v[2]*100})
	end
	return r
end

function GameUIDragonEyrieDetail:GetInfoListItem(index,title,val)
	local bg = display.newSprite(string.format("box_bg_item_520x48_%d.png",index%2))
	UIKit:ttfLabel({
	 	text = title,
	 	color = 0x615b44,
	 	size = 20
	 }):align(display.LEFT_CENTER, 10, 24):addTo(bg)

	UIKit:ttfLabel({
	 	text = val,
	 	color = 0x403c2f,
	 	size = 20,
	 	align = cc.TEXT_ALIGNMENT_RIGHT,
	 }):align(display.RIGHT_CENTER, 510, 24):addTo(bg)
	 return bg
end

return GameUIDragonEyrieDetail