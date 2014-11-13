local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local Enum = import("..utils.Enum")
local Localize = import("..utils.Localize")
local AllianceMap = import("..entity.AllianceMap")
local window = import("..utils.window")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local WidgetAllianceBuildingInfo = import("..widget.WidgetAllianceBuildingInfo")
local WidgetPushButton = import("..widget.WidgetPushButton")

local WidgetAllianceBuildingUpgrade = class("WidgetAllianceBuildingUpgrade", function ()
    return display.newLayer()
end)

local UPGRADE_ERR_TYPE = Enum("POSITION","KEEP","HONOUR")

local ERR_MESSAGE = {
    [UPGRADE_ERR_TYPE.POSITION] = _("只有联盟盟主才能升级联盟宫殿"),
    [UPGRADE_ERR_TYPE.KEEP] = _("联盟盟主的城堡等级不足"),
    [UPGRADE_ERR_TYPE.HONOUR] = _("荣耀点不足"),
}

function WidgetAllianceBuildingUpgrade:ctor(building)
    self:setNodeEventEnabled(true)
    self.building = building
    self.building_config = GameDatas.AllianceBuilding[building.name]
    self.alliance = Alliance_Manager:GetMyAlliance()
end
function WidgetAllianceBuildingUpgrade:RefreahBuilding(building)
    self.building = building
    self.building_config = GameDatas.AllianceBuilding[building.name]
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

    self.building_info_btn = WidgetPushButton.new({normal = UIKit:getImageByBuildingType( self.building.name ,1),
        pressed = UIKit:getImageByBuildingType( self.building.name ,1)})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                print("弹出建筑介绍详情")
                WidgetAllianceBuildingInfo.new():addTo(self)
            end
        end):align(display.CENTER, display.cx-196, display.top-158):addTo(self)
    self.building_info_btn:setScale(124/self.building_info_btn:getCascadeBoundingBox().size.width)

    -- i image
    display.newSprite("info_26x26.png"):align(display.CENTER, display.cx-250, display.top-225)
        :addTo(self)

    self:InitBuildingIntroduces()

    self:InitNextLevelEfficiency()
    self:SetBuildingLevel()
    self.upgrade_button = WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("立即升级"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local err = self:IsAbleToUpgrade()
                if err then
                    FullScreenPopDialogUI.new()
                        :SetTitle(_("提示"))
                        :SetPopMessage(ERR_MESSAGE[err])
                        :AddToCurrentScene()
                else
                    NetManager:getUpgradeAllianceBuildingPromise(self.building.name)
                end
            end
        end):align(display.CENTER, display.cx, display.top-430):addTo(self)
    self:VisibleUpgradeButton()

    self:InitRequirement()

    self.alliance:GetAllianceMap():AddListenOnType(self,AllianceMap.LISTEN_TYPE.BUILDING_LEVEL)

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
    self.building_introduces:setString(bd[self.building.name])
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
    self.builging_level:setString(_("等级").." ".. self.building.level)
    if #self.building_config == self.building.level then
        self.next_level:setString(_("等级已满 "))
    else
        self.next_level:setString(_("等级 ")..self.building.level+1)
    end
end

function WidgetAllianceBuildingUpgrade:SetUpgradeEfficiency()
    local bd = Localize.building_description
    local building = self.building
    local now_c = self.building_config[building.level]
    local next_c = self:getNextLevelConfig__()
    local efficiency
    if #self.building_config == self.building.level then
        efficiency = _("已达到最大等级")
    else
        if building.name == "palace" then
            efficiency = string.format("%s+%d,%s+%d",bd.palace_total_members,next_c.memberCount-now_c.memberCount,bd.palace_alliance_power,next_c.power)
        else
            efficiency = _("本地化缺失")
        end
    end

    self.efficiency:setString(efficiency)
end

function WidgetAllianceBuildingUpgrade:InitRequirement()
    local alliance = Alliance_Manager:GetMyAlliance()
    if #self.building_config == self.building.level then
        if self.requirement_listview then
            self.requirement_listview:setVisible(false)
        end
        return
    end
    local now_c = self.building_config[self.building.level+1]
    local requirements = {
        {resource_type = _("荣耀点"),
            isVisible = true,
            isSatisfy = alliance:Honour()>=now_c.needHonour,
            icon="honour.png",
            description=alliance:Honour().."/"..now_c.needHonour},
        {resource_type = _("联盟城堡等级"),
            isVisible = alliance:GetMemeberById(DataManager:getUserData()._id):IsArchon(),
            isSatisfy = City:GetFirstBuildingByType("keep"):GetLevel()>=now_c.needKeep,
            icon="keep_760x855.png",
            description=City:GetFirstBuildingByType("keep"):GetLevel().."/"..now_c.needKeep},

        {resource_type = _("职位"),
            isVisible = true,
            isSatisfy = alliance:GetMemeberById(DataManager:getUserData()._id):IsArchon() ,
            icon="leader.png",
            description= _("联盟盟主")},
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
    self.alliance:GetAllianceMap():RemoveListenerOnType(self,AllianceMap.LISTEN_TYPE.BUILDING_LEVEL)
end

function WidgetAllianceBuildingUpgrade:IsAbleToUpgrade()
    local alliance = Alliance_Manager:GetMyAlliance()
    local now_c = self.building_config[self.building.level+1]
    if self.building.name=="palace" then
        if not alliance:GetMemeberById(DataManager:getUserData()._id):IsArchon() then
            return UPGRADE_ERR_TYPE.POSITION
        else
            if alliance:Honour()<now_c.needHonour then
                return UPGRADE_ERR_TYPE.HONOUR
            elseif City:GetFirstBuildingByType("keep"):GetLevel()<now_c.needKeep then
                return UPGRADE_ERR_TYPE.KEEP
            end
        end
    end
end

function WidgetAllianceBuildingUpgrade:OnBuildingLevelChange(building)
    self:RefreahBuilding(building)
    self:InitRequirement()
    self:SetBuildingLevel()
    self:SetUpgradeEfficiency()
    self:VisibleUpgradeButton()
end

function WidgetAllianceBuildingUpgrade:VisibleUpgradeButton()
    if #self.building_config == self.building.level then
        self.upgrade_button:setVisible(false)
    end
end

function WidgetAllianceBuildingUpgrade:getNextLevelConfig__()
    self.building_config = GameDatas.AllianceBuilding[self.building.name]
    if #self.building_config == self.building.level then
        return self.building_config[self.building.level]
    else
        return self.building_config[self.building.level+1]
    end
end

return WidgetAllianceBuildingUpgrade



