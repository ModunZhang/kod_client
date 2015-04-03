local GameUtils = GameUtils
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSliderWithInput = import("..widget.WidgetSliderWithInput")
local HospitalUpgradeBuilding = import("..entity.HospitalUpgradeBuilding")
local UILib = import("..ui.UILib")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetTreatSoldier = class("WidgetTreatSoldier", function(...)
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            node:blank_clicked()
        end
        return true
    end)
    return node
end)
local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special

local SOLDIER_TYPE = {
    ["swordsman_1"] = { png = "#Infantry_1_render/idle/1/00000.png" },
    ["swordsman_2"] = { png = "soldier_swordsman_2.png" },
    ["swordsman_3"] = { png = "soldier_swordsman_3.png" },
    ["sentinel_1"] = { png = "soldier_sentinel_1.png" },
    ["sentinel_2"] = { png = "soldier_sentinel_2.png" },
    ["sentinel_3"] = { png = "soldier_sentinel_3.png" },
    ["archer_1"] = { png = "#Archer_1_render/idle/1/00000.png" },
    ["archer_2"] = { png = "soldier_archer_2.png" },
    ["archer_3"] = { png = "soldier_archer_3.png" },
    ["crossbowman_1"] = { png = "soldier_crossbowman_1.png" },
    ["crossbowman_2"] = { png = "soldier_crossbowman_2.png" },
    ["crossbowman_3"] = { png = "soldier_crossbowman_2.png" },
    ["lancer_1"] = { png = "#Cavalry_1_render/idle/1/00000.png" },
    ["lancer_2"] = { png = "soldier_lancer_2.png" },
    ["lancer_3"] = { png = "soldier_lancer_3.png" },
    ["horseArcher_1"] = { png = "soldier_horseArcher_1.png" },
    ["horseArcher_2"] = { png = "soldier_horseArcher_2.png" },
    ["horseArcher_3"] = { png = "soldier_horseArcher_3.png" },
    ["catapult_1"] = { png = "#Catapult_1_render/move/1/00000.png" },
    ["catapult_2"] = { png = "soldier_catapult_2.png" },
    ["catapult_3"] = { png = "soldier_catapult_3.png" },
    ["ballista_1"] = { png = "soldier_ballista_1.png" },
    ["ballista_2"] = { png = "soldier_ballista_2.png" },
    ["ballista_3"] = { png = "soldier_ballista_3.png" },
    ["skeletonWarrior"] = { png = "soldier_skeletonWarrior.png" },
    ["skeletonArcher"] = { png = "soldier_skeletonArcher.png" },
    ["deathKnight"] = { png = "soldier_deathKnight.png" },
    ["meatWagon"] = { png = "meatWagon.png" },
    ["priest"] = {},
    ["demonHunter"] = {},
    ["paladin"] = {},
    ["steamTank"] = {},
}
local SOLDIER_CATEGORY_MAP = {
    ["swordsman"] = "infantry",
    ["sentinel"] = "infantry",

    ["ranger"] = "archer",
    ["crossbowman"] = "archer",

    ["lancer"] = "cavalry",
    ["horseArcher"] = "cavalry",

    ["catapult"] = "siege",
    ["ballista"] = "siege",
}
local SOLDIER_VS_MAP = {
    ["infantry"] = {
        strong_vs = { "siege", "wall" },
        weak_vs = { "cavalry", "archer" }
    },
    ["archer"] = {
        strong_vs = { "cavalry", "infantry" },
        weak_vs = { "wall", "siege" }
    },
    ["cavalry"] = {
        strong_vs = { "infantry", "siege" },
        weak_vs = { "archer", "wall" }
    },
    ["siege"] = {
        strong_vs = { "wall", "archer" },
        weak_vs = { "infantry", "cavalry" }
    },
    ["wall"] = {
        strong_vs = { "archer", "cavalry" },
        weak_vs = { "siege", "infantry"}
    }
}
local SOLDIER_LOCALIZE_MAP = {
    ["infantry"] = _("步兵"),
    ["archer"] = _("弓手"),
    ["cavalry"] = _("骑兵"),
    ["siege"] = _("攻城"),
    ["wall"] = _("城墙"),
}

local function return_vs_soldiers_map(soldier_type)
    return SOLDIER_VS_MAP[SOLDIER_CATEGORY_MAP[soldier_type]]
end

