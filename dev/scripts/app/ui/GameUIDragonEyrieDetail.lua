--
-- Author: Danny He
-- Date: 2014-10-31 15:08:59
--
local GameUIDragonEyrieDetail = UIKit:createUIClass("GameUIDragonEyrieDetail","GameUIWithCommonHeader")
local cocos_promise = import('..utils.cocos_promise')
local window = import('..utils.window')
local StarBar = import(".StarBar")
local DragonSprite = import("..sprites.DragonSprite")
local GameUIDragonEyrieMain = import(".GameUIDragonEyrieMain")
local WidgetPushButton = import("..widget.WidgetPushButton")
local DragonManager = import("..entity.DragonManager")
local WidgetDragonTabButtons = import("..widget.WidgetDragonTabButtons")
local Dragon = import("..entity.Dragon")
local UIListView = import(".UIListView")
local Localize = import("..utils.Localize")
local config_intInit = GameDatas.PlayerInitData.intInit
local WidgetUseItems = import("..widget.WidgetUseItems")
local GameUIDragonHateSpeedUp = import(".GameUIDragonHateSpeedUp")
local UILib = import(".UILib")

-- building = DragonEyrie
function GameUIDragonEyrieDetail:ctor(city,building,dragon_type)
    GameUIDragonEyrieDetail.super.ctor(self,city,_("龙巢"))
    self.building = building
    self.dragon_manager = building:GetDragonManager()
    self.dragon = self.dragon_manager:GetDragon(dragon_type)
    self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
    self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
    self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventTimer)
    self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventChanged)
end

function GameUIDragonEyrieDetail:OnDragonEventChanged()
    local dragonEvent = self.dragon_manager:GetDragonEventByDragonType(self:GetDragon():Type())
    if dragonEvent then
        self:RefreshUI()
    end
end
function GameUIDragonEyrieDetail:OnDragonEventTimer(dragonEvent)
    if self:GetDragon():Type() == dragonEvent:DragonType() and self.hate_label_2 and self.hate_label_2:isVisible() then
        self.hate_label_2:setString(GameUtils:formatTimeStyleDayHour(dragonEvent:GetTime()))
        self.hate_button:hide()
        self.hate_speed_button:show()
        self.dragonEvent__ = dragonEvent
    end
end

function GameUIDragonEyrieDetail:CreateBetweenBgAndTitle()
    self.content_node = display.newNode():addTo(self:GetView())
    local clipNode = display.newClippingRegionNode(cc.rect(0,0,614,519))
    clipNode:addTo(self.content_node):pos(window.cx - 307,window.top - 519)
    display.newSprite("dragon_animate_bg_624x606.png"):align(display.LEFT_BOTTOM,-5,0):addTo(clipNode)
    display.newSprite("eyrie_584x547.png"):align(display.CENTER_TOP,307, 353):addTo(clipNode)
    self.dragon_base = clipNode
    self:BuildDragonContent()
    local star_bg = display.newSprite("dragon_title_bg_534x16.png")
        :align(display.CENTER_TOP,window.cx,window.top - 100)
        :addTo(self.content_node)
    self.star_bg = star_bg
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
    self.tab_buttons = WidgetDragonTabButtons.new(function(tag)
        self:OnTabButtonClicked(tag)
    end):addTo(self.dragon_base):pos(-4,-42)

end

function GameUIDragonEyrieDetail:OnMoveInStage()
    GameUIDragonEyrieDetail.super.OnMoveInStage(self)
    self:BuildUI()
end

function GameUIDragonEyrieDetail:OnMoveOutStage()
    self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
    self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonHatched)
    self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventTimer)
    self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDragonEventChanged)
    GameUIDragonEyrieDetail.super.OnMoveOutStage(self)
end

function GameUIDragonEyrieDetail:VisibleStarBar(v)
    self.star_bg:setVisible(v)
end

function GameUIDragonEyrieDetail:BuildUI()
    if self:GetDragon():Ishated() then
        self.tab_buttons:VisibleFunctionButtons(true)
        self.tab_buttons:SelectButtonByTag("equipment")
        self:VisibleStarBar(true)
    else -- 未孵化
        self.tab_buttons:SetTitleString(self:GetDragon():GetLocalizedName())
        self.tab_buttons:VisibleFunctionButtons(false)
        self:CreateHateUIIf()
        self:VisibleStarBar(false)
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

