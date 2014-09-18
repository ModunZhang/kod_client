--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIToolShop = UIKit:createUIClass("GameUIToolShop", "GameUIWithCommonHeader")

local MATERIALS_MAP = {
    blueprints = { "blueprints_112x112.png",  _("建筑图纸"), 1},
    tools = { "tools_112x112.png",  _("建筑工具"), 2},
    tiles = { "tiles_112x112.png",  _("砖石瓦片"), 3},
    pulley = { "pulley_112x112.png",  _("滑轮组"), 4},
    trainingFigure = { "trainingFigure_112x112.png",  _("木人桩"), 1},
    bowTarget = { "bowTarget_112x112.png", _("箭靶"), 2},
    saddle = { "saddle_112x112.png",  _("马鞍"), 3},
    ironPart = { "ironPart_112x112.png",  _("精铁零件"), 4},
}

function GameUIToolShop:ctor(city, toolShop)
    GameUIToolShop.super.ctor(self, city, _("工具作坊"))
    self.toolShop = toolShop
end
function GameUIToolShop:onEnter()
    GameUIToolShop.super.onEnter(self)
    self:Manufacture()
    self:TabButtons()
    self.toolShop:AddToolShopListener(self)
end
function GameUIToolShop:onExit()
    self.toolShop:RemoveToolShopListener(self)
    GameUIToolShop.super.onExit(self)
end
function GameUIToolShop:OnBeginMakeMaterialsWithEvent(tool_shop, event)
    self:UpdateEvent(event)
end
function GameUIToolShop:OnMakingMaterialsWithEvent(tool_shop, event, current_time)
    self:UpdateEvent(event)
end
function GameUIToolShop:OnEndMakeMaterialsWithEvent(tool_shop, event, current_time)
    self:UpdateEvent(event)
end
function GameUIToolShop:OnGetMaterialsWithEvent(tool_shop, event)
	self:UpdateEvent(event)
end
function GameUIToolShop:UpdateEvent(event)
	if event:Category() == "building" then
        self.building_item:UpdateByEvent(event)
    elseif event:Category() == "technology" then
        self.technology_event:UpdateByEvent(event)
    end
end
function GameUIToolShop:Manufacture()
    self.list_view = self:CreateVerticalListView(20, display.bottom + 80, display.right - 20, display.top - 100)
    local item = self:CreateMaterialItemWithListView(self.list_view,
        _("生产建筑所需材料"),
        {
            "blueprints",
            "tools",
            "tiles",
            "pulley",
        })
    self.list_view:addItem(item)
    item:GetNeedBox():SetClicked(function()
        NetManager:makeBuildingMaterial(NOT_HANDLE)
    end)
    item:GetMaterial():SetClicked(function()
        NetManager:getBuildingMaterials(NOT_HANDLE)
    end)
    item:UpdateByEvent(self.toolShop:GetMakeMaterialsEventByCategory("building"))
    self.building_item = item

    local item = self:CreateMaterialItemWithListView(self.list_view,
        _("军事科技所需材料"),
        {
            "trainingFigure",
            "bowTarget",
            "saddle",
            "ironPart",
        })
    self.list_view:addItem(item)
    item:GetNeedBox():SetClicked(function()
        NetManager:makeTechnologyMaterial(NOT_HANDLE)
    end)
    item:GetMaterial():SetClicked(function()
        NetManager:getTechnologyMaterials(NOT_HANDLE)
    end)
    item:UpdateByEvent(self.toolShop:GetMakeMaterialsEventByCategory("technology"))
    self.technology_event = item

    self.list_view:reload():resetPosition()
end
function GameUIToolShop:TabButtons()
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
            self.list_view:setVisible(false)
        elseif tag == "manufacture" then
            self.list_view:setVisible(true)
        end
    end):pos(display.cx, display.bottom + 50)
end

