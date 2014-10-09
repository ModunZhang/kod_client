--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local MaterialManager = import("..entity.MaterialManager")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetNeedBox = import("..widget.WidgetNeedBox")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local GameUIToolShop = UIKit:createUIClass("GameUIToolShop", "GameUIUpgradeBuilding")

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
    GameUIToolShop.super.ctor(self, city, _("工具作坊"),toolShop)
    self.tool_shop_city = city
    self.toolShop = toolShop
end
function GameUIToolShop:onEnter()
    GameUIToolShop.super.onEnter(self)
    self:Manufacture()
    self:TabButtons()
    self.toolShop:AddToolShopListener(self)
    self.tool_shop_city:GetMaterialManager():AddObserver(self)
end
function GameUIToolShop:onExit()
    self.toolShop:RemoveToolShopListener(self)
    self.tool_shop_city:GetMaterialManager():RemoveObserver(self)
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
function GameUIToolShop:OnMaterialsChanged(material_manager, material_type, changed)
    if MaterialManager.MATERIAL_TYPE.BUILD == material_type then
        self.building_item:SetStoreMaterials(LuaUtils:table_map(changed, function(k, v)
            return k, v.new
        end))
    end
end
function GameUIToolShop:UpdateEvent(event)
    if event:Category() == "building" then
        self.building_item:UpdateByEvent(event)
    elseif event:Category() == "technology" then
        self.technology_event:UpdateByEvent(event)
    end
end
function GameUIToolShop:Manufacture()
    self.list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 100)
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
    local material_manager = self.tool_shop_city:GetMaterialManager()
    local materials = material_manager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)
    dump(materials)
    self.building_item:SetStoreMaterials(materials)
    self.technology_event:SetStoreMaterials(materials)
end
function GameUIToolShop:TabButtons()
    self:CreateTabButtons({
        {
            label = _("制作"),
            tag = "manufacture",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.list_view:setVisible(false)
        elseif tag == "manufacture" then
            self.list_view:setVisible(true)
        end
    end):pos(window.cx, window.bottom + 34)
end

function GameUIToolShop:CreateMaterialItemWithListView(list_view, title, materials)
    local toolShop = self.toolShop
    local align_x, align_y = 30, 35
    local height = 380
    local content = WidgetUIBackGround.new(height):align(display.CENTER)

    local size = content:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png",
        {scale9 = true})
        :addTo(content, 2)
        :align(display.CENTER, size.width / 2, height - 49/2)

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
        local need_box = WidgetNeedBox.new()

        local contetn_size = need_box:getCascadeBoundingBox()
        local width = contetn_size.width
        local height = contetn_size.height

        local describe = cc.ui.UILabel.new({
            text = _("随机制造10个材料"),
            size = 22,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(need_box, 2)
            :align(display.LEFT_CENTER, 0, height + 22)

        local button = WidgetPushButton.new(
            {normal = "yellow_btn_up.png", pressed = "yellow_btn_down.png"},
            {scale9 = false}
        ):addTo(need_box, 2)
            :align(display.CENTER, width + 100, height / 2)
            :setButtonLabel(cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = _("建造"),
                size = 24,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xfff3c7)}))


        function need_box:Update(category)
            local number, wood, stone, iron, time = toolShop:GetNeedByCategory(category)
            describe:setString(_("随机制造")..string.format("%d", number).._("个材料"))
            self:SetNeedNumber(wood, stone, iron, time)
            return self
        end
        function need_box:SetClicked(func)
            button:onButtonClicked(function(event)
                func()
            end)
            return self
        end
        return need_box
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

        local button = WidgetPushButton.new(
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
    local progress_box = WidgetTimerProgress.new()
        :addTo(content, 2)
        :pos(align_x, align_y)
        :hide()
        :OnButtonClicked(function(event)
            print("hello")
        end)
        progress_box:GetSpeedUpButton():setButtonEnabled(false)

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
            local number = toolShop:GetNeedByCategory(event:Category())
            local elapse_time = event:ElapseTime(server_time)
            local total_time = event:FinishTime() - event:StartTime()
            local percent = elapse_time * 100.0 / total_time

            self:GetProgressBox():show()
                :SetDescribe(string.format("%s X%d", _("制造材料"), number))
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
    function item:SetStoreMaterials(materials)
        for k, v in pairs(materials) do
            local ui = materials_map[k]
            if ui then
                ui:SetStoreNumber(v)
            end
        end
    end
    function item:SetGetMaterials(materials)
        local get_material = LuaUtils:table_map(materials, function(k, v)
            return v.type, v.count
        end)
        for k, v in pairs(materials_map) do
            v:ShowNumber(get_material[k])
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







