function GameUIDragonEyrieDetail:GetHateLabelText()
    local dragonEvent = self.dragon_manager:GetDragonEventByDragonType(self:GetDragon():Type())
    if dragonEvent then
        return _("正在孵化,剩余时间"),GameUtils:formatTimeStyleDayHour(dragonEvent:GetTime())
    else
        return string.format(Localize.hate_dragon[self:GetDragon():Type()] .. _("需要%.1f个小时"),
            config_intInit['playerHatchDragonNeedMinutes']['value']),_("龙巢同一时间只能孵化一只巨龙")
    end
end

function GameUIDragonEyrieDetail:CheckCanSpeedUpDragonHate()
    return self.dragon_manager:GetDragonEventByDragonType(self:GetDragon():Type()) ~= nil
end

--孵化界面
function GameUIDragonEyrieDetail:CreateHateUIIf()
    if self.hate_node then
        self.hate_node:show()
        return
    end
    local hate_node = display.newNode():addTo(self:GetView())
    local hate_button = WidgetPushButton.new({
        normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"
    }):setButtonLabel("normal",UIKit:ttfLabel({
        text = _("开始孵化"),
        size = 24,
        color = 0xffedae,
        shadow = true
    })):addTo(hate_node):align(display.CENTER_BOTTOM,window.cx,window.bottom + 20):onButtonClicked(function()
        self:OnEnergyButtonClicked()
    end)
    self.hate_button = hate_button
    local speed_button = WidgetPushButton.new({
        normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"
    },{scale9 = true}):setButtonSize(185, 65):setButtonLabel("normal",UIKit:ttfLabel({
        text = _("加速"),
        size = 24,
        color = 0xffedae,
        shadow = true
    }))
        :addTo(hate_node):align(display.CENTER_BOTTOM,window.cx,window.bottom + 20)
        :onButtonClicked(handler(self, self.OnHateSpeedUpClicked))
    speed_button:setVisible(self:CheckCanSpeedUpDragonHate())

    self.hate_speed_button = speed_button
    local hate_bg = UIKit:CreateBoxPanel9({width = 556,height = 78})
        :addTo(hate_node)
        :align(display.CENTER_BOTTOM,window.cx,hate_button:getPositionY()+hate_button:getCascadeBoundingBox().height+6)
    local label_text_1,label_text_2 = self:GetHateLabelText()
    self.hate_label_1 = UIKit:ttfLabel({
        text = label_text_1,
        size = 20,
        color= 0x403c2f
    }):align(display.TOP_CENTER, 278, 70):addTo(hate_bg)
    self.hate_label_2 = UIKit:ttfLabel({
        text = label_text_2,
        size = 20,
        color= 0x403c2f
    }):align(display.BOTTOM_CENTER, 278, 18):addTo(hate_bg)
    local icon_bg = display.newSprite("hate_dragon_icon_bg_232x188.png")
        :addTo(hate_node)
        :align(display.CENTER_BOTTOM,window.cx,hate_bg:getPositionY()+hate_bg:getContentSize().height+8):scale(0.9)
    display.newSprite("redDragon_icon_151x133.png", 96,114):addTo(icon_bg)

    local tip_label = UIKit:ttfLabel({
        text = Localize.dragon_buffer[self:GetDragon():Type()],
        size = 18,
        color= 0x797154,
        align= cc.TEXT_ALIGNMENT_CENTER
    })
        :addTo(hate_node)
        :align(display.CENTER_BOTTOM, window.cx, icon_bg:getPositionY()+icon_bg:getCascadeBoundingBox().height + 10)
    local title_bar = display.newSprite("cyan_title_bar_570x30.png")
        :addTo(hate_node)
        :align(display.BOTTOM_CENTER, window.cx, tip_label:getPositionY()+tip_label:getContentSize().height+15)
    UIKit:ttfLabel({
        text = Localize.hate_dragon[self:GetDragon():Type()],
        size = 22,
        color= 0xffedae
    }):align(display.CENTER,285,15):addTo(title_bar)

    self.hate_node = hate_node
    self:RefreshUI()
    return self.hate_node
end

function GameUIDragonEyrieDetail:OnResourceChanged(resource_manager)
    GameUIDragonEyrieDetail.super.OnResourceChanged(self,resource_manager)
    if not self:GetDragon():Ishated() then return end
    if self.skill_ui and self.skill_ui.blood_label then
        self.skill_ui.blood_label:setString(resource_manager:GetBloodResource():GetValue())
    end