function GameUIToolShop:CreateMaterialItemWithListView(list_view, title, materials)
    local toolShop = self.toolShop
    local align_x, align_y = 30, 35
    local height = 380
    local content = cc.ui.UIImage.new("back_ground_608x164.png",
        {scale9 = true})
        :align(display.CENTER)
        :setLayoutSize(608, height)

    local pos = content:getAnchorPointInPoints()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png",
        {scale9 = true})
        :addTo(content, 2)
        :align(display.CENTER, pos.x, height - 49/2)

    cc.ui.UILabel.new({
        text = title,
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2):align(display.LEFT_BOTTOM, align_x, 10)

    local function new_material(type)
        local origin_x, origin_y, gap_x = 90, height - 150, 143
        local png = MATERIALS_MAP[type][1]
        local describe = MATERIALS_MAP[type][2]
        local index = MATERIALS_MAP[type][3]

        local back_ground = cc.ui.UIImage.new("material_back_ground_120x120.png")
            :align(display.CENTER, origin_x + gap_x * (index - 1), origin_y)

        local pos = back_ground:getAnchorPointInPoints()

        local material = cc.ui.UIImage.new(png)
            :addTo(back_ground)
            :align(display.CENTER, pos.x, pos.y)


        local num_bg = display.newColorLayer(UIKit:hex2c4b(0x7d000000))
            :addTo(material):pos(0, 0)
        num_bg:setContentSize(material:getContentSize().width, 24)
        num_bg:setTouchEnabled(false)

        local store_label = cc.ui.UILabel.new({
            text = "1000",
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_LEFT,
            color = UIKit:hex2c3b(0x0e7600)
        }):addTo(num_bg)
            :align(display.CENTER, material:getContentSize().width / 2, 12)


        local name_label = cc.ui.UILabel.new({
            text = describe,
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground, 2)
            :align(display.CENTER, pos.x, pos.y + 78)

        local num_label = cc.ui.UILabel.new({
            text = "+2",
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = display.COLOR_GREEN
        }):addTo(back_ground, 2)
            :align(display.CENTER, pos.x, pos.y - 78)
            :hide()
        function back_ground:SetStoreNumber(number)
            store_label:setString(number)
            return self
        end
        function back_ground:ShowNumber(number)
            num_label:show()
            num_label:setString(number == nil and "" or ("+"..number))
            return self
        end
        function back_ground:Reset()
            num_label:hide()
            return self
        end
        function back_ground:Index()
            return index
        end

        return back_ground
    end


    local materials_map = {}
    for i, v in ipairs(materials) do
        materials_map[v] = new_material(v):addTo(content, 2):Reset()
    end


    local function new_need_box()
        local col1_x, col2_x = 35, 190
        local row1_y, row2_y = 65, 25
        local label_relate_x, label_relate_y = 25, 0
        local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png")
        local wood = cc.ui.UIImage.new("res_wood_114x100.png")
            :addTo(back_ground_351x96):align(display.CENTER, col1_x, row1_y):scale(0.4)
        local wood_label = cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col1_x + label_relate_x, row1_y + label_relate_y)

        local stone = cc.ui.UIImage.new("res_stone_128x128.png")
            :addTo(back_ground_351x96):align(display.CENTER, col2_x, row1_y):scale(0.4)
        local stone_label = cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col2_x + label_relate_x, row1_y + label_relate_y)


        local iron = cc.ui.UIImage.new("res_iron_114x100.png")
            :addTo(back_ground_351x96):align(display.CENTER, col1_x, row2_y):scale(0.4)
        local iron_label = cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col1_x + label_relate_x, row2_y + label_relate_y)


        local time = cc.ui.UIImage.new("hourglass_39x46.png")
            :addTo(back_ground_351x96):align(display.CENTER, col2_x, row2_y):scale(0.8)
        local time_label = cc.ui.UILabel.new({
            text = "100",
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, col2_x + label_relate_x, row2_y + label_relate_y)


        local describe = cc.ui.UILabel.new({
            text = _("随机制造10个材料"),
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2)
            :align(display.LEFT_CENTER, 0, back_ground_351x96:getContentSize().height + 22)

        local button = cc.ui.UIPushButton.new(
            {normal = "yellow_btn_up.png", pressed = "yellow_btn_down.png"},
            {scale9 = false}
        ):setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
            :addTo(back_ground_351x96, 2)
            :align(display.CENTER, back_ground_351x96:getContentSize().width + 105, back_ground_351x96:getContentSize().height / 2)

        local back_ground = back_ground_351x96
        function back_ground:Update(category)
            local number, wood, stone, iron, time = toolShop:GetNeedByCategory(category)
            describe:setString(_("随机制造")..string.format("%d", number).._("个材料"))
            wood_label:setString(wood)
            stone_label:setString(stone)
            iron_label:setString(iron)
            time_label:setString(time)
            return self
        end
        function back_ground:SetClicked(func)
            button:onButtonClicked(function(event)
                func()
            end)
            return self
        end
        return back_ground
    end

    local function new_progress_box()
        local height = 100
        local width = 549
        local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png", {scale9 = true})
            :setLayoutSize(width, height)
        local describe = cc.ui.UILabel.new({
            text = _("制造材料"),
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 15, height - 30)


        local progress_bg_311x35 = cc.ui.UIImage.new("progress_bg_311x35.png")
            :addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 35, 40)
        local progress_timer = display.newProgressTimer("progress_bar_315x33.png", display.PROGRESS_TIMER_BAR)
            :align(display.LEFT_BOTTOM, 0, 0):addTo(progress_bg_311x35, 2):pos(0, 1)
        progress_timer:setBarChangeRate(cc.p(1,0))
        progress_timer:setMidpoint(cc.p(0,0))

        local progress_label = cc.ui.UILabel.new({
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
        ):setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
            :addTo(back_ground_351x96, 2):align(display.CENTER, width - 100, height / 2)

        local back_ground = back_ground_351x96
        function back_ground:SetClicked(func)
            button:onButtonClicked(function(event)
                func()
            end)
            return self
        end
        function back_ground:SetNumber(number)
            describe:setString(_("制造材料")..string.format(" %d", number))
            return self
        end
        function back_ground:SetProgressInfo(time_label, percent)
            progress_label:setString(time_label)
            progress_timer:setPercentage(percent)
            return self
        end

        return back_ground_351x96
    end


    local function new_get_material()
        local height = 48
        local material = display.newNode()
        local describe = cc.ui.UILabel.new({
            text = _("制造材料完成"),
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(material, 2):align(display.LEFT_CENTER, 0, height)

        local button = cc.ui.UIPushButton.new(
            {normal = "yellow_btn_up.png", pressed = "yellow_btn_down.png"},
            {scale9 = false}
        ):setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("获得"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
            :addTo(material, 2):align(display.CENTER, 351 + 105, height)

        function material:SetNumber(number)
            describe:setString(_("制造材料")..string.format(" %d ", number).._("完成!"))
            return self
        end
        function material:SetClicked(func)
            button:onButtonClicked(function(event)
                func()
            end)
            return self
        end
        return material
    end

    local back_ground_351x96 = new_need_box():addTo(content, 2):pos(align_x, align_y):hide()
    local progress_box = new_progress_box():addTo(content, 2):pos(align_x, align_y):hide()
    local get_material = new_get_material():addTo(content, 2):pos(align_x, align_y):hide()

    local item = list_view:newItem()
    function item:UpdateByEvent(event)
        local server_time = app.timer:GetServerTime()
        if event:IsEmpty() then
            self:ResetGetMaterials()
            self:GetNeedBox():show():Update(event:Category())

            self:GetProgressBox():hide()
            self:GetMaterial():hide()
        elseif event:IsMaking(server_time) then
            local number, _, _, _, _ = toolShop:GetNeedByCategory(event:Category())
            local elapse_time = event:ElapseTime(server_time)
            local total_time = event:FinishTime() - event:StartTime()
            local percent = math.floor((elapse_time * 100.0 / total_time))

            self:GetProgressBox():show()
                :SetNumber(number)
                :SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(server_time)), percent)

            self:GetMaterial():hide()
            self:GetNeedBox():hide()
        elseif event:IsStored(server_time) then
            self:SetGetMaterials(event:Content())
            self:GetMaterial():show():SetNumber(event:TotalCount())

            self:GetProgressBox():hide()
            self:GetNeedBox():hide()
        end
        return self
    end
    function item:GetNeedBox()
        return back_ground_351x96
    end
    function item:GetProgressBox()
        return progress_box
    end
    function item:GetMaterial()
        return get_material
    end
    function item:SetGetMaterials(materials)
        for k, v in pairs(materials_map) do
            v:ShowNumber(nil)
        end
        for k, v in pairs(materials) do
            materials_map[v.type]:ShowNumber(v.count)
        end
    end
    function item:ResetGetMaterials()
        for k, v in pairs(materials_map) do
            v:Reset()
        end
    end

    item:addContent(content)
    item:setItemSize(549, height + 10)
    return item
end





return GameUIToolShop






























