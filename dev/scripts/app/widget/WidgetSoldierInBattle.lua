local Localize = import("..utils.Localize")
local UILib = import("..ui.UILib")
local UIImage = cc.ui.UIImage
local WidgetSoldierInBattle = class("WidgetSoldierInBattle", UIImage)

function WidgetSoldierInBattle:ctor(filename, options)
    WidgetSoldierInBattle.super.ctor(self, filename, options)
    local pos = {x = 284/2,y = 128/2}


    local soldier_bg = display.newSprite(UILib.soldier_bg[options.star], nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self):align(display.CENTER, 55, pos.y):scale(0.9)
    local pos = soldier_bg:getAnchorPointInPoints()
    local soldier = display.newSprite(UILib.soldier_image[options.soldier][options.star], nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(soldier_bg):align(display.CENTER, pos.x, pos.y):scale(0.5)
    self.soldier_bg = soldier_bg
    self.soldier = soldier


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
        self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "fighting" then
        self.status:setColor(UIKit:hex2c3b(0x007c23))
        self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "defeated" then
        self.status:setColor(UIKit:hex2c3b(0x7e0000))
        local filter = filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        self.soldier_bg:setFilter(filter)
        self.soldier:setFilter(filter)
    else
        assert(false, "没有状态!")
    end
    self.status:setString(Localize.soldier_status[status])
    return self
end

return WidgetSoldierInBattle








