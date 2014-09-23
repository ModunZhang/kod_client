--
-- Author: Danny He
-- Date: 2014-09-17 09:00:04
--
local GameUIDragonEyrie = UIKit:createUIClass("GameUIDragonEyrie","GameUIWithCommonHeader")
local TabButtons = import(".TabButtons")
local StarBar = import(".StarBar")
local UIListView = import(".UIListView")

function GameUIDragonEyrie:GetStarBar()
end


function GameUIDragonEyrie:ctor(city,building)
	GameUIDragonEyrie.super.ctor(self,City,_("龙巢"))
    self.building = building
    self.building:SetListener(self)
    self.current_page = 0
end

function GameUIDragonEyrie:onEnter()
	GameUIDragonEyrie.super.onEnter(self)
	self:CreateTabButtons()
    self:ChangePageAction(1)
end

function GameUIDragonEyrie:ChangePageAction(pageFlag)
    local targetPage = self.current_page + pageFlag
    if targetPage > 0 and targetPage < 4 and self.current_page ~= targetPage then
        self.current_page = targetPage
    end
    if self.dragonUI then
        self.dragonUI.pageControl:setNum(self.current_page)
    end
    self:ChangeCurentContent(self.button_tag)
end

function GameUIDragonEyrie:GetCurrentDragon()
    return self.building:GetDragonEntity(self.current_page)
end


function GameUIDragonEyrie:RefreshUIData()
    local dragon = self:GetCurrentDragon()
    if self.dragon_bg then -- 龙
        self.dragonUI.dragonNameLabel:setString(dragon.type)
        self.dragonUI.dragonLVLabel:setString("LV " .. dragon.level .. '/' .. self.building:GetLevelMaxWithStar(dragon.star))
        self.dragonUI.dragonLVLabel:setVisible(dragon.star>0)
        self.dragonUI.dragonStarBar:setNum(dragon.star)
        self.dragonUI.dragonEXPLabel:setString(dragon.exp .. '/' .. self.building:GetNextLevelMaxExp(dragon))
        self.dragonUI.dragonEXPLabel:setVisible(dragon.star>0)
        self.dragonUI.dragonStateLabel:setString(dragon.status)
        if dragon.star < 1 then -- 孵化
            self.dragonUI.vitalityProgressMain:hide()
            self.dragonUI.dragon_LV_icon:hide()
            self.dragonUI.dragonContent:setTexture("dragon_hatch.png")
            local energy = City.resource_manager:GetEnergyResource()
            self.hatchUI.nextEnergyLabel:setString(self:GetHatchEneryLabelString())
            self.hatchUI.costEnergyLabel:setString(100) -- 服务器暂时定值为100 TODO: 转化一次 消耗 100 能量 ---> 100活力
            self.hatchUI.progressTimer:setPercentage(dragon.vitality/100) -- vitality此时为孵化龙的活力 不会自增长 需要自己转化  100为服务器暂定值
            self.hatchUI.drgonVitalityLabel:setString(dragon.vitality .. "/100")
        else
            self.dragonUI.vitalityProgressMain:show()
            self.dragonUI.dragon_LV_icon:show()
            self.dragonUI.dragonContent:setTexture("dragon.png")
            self.dragonUI.drgonVitalityProgress:setPercentage(dragon.vitality/self.building:GetMaxVitalityCurrentLevel(dragon)*100)
            self.dragonUI.drgonVitalityLabel:setString(dragon.vitality .. "/" .. self.building:GetMaxVitalityCurrentLevel(dragon))
            self.dragonUI.vitalityProductPerHourLabel:setString("+" .. self.building:GetVitalityRecoveryPerHour() .. "/h")
        end

        local currentButtonTag = self.tabButton:GetSelectedButtonTag()
        if dragon.star > 0 then --不是孵化界面
            if currentButtonTag == "equipment" then
                self.equipmentUI.strenghLabel:setString(dragon.strength)
                self.equipmentUI.vitailtyLabel:setString(dragon.vitality)
                --
                -- self.equipmentUI.equipmentContent
                self:HandleEquipmentItem(dragon)
            end
        end
    end
