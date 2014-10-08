local Localize = import("..utils.Localize")
local SpriteConfig = import("..sprites.SpriteConfig")
local window = import("..utils.window")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIHasBeenBuild = UIKit:createUIClass('GameUIHasBeenBuild', "GameUIWithCommonHeader")


local building_config_map = {
    ["keep"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["watchTower"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["warehouse"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["dragonEyrie"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["toolShop"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["materialDepot"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["armyCamp"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["barracks"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["blackSmith"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["foundry"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["stoneMason"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["lumbermill"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["mill"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["hospital"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["townHall"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["tradeGuild"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["academy"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["prison"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["hunterHall"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["trainingGround"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["stable"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["workShop"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["wall"] = {scale = 0.2, offset = {x = 0, y = 0}},
    ["tower"] = {scale = 0.2, offset = {x = 0, y = 0}},
}






function GameUIHasBeenBuild:ctor(city)
    GameUIHasBeenBuild.super.ctor(self, city, _("建筑列表"))
    self.build_city = city
end
function GameUIHasBeenBuild:onEnter()
    self.build_city:AddListenOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onEnter(self)
    self:TabButtons()
end
function GameUIHasBeenBuild:onExit()
    self.build_city:RemoveListenerOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onExit(self)
end
function GameUIHasBeenBuild:OnUpgradingBegin(building, current_time, city)
-- dump(building)
end
function GameUIHasBeenBuild:OnUpgrading(building, current_time, city)
-- dump(building)
end
function GameUIHasBeenBuild:OnUpgradingFinished(building, current_time, city)
-- dump(building)
end

function GameUIHasBeenBuild:TabButtons()
    self:CreateTabButtons({
        {
            label = _("功能建筑"),
            tag = "function",
            default = true
        },
        {
            label = _("资源建筑"),
            tag = "resource",
        },
    },
    function(tag)
        if tag == "function" then
            self:LoadFunctionListView()
        elseif tag == "resource" then
            self:UnloadFunctionListView()
        end
    end):pos(window.cx, window.bottom + 34)
end
function GameUIHasBeenBuild:LoadFunctionListView()
    if not self.function_list_view then
        self.function_list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 180)
        for i, v in pairs(self.build_city:GetFunctionBuildingsWhichIsUnlocked()) do
            -- print(v:UniqueKey())
            local item = self:CreateItemWithListView(self.function_list_view)
            item:SetBuildingType(v:GetType(), v:GetLevel())
            item:UpdateByBuilding(v)
            self.function_list_view:addItem(item)
        end
        self.function_list_view:reload():resetPosition()
    end
    self.function_list_view:setVisible(true)
end
function GameUIHasBeenBuild:UnloadFunctionListView()
    self.function_list_view:removeFromParentAndCleanup(true)
    self.function_list_view = nil
end



--
function GameUIHasBeenBuild:CreateItemWithListView(list_view)
    local item = list_view:newItem()
    local back_ground = WidgetUIBackGround.new(170)
    item:addContent(back_ground)

    local w, h = back_ground:getContentSize().width, back_ground:getContentSize().height
    item:setItemSize(w, h + 10)

    local left_x, right_x = 15, 160
    local left = display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.LEFT_CENTER, left_x, h/2):flipX(true)

    display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.RIGHT_CENTER, right_x, h/2)

    WidgetPushButton.new(
        {normal = "info_26x26.png",pressed = "info_26x26.png"})
        :addTo(left)
        :align(display.CENTER, 6, 6)


    local building_icon = display.newSprite("keep_131x164.png")
        :addTo(back_ground):align(display.BOTTOM_CENTER, (left_x + right_x) / 2, 30)


    local title_blue = cc.ui.UIImage.new("title_blue_402x48.png", {scale9 = true})
        :addTo(back_ground):align(display.LEFT_CENTER, right_x, h - 33)
    title_blue:setContentSize(cc.size(435, 48))
    local size = title_blue:getContentSize()
    local title_label = cc.ui.UILabel.new({
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2)
        :align(display.LEFT_CENTER, 30, size.height/2)


    local condition_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x7e0000)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 170, h/2)



    local desc_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 170, 35)


    local instant_build = WidgetPushButton.new(
        {normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"})
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))


    local gem_bg = display.newSprite("back_ground_97x20.png")
        :addTo(back_ground, 2)
        :align(display.CENTER, w - 90, h/2)

    display.newSprite("gem_66x56.png")
        :addTo(gem_bg, 2)
        :align(display.CENTER, 20, 20/2)
        :scale(0.4)

    local gem_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xfff3c7)
    }):addTo(gem_bg, 2)
        :align(display.LEFT_CENTER, 40, 20/2)


    local normal_build = WidgetPushButton.new(
        {normal = "yellow_btn_up_149x47.png",pressed = "yellow_btn_down_149x47.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))


    local progress = WidgetProgress.new(UIKit:hex2c3b(0xfff3c7), "progress_bg_402x36.png", "progress_bar_404x34.png"):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 185, h/2)

    local speed_up = WidgetPushButton.new(
        {normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"})
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("加速"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))


    function item:SetBuildingType(building_type, level)
        self:SetTitleLabel(Localize.building_name[building_type])
        local config = building_config_map[building_type]
        local png = SpriteConfig[building_type]:GetConfigByLevel(level).png
        building_icon:setTexture(png)
        building_icon:scale(config.scale)
        -- building_icon:(config.scale)
        return self
    end
    function item:SetTitleLabel(label)
        if title_label:getString() ~= label then
            title_label:setString(label)
        end
        return self
    end
    function item:SetGemLabel(label)
        if gem_label:getString() ~= label then
            gem_label:setString(label)
        end
        return self
    end
    function item:SetDescLabel(label)
        if desc_label:getString() ~= label then
            desc_label:setString(label)
        end
        return self
    end
    function item:SetProgressInfo(time_label, percent)
        progress:SetProgressInfo(time_label, percent)
        return self
    end
    function item:UpdateByBuilding(building)
        self.building = building
        if building:IsUpgrading() then
            self:ChangeStatus("building")
        else
            if building:IsMaxLevel() then
                self:ChangeStatus("max")
            else
                self:ChangeStatus("normal")
            end
        end
    end
    function item:UpdateDesc(building)
        if building:IsUpgrading() then
            self:SetDescLabel(string.format("%s%d", _("正在升级到"), building:GetLevel()))
        else
            if building:IsMaxLevel() then
                self:SetDescLabel(string.format("%s", _("已经到最大等级了")))
            else
                self:SetDescLabel(string.format("%s%d%s%d", _("从等级"), building:GetLevel(), _("升级到等级"), building:GetNextLevel()))
            end
        end
    end
    function item:OnBuildingUpgradingBegin(building)
        self:ChangeStatus("building")
    end
    function item:OnBuildingUpgrading(building)

    end
    function item:OnBuildingUpgradingEnd(building)

    end
    function item:ChangeStatus(status)
        if self.status == status then
            return
        end
        if status == "instant" then
            self:HideNormal()
            self:HideProgress()
            self:HideDisable()
            self:HideMax()

            self:ShowInstant()
        elseif status == "normal" then
            self:HideInstant()
            self:HideProgress()
            self:HideDisable()
            self:HideMax()

            self:ShowNormal()
        elseif status == "building" then
            self:HideInstant()
            self:HideNormal()
            self:HideDisable()
            self:HideMax()

            self:ShowProgress()
        elseif status == "disable" then
            self:HideInstant()
            self:HideNormal()
            self:HideProgress()
            self:HideMax()

            self:ShowDisable()
        elseif status == "max" then
            self:HideInstant()
            self:HideNormal()
            self:HideProgress()
            self:HideDisable()

            self:ShowMax()
        end
        self.status = status
        self:UpdateDesc(self.building)
        return self
    end
    function item:HideInstant()
        gem_bg:setVisible(false)
        instant_build:setVisible(false)
    end
    function item:ShowInstant()
        gem_bg:setVisible(true)
        instant_build:setVisible(true)
        condition_label:setString(_("不满足升级条件"))
        condition_label:setColor(UIKit:hex2c3b(0x7e0000))
    end
    function item:HideNormal()
        normal_build:setVisible(false)
    end
    function item:ShowNormal()
        normal_build:setVisible(true)
        condition_label:setString(_("满足条件升级"))
        condition_label:setColor(UIKit:hex2c3b(0x007c23))
    end
    function item:HideProgress()
        progress:setVisible(false)
        speed_up:setVisible(false)
    end
    function item:ShowProgress()
        progress:setVisible(true)
        speed_up:setVisible(true)
    end
    function item:HideDisable()
        normal_build:setButtonEnabled(true)
        normal_build:setVisible(false)
    end
    function item:ShowDisable()
        normal_build:setButtonEnabled(false)
        normal_build:setVisible(true)
        condition_label:setString(_("不满足升级条件"))
        condition_label:setColor(UIKit:hex2c3b(0x7e0000))
    end
    function item:HideMax()

    end
    function item:ShowMax()
        normal_build:setVisible(false)
        condition_label:setVisible(false)
    end

    -- item:ChangeStatus("disable"):SetGemLabel("999"):SetNumberLabel("999"):SetProgressInfo("asdf", 80):SetTitleLabel(_("城"))

    return item
end

return GameUIHasBeenBuild






























