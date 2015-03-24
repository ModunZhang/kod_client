local Localize = import("..utils.Localize")
local UILib = import("..ui.UILib")
local UIImage = cc.ui.UIImage
local WidgetSoldierInBattle = class("WidgetSoldierInBattle", UIImage)

function WidgetSoldierInBattle:ctor(filename, options)
    WidgetSoldierInBattle.super.ctor(self, filename, options)
    local pos = {x = 284/2,y = 128/2}

    local soldier_level = options.star
    local soldier_type = options.soldier
    local soldier_ui_config = UILib.soldier_image[soldier_type][soldier_level]
    local soldier_head_icon = display.newSprite(soldier_ui_config, nil, nil, {class=cc.FilteredSpriteWithOne}):align(display.LEFT_BOTTOM,0,10)
    soldier_head_icon:scale(104/soldier_head_icon:getContentSize().height)
    local soldier_head_bg  = display.newSprite("box_soldier_128x128.png")
        :align(display.CENTER, soldier_head_icon:getContentSize().width/2, soldier_head_icon:getContentSize().height-64)
        :addTo(soldier_head_icon)
    soldier_head_icon:addTo(self):align(display.CENTER, 55, pos.y):scale(0.9)
    self.soldier = soldier_head_icon
    self.soldier_name = options.soldier


    if options.side == "blue" then
        cc.ui.UIImage.new("title_blue_166x30.png")
            :addTo(self):align(display.LEFT_CENTER, 110, 105)
    elseif options.side == "red" then
        cc.ui.UIImage.new("title_red_166x30.png")
            :addTo(self):align(display.LEFT_CENTER, 110, 105)
    else
        assert(false, "只有两边!")
    end

    cc.ui.UILabel.new({
        text = Localize.soldier_name[options.soldier],
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0xebdba0)
    }):addTo(self):align(display.LEFT_CENTER, 120, 105)


    cc.ui.UIImage.new("back_ground_166x84.png")
        :addTo(self):align(display.LEFT_CENTER, 110, 45)

    self.name = cc.ui.UILabel.new({
        text = Localize.getSoldierCategoryByName(options.soldier),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(self):align(display.LEFT_CENTER, 120, 65)

    self.status = cc.ui.UILabel.new({
        font = UIKit:getFontFilePath(),
        size = 22,
    }):addTo(self):align(display.LEFT_CENTER, 120, 30)


    self:SetUnitStatus("waiting")
end
function WidgetSoldierInBattle:SetUnitStatus(status)
    if status == "waiting" then
        self.status:setColor(UIKit:hex2c3b(0x403c2f))
        -- self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "fighting" then
        self.status:setColor(UIKit:hex2c3b(0x007c23))
        -- self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "defeated" then
        self.status:setColor(UIKit:hex2c3b(0x7e0000))
        local filter = filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        -- self.soldier_bg:setFilter(filter)
        self.soldier:setFilter(filter)
    else
        assert(false, "没有状态!")
    end
    self.status:setString(Localize.soldier_status[status])
    return self
end
function WidgetSoldierInBattle:GetSoldierName()
    return self.soldier_name
end

return WidgetSoldierInBattle