end
-- api
function GameUIDragonEyrie:HatchAction()
    local dragon = self:GetCurrentDragon()
    PushService:HatchDragon(dragon.type,function()end)
end

function GameUIDragonEyrie:DragonDataChanged()
    self:ChangeCurentContent(self.button_tag)
end

function GameUIDragonEyrie:ChangeCurentContent(tag)
    if self.current_content then
        self.current_content:setVisible(false)
    end
    if tag == "equipment" then
        self:CreateDragonIf() -- 龙信息
        if self:GetCurrentDragon() and self:GetCurrentDragon().star < 1 then
            self.current_content = self:CreateHatchDragonIf()
        else
             self.current_content = self:CreateEquipmentContentIf()
        end
        self:RefreshUIData()
    end
    if self.dragonEquipment then
        self.dragonEquipment:DragonDataChanged()
    end
end


function GameUIDragonEyrie:TabButtonsAction(tag)
    self.button_tag = tag
    if tag == "upgrade" then
        if self.dragon_bg then
            self.dragon_bg:setVisible(false)
            self.current_content:setVisible(false)
        end
    else
        self:ChangeCurentContent(tag)
    end
end

--计算获取下一点能量的剩余时间
function GameUIDragonEyrie:GetHatchEneryLabelString()
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

function GameUIDragonEyrie:OnResourceChanged(resource_manager)
    GameUIDragonEyrie.super.OnResourceChanged(self,resource_manager)
    local energy = resource_manager:GetEnergyResource()
    if self.building and self.hatchUI and energy then
        self.hatchUI.nextEnergyLabel:setString(self:GetHatchEneryLabelString())
    end
end


