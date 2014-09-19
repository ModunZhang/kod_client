local WidgetNeedBox = class("WidgetNeedBox", function(...)
    return display.newNode(...)
end)
function WidgetNeedBox:ctor()
    local col1_x, col2_x = 35, 190
    local row1_y, row2_y = 65, 25
    local label_relate_x, label_relate_y = 25, 0

    local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png"):addTo(self)
    
    local wood = cc.ui.UIImage.new("res_wood_114x100.png")
        :addTo(back_ground_351x96)
        :align(display.CENTER, col1_x, row1_y)
        :scale(0.4)
    self.wood_label = cc.ui.UILabel.new({
        text = "100",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_351x96, 2)
    :align(display.LEFT_CENTER, col1_x + label_relate_x, row1_y + label_relate_y)

    local stone = cc.ui.UIImage.new("res_stone_128x128.png")
        :addTo(back_ground_351x96)
        :align(display.CENTER, col2_x, row1_y)
        :scale(0.4)
    self.stone_label = cc.ui.UILabel.new({
        text = "100",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_351x96, 2)
    :align(display.LEFT_CENTER, col2_x + label_relate_x, row1_y + label_relate_y)


    local iron = cc.ui.UIImage.new("res_iron_114x100.png")
        :addTo(back_ground_351x96)
        :align(display.CENTER, col1_x, row2_y)
        :scale(0.4)
    self.iron_label = cc.ui.UILabel.new({
        text = "100",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_351x96, 2)
    :align(display.LEFT_CENTER, col1_x + label_relate_x, row2_y + label_relate_y)


    local time = cc.ui.UIImage.new("hourglass_39x46.png")
        :addTo(back_ground_351x96)
        :align(display.CENTER, col2_x, row2_y)
        :scale(0.8)
    self.time_label = cc.ui.UILabel.new({
        text = "100",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_351x96, 2)
    :align(display.LEFT_CENTER, col2_x + label_relate_x, row2_y + label_relate_y)
end

local GameUtils = GameUtils
function WidgetNeedBox:SetNeedNumber(wood_number, stone_number, iron_number, time_number)
    self.wood_label:setString(GameUtils:formatNumber(wood_number))
    self.stone_label:setString(GameUtils:formatNumber(stone_number))
    self.iron_label:setString(GameUtils:formatNumber(iron_number))
    self.time_label:setString(GameUtils:formatTimeStyle1(time_number))
    return self
end

return WidgetNeedBox






