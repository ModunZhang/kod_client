--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIToolShop = UIKit:createUIClass("GameUIToolShop", "GameUIWithCommonHeader")
function GameUIToolShop:ctor(city)
    GameUIToolShop.super.ctor(self, city, _("工具作坊"))
end
function GameUIToolShop:onEnter()
    GameUIToolShop.super.onEnter(self)


    self.list_view = self:CreateVerticalListView(20, display.bottom + 80, display.right - 20, display.top - 100)
    local item = self:CreateMaterialItemWithListView(self.list_view)
    self.list_view:addItem(item)
    local item = self:CreateMaterialItemWithListView(self.list_view)
    self.list_view:addItem(item)
    self.list_view:reload():resetPosition()


    self:CreateTabButtons({
        {
            label = _("升级"),
            tag = "upgrade",
        },
        {
            label = _("制作"),
            tag = "manufacture",
            default = true,
        }
    },
    function(tag)
        if tag == 'upgrade' then
        elseif tag == "manufacture" then
        end
    end):pos(display.cx, display.bottom + 50)
end


function GameUIToolShop:CreateMaterialItemWithListView(list_view)
    local height = 380
    local content = cc.ui.UIImage.new("back_ground_608x164.png",
        {scale9 = true})
        :align(display.CENTER)
        :setLayoutSize(608, height)

    local pos = content:getAnchorPointInPoints()
    local title = cc.ui.UIImage.new("title_blue_596x49.png",
        {scale9 = true})
        :addTo(content, 2)
        :align(display.CENTER, pos.x, height - 49/2)

    cc.ui.UILabel.new({
        text = _("生产建筑所需材料"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title, 2):align(display.LEFT_BOTTOM, 30, 10)


    local material_map = {
        blueprints = { "blueprints_112x112.png",  _("建筑图纸")}
    }
    local function new_material(type)
        local back_ground = cc.ui.UIImage.new("material_back_ground_120x120.png"):align(display.CENTER)
        local pos = back_ground:getAnchorPointInPoints()
        cc.ui.UIImage.new(material_map[type][1]):addTo(back_ground):align(display.CENTER, pos.x, pos.y)
        cc.ui.UILabel.new({
            text = material_map[type][2],
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground, 2):align(display.CENTER, pos.x, pos.y - 78)
        return back_ground
    end
    local origin_x, origin_y, gap_x = 90, height - 120, 143
    for i = 1, 4 do
        new_material("blueprints"):addTo(content, 2):pos(origin_x + gap_x * (i - 1), origin_y)
    end


    local function new_need_box()
        local col1_x, col2_x = 35, 190
        local row1_y, row2_y = 65, 25
        local label_relate_x, label_relate_y = 25, 0
        local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png")
        local wood = cc.ui.UIImage.new("res_wood_114x100.png")
            :addTo(back_ground_351x96):align(display.CENTER, col1_x, row1_y):scale(0.4)
        cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col1_x + label_relate_x, row1_y + label_relate_y)

        local stone = cc.ui.UIImage.new("res_stone_128x128.png")
            :addTo(back_ground_351x96):align(display.CENTER, col2_x, row1_y):scale(0.4)
        cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col2_x + label_relate_x, row1_y + label_relate_y)


        local iron = cc.ui.UIImage.new("res_iron_114x100.png")
            :addTo(back_ground_351x96):align(display.CENTER, col1_x, row2_y):scale(0.4)
        cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col1_x + label_relate_x, row2_y + label_relate_y)


        local hourglass = cc.ui.UIImage.new("hourglass_39x46.png")
            :addTo(back_ground_351x96):align(display.CENTER, col2_x, row2_y):scale(0.8)
        cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col2_x + label_relate_x, row2_y + label_relate_y)
        return back_ground_351x96
    end

    -- local back_ground_351x96 = new_need_box():addTo(content, 2):pos(30, 20)
    -- cc.ui.UILabel.new({
    --     text = _("随机制造10个材料"),
    --     size = 22,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_RIGHT,
    --     color = UIKit:hex2c3b(0x403c2f)
    -- }):addTo(back_ground_351x96, 2)
    --     :align(display.LEFT_CENTER, 0, back_ground_351x96:getContentSize().height + 22)
    -- local button = cc.ui.UIPushButton.new(
    --     {normal = "yellow_btn_up.png", pressed = "yellow_btn_down.png"},
    --     {scale9 = false}
    -- ):onButtonClicked(function(event)
    --     end)
    --     :setButtonLabel(cc.ui.UILabel.new({
    --         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --         text = _("建造"),
    --         size = 24,
    --         font = UIKit:getFontFilePath(),
    --         color = UIKit:hex2c3b(0xfff3c7)}))
    --     :addTo(back_ground_351x96, 2)
    --     :align(display.CENTER, back_ground_351x96:getContentSize().width + 120, back_ground_351x96:getContentSize().height / 2)


    local function new_progress_box()
        local height = 120
        local width = 549
        local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png", {scale9 = true})
            :setLayoutSize(width, height)
        cc.ui.UILabel.new({
            text = _("制造材料"),
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 15, height - 30)


        local progress_bg_311x35 = cc.ui.UIImage.new("progress_bg_311x35.png")
            :addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 35, 40)
        local ProgressTimer = display.newProgressTimer("progress_bar_315x33.png", display.PROGRESS_TIMER_BAR)
            :align(display.LEFT_BOTTOM, 0, 0):addTo(progress_bg_311x35, 2):pos(0, 1)
        ProgressTimer:setBarChangeRate(cc.p(1,0))
        ProgressTimer:setMidpoint(cc.p(0,0))
        ProgressTimer:setPercentage(50)

        cc.ui.UILabel.new({
            text = "00:20:30",
            size = 14,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0xfdfac2)
        }):addTo(progress_bg_311x35, 2):align(display.LEFT_CENTER, 35, 20)


        local back_ground_43x43 = cc.ui.UIImage.new("back_ground_43x43.png")
            :addTo(back_ground_351x96, 2):align(display.CENTER, 35, 40)
        local pos = back_ground_43x43:getAnchorPointInPoints()
        cc.ui.UIImage.new("hourglass_39x46.png"):addTo(back_ground_43x43):align(display.CENTER, pos.x, pos.y):scale(0.8)


        local button = cc.ui.UIPushButton.new(
            {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
            {scale9 = false}
        ):onButtonClicked(function(event)
            end)
            :setButtonLabel(cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = _("加速"),
                size = 24,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xfff3c7)}))
            :addTo(back_ground_351x96, 2):align(display.CENTER, width - 100, height / 2)

        return back_ground_351x96
    end
    new_progress_box():addTo(content, 2):pos(30, 20)

    local item = list_view:newItem()
    item:addContent(content)
    item:setItemSize(549, height + 10)
    return item
end





return GameUIToolShop


