function GameUIDragonEyrie:CreateDragonIf()
	if self.dragon_bg then self.dragon_bg:setVisible(true) return self.dragon_bg end -- 只需创建一次
    self.dragonUI = {}

	local bg = display.newSprite("dragon_bg.png")
		:addTo(self)
        :pos(display.cx,display.top - 350)
	local title = display.newSprite("drgon_title_blue.png")
		:addTo(bg)
		:align(display.LEFT_TOP, 8, bg:getContentSize().height-8)
	self.dragonUI.dragonNameLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "Red Dragon",
        font = UIKit:getFontFilePath(),
        size = 28,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title):align(display.LEFT_BOTTOM, 10, 10)

	self.dragonUI.dragonLVLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "LV 20/50",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xb1a475)
    }):addTo(title):align(display.RIGHT_BOTTOM, title:getContentSize().width - 10, 10)

	local drgonBg = display.newSprite("dragon.png")
		:addTo(bg):align(display.LEFT_TOP,display.left+9,title:getPositionY() - title:getContentSize().height+3)
    self.dragonUI.dragonContent = drgonBg
	local shieldView = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
			:addTo(bg)
			:size(595,31)
			:pos(display.left+9, title:getPositionY() - title:getContentSize().height-28)
    self.dragonUI.dragonStarBar = StarBar.new({
		max = 5,
		bg = "Stars_bar_bg.png",
		fill = "Stars_bar_highlight.png", 
		num = 3,
		margin = 0,
	}):addTo(shieldView)
	self.dragonUI.dragonEXPLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "2600/2600",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xb1a475)
    }):addTo(shieldView):align(display.RIGHT_BOTTOM, 585, 5)


	local rightButton = cc.ui.UIPushButton.new({normal = "drgon_switching_normal.png",pressed = "drgon_switching_hight.png"}, {scale9 = false}):addTo(bg)
	rightButton:align(display.RIGHT_TOP,bg:getContentSize().width - 7,shieldView:getPositionY() - 80)
        :onButtonClicked(function()
            self:ChangePageAction(1)
        end)
	local leftButton = cc.ui.UIPushButton.new({normal = "drgon_switching_normal.png",pressed = "drgon_switching_hight.png"}, {scale9 = false}):addTo(bg)
        :onButtonClicked(function()
            self:ChangePageAction(-1)
        end)
	leftButton:setRotation(180)
	leftButton:pos(display.left+35,shieldView:getPositionY()-80 - 56)
    self.dragonUI.prePageButton = leftButton
    self.dragonUI.nextPageButton = rightButton
	local lv_bg = display.newSprite("drgon_lvbar_bg.png"):addTo(bg):align(display.RIGHT_TOP,drgonBg:getContentSize().width+10,drgonBg:getPositionY()-drgonBg:getContentSize().height)
    self.dragonUI.vitalityProgressMain = lv_bg
	local progressFill = display.newSprite("drgon_lvbar_color.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(lv_bg)
    ProgressTimer:setPercentage(0)
    self.dragonUI.drgonVitalityProgress = ProgressTimer
    self.dragonUI.drgonVitalityLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "120/360",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xfff3c7)
    }):addTo(lv_bg):align(display.LEFT_BOTTOM, 20, 5)

    self.dragonUI.vitalityProductPerHourLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "+55/h",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xfff3c7)
    }):addTo(lv_bg):align(display.RIGHT_BOTTOM, lv_bg:getContentSize().width - 50, 5)

    local iconbg = display.newSprite("drgon_process_icon_bg.png")
    	:addTo(bg)
    	:align(display.LEFT_TOP, 8,drgonBg:getPositionY()-drgonBg:getContentSize().height+5)
    self.dragonUI.dragon_LV_icon = iconbg
	display.newSprite("dragon_lv_icon.png")
		:addTo(iconbg)
		:pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)
	local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "待命中",
        font = UIKit:getFontFilePath(),
        size = 20,
        valign = cc.ui.TEXT_VALIGN_CENTER,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0x388500)
    }):addTo(bg):align(display.CENTER,bg:getContentSize().width/2,lv_bg:getPositionY() - lv_bg:getContentSize().height - 20)
    self.dragonUI.dragonStateLabel = label
    local pageContent = StarBar.new({
		max = 3,
		bg = "dragon_page_bg.png",
		fill = "dragon_page_focus.png", 
		num = 1,
		margin = 20,
		fillFunc = function(index,current,max)
			return index == current
		end
	})
    self.dragonUI.pageControl = pageContent
	pageContent:pos(display.cx-pageContent:getContentSize().width/2,label:getPositionY() - label:getContentSize().height-10):addTo(bg)
	local add_button = cc.ui.UIPushButton.new({normal = "dragon_add_button_normal.png",pressed = "dragon_add_button_highlight.png"}, {scale9 = false})
		:addTo(lv_bg)
		:align(display.TOP_RIGHT,lv_bg:getContentSize().width,lv_bg:getContentSize().height)
	
    self.dragon_bg = bg
    return self.dragon_bg
end

