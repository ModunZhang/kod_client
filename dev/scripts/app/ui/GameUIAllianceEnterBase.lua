--
-- Author: Danny He
-- Date: 2014-12-29 11:34:54
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIAllianceEnterBase = UIKit:createUIClass("GameUIAllianceEnterBase")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local Localize = import("..utils.Localize")
-- building is allianceobject
function GameUIAllianceEnterBase:ctor(building,isMyAlliance,my_alliance)
	GameUIAllianceEnterBase.super.ctor(self)
	self.building = building
	self.my_alliance = my_alliance
    self.isMyAlliance = isMyAlliance
end

function GameUIAllianceEnterBase:IsMyAlliance()
    return self.isMyAlliance
end

function GameUIAllianceEnterBase:GetBuilding()
	return self.building
end

function GameUIAllianceEnterBase:GetMyAlliance()
    return self.my_alliance
end

function GameUIAllianceEnterBase:GetBuildingCategory()
	return self:GetBuilding():GetCategory()
end

function GameUIAllianceEnterBase:GetUIHeight()
	return 242
end

function GameUIAllianceEnterBase:GetUITitle()
	return _("空地")
end

function GameUIAllianceEnterBase:GetBody()
	return self.body
end

function GameUIAllianceEnterBase:onEnter()
	GameUIAllianceEnterBase.super.onEnter(self)
	UIKit:shadowLayer():addTo(self)
	self.body = self:BuildBackground()
	self:InitBuildingImage()
	self:InitBuildingDese()
	self:InitBuildingInfo()
	self:InitEnterButton()
	self:FixedUI()
end

function GameUIAllianceEnterBase:BuildBackground()
	local body = WidgetUIBackGround.new({height=self:GetUIHeight(),isFrame = "no"}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+8)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = self:GetUITitle(),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    self.close_btn = UIKit:closeButton():onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:leftButtonClicked()
            end
        end):align(display.CENTER_RIGHT, rb_size.width,rb_size.height+10):addTo(body)
    body:align(display.CENTER, window.cx, window.top - 400)
        :addTo(self)
    return body
end


function GameUIAllianceEnterBase:GetBuildingInfo()
  	return {
            {
                {_("坐标"),0x797154},
                {self:GetLocation(),0x403c2f},
            }
        }
end

function GameUIAllianceEnterBase:GetLocation()
	local building = self:GetBuilding()
	local x,y = building:GetLogicPosition()
	return x .. "," .. y
end


function GameUIAllianceEnterBase:GetBuildingImage()
	return "tree_1_120x120.png"
end