end

function GameUIDragonEyrieDetail:GetDragon()
    return self.dragon
end
--充能
function GameUIDragonEyrieDetail:OnEnergyButtonClicked()
    local dragon = self:GetDragon()
    NetManager:getHatchDragonPromise(dragon:Type())
end

function GameUIDragonEyrieDetail:RefreshUI()
    local dragon = self:GetDragon()
    if not dragon:Ishated() then
        if not self.hate_node then return end
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
    self:VisibleStarBar(true)
    self.tab_buttons:SelectButtonByTag("equipment")
    self.tab_buttons:VisibleFunctionButtons(true)
    self:RefreshUI()
end
--装备
function GameUIDragonEyrieDetail:CreateNodeIf_equipment()
    if self.equipment_node then return self.equipment_node end
    local equipment_node = display.newNode():addTo(self:GetView())
    self.equipment_ui = {}
    --lv label 是公用
    self.lv_label = UIKit:ttfLabel({
        text = "LV 22/50",
        size = 22,
        color = 0x403c2f
    }):align(display.BOTTOM_CENTER,window.cx,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height - 35)
        :addTo(self:GetView())
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
        UIKit:showMessageDialog(_("提示"), _("龙未达到晋级等级"), function()end)
        return
    end

    if not dragon:EquipmentsIsReachMaxStar() then
        UIKit:showMessageDialog(_("提示"), _("所有装备未达到最高星级"), function()end)
        return
    end
    NetManager:getUpgradeDragonStarPromise(dragon:Type())
end

function GameUIDragonEyrieDetail:HandleEquipments(dragon)
    self.equipment_nodes = {}
    self.equipment_ui.equipment_box:removeAllChildren()
    local eqs = self.equipment_ui.equipment_box
    for i=1,6 do
        local equipment = self:GetEquipmentItem(dragon:GetEquipmentByBody(i),true)
        if i < 4 then
            local x = (i - 1)*(equipment:getContentSize().width*equipment:getScale() + 10)
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p(x,equipment:getContentSize().height*equipment:getScale() + 10))
            equipment:addTo(eqs)
        else
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p((i - 4)*(equipment:getContentSize().width*equipment:getScale() + 10),0))
            equipment:addTo(eqs)
        end
        i = i + 1
        table.insert(self.equipment_nodes,equipment)
    end

end