function GameUIDragonEyrie:CreateHatchDragonIf()
    --bindData
    if self.content_hatchdragon then self.content_hatchdragon:setVisible(true) return self.content_hatchdragon end
    self.hatchUI = {}

    local hatchNode = display.newNode()
    local content_bg = display.newScale9Sprite("dragon_content_bg.png")
        :addTo(hatchNode)
        :align(display.LEFT_BOTTOM, 0, 0)
    local rect = content_bg:getContentSize()
    hatchNode:addTo(self)
        :pos((display.width - content_bg:getContentSize().width)/2,self.dragon_bg:getPositionY()-self.dragon_bg:getContentSize().height/2-content_bg:getContentSize().height)
    content_bg:size(content_bg:getContentSize().width,content_bg:getContentSize().height/2)
     cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("消耗能量,为龙蛋补充活力,活力补充到100时,可以获得巨龙"),
        font = UIKit:getFontFilePath(),
        size = 20,
        dimensions = cc.size(content_bg:getContentSize().width,content_bg:getContentSize().height),
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x6403c2f)
    }):addTo(content_bg,2):align(display.LEFT_TOP, 10, content_bg:getContentSize().height - 20)

    local iconbg = display.newSprite("drgon_process_icon_bg.png")
        :addTo(hatchNode)
        :align(display.LEFT_BOTTOM, 0,content_bg:getContentSize().height + 20)
    display.newSprite("dragon_lv_icon.png")
        :addTo(iconbg)
        :pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)

    local lv_bg = display.newScale9Sprite("drgon_lvbar_bg.png"):addTo(hatchNode,-1):align(display.LEFT_BOTTOM,30,content_bg:getContentSize().height + 22)
    lv_bg:size(400,lv_bg:getContentSize().height)
    local progressFill = display.newSprite("drgon_lvbar_color.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setScaleX(0.71)
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(lv_bg,2)
    ProgressTimer:setPercentage(100)
    self.hatchUI.progressTimer = ProgressTimer
    local hateButton = cc.ui.UIPushButton.new({normal = "dragon_yellow_button.png",pressed = "dragon_yellow_button_h.png"}, {scale9 = true})
    :setButtonSize(110,50)
    :setButtonLabel("normal",  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("孵化"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0xffedae)
    }))
    :onButtonClicked(function()
        self:HatchAction()
    end)
    :addTo(hatchNode)
    :align(display.LEFT_BOTTOM,lv_bg:getPositionX()+410,lv_bg:getPositionY()-5)

    self.hatchUI.drgonVitalityLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("120/360"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(lv_bg,3):pos(20,lv_bg:getContentSize().height/2)

    local energyIcon_big =  display.newSprite("dragon_hate_icon.png"):align(display.LEFT_BOTTOM,0,iconbg:getPositionY()+iconbg:getContentSize().height + 20)
        :addTo(hatchNode)
    self.hatchUI.nextEnergyLabel =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "80/100 下一点 00:02:32",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(hatchNode):align(display.LEFT_BOTTOM,energyIcon_big:getPositionX()+energyIcon_big:getContentSize().width,energyIcon_big:getPositionY()+10)

    local energyIcon_small = display.newSprite("dragon_hate_icon.png")
        :align(display.RIGHT_BOTTOM,rect.width - 100,energyIcon_big:getPositionY()+5)
        :addTo(hatchNode)
    energyIcon_small:setScale(0.6)

    local lvBg = display.newSprite("LV_background.png"):addTo(hatchNode,-1)
        :align(display.LEFT_BOTTOM, energyIcon_small:getPositionX()-10, energyIcon_small:getPositionY())

    self.hatchUI.costEnergyLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "20",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(lvBg):align(display.LEFT_BOTTOM,40,2)

    self.content_hatchdragon = hatchNode
    return self.content_hatchdragon
end


function GameUIDragonEyrie:CreateEquipmentContentIf()
	if self.equipment_content then self.equipment_content:setVisible(true) return self.equipment_content end
    self.equipmentUI = {}
	local content_bg = display.newSprite("dragon_content_bg.png")
		:addTo(self)
	content_bg:pos(display.cx,self.dragon_bg:getPositionY()-self.dragon_bg:getContentSize().height/2-130)
	local eqs = display.newNode()
	-- for i=1,6 do
	-- 	local eq = self:GetEquipmentItem()
	-- 	if i < 4 then
	-- 		local x = (i - 1)*(eq:getContentSize().width + 10)
 --            eq:setAnchorPoint(cc.p(0,0))
 --            eq:setPosition(cc.p(x,0))
 --            eq:addTo(eqs)
	-- 	else
 --            eq:setAnchorPoint(cc.p(0,0))
 --            eq:setPosition(cc.p((i - 4)*(eq:getContentSize().width + 10),eq:getContentSize().height + 10))
 --            eq:addTo(eqs)
	-- 	end
	-- end
	eqs:addTo(content_bg):pos(8,16)
    self.equipmentUI.equipmentContent = eqs
	local upgradeButton = cc.ui.UIPushButton.new({normal = "dragon_yellow_button.png",pressed = "dragon_yellow_button_h.png"}, {scale9 = false})
		:addTo(content_bg)
		:align(display.RIGHT_BOTTOM,content_bg:getContentSize().width - 10, 15)
		:setButtonLabel("normal",cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	        text = "晋级",
	        font = UIKit:getFontFilePath(),
	        size = 24,
	        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
	        color = UIKit:hex2c3b(0xfff3c7)
		}))

	 cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("力量"),
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x6d6651)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 210)
	self.equipmentUI.strenghLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "400000000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 180)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("活力"),
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x6d6651)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 130)

    self.equipmentUI.vitailtyLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "400000000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 100)
    self.equipment_content = content_bg
    return self.equipment_content
