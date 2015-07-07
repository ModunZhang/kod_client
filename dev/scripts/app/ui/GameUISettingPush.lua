--
-- Author: Danny He
-- Date: 2015-02-24 08:49:25
--
local GameUISettingPush = UIKit:createUIClass("GameUISettingPush","UIAutoClose")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetBackGroundTabButtons = import("..widget.WidgetBackGroundTabButtons")
local window = import("..utils.window")
local UICheckBoxButton = import(".UICheckBoxButton")

local CHECKBOX_BUTTON_IMAGES = {
    off = "CheckBoxButtonOff_100x56.png",
    on = "CheckBoxButtonOn_100x56.png",
}

function GameUISettingPush:onEnter()
    GameUISettingPush.super.onEnter(self)
    self:BuildUI()
end

function GameUISettingPush:BuildUI()
    local bg = WidgetUIBackGround.new({height=762})
    self:addTouchAbleChild(bg)
    bg:pos(((display.width - bg:getContentSize().width)/2),window.bottom_top)
    self.bg = bg
    local titleBar = display.newSprite("title_blue_600x56.png"):align(display.LEFT_BOTTOM,3,747):addTo(bg)
    local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
        :addTo(titleBar)
        :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,0)
        :onButtonClicked(function ()
            self:LeftButtonClicked()
        end)
    UIKit:ttfLabel({
        text = _("推送通知"),
        size = 22,
        shadow = true,
        color = 0xffedae
    }):addTo(titleBar):align(display.CENTER,300,28)

    WidgetBackGroundTabButtons.new({
        {
            label = _("通知"),
            tag = "notice",
            default = true
        },
        {
            label = _("提醒"),
            tag = "remind",
        },
    }, function(tag)
        if tag == 'notice' then
            if not self.push_node then
                self.push_node =self:CreatePushNode():addTo(bg)
            else
                self.push_node:show()
            end
            if self.remind_node then
                self.remind_node:hide()
            end
        else
            if not self.remind_node then
                self.remind_node = self:CreateRemindNode():addTo(bg)
            else
                self.remind_node:show()
            end
            if self.push_node then
                self.push_node:hide()
            end
        end
    end):addTo(bg):pos(window.cx-15,34)
end
function GameUISettingPush:CreatePushNode()
    local push_node = display.newNode()
    push_node:setContentSize(self.bg:getContentSize())
    local bg = push_node

    local building_push_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,732)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("建筑队列完成提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(building_push_bg)
    local building_push_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(building_push_bg)
        :setButtonSelected(app:GetPushManager():GetBuildPushState(),true)
    building_push_button:setTag(1)
    local soldier_push_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,624)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("招募兵种完成提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(soldier_push_bg)
    local soldier_push_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(soldier_push_bg)
        :setButtonSelected(app:GetPushManager():GetSoldierPushState(),true)
    soldier_push_button:setTag(2)
    local technology_push_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,516)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("科技研发完成提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(technology_push_bg)
    local technology_push_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(technology_push_bg)
        :setButtonSelected(app:GetPushManager():GetTechnologyPushState(),true)
    technology_push_button:setTag(3)

    local tool_equipment_push_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,408)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("工具&装备制造完成提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(tool_equipment_push_bg)
    local tool_push_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(tool_equipment_push_bg)
        :setButtonSelected(app:GetPushManager():GetToolEquipemtPushState(),true)
    tool_push_button:setTag(4)


    local watch_tower_push_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,300)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("瞭望塔预警提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(watch_tower_push_bg)
    local watch_tower_push_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(watch_tower_push_bg)
        :setButtonSelected(app:GetPushManager():GetWatchTowerPushState(),true)
    watch_tower_push_button:setTag(5)
    return push_node
end
function GameUISettingPush:onButtonStateChanged(button)
    local tag = button:getTag()
    local isOn = button:isButtonSelected()
    if tag == 1 then
        app:GetPushManager():SwitchBuildPush(isOn)
    elseif tag == 2 then
        app:GetPushManager():SwitchSoldierPush(isOn)
    elseif tag == 3 then
        app:GetPushManager():SwitchTechnologyPush(isOn)
    elseif tag == 4 then
        app:GetPushManager():SwitchToolEquipmentPush(isOn)
    elseif tag == 5 then
        app:GetPushManager():SwitchWatchTowerPush(isOn)
    end
end
function GameUISettingPush:CreateRemindNode()
     local remind_node = display.newNode()
    remind_node:setContentSize(self.bg:getContentSize())
    local bg = remind_node

    local gem_remind_bg = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
        :align(display.CENTER_TOP,304,732)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("金龙币消费提醒"),
        size = 20,
        color= 0x615b44
    }):align(display.CENTER_LEFT,15,48):addTo(gem_remind_bg)
    local gem_remind_button = UICheckBoxButton.new(CHECKBOX_BUTTON_IMAGES)
        :setButtonLabelAlignment(display.CENTER)
        :onButtonStateChanged(function(event)
            self:onRemindButtonStateChanged(event.target)
        end)
        :align(display.RIGHT_CENTER, 540, 48)
        :addTo(gem_remind_bg)
        :setButtonSelected(app:GetGameDefautlt():IsOpenGemRemind() ,true)
    gem_remind_button:setTag(1)

    return remind_node
end
function GameUISettingPush:onRemindButtonStateChanged(button)
    local tag = button:getTag()
    local isOn = button:isButtonSelected()
    if tag == 1 then
        if isOn then
            app:GetGameDefautlt():OpenGemRemind()
        else
            app:GetGameDefautlt():CloseGemRemind()()
        end
    end
end
return GameUISettingPush