function GameUIAllianceEnterBase:InitBuildingImage()
    local body = self:GetBody()
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 30,self:GetUIHeight()-90)
        :addTo(body):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 163, self:GetUIHeight()-90)
        :addTo(body)
    local building_image = display.newSprite(self:GetBuildingImage())
        :addTo(body):pos(105, self:GetUIHeight()-60)
    building_image:setAnchorPoint(cc.p(0.5,0.5))
    building_image:setScale(125/building_image:getContentSize().width)
    local level_bg = display.newSprite("back_ground_138x34.png"):addTo(body):pos(96, self:GetUIHeight()-180)
    local label = UIKit:ttfLabel({
        text = self:GetLevelLabelText(),
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
        :addTo(level_bg)
    self.level_bg = level_bg
    self.level_label = label
    local honour_icon = display.newSprite("honour.png"):align(display.CENTER, 20, level_bg:getContentSize().height/2)
        :addTo(level_bg)
    local honour_label= UIKit:ttfLabel({
        text = self:GetHonourLabelText(),
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
        :addTo(level_bg)
    self.honour_icon = honour_icon
    self.honour_label = honour_label
end

function GameUIAllianceEnterBase:GetLevelBg()
	return self.level_bg
end

function GameUIAllianceEnterBase:GetLevelLabelText()
	return self:GetBuilding().level and _("等级") .. self:GetBuilding().level or ""
end

function GameUIAllianceEnterBase:GetHonourLabelText()
	return "1000"
end

function GameUIAllianceEnterBase:GetLevelLabel()
	return self.level_label
end

function GameUIAllianceEnterBase:GetHonourIcon()
	return self.honour_icon
end

function GameUIAllianceEnterBase:GetHonourLabel()
	return self.honour_label
end

function GameUIAllianceEnterBase:FixedUI()
	self:GetLevelBg():hide()
    self.process_bar_bg:hide()
end

function GameUIAllianceEnterBase:InitBuildingDese()
    local body = self:GetBody()
    self.desc_label = UIKit:ttfLabel({
        text = self:GetBuildingDesc(),
        size = 18,
        color = 0x797154,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP, 180, self:GetUIHeight()-20):addTo(body)

    self.process_bar_bg = display.newSprite("Progress_bar_1.png"):align(display.LEFT_TOP, 180, self:GetUIHeight()-30):addTo(body)    
    self.progressTimer = UIKit:commonProgressTimer("progress_bar_366x34.png"):addTo(self.process_bar_bg):align(display.LEFT_BOTTOM,0,0):scale(386/366)
    self.progressTimer:setPercentage(100)
    self.process_icon_bg =   display.newSprite("back_ground_43x43.png"):addTo(self.process_bar_bg):pos(10,18)
    local icon,scale = self:GetProcessIcon()
    self.process_icon =  display.newSprite(icon):addTo(self.process_icon_bg):pos(21,21):scale(scale)
    self.process_label = UIKit:ttfLabel({
        size = 20,
        color = 0xfff3c7,
        shadow = true,
        text = self:GetProcessLabelText()
    }):align(display.LEFT_CENTER,self.process_icon_bg:getPositionX() + 40,self.process_icon_bg:getPositionY()):addTo(self.process_bar_bg)
end

function GameUIAllianceEnterBase:GetProgressTimer()
    return  self.progressTimer
end

function GameUIAllianceEnterBase:GetProcessLabel()
    return self.process_label
end

function GameUIAllianceEnterBase:GetBuildingInfoOriginalY()
    return self.desc_label:getPositionY()-self.desc_label:getContentSize().height-40
end

function GameUIAllianceEnterBase:InitBuildingInfo()
    local original_y = self:GetBuildingInfoOriginalY()
    local gap_y = 40
    local info_count = 0
    local info = self:GetBuildingInfo()
    for k,v in pairs(info) do
        self:CreateItemWithLine(v)
            :align(display.CENTER, 380, original_y - gap_y*info_count)
            :addTo(self.body)
        info_count = info_count + 1
    end
end

function GameUIAllianceEnterBase:CreateItemWithLine(params)
    local line = display.newSprite("dividing_line.png")
    local size = line:getContentSize()
    UIKit:ttfLabel({
        text = params[1][1],
        size = 20,
        color = params[1][2],
    }):align(display.LEFT_BOTTOM, 0, 6)
        :addTo(line)
    if params[2] then
        local label = UIKit:ttfLabel({
            text = params[2][1],
            size = 20,
            color = params[2][2],
        }):align(display.RIGHT_BOTTOM, size.width, 6)
            :addTo(line)
        label:setTag(100)
    end
    if params[2] and params[2][3] then
        line:setTag(params[2][3])
    end
    return line
end

function GameUIAllianceEnterBase:GetInfoLabelByTag(tag)
    local line = self:GetBody():getChildByTag(tag)
    if line then
        return line:getChildByTag(100)
    else
        return nil
    end
end

function GameUIAllianceEnterBase:InitEnterButton()
	local buttons = self:GetEnterButtons()
    local width = 608
    local btn_width = 130
    local count = 0
    for _,v in ipairs(buttons) do
        local btn = v:align(display.RIGHT_TOP,width-count*btn_width, 5):addTo(self:GetBody())
        count = count + 1
    end
end

function GameUIAllianceEnterBase:GetEnterButtons()
    if self:IsMyAlliance() then
    	local move_city_button = self:BuildOneButton("icon_move_city.png",_("迁移城市")):onButtonClicked(function()
    		self:leftButtonClicked()
    	end)
    	local move_building_button = self:BuildOneButton("icon_move_alliance_building.png",_("迁移联盟建筑")):onButtonClicked(function()
    		self:leftButtonClicked()
    	end)
        return {move_city_button,move_building_button}
    else
        return {}
    end
end


function GameUIAllianceEnterBase:BuildOneButton(image,title)
	local btn = WidgetPushButton.new({normal = "btn_130X104.png",pressed = "btn_pressed_130X104.png"})
    local s = btn:getCascadeBoundingBox().size
    display.newSprite(image):align(display.CENTER, -s.width/2, -s.height/2+22):addTo(btn)
    UIKit:ttfLabel({
            text =  title,
            size = 18,
            color = 0xffedae,
    }):align(display.CENTER, -s.width/2 , -s.height+25):addTo(btn)
    return btn
end

function GameUIAllianceEnterBase:GetDescLabel()
	return self.desc_label
end

function GameUIAllianceEnterBase:GetProcessIcon()
	return "wall_36x41.png",1
end

function GameUIAllianceEnterBase:GetProcessLabelText()
	return "100/100"
end

function GameUIAllianceEnterBase:GetBuildingDesc()
	return _("联盟将军可将联盟建筑移动到空地,玩家可将自己的城市移动到空地处,空地定期刷新放逐者的村落,树木,山脉和湖泊")
end

return GameUIAllianceEnterBase