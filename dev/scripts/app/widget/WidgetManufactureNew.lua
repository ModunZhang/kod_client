local window = import("..utils.window")
local Localize = import("..utils.Localize")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetRoundTabButtons = import("..widget.WidgetRoundTabButtons")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local WidgetTimerProgressStyleThree = import("..widget.WidgetTimerProgressStyleThree")
local MaterialManager = import("..entity.MaterialManager")
local WidgetManufactureNew = class("WidgetManufactureNew", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)
local timer = app.timer


local function newProgress()
    local node = display.newNode()
    node.describe = UIKit:ttfLabel({
        size = 20,
        color = 0x403c2f
    }):addTo(node):align(display.LEFT_CENTER, -250, 35)

    node.progress = WidgetProgress.new():addTo(node)
        :align(display.LEFT_CENTER, -250, -18)

    node.btn = cc.ui.UIPushButton.new({
        normal = "green_btn_up_148x76.png",
        pressed = "green_btn_down_148x76.png",
    }, {scale9 = false}):setButtonLabel(UIKit:ttfLabel({
        text = _("加速"),
        size = 24,
        color = 0xffedae,
    })):addTo(node):pos(200,0)

    return node
end


function WidgetManufactureNew:ctor(toolShop)
    self.toolShop = toolShop
end
--
function WidgetManufactureNew:onEnter()
    self.view = display.newNode():addTo(self)
    self.material_tab = WidgetRoundTabButtons.new({
        {tag = "building",label = _("建筑材料")},
        {tag = "technology",label = _("军事材料")},
    }, function(tag)
        self:Reload(tag)
    end):align(display.TOP_CENTER,window.cx,window.top-84):addTo(self)

    local server_time = timer:GetServerTime()
    local making, stored
    for i,v in ipairs({self.toolShop:GetTechnologyEvent(), self.toolShop:GetBuildingEvent()}) do
        if v:IsMaking(server_time) then
            making = v
        elseif v:IsStored(server_time) then
            stored = v
        end
    end
    if making then
        self.material_tab:SelectTab(making:Category())
    elseif stored then
        self.material_tab:SelectTab(stored:Category())
    else
        self.material_tab:SelectTab("building")
    end

    --
    self.toolShop:AddToolShopListener(self)
    self.toolShop:BelongCity():GetMaterialManager():AddObserver(self)
end
function WidgetManufactureNew:onExit()
    self.toolShop:RemoveToolShopListener(self)
    self.toolShop:BelongCity():GetMaterialManager():RemoveObserver(self)
end
--
function WidgetManufactureNew:OnBeginMakeMaterialsWithEvent(tool_shop, event)
    app:GetAudioManager():PlayeEffectSoundWithKey("UI_TOOLSHOP_CRAFT_START")
    self:UpdateCurrentEvent()
    self:RefreshRequirementList()
end
function WidgetManufactureNew:OnMakingMaterialsWithEvent(tool_shop, event, current_time)
    self:UpdateCurrentEvent()
end
function WidgetManufactureNew:OnEndMakeMaterialsWithEvent(tool_shop, event, current_time)
    self:UpdateCurrentEvent()
    self:RefreshRequirementList()
end
function WidgetManufactureNew:OnGetMaterialsWithEvent(tool_shop, event)
    self:UpdateCurrentEvent()
    self:RefreshRequirementList()
end
function WidgetManufactureNew:OnMaterialsChanged(material_manager, material_type, changed)
    for k,v in pairs(changed) do
        if self.material_map[k] then
            self.material_map[k]:SetNumber(v.new)
        end
    end
end
--
function WidgetManufactureNew:Reload(tag)
    if tag == "building" then
        self:ReloadMaterials({
            "blueprints",
            "tools",
            "tiles" ,
            "pulley" ,
        }, self.toolShop:BelongCity():GetMaterialManager():GetBuildMaterias())
    elseif tag == "technology" then
        self:ReloadMaterials({
            "trainingFigure",
            "bowTarget",
            "saddle",
            "ironPart",
        }, self.toolShop:BelongCity():GetMaterialManager():GetTechnologyMaterias())
    else
        assert(false)
    end
end
function WidgetManufactureNew:ReloadMaterials(materials, materials_map)
    self.view:removeAllChildren()
    self.material_map = {}
    for i,v in ipairs(materials) do
        local x, y = window.left + (i-1) * 142 + 42, window.top - 380
        local title = display.newScale9Sprite("back_ground_96x30.png", nil, nil, cc.size(120, 30))
            :addTo(self.view):pos(x + 66, y + 190)
        local point = title:getAnchorPointInPoints()
        UIKit:ttfLabel({
            text = Localize.materials[v],
            size = 20,
            color = 0xffedae
        }):addTo(title, 10):align(display.CENTER, point.x, point.y)

        self.material_map[v] = WidgetMaterialBox.new(MaterialManager.MATERIAL_TYPE.BUILD, v)
            :addTo(self.view):pos(x, y):SetNumber(materials_map[v])
    end


    self.build_node = display.newNode():addTo(self.view)
        :pos(window.cx, window.top - 445)
    self.build_node.build_label = UIKit:ttfLabel({
        size = 20,
        color = 0x403c2f,
    }):addTo(self.build_node):align(display.LEFT_CENTER, -275, 0)
    self.build_node.build_btn = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("生产")},
            listener = function ()
                local user = self.toolShop:BelongCity():GetUser()
                local resource_manager = self.toolShop:BelongCity():GetResourceManager()
                local server_time = timer:GetServerTime()
                local wood_cur = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(server_time)
                local stone_cur = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(server_time)
                local iron_cur = resource_manager:GetIronResource():GetResourceValueByCurrentTime(server_time)
                local count, wood, stone, iron, time
                if self.material_tab:GetSelectedButtonTag() == "building" then
                    count, wood, stone, iron, time = self.toolShop:GetNeedByCategory("building")
                else
                    count, wood, stone, iron, time = self.toolShop:GetNeedByCategory("technology")
                end
                local need_gems = DataUtils:buyResource({
                    wood = wood,
                    stone = stone,
                    iron = iron,
                }, {
                    wood = wood_cur,
                    stone = stone_cur,
                    iron = iron_cur,
                })
                if need_gems > 0 then
                    UIKit:showMessageDialog(_("提示"), "资源不足!")
                        :CreateOKButtonWithPrice(
                            {
                                listener = function()
                                    if need_gems > user:GetGemResource():GetValue() then
                                        UIKit:showMessageDialog(_("主人"),_("金龙币不足"))
                                            :CreateOKButton(
                                                {
                                                    listener = function ()
                                                        UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
                                                    end,
                                                    btn_name= _("前往商店")
                                                }
                                            )
                                    else
                                        self:BuildMaterial()
                                    end
                                end,
                                btn_images = {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"},
                                price = need_gems
                            }
                        ):CreateCancelButton()
                else
                    self:BuildMaterial()
                end
            end,
        }
    ):pos(180,0):addTo(self.build_node).button


    self.progress_node = display.newNode():addTo(self.view)
        :pos(window.cx, window.top - 445):hide()
    self.progress_node.progress = newProgress():addTo(self.progress_node)
    self.progress_node.progress.btn:onButtonClicked(function()
        UIKit:newGameUI("GameUIToolShopSpeedUp", self.toolShop):AddToCurrentScene(true)
    end)


    self.get_node = display.newNode():addTo(self.view)
        :pos(window.cx, window.top - 445):hide()
    UIKit:ttfLabel({
        text = _("制造材料完成!"),
        size = 20,
        color = 0x403c2f,
    }):addTo(self.get_node):align(display.LEFT_CENTER, -275, 0)
    self.get_node.get_btn = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("获得")},
            listener = function ()
                local event
                if self.material_tab:GetSelectedButtonTag() == "building" then
                    event = self.toolShop:GetBuildingEvent()
                else
                    event = self.toolShop:GetTechnologyEvent()
                end
                if self:CheckOverFlow(event:Content()) then
                    self:CreateFetchDialog(function()
                        self:FetchMaterials(event)
                    end, _("当前材料库房中的材料已满，你可能无法获得这些材料。是否仍要获取？"))
                else
                    self:FetchMaterials(event)
                end
            end,
        }
    ):pos(180,0):addTo(self.get_node)


    self.require_list = WidgetRequirementListview.new({
        title = _("所需资源"),
        height = 204,
        contents = {
            {
                resource_type = _("木材"),
                isVisible = true,
                isSatisfy = false,
                icon = "res_wood_82x73.png",
                description = "1000/1000"
            },
            {
                resource_type = _("石料"),
                isVisible = true,
                isSatisfy = false,
                icon = "res_stone_88x82.png",
                description = "1000/1000"
            },
            {
                resource_type = _("铁矿"),
                isVisible = true,
                isSatisfy = true,
                icon = "res_iron_91x63.png",
                description = "1000/1000"
            },
            {
                resource_type = _("时间"),
                isVisible = true,
                isSatisfy = true,
                icon = "hourglass_30x38.png",
                description = "00:23:00"
            },
        },
    }):addTo(self.view):pos(window.cx-274, window.top - 770)

    self:UpdateCurrentEvent()
end
function WidgetManufactureNew:UpdateCurrentEvent()
    if self.material_tab:GetSelectedButtonTag() == "building" then
        self:UpdateByEvent(self.toolShop:GetBuildingEvent())
    else
        self:UpdateByEvent(self.toolShop:GetTechnologyEvent())
    end
end
function WidgetManufactureNew:UpdateByEvent(event)
    local server_time = timer:GetServerTime()
    if event:IsEmpty() then
        self.build_node:show()
        self.build_node.build_btn:setButtonEnabled(self.toolShop:CanMakeMaterial(server_time))
        self.progress_node:hide()
        self.get_node:hide()
        self:CleanStoreNumbers()
        local number, wood, stone, iron, time = self.toolShop:GetNeedByCategory(event:Category())
        self.build_node.build_label:setString(string.format(_("随机制造%d个材料"), number))
        self:RefreshRequirementList(wood, stone, iron, time)
    elseif event:IsStored(server_time) then
        self.build_node:hide()
        self.progress_node:hide()
        self.get_node:show()
        for i,v in ipairs(event:Content()) do
            if self.material_map[v.name] then
                self.material_map[v.name]:SetSecondNumber(string.format("+%d", v.count))
            end
        end
    elseif event:IsMaking(server_time) then
        self.build_node:hide()
        self.progress_node:show()
        self.get_node:hide()
        local number = self.toolShop:GetNeedByCategory(event:Category())
        local elapse_time = event:ElapseTime(server_time)
        local total_time = event:FinishTime() - event:StartTime()
        local percent = elapse_time * 100.0 / total_time
        local prog = self.progress_node.progress
        prog.describe:setString(string.format(_("制造材料 x%d"), number))
        prog.progress:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(server_time)), percent)
    end
end
function WidgetManufactureNew:CleanStoreNumbers()
    for k,v in pairs(self.material_map) do
        v:SetSecondNumber()
    end
end
function WidgetManufactureNew:RefreshRequirementList(wood, stone, iron, time)
    local server_time = timer:GetServerTime()
    local resource_manager = self.toolShop:BelongCity():GetResourceManager()
    local wood_cur = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(server_time)
    local stone_cur = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(server_time)
    local iron_cur = resource_manager:GetIronResource():GetResourceValueByCurrentTime(server_time)
    local buff = string.format("(-%s)", GameUtils:formatTimeStyle1(math.ceil(time *  self.toolShop:BelongCity():FindTechByName("sketching"):GetBuffEffectVal())))
    self.require_list:RefreshListView({
        {
            resource_type = _("木材"),
            isVisible = true,
            isSatisfy = wood_cur >= wood,
            icon = "res_wood_82x73.png",
            description = wood_cur.."/"..wood,
        },
        {
            resource_type = _("石料"),
            isVisible = true,
            isSatisfy = stone_cur >= stone,
            icon = "res_stone_88x82.png",
            description = stone_cur.."/"..stone
        },
        {
            resource_type = _("铁矿"),
            isVisible = true,
            isSatisfy = iron_cur >= iron,
            icon = "res_iron_91x63.png",
            description = iron_cur.."/"..iron
        },
        {
            resource_type = _("时间"),
            isVisible = true,
            isSatisfy = true,
            icon = "hourglass_30x38.png",
            description = GameUtils:formatTimeStyle1(time)..buff
        },
    })
end
function WidgetManufactureNew:CreateFetchDialog(func,text)
    local dialog = UIKit:showMessageDialogWithParams({
        title = _("提示"),
        content = text,
        ok_callback = func,
        ok_btn_images = {normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"},
        ok_string = _("强行获取"),
        cancel_callback = function () end,
        cancel_btn_images = {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
    })
end
function WidgetManufactureNew:CheckOverFlow(content)
    local city = self.toolShop:BelongCity()
    local material_man = city:GetMaterialManager()
    local limit = city:GetFirstBuildingByType("materialDepot"):GetMaxMaterial()
    local mm = material_man:GetMaterialsByType(material_man.MATERIAL_TYPE.TECHNOLOGY)
    for k,v in pairs(material_man:GetMaterialsByType(material_man.MATERIAL_TYPE.BUILD)) do
        mm[k] = v
    end
    local overflows = {}
    for _,v in ipairs(content) do
        if mm[v.name] + v.count > limit then
            overflows[v.name] = true
        end
    end
    return next(overflows)
end
function WidgetManufactureNew:FetchMaterials(event)
    local content = event:Content()
    NetManager:getFetchMaterialsPromise(event:Id()):done(function()
        local desc_t = {}
        for i,v in ipairs(content) do
            table.insert(desc_t, string.format("%sx%d", Localize.materials[v.name], v.count))
        end
        if event:Category() == "building" then
            GameGlobalUI:showTips(_("获取建筑材料"), table.concat(desc_t, ", "))
        else
            GameGlobalUI:showTips(_("获取科技材料"), table.concat(desc_t, ", "))
        end
    end)
end
function WidgetManufactureNew:BuildMaterial()
    if self.material_tab:GetSelectedButtonTag() == "building" then
        NetManager:getMakeBuildingMaterialPromise()
    else
        NetManager:getMakeTechnologyMaterialPromise()
    end
end


return WidgetManufactureNew