end

--返回装备的背景图和装备icon
function GameUIDragonEyrie:GetEquipmentItemImageInfo( dragonType,equipmentCategory,equipmentStar)
    --三条龙的背景
    local bgImages = {greenDragon="drgon_eq_bg_gray.png",redDragon="drgon_eq_bg_gray.png",blueDragon="drgon_eq_bg_gray.png"}
    local equipmentIcon = {}
    --五个星级的装备
    equipmentIcon["armguardLeft"] = {"armguard_1.png","armguard_1.png","armguard_1.png","armguard_1.png","armguard_1.png"}
    equipmentIcon["armguardRight"] = {"armguard_1.png","armguard_1.png","armguard_1.png","armguard_1.png","armguard_1.png"}
    equipmentIcon["crown"] = {"crown_1.png","crown_1.png","crown_1.png","crown_1.png","crown_1.png"}
    return bgImages[dragonType],equipmentIcon[equipmentCategory][equipmentStar]
end



function GameUIDragonEyrie:GetEquipmentItem(isFromConfig,equipmentCategory,dragon)
    local config_equipments = self.building:GetEquipmentsByStarAndType(dragon.star,dragon.type)
    local equipment = config_equipments[equipmentCategory]
    if not equipment then -- 锁住的部位:TODO
        local bgImage,equipmentIcon = "drgon_eq_bg_gray.png","crown_1.png"
        local bg = display.newSprite(bgImage)
        display.newFilteredSprite(equipmentIcon,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(bg):opacity(23):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
        return bg
    else
        equipment = config_equipments[equipmentCategory]
        if not isFromConfig then --来自服务器
            equipment = dragon.equipments[equipmentCategory]
        end
        local bgImage,equipmentIcon = self:GetEquipmentItemImageInfo(dragon.type,equipmentCategory,dragon.star)
        local bg = display.newSprite(bgImage)
        bg:setTouchEnabled(true)
        bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
         local name, x, y = event.name, event.x, event.y
         if name == "ended" and bg:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
                self:HandleClickedOnEquipmentItem(dragon,equipmentCategory)
            end
            return bg:getCascadeBoundingBox():containsPoint(cc.p(x,y))
        end)
        if not isFromConfig then
           display.newSprite(equipmentIcon):addTo(bg):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
            local stars_bg = display.newSprite("dragon_eq_stars_bg.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
            local info = display.newSprite("dragon_eq_info.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
            StarBar.new({
                max = dragon.star,
                bg = "Stars_bar_bg.png",
                fill = "Stars_bar_highlight.png", 
                num = equipment.star,
                margin = 0,
                direction = StarBar.DIRECTION_VERTICAL,
                scale = 0.5,
         }):addTo(bg):align(display.LEFT_BOTTOM,info:getPositionX()-20, info:getPositionY()+info:getContentSize().height - 25)   
        else
            display.newFilteredSprite(equipmentIcon,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(bg):opacity(23):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
            local info = display.newSprite("dragon_eq_info.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
        end
        return bg
    end
end

function GameUIDragonEyrie:CreateSkillContentIf()
	if self.skill_content then self.skill_content:setVisible(true) return self.skill_content end
    local skill = display.newNode()


    local list = UIListView.new {
        bg = "dragon_content_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(0, 0, 551, 195),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT      
    }
    :addTo(skill)
    local star = display.newSprite("dragon_star.png")
    :addTo(skill)
    :align(display.LEFT_BOTTOM,0,200)
    local timeLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "next one 00:20:45",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    })
    timeLabel:setAnchorPoint(cc.p(0,0))
    timeLabel:setPosition(cc.p(star:getPositionX() + star:getContentSize().width,star:getPositionY()))
    timeLabel:addTo(skill)

    local magic_bottle = display.newSprite("dragon_magic_bottle.png")
     :addTo(skill)
     :align(display.LEFT_BOTTOM,timeLabel:getPositionX()+timeLabel:getContentSize().width + 200 , timeLabel:getPositionY())

    local value_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "30000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(skill):align(display.LEFT_BOTTOM,magic_bottle:getPositionX()+magic_bottle:getContentSize().width+10,magic_bottle:getPositionY())

    local line  = display.newScale9Sprite("dividing_line.png")
     :addTo(skill)
     :align(display.LEFT_TOP,0,star:getPositionY() - 1)

    line:size(551,line:getContentSize().height)
    self.skill_content = skill
    skill:addTo(self):pos((display.width - 551)/2,display.top - 850)
    return self.skill_content
end

function GameUIDragonEyrie:GetSkillItem()
	local node = display.newNode()

end

function GameUIDragonEyrie:CreateInfomationIf()
	if self.info_content then  self.info_content:setVisible(true) return self.info_content end
	self.info_content = UIListView.new {
		bg = "dragon_info_bg.png",
        bgScale9 = true,
        viewRect = cc.rect((display.width - 551) /2, self.dragon_bg:getPositionY()-self.dragon_bg:getContentSize().height+30, 551, 200),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT      
    }
    :addTo(self)

    for i=1,4 do
    	local item = self.info_content:newItem()
    	local bg = display.newSprite(string.format("dragon_info_item_bg%d.png",i%2))
    	item:addContent(bg)
    	item:setItemSize(551,bg:getContentSize().height)
    	self.info_content:addItem(item)
    end
    self.info_content:reload()
    return self.info_content
end

function GameUIDragonEyrie:CreateTabButtons()
	local tab_buttons = TabButtons.new({
        {
            label = _("升级"),
            tag = "upgrade",
            default = true,
        },
        {
            label = _("装备"),
            tag = "equipment",
        },
        {
            label = _("技能"),
            tag = "skill",
        },
        {
            label = _("信息"),
            tag = "information",
        }
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
    	self:TabButtonsAction(tag)
    end):addTo(self):pos(display.cx, display.top - 910)
    self.tabButton = tab_buttons
end

function GameUIDragonEyrie:onMovieOutStage()
    self.building:RemoveListener()
    GameUIDragonEyrie.super.onMovieOutStage(self)
end

function GameUIDragonEyrie:HandleEquipmentItem(dragon)
    self.equipmentUI.equipmentContent:removeAllChildren() -- clear 
    local equipmentCategorys = self.building:GetEquipmentCategorys()
    local eqs = self.equipmentUI.equipmentContent
    for i=1,6 do
        local category = equipmentCategorys[i]
        local equipment = self:GetEquipmentItem(dragon.equipments[category].name == "",category,dragon)
        if i < 4 then
            local x = (i - 1)*(equipment:getContentSize().width + 10)
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p(x,equipment:getContentSize().height + 10))
            equipment:addTo(eqs)
        else
            equipment:setAnchorPoint(cc.p(0,0))
            equipment:setPosition(cc.p((i - 4)*(equipment:getContentSize().width + 10),0))
            equipment:addTo(eqs)
        end
        i = i + 1 
    end     
end

function GameUIDragonEyrie:HandleClickedOnEquipmentItem(dragon,equipmentCategory)
    self.dragonEquipment = UIKit:newGameUI("GameUIDragonEquipment",self,dragon,equipmentCategory)    
    self.dragonEquipment:addToCurrentScene(false)
end

return GameUIDragonEyrie