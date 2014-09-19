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


function GameUIDragonEyrie:ctor(building)
	GameUIDragonEyrie.super.ctor(self,City,_("龙巢"))
    self.building = building
end

function GameUIDragonEyrie:onEnter()
	GameUIDragonEyrie.super.onEnter(self)
	self:CreateTabButtons()
end

function GameUIDragonEyrie:CreateDragonIf(dragon_data)
	if self.dragon_bg then self.dragon_bg:setVisible(true) return end -- 只需创建一次
	local bg = display.newSprite("dragon_bg.png")
		:addTo(self)
        :pos(display.cx,display.top - 350)
	local title = display.newSprite("drgon_title_blue.png")
		:addTo(bg)
		:align(display.LEFT_TOP, 8, bg:getContentSize().height-8)
	cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "Red Dragon",
        font = UIKit:getFontFilePath(),
        size = 28,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title):align(display.LEFT_BOTTOM, 10, 10)

	cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "LV 20/50",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xb1a475)
    }):addTo(title):align(display.RIGHT_BOTTOM, title:getContentSize().width - 10, 10)

	local drgonBg = display.newSprite("dragon.png")
		:addTo(bg):align(display.LEFT_TOP,display.left+9,title:getPositionY() - title:getContentSize().height+3)

	local shieldView = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
			:addTo(bg)
			:size(595,31)
			:pos(display.left+9, title:getPositionY() - title:getContentSize().height-28)
	StarBar.new({
		max = 5,
		bg = "Stars_bar_bg.png",
		fill = "Stars_bar_highlight.png", 
		num = 3,
		margin = 0,
	}):addTo(shieldView)

	cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "2600/2600",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xb1a475)
    }):addTo(shieldView):align(display.RIGHT_BOTTOM, 585, 5)


	local rightButton = cc.ui.UIPushButton.new({normal = "drgon_switching_normal.png",pressed = "drgon_switching_hight.png"}, {scale9 = false}):addTo(bg)
	rightButton:align(display.RIGHT_TOP,bg:getContentSize().width - 7,shieldView:getPositionY() - 80)
	local leftButton = cc.ui.UIPushButton.new({normal = "drgon_switching_normal.png",pressed = "drgon_switching_hight.png"}, {scale9 = false}):addTo(bg)
	leftButton:setRotation(180)
	leftButton:pos(display.left+35,shieldView:getPositionY()-80 - 56)

	local lv_bg = display.newSprite("drgon_lvbar_bg.png"):addTo(bg):align(display.RIGHT_TOP,drgonBg:getContentSize().width+10,drgonBg:getPositionY()-drgonBg:getContentSize().height)
	local progressFill = display.newSprite("drgon_lvbar_color.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(lv_bg)
    ProgressTimer:setPercentage(10)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "120/360",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xfff3c7)
    }):addTo(lv_bg):align(display.LEFT_BOTTOM, 20, 5)

     cc.ui.UILabel.new({
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
	display.newSprite("dragon_lv_icon.png")
		:addTo(iconbg)
		:pos(iconbg:getContentSize().width/2,iconbg:getContentSize().height/2)
	local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "待命中",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(575, 33),
        color = UIKit:hex2c3b(0x388500)
    }):addTo(bg):align(display.CENTER,display.cx,lv_bg:getPositionY() - lv_bg:getContentSize().height - 20)
    local pageContent = StarBar.new({
		max = 3,
		bg = "dragon_page_bg.png",
		fill = "dragon_page_focus.png", 
		num = 2,
		margin = 20,
		fillFunc = function(index,current,max)
			return index == current
		end
	})
	pageContent:pos(display.cx-60,label:getPositionY() - label:getContentSize().height):addTo(bg)
	local add_button = cc.ui.UIPushButton.new({normal = "dragon_add_button_normal.png",pressed = "dragon_add_button_highlight.png"}, {scale9 = false})
		:addTo(lv_bg)
		:align(display.TOP_RIGHT,lv_bg:getContentSize().width,lv_bg:getContentSize().height)
	
    self.dragon_bg = bg
end

function GameUIDragonEyrie:CreateHatchDragonIf()
    local hatchNode = display.newNode()
    local content_bg = display.newSprite("dragon_content_bg.png")
        :addTo(self)
        :align(display.LEFT_BOTTOM, 0, 0)
    hatchNode:addTo(self)
        :pos((display.width - content_bg:getContentSize().width)/2,self.dragon_bg:getPositionY()-self.dragon_bg:getContentSize().height/2-130)
end


function GameUIDragonEyrie:CreateEquipmentContentIf()
	if self.equipment_content then self.equipment_content:setVisible(true) return  end
	local content_bg = display.newSprite("dragon_content_bg.png")
		:addTo(self)
	content_bg:pos(display.cx,self.dragon_bg:getPositionY()-self.dragon_bg:getContentSize().height/2-130)
	local eqs = display.newNode()
	for i=1,6 do
		local eq = self:GetEquipmentItem()
		if i < 4 then
			local x = (i - 1)*(eq:getContentSize().width + 10)
			eq:addTo(eqs):align(display.LEFT_BTTOM,x,0)
		else
			eq:addTo(eqs):align(display.LEFT_BTTOM, (i - 4)*(eq:getContentSize().width + 10),eq:getContentSize().height + 10)
		end
	end
	eqs:addTo(content_bg):pos(60,70)

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
        text = "Strength",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x6d6651)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 210)
	cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "400000000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 180)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "Vitality",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x6d6651)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 130)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "400000000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content_bg):align(display.LEFT_BOTTOM, 360, 100)
    self.equipment_content = content_bg
end


function GameUIDragonEyrie:GetEquipmentItem()
	local bg = display.newSprite("drgon_eq_bg_gray.png")
	bg:setTouchEnabled(true)
	bg:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
		local name, x, y = event.name, event.x, event.y
		if name == "ended" and bg:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then

      	end
      	return bg:getCascadeBoundingBox():containsPoint(cc.p(x,y))
	end)
	display.newSprite("headpiece.png"):addTo(bg):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
	local stars_bg = display.newSprite("dragon_eq_stars_bg.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
	local info = display.newSprite("dragon_eq_info.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
	StarBar.new({
		max = 5,
		bg = "Stars_bar_bg.png",
		fill = "Stars_bar_highlight.png", 
		num = 3,
		margin = 0,
		direction = StarBar.DIRECTION_VERTICAL,
		scale = 0.5,
	}):addTo(bg):align(display.LEFT_BOTTOM,info:getPositionX()-20, info:getPositionY()+info:getContentSize().height - 25)	
	return bg
end

function GameUIDragonEyrie:VisibleSkillContent(b)
    if not self.skill_content then return end
    self.skill_content:setVisible(b)
    self.skill_line:setVisible(b)
    self.skill_star:setVisible(b)
    self.skill_magic_bottle:setVisible(b)
    self.skill_value_label:setVisible(b)
    self.skill_time_label:setVisible(b)
end

function GameUIDragonEyrie:CreateSkillContentIf()
	if self.skill_content then self.skill_content:setVisible(true) return end
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
    }):addTo(skill):align(display.LEFT_BTTOM, star:getPositionX() + star:getContentSize().width,star:getPositionY() + 12)

    local magic_bottle = display.newSprite("dragon_magic_bottle.png")
     :addTo(skill)
     :align(display.LEFT_TOP,timeLabel:getPositionX()+timeLabel:getContentSize().width + 200 , timeLabel:getPositionY()+14)

    local value_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "30000",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(skill):align(display.LEFT_TOP,magic_bottle:getPositionX()+magic_bottle:getContentSize().width+10,magic_bottle:getPositionY())

    local line  = display.newScale9Sprite("dividing_line.png")
     :addTo(skill)
     :align(display.LEFT_TOP,0,star:getPositionY() - 1)

    line:size(551,line:getContentSize().height)
    self.skill_content = skill
    skill:addTo(self):pos((display.width - 551)/2,display.top - 850)


    -- self.skill_line = line
    -- self.skill_star = star
    -- self.skill_magic_bottle = magic_bottle
    -- self.skill_value_label  = value_label
    -- self.skill_time_label   = timeLabel
end

function GameUIDragonEyrie:GetSkillItem()
	local node = display.newNode()

end

function GameUIDragonEyrie:CreateInfomationIf()
	if self.info_content then  self.info_content:setVisible(true) return end
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
    	if tag ~= "upgrade" then
    		if self.current_content then
    			self.current_content:setVisible(false)
    		end
    		self:CreateDragonIf()
    	end
   		if tag == "upgrade" then
   			if self.dragon_bg then
   				self.dragon_bg:setVisible(false)
   				self.current_content:setVisible(false)
   			end
   		elseif tag == "equipment" then
   			self:CreateEquipmentContentIf()
   			self.current_content = self.equipment_content
   		elseif tag == "skill" then
   			self:CreateSkillContentIf()
            self.current_content = self.skill_content
   		elseif tag == "information" then
   			self:CreateInfomationIf()
   			self.current_content = self.info_content
   		end
    end):addTo(self):pos(display.cx, display.top - 910)
end



return GameUIDragonEyrie