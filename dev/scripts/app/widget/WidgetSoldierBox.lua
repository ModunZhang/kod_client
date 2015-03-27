local UIPushButton = cc.ui.UIPushButton
local UILib = import("..ui.UILib")
local WidgetPushButton = import(".WidgetPushButton")
local WidgetSoldierBox = class("WidgetSoldierBox", function()
    return display.newNode()
end)
local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special

function WidgetSoldierBox:ctor(soldier_png, cb)
    self.soldier_bg = WidgetPushButton.new({normal = "box_120x154.png",
        pressed = "box_120x154.png"}):addTo(self)
        :onButtonClicked(cb)
        :align(display.CENTER, 0,0)

    local rect = self.soldier_bg:getCascadeBoundingBox()

    local number_bg = cc.ui.UIImage.new("back_ground_118x36.png"):addTo(self.soldier_bg)
        :align(display.CENTER, 0, - rect.height / 2 +20)

    local size = number_bg:getContentSize()
    self.number = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x423f32)
    }):addTo(number_bg):align(display.CENTER, size.width / 2, size.height / 2)
end

function WidgetSoldierBox:SetSoldier(soldier_type, star)
    star = checknumber(star)
    local soldier_ui_config = UILib.soldier_image[soldier_type][star]
    if soldier_ui_config then
        if self.soldier then
            self.soldier_bg:removeChild(self.soldier)
        end
        self.soldier = display.newSprite(soldier_ui_config, nil, nil, {class=cc.FilteredSpriteWithOne}):addTo(self.soldier_bg)
            :align(display.CENTER, 0, 20)
        self.soldier:scale(104/self.soldier:getContentSize().height)
        display.newSprite("box_soldier_128x128.png"):addTo(self.soldier):align(display.CENTER, self.soldier:getContentSize().width/2, self.soldier:getContentSize().height-64)
    end
    return self
end
function WidgetSoldierBox:SetNumber(number)
    if type(number) == 'string' then
         self.number:setString(number)
    elseif type(number) == 'number' then
        self.number:setString(string.format("%s%d", _("数量: "), number))
        self:Enable(number>0)
    end
    return self
end
function WidgetSoldierBox:Enable(b)
    if b then
        self.soldier:clearFilter()
    else
        self.soldier:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
    end
    return self
end
function WidgetSoldierBox:SetCondition(text)
    self.number:setString(text)
    return self
end
function WidgetSoldierBox:IsLocked()
    return self.soldier:getFilter()
end
function WidgetSoldierBox:align(anchorPoint, x, y)
    self.soldier_bg:align(anchorPoint)
    if x and y then self:setPosition(x, y) end
    return self
end
function WidgetSoldierBox:alignByPoint(point, x, y)
    self.soldier_bg:setAnchorPoint(point)
    if x and y then self:setPosition(x, y) end
    return self
end
function WidgetSoldierBox:SetButtonListener( cb )
    self.soldier_bg:removeAllEventListeners()
    self.soldier_bg:onButtonClicked(cb)
end

return WidgetSoldierBox