function GameUIDragonEyrieDetail:GetEquipmentItem(equipment_obj,needInfoIcon)
    needInfoIcon = needInfoIcon or false
    local bgImage,bodyImage,equipmentImage = self:GetEquipmentItemImageInfo(equipment_obj)
    local equipment_node = display.newSprite(bgImage):scale(0.71)
    if equipment_obj:IsLocked() then
        equipment_node = display.newSprite(bgImage):scale(0.71)
        local icon = display.newFilteredSprite(bodyImage,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(equipment_node):pos(73,73)
        -- icon:setOpacity(25)
        display.newSprite("lock_80x104.png", 73, 73):addTo(equipment_node)

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
            -- icon:setOpacity(30)

        end
    end
    return equipment_node
end

--返回装备图片信息 return 背景图 身体部位图 装备图(暂时用身体图)
function GameUIDragonEyrieDetail:GetEquipmentItemImageInfo(equipment_obj)
    --装备5个星级背景
    local bgImages = {"eq_bg_1_146x146.png","eq_bg_2_146x146.png","eq_bg_3_146x146.png","eq_bg_4_146x146.png","eq_bg_5_146x146.png"}
    local bg_index = equipment_obj:Star()
    if bg_index == 0 then
        bg_index = 1
    end
    local image = UILib.getDragonEquipmentImage(equipment_obj:Type(),equipment_obj:Body(),bg_index)
    return bgImages[bg_index],image,image
end

function GameUIDragonEyrieDetail:OnBasicChanged()
    self:RefreshUI()
end

function GameUIDragonEyrieDetail:OnTabButtonClicked(tag)
    if tag == 'back' then
        self:LeftButtonClicked()
        return
    end
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
    UIKit:newGameUI("GameUIDragonEquipment",self.building,self:GetDragon(),equipment_obj):AddToCurrentScene(true)
end

--技能
function GameUIDragonEyrieDetail:CreateNodeIf_skill()
    if self.skill_node then return self.skill_node end
    self.skill_ui = {}
    local skill_node = display.newNode():addTo(self:GetView())

    local list_bg = UIKit:CreateBoxPanel(316)
        :addTo(skill_node)
        :pos(window.left+45,self.dragon_base:getPositionY()-self.dragon_base:getContentSize().height - 320 - 90)
    local header_bg = UIKit:CreateBoxPanel9({height = 40}):addTo(skill_node):align(display.LEFT_BOTTOM, list_bg:getPositionX(), list_bg:getPositionY()+316+10)
    local list = UIListView.new {
        viewRect = cc.rect(8,8, 552, 302),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    }:addTo(list_bg)
    local add_button = WidgetPushButton.new({normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"})
        :addTo(header_bg)
        :scale(0.7)
        :align(display.RIGHT_CENTER,540,20)
        :onButtonClicked(function()
            self:OnHeroBloodUseItemClicked()
        end)

    self.skill_ui.listView = list
    local blood_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x403c2f,
        align = cc.TEXT_ALIGNMENT_RIGHT
    })
        :addTo(header_bg)
        :align(display.RIGHT_CENTER,add_button:getPositionX() - 50,add_button:getPositionY())

    self.skill_ui.blood_label = blood_label
    local magic_bottle = display.newSprite("dragon_magic_bottle.png")
        :align(display.LEFT_CENTER,15, blood_label:getPositionY())
        :addTo(header_bg)
    UIKit:ttfLabel({
        text = _("英雄之血"),
        size = 20,
        color = 0x403c2f,
        align = cc.TEXT_ALIGNMENT_LEFT
    }):align(display.LEFT_CENTER, magic_bottle:getPositionX() + magic_bottle:getContentSize().width + 10, magic_bottle:getPositionY()):addTo(header_bg)
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
    local skill_icon = UILib.dragon_skill_icon[skill:Name()][skill:Type()]
    if skill:IsLocked() then
        display.newFilteredSprite(skill_icon,"GRAY", {0.2,0.5,0.1,0.1}):addTo(box):pos(43,41):scale(74/128)
        display.newSprite("skill_lock_32x50.png",42,42):addTo(box)
    else
        display.newSprite(skill_icon, 43, 41):addTo(box):scale(74/128)
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
            local x = (j-1) * (176 + 4)
            oneSkill:pos(x,0)
            oneSkill:onButtonClicked(function(event)
                self:SkillListItemClicked(skillData)
            end)
        end
        content:size(552,120)
        item:addContent(content)
        item:setItemSize(552,120)
        self.skill_ui.listView:addItem(item)
    end
    self.skill_ui.listView:reload()
end

function GameUIDragonEyrieDetail:SkillListItemClicked(skill)
    if skill:IsLocked() then return end
    UIKit:newGameUI("GameUIDragonSkill",self.building,skill):AddToCurrentScene(true)
end

--信息
function GameUIDragonEyrieDetail:CreateNodeIf_info()
    if self.info_node then return self.info_node end
    local info_node = display.newNode():addTo(self:GetView())
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
        if v[2]*100 > 0 then
            table.insert(r,{Localize.dragon_buff_effection[v[1]] or v[1],string.format("%d%%",v[2]*100)})
        end
    end

    for __,v in ipairs(dragon:GetAllSkillBuffEffect()) do
        if v[2]*100 > 0 then
            table.insert(r,{Localize.dragon_skill_effection[v[1]] or v[1],string.format("%d%%",v[2]*100)})
        end
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

function GameUIDragonEyrieDetail:OnHateSpeedUpClicked()
    UIKit:newGameUI("GameUIDragonHateSpeedUp", self.dragon_manager,self.dragonEvent__):AddToCurrentScene(true)
end

-- dragon_body ==> Dragon.DRAGON_BODY.XXX
function GameUIDragonEyrieDetail:Find(dragon_body)
    dragon_body = checknumber(dragon_body)
    return cocos_promise.defer(function()
        if not self.equipment_nodes[dragon_body] then
            promise.reject({code = -1, msg = "没有找到对应item"}, building_type)
        end
        return self.equipment_nodes[dragon_body]
    end)
end

function GameUIDragonEyrieDetail:OnHeroBloodUseItemClicked()
    local widgetUseItems = WidgetUseItems.new():Create({
        item_type = WidgetUseItems.USE_TYPE.HERO_BLOOD,
        dragon = self:GetDragon()
    })
    widgetUseItems:AddToCurrentScene()
end

return GameUIDragonEyrieDetail

