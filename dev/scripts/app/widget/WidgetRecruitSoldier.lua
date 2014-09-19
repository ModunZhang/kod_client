local WidgetHourGlass = import("..widget.WidgetHourGlass")
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


    local slider_height, label_height = size.height - 170, size.height - 150
    WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"}, {max = 100000}):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 25, slider_height)
        :onSliderValueChanged(function(event)
            -- print(event.value)
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
        :align(display.CENTER, size.width - 70, label_height)

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
        :align(display.CENTER, size.width - 70, label_height - 35)


    local need = cc.ui.UIImage.new("back_ground_583x107.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height/2 - 30)

    local size = need:getContentSize()
    local margin_x = 80
    local length = size.width - margin_x * 2
    local origin_x, origin_y, gap_x = margin_x, 30, length / 4
    local res_map = {
        "res_food_114x100.png",
        "res_wood_114x100.png",
        "res_iron_114x100.png",
        "res_stone_128x128.png",
        "res_citizen_44x50.png",
    }
    for i, v in pairs(res_map) do
        local x = origin_x + (i - 1) * gap_x
        local scale = i == #res_map and 1 or 0.4
        cc.ui.UIImage.new(v):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y):scale(scale)

        cc.ui.UILabel.new({
            text = "2.1k\n/ 20000",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            -- color = UIKit:hex2c3b(0x403c2f)
            color = display.COLOR_RED
        }):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y - 50)
    end

    local size = back_ground:getContentSize()
    local instant_button = cc.ui.UIPushButton.new(
        {normal = "green_btn_up_250x65.png",pressed = "green_btn_down_250x65.png"})
        :addTo(back_ground, 2)
        :align(display.CENTER, 160, 120)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("立即招募"),
            size = 24,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            dump(event)
        end)

    cc.ui.UIImage.new("gem_66x56.png"):addTo(instant_button, 2)
        :align(display.CENTER, -100, -50):scale(0.5)

    cc.ui.UILabel.new({
        text = "600",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(instant_button, 2)
        :align(display.LEFT_CENTER, -100 + 20, -50)


    local button = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"})
        :addTo(back_ground, 2)
        :align(display.CENTER, size.width - 120, 120)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("招募"),
            size = 27,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            dump(event)
        end)

    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(button, 2)
        :align(display.LEFT_CENTER, -90, -55):scale(0.7)

	local center = -20
    cc.ui.UILabel.new({
        text = "20:20:20",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(button, 2)
        :align(display.CENTER, center, -50)

    cc.ui.UILabel.new({
        text = "-(20:20:20)",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x068329)
    }):addTo(button, 2)
        :align(display.CENTER, center, -70)


    self.back_ground = back_ground
end

function WidgetRecruitSoldier:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint)
    if x and y then self:pos(x, y) end
    return self
end


return WidgetRecruitSoldier











