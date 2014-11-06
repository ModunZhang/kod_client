local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local WidgetPushButton = import("..widget.WidgetPushButton")

local WidgetAllianceBuildingUpgrade = class("WidgetAllianceBuildingUpgrade", function ()
    return display.newLayer()
end)

function WidgetAllianceBuildingUpgrade:ctor()
    self:setNodeEventEnabled(true)
end

-- Node Event
function WidgetAllianceBuildingUpgrade:onEnter()
    -- building level
    local level_bg = display.newSprite("upgrade_level_bg.png", display.cx+80, display.top-125):addTo(self)
    self.builging_level = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 26,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_BOTTOM, 20, 8)
        :addTo(level_bg)
    -- 建筑功能介绍
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-250, display.top-175)
        :addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-145, display.top-175)
        :addTo(self)

    self.building_image = display.newSprite(UIKit:getImageByBuildingType( "keep" ,1), 0, 0):addTo(self):pos(display.cx-196, display.top-158)
    self.building_image:setAnchorPoint(cc.p(0.5,0.5))
    self.building_image:setScale(124/self.building_image:getContentSize().width)
    self:InitBuildingIntroduces()

    self:InitNextLevelEfficiency()
    self:SetBuildingLevel()
    WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("立即升级"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, display.cx, display.top-430):addTo(self)

    self:InitRequirement()
end

function WidgetAllianceBuildingUpgrade:InitBuildingIntroduces()
    self.building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        dimensions = cc.size(380, 90),
        color = UIKit:hex2c3b(0x797154)
    }):align(display.LEFT_CENTER,display.cx-110, display.top-190):addTo(self)
    self:SetBuildingIntroduces()
end

function WidgetAllianceBuildingUpgrade:SetBuildingIntroduces()
    local bd = Localize.building_description
    self.building_introduces:setString(bd["palace"])
end

function WidgetAllianceBuildingUpgrade:InitNextLevelEfficiency()
    -- 下一级 框
    local bg  = display.newSprite("upgrade_next_level_bg.png", window.left+110, window.top-320):addTo(self)
    local bg_size = bg:getContentSize()
    self.next_level = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER,bg_size.width/2,bg_size.height/2):addTo(bg)

    local efficiency_bg = display.newSprite("back_ground_398x97.png", window.cx+70, window.top-320):addTo(self)
    local efficiency_bg_size = efficiency_bg:getContentSize()
    self.efficiency = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        dimensions = cc.size(380,0),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(efficiency_bg):align(display.LEFT_CENTER)
    self.efficiency:pos(10,efficiency_bg_size.height/2)
    self:SetUpgradeEfficiency()
end
function WidgetAllianceBuildingUpgrade:SetBuildingLevel()
    self.builging_level:setString(_("等级 1"))
    -- if self.building:GetNextLevel() == self.building:GetLevel() then
    self.next_level:setString(_("等级已满 "))
    -- else
    --     self.next_level:setString(_("等级 ")..self.building:GetNextLevel())
    -- end
end

function WidgetAllianceBuildingUpgrade:SetUpgradeEfficiency()
    local bd = Localize.building_description
    local building = self.building
    local efficiency
    efficiency = string.format("%s+%d,%s+%d",bd.palace_total_members,"4",bd.palace_alliance_power,"300")

    self.efficiency:setString(efficiency)
end

function WidgetAllianceBuildingUpgrade:InitRequirement()
    local requirements = {
        {resource_type = _("荣耀点"),
            isVisible = true,
            isSatisfy = true,
            icon="honour.png",
            description="200/400"},
        {resource_type = _("联盟城堡等级"),
            isVisible = true,
            isSatisfy = true,
            icon="keep_760x855.png",
            description="22/16"},

        {resource_type = _("职位"),
            isVisible = true,
            isSatisfy = true ,
            icon="leader.png",
            description= "联盟盟主"},
    }

    if not self.requirement_listview then
        self.requirement_listview = WidgetRequirementListview.new({
            title = _("升级需求"),
            height = 298,
            contents = requirements,
        }):addTo(self):pos(display.cx-275, display.top-866)
    end
    self.requirement_listview:RefreshListView(requirements)
end

function WidgetAllianceBuildingUpgrade:onExit()

end


return WidgetAllianceBuildingUpgrade