function WidgetTreatSoldier:ctor(soldier_type, star, treat_max)
    self.soldier_type = soldier_type
    self.treat_max = treat_max

    local label_origin_x = 190

    -- bg
    local back_ground = WidgetUIBackGround.new({height=500}):addTo(self)

    back_ground:setTouchEnabled(true)

    -- title
    local size = back_ground:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_430x30.png"):addTo(back_ground, 2)
        :align(display.RIGHT_CENTER, size.width-10, size.height - 40)

    -- title label
    local size = title_blue:getContentSize()
    self.title = cc.ui.UILabel.new({
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, 10, size.height/2)


    -- soldier bg
    local size = back_ground:getContentSize()
    local width, height = 140, 130
    local soldier_bg = cc.ui.UIImage.new("back_ground_54x127.png",
        {scale9 = true}):addTo(back_ground, 2)
        :align(display.CENTER, 84, size.height - 84)
        :setLayoutSize(width, height)

    -- stars
    self.stars = {}
    local origin_x, origin_y, gap_y = width - 15, 15, 25
    for i = 1, 5 do
        local bg = cc.ui.UIImage.new("star_bg_24x23.png"):addTo(soldier_bg, 2)
            :align(display.CENTER, origin_x, origin_y + (i - 1) * gap_y)

        local pos = bg:getAnchorPointInPoints()
        local star = cc.ui.UIImage.new("star_18x16.png"):addTo(bg)
            :align(display.CENTER, pos.x, pos.y)
        table.insert(self.stars, star)
    end


    -- star_bg
    local size = soldier_bg:getContentSize()
    local star_bg = cc.ui.UIImage.new("star1_114x128.png"):addTo(soldier_bg, 2)
        :align(display.CENTER, 55, size.height/2)
    self.star_bg = star_bg

    -- soldier type
    local pos = star_bg:getAnchorPointInPoints()

    local size = back_ground:getContentSize()
    local label = cc.ui.UILabel.new({
        text = "强势对抗",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x5bb800)
    }):addTo(back_ground, 2)
        :align(display.LEFT_BOTTOM, label_origin_x, size.height - 85 - 11)

    local vs_map = return_vs_soldiers_map(soldier_type)
    local strong_vs = {}
    for i, v in ipairs(vs_map.strong_vs) do
        table.insert(strong_vs, SOLDIER_LOCALIZE_MAP[v])
    end
    local soldier_name = cc.ui.UILabel.new({
        text = table.concat(strong_vs, ", "),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x + label:getContentSize().width, size.height - 85)

    local label = cc.ui.UILabel.new({
        text = "弱势对抗",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x890000)
    }):addTo(back_ground, 2)
        :align(display.LEFT_BOTTOM, label_origin_x, size.height - 120 - 11)

    local weak_vs = {}
    for i, v in ipairs(vs_map.weak_vs) do
        table.insert(weak_vs, SOLDIER_LOCALIZE_MAP[v])
    end
    local soldier_name = cc.ui.UILabel.new({
        text = table.concat(weak_vs, ", "),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x + label:getContentSize().width, size.height - 120)


    -- food icon
    cc.ui.UIImage.new("res_food_114x100.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 130, size.height - 100):scale(0.5)

    cc.ui.UILabel.new({
        text = _("维护费"),
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x7f775f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 90, size.height - 80)

    -- upkeep
    self.upkeep = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 60, size.height - 110)


    -- local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
    --     progress = "slider_progress_445x14.png",
    --     button = "slider_btn_66x66.png"}, {max = treat_max}):addTo(back_ground, 2)
    --     :align(display.LEFT_CENTER, 25, slider_height)
    --     :onSliderValueChanged(function(event)
    --         self:OnCountChanged(math.floor(event.value))
    --     end)


    -- -- soldier count bg
    -- local bg = cc.ui.UIImage.new("back_ground_83x32.png"):addTo(back_ground, 2)
    --     :align(display.CENTER, size.width - 70, label_height)

    -- -- soldier current
    -- local pos = bg:getAnchorPointInPoints()
    -- self.soldier_current_count = cc.ui.UILabel.new({
    --     text = "0",
    --     size = 20,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_RIGHT,
    --     color = UIKit:hex2c3b(0x403c2f)
    -- }):addTo(bg, 2)
    --     :align(display.CENTER, pos.x, pos.y)

    -- -- soldier total count
    -- self.soldier_total_count = cc.ui.UILabel.new({
    --     text = string.format("/ %d", treat_max),
    --     size = 20,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_RIGHT,
    --     color = UIKit:hex2c3b(0x403c2f)
    -- }):addTo(back_ground, 2)
    --     :align(display.CENTER, size.width - 70, label_height - 35)

    -- progress
    WidgetSliderWithInput.new({max = treat_max}):addTo(back_ground):align(display.LEFT_CENTER, 25, 330)
        :SetSliderSize(445, 24)
        :OnSliderValueChanged(function(event)
            self:OnCountChanged(math.floor(event.value))
        end)
        :LayoutValueLabel(WidgetSliderWithInput.STYLE_LAYOUT.RIGHT,0)



    -- need bg
    local need = WidgetUIBackGround.new({
        width = 556,
        height = 106,
        top_img = "back_ground_426x14_top_1.png",
        bottom_img = "back_ground_426x14_top_1.png",
        mid_img = "back_ground_426x1_mid_1.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,size.width/2, size.height/2 - 40):addTo(back_ground)


    -- needs
    local size = need:getContentSize()
    local margin_x = 120
    local length = size.width - margin_x * 2
    local origin_x, origin_y, gap_x = margin_x, 30, length / 3
    local res_map = {
        { "treatFood", "res_food_114x100.png" },
        { "treatWood", "res_wood_114x100.png" },
        { "treatIron", "res_iron_114x100.png" },
        { "treatStone", "res_stone_128x128.png" },
    -- { "citizen", "res_citizen_44x50.png" },
    }
    self.res_map = {}
    for i, v in pairs(res_map) do
        local res_type = v[1]
        local png = v[2]
        local x = origin_x + (i - 1) * gap_x
        local scale =  0.4
        cc.ui.UIImage.new(png):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y):scale(scale)

        local total = cc.ui.UILabel.new({
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y - 40)

        local need = cc.ui.UILabel.new({
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x403c2f)
        -- color = display.COLOR_RED
        }):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y - 60)

        self.res_map[res_type] = { total = total, need = need }
    end

    -- 立即治愈
    local size = back_ground:getContentSize()
    local instant_button = WidgetPushButton.new(
        {normal = "green_btn_up_250x65.png",pressed = "green_btn_down_250x65.png"},
        {scale9 = false},
        {
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground, 2)
        :align(display.CENTER, 160, 110)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("立即治愈"),
            size = 24,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            local soldiers = {{name=self.soldier_type, count=self.count}}
            local treat_fun = function ()
                -- NetManager:instantTreatSoldiers(soldiers, NOT_HANDLE)
                NetManager:getInstantTreatSoldiersPromise(soldiers):catch(function(err)
                    dump(err:reason())
                end)
                self:instant_button_clicked()
            end
            if self.count<1 then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("请设置要治愈的伤兵数")):AddToCurrentScene()
            elseif self.treat_now_gems>City:GetUser():GetGemResource():GetValue() then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("宝石补足"))
                    :CreateOKButton(
                        {
                            listener = function ()
                                UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
                                City:GetResourceManager():RemoveObserver(self)
                                self:getParent():LeftButtonClicked()
                            end,
                            btn_name= _("前往商店")
                        }
                    ):AddToCurrentScene()
            else
                treat_fun()
            end
        end):SetFilter({
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })

    -- gem
    cc.ui.UIImage.new("gem_66x56.png"):addTo(instant_button, 2)
        :align(display.CENTER, -100, -50):scale(0.5)

    -- gem count
    self.gem_label = cc.ui.UILabel.new({
        text = "600",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(instant_button, 2)
        :align(display.LEFT_CENTER, -100 + 20, -50)


    -- 治愈
    local button = WidgetPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"} ,
        {scale9 = false},
        {
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground, 2)
        :align(display.CENTER, size.width - 120, 110)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("治愈"),
            size = 27,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            local hospital = City:GetFirstBuildingByType("hospital")
            local soldiers = {{name=self.soldier_type, count=self.count}}
            local treat_fun = function ()
                -- NetManager:treatSoldiers(soldiers, NOT_HANDLE)
                NetManager:getTreatSoldiersPromise(soldiers):catch(function(err)
                    dump(err:reason())
                end)
                self:button_clicked()
            end
            local isAbleToTreat =hospital:IsAbleToTreat(soldiers)
            if self.count<1 then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("请设置要治愈的伤兵数")):AddToCurrentScene()
            elseif City:GetUser():GetGemResource():GetValue()< hospital:GetTreatGems(soldiers) then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("没有足够的宝石补充资源"))
                    :CreateOKButton(
                        {
                            listener = function ()
                                UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
                                City:GetResourceManager():RemoveObserver(self)
                                self:getParent():LeftButtonClicked()
                            end,
                            btn_name= _("前往商店")
                        }
                    ):AddToCurrentScene()
            elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING_AND_LACK_RESOURCE then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("正在治愈，资源不足"))
                    :CreateOKButton(
                        {
                            listener = treat_fun
                        }
                    )
                    :CreateNeeds({value = hospital:GetTreatGems(soldiers)}):AddToCurrentScene()
            elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.LACK_RESOURCE then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("资源不足，是否花费宝石补足"))
                    :CreateOKButton({
                        listener = treat_fun
                    })
                    :CreateNeeds({value = hospital:GetTreatGems(soldiers)}):AddToCurrentScene()
            elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING then
                local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("正在治愈，是否花费魔法石立即完成"))
                    :CreateOKButton({
                        listener = treat_fun
                    })
                    :CreateNeeds({value = hospital:GetTreatGems(soldiers)}):AddToCurrentScene()
            else
                treat_fun()
            end
        end):SetFilter({
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })

    -- 时间glass
    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(button, 2)
        :align(display.LEFT_CENTER, -90, -55):scale(0.7)

    -- 时间
    local center = -20
    self.treat_time = cc.ui.UILabel.new({
        -- text = "20:20:20",
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

    self:SetSoldier(soldier_type, star)
    self:OnCountChanged(0)
end
function WidgetTreatSoldier:SetSoldier(soldier_type, star)
    local soldier_config, soldier_ui_config = self:GetConfigBySoldierTypeAndStar(soldier_type, star)
    -- title
    self.title:setString(Localize.soldier_name[soldier_type])
    -- bg
    self.star_bg:setTexture(display.newSprite(UILib.soldier_bg[star]):getTexture())
    -- soldier
    if self.soldier then
        self.star_bg:removeChild(self.soldier)
    end
    self.soldier = display.newSprite(soldier_ui_config):addTo(self.star_bg)
        :align(display.CENTER, self.star_bg:getContentSize().width/2, self.star_bg:getContentSize().height/2)
    self.soldier:scale(130/self.soldier:getContentSize().height)
    -- stars
    local star = soldier_config.star
    for i, v in ipairs(self.stars) do
        v:setVisible(i <= star)
    end

    self.soldier_config = soldier_config
    self.soldier_ui_config = soldier_ui_config
    return self
end
function WidgetTreatSoldier:GetConfigBySoldierTypeAndStar(soldier_type, star)
    local soldier_type_with_star = soldier_type..(star == nil and "" or string.format("_%d", star))
    local soldier_config = NORMAL[soldier_type_with_star] == nil and SPECIAL[soldier_type] or NORMAL[soldier_type_with_star]
    local soldier_ui_config = UILib.soldier_image[soldier_type][star]
    return soldier_config, soldier_ui_config
end
function WidgetTreatSoldier:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end
local app = app
local timer = app.timer
function WidgetTreatSoldier:OnResourceChanged(resource_manager)
    local server_time = timer:GetServerTime()
    local res_map = {}
    res_map.treatWood = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(server_time)
    res_map.treatFood = resource_manager:GetFoodResource():GetResourceValueByCurrentTime(server_time)
    res_map.treatIron = resource_manager:GetIronResource():GetResourceValueByCurrentTime(server_time)
    res_map.treatStone = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(server_time)
    -- res_map.citizen = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(server_time)
    for k, v in pairs(self.res_map) do
        local total = res_map[k]
        v.total:setString(GameUtils:formatNumber(total))
    end
    self.res_total_map = res_map
end
function WidgetTreatSoldier:OnInstantButtonClicked(func)
    self.instant_button_clicked = func
    return self
end
function WidgetTreatSoldier:OnNormalButtonClicked(func)
    self.button_clicked = func
    return self
end
function WidgetTreatSoldier:OnBlankClicked(func)
    self.blank_clicked = func
    return self
end
function WidgetTreatSoldier:OnCountChanged(count)
    local soldier_config = self.soldier_config
    local soldier_ui_config = self.soldier_ui_config
    local total_time = soldier_config.treatTime * count
    -- self.soldier_current_count:setString(string.format("%d", count))
    self.upkeep:setString(string.format("%s%d", count > 0 and "-" or "", soldier_config.consumeFoodPerHour * count))
    self.treat_time:setString(GameUtils:formatTimeStyle1(total_time))

    local total_map = self.res_total_map == nil and {} or self.res_total_map
    local current_res_map = {}
    for k, v in pairs(self.res_map) do
        local total = total_map[k] == nil and 0 or total_map[k]
        local current = soldier_config[k] * count
        local rs_k = ""
        if k=="treatStone" then
            rs_k = "stone"
        elseif k=="treatIron" then
            rs_k = "iron"
        elseif k=="treatFood" then
            rs_k = "food"
        elseif k=="treatWood" then
            rs_k = "wood"
        end
        current_res_map[rs_k] = current
        local color = total >= current and UIKit:hex2c3b(0x403c2f) or display.COLOR_RED
        v.need:setString(string.format("/ %s", GameUtils:formatNumber(current)))
        v.total:setColor(color)
        v.need:setColor(color)
    end
    self.count = count
    LuaUtils:outputTable("current_res_map", current_res_map)
    self.treat_now_gems = DataUtils:buyResource(current_res_map, {}) + DataUtils:getGemByTimeInterval(total_time)
    self.gem_label:setString(self.treat_now_gems)
end
return WidgetTreatSoldier































