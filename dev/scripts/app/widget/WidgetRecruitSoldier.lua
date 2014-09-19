local WidgetSlider = import("..widget.WidgetSlider")
local WidgetRecruitSoldier = class("WidgetRecruitSoldier", function(...)
    return display.newNode(...)
end)



function WidgetRecruitSoldier:ctor()

    local label_origin_x = 190

    local back_ground = cc.ui.UIImage.new("back_ground_608x458.png",
        {scale9 = true}):addTo(self):setLayoutSize(608, 500)


    local size = back_ground:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height - 49/2)

    local size = title_blue:getContentSize()
    cc.ui.UILabel.new({
        text = "T3 弓箭手",
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, label_origin_x, size.height/2)

    cc.ui.UIPushButton.new({normal = "info_16x33.png",
        pressed = "info_16x33.png"}):addTo(title_blue)
        :align(display.LEFT_CENTER, title_blue:getContentSize().width - 30, size.height/2)
        :onButtonClicked(function(event)
            print("hello")
        end)


    local size = back_ground:getContentSize()
    local width, height = 150, 127
    local soldier_bg = cc.ui.UIImage.new("back_ground_54x127.png",
        {scale9 = true}):addTo(back_ground, 2)
        :align(display.CENTER, 100, size.height - 50)
        :setLayoutSize(width, height)



    local origin_x, origin_y, gap_y = width - 20, 15, 25
    for i = 1, 5 do
        local bg = cc.ui.UIImage.new("star_bg_24x23.png"):addTo(soldier_bg, 2)
            :align(display.CENTER, origin_x, origin_y + (i - 1) * gap_y)
        local pos = bg:getAnchorPointInPoints()

        cc.ui.UIImage.new("star_18x16.png"):addTo(bg)
            :align(display.CENTER, pos.x, pos.y)
    end


    local star_bg = cc.ui.UIImage.new("star1_114x128.png"):addTo(soldier_bg, 2)
        :align(display.CENTER, 60, height/2)

    local pos = star_bg:getAnchorPointInPoints()
    local soldier = cc.ui.UIImage.new("soldier_130x183.png"):addTo(star_bg)
        :align(display.CENTER, pos.x, pos.y + 5):scale(0.7)



    local size = back_ground:getContentSize()
    cc.ui.UILabel.new({
        text = "克制",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x5bb800)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x, size.height - 65)

    cc.ui.UILabel.new({
        text = "被克制",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x890000)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x, size.height - 100)


    cc.ui.UIImage.new("res_food_114x100.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 130, size.height - 90):scale(0.5)

    cc.ui.UILabel.new({
        text = "需要食物",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x7f775f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 100, size.height - 70)

    cc.ui.UILabel.new({
        text = "-100",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 100, size.height - 100)



    WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"}):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 25, size.height - 150)
        :onSliderValueChanged(function(event)
            end)
        :setSliderValue(0)


    cc.ui.UILabel.new({
        text = "-100",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 100, size.height - 100)

    local bg = cc.ui.UIImage.new("back_ground_83x32.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 70, size.height - 130)

    local pos = bg:getAnchorPointInPoints()
    cc.ui.UILabel.new({
        text = "20000",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(bg, 2)
        :align(display.CENTER, pos.x, pos.y)

    cc.ui.UILabel.new({
        text = "/ 20000",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 70, size.height - 160)


    cc.ui.UIImage.new("back_ground_583x107.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height/2)
    


    self.back_ground = back_ground
end

function WidgetRecruitSoldier:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint)
    if x and y then self:pos(x, y) end
    return self
end


return WidgetRecruitSoldier





