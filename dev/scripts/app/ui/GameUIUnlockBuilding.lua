local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local UpgradeBuilding = import("..entity.UpgradeBuilding")
local Localize = import("..utils.Localize")
local window = import("..utils.window")

local GameUIUnlockBuilding = class("GameUIUnlockBuilding", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function GameUIUnlockBuilding:ctor( city, tile )
    self.city = city
    self.tile = tile
    self.building = city:GetBuildingByLocationId(tile.location_id)
    self:setNodeEventEnabled(true)
    self:Init()
    self.city:GetResourceManager():AddObserver(self)

end
function GameUIUnlockBuilding:OnResourceChanged(resource_manager)
    self:SetUpgradeRequirementListview()
end
function GameUIUnlockBuilding:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
end
function GameUIUnlockBuilding:Init()
    -- bg
    local bg = display.newScale9Sprite("full_screen_dialog_bg.png",display.cx, display.top-480, cc.size(612,663)):addTo(self)
    -- title bg
    local title_bg = display.newSprite("Title_blue.png"):align(display.TOP_LEFT, 8, bg:getContentSize().height):addTo(bg,2)
    -- title label
    self.title = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text =  _("解锁建筑"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,title_bg:getContentSize().width/2,title_bg:getContentSize().height/2):addTo(title_bg)

    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, bg:getContentSize().width-15, bg:getContentSize().height-5):addTo(bg,2):addChild(display.newSprite("X_3.png"))
    -- 建筑功能介绍
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-250, display.top-265)
        :addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-145, display.top-265)
        :addTo(self)
    -- local building_introduces_bg = display.newSprite("upgrade_introduce_bg.png", display.cx, display.top-290):addTo(self)
    self.building_image = display.newScale9Sprite(UIKit:getImageByBuildingType( self.building:GetType()), display.cx-197, display.top-245):addTo(self)
    self.building_image:setAnchorPoint(cc.p(0.5,0.5))
    self.building_image:setScale(124/self.building_image:getContentSize().width)
    self:InitBuildingIntroduces()

    -- upgrade now button
    cc.ui.UIPushButton.new({normal = "upgrade_green_button_normal.png",pressed = "upgrade_green_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("立即解锁"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local upgrade_listener = function()

                    NetManager:instantUpgradeBuildingByLocation(City:GetLocationIdByBuildingType(self.building:GetType()), NOT_HANDLE)
                    -- print(self.building:GetType().."---------------- 立即解锁 button has been  clicked ")
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(true)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                    self:removeFromParent(true)
                end
            end
        end):align(display.CENTER, display.cx-150, display.top-380):addTo(self)
    -- upgrade button
    cc.ui.UIPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("解锁"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local upgrade_listener = function()
                    NetManager:upgradeBuildingByLocation(City:GetLocationIdByBuildingType(self.building:GetType()), NOT_HANDLE)
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(false)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                    self:removeFromParent(true)
                end
            end
        end):align(display.CENTER, display.cx+180, display.top-380):addTo(self)
    -- 立即升级所需宝石
    display.newSprite("Topaz-icon.png", display.cx-260, display.top-440):addTo(self):setScale(0.5)
    self.upgrade_now_need_gems_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx-240,display.top-446):addTo(self)
    self:SetUpgradeNowNeedGems()
    --升级所需时间
    display.newSprite("upgrade_hourglass.png", display.cx+100, display.top-440):addTo(self):setScale(0.6)
    self.upgrade_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx+125,display.top-430):addTo(self)
    self:SetUpgradeTime()

    -- 科技减少升级时间
    self.buff_reduce_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "(-00:20:00)",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x068329)
    }):align(display.LEFT_CENTER,display.cx+120,display.top-450):addTo(self)

    --升级需求listview
    self:SetUpgradeRequirementListview()
end

function GameUIUnlockBuilding:InitBuildingIntroduces()
    self.building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 22,
        dimensions = cc.size(350, 90),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx-100, display.top-280):addTo(self)
    self:SetBuildingIntroduces()
end

function GameUIUnlockBuilding:SetBuildingIntroduces()
    local bd = Localize.building_description
    self.building_introduces:setString(bd[self.building:GetType()])
end



function GameUIUnlockBuilding:SetUpgradeRequirementListview()
    local wood = City.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local iron = City.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local stone = City.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local population = City.resource_manager:GetPopulationResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())


    local userData = DataManager:getUserData()
    requirements = {
        {resource_type = _("建造队列"),isVisible = true, isSatisfy = #City:GetOnUpgradingBuildings()<1,
            icon="hammer_31x33.png",description=GameUtils:formatNumber(#City:GetOnUpgradingBuildings()).."/1"},
        {resource_type = _("木材"),isVisible = self.building:GetLevelUpWood()>0,      isSatisfy = wood>self.building:GetLevelUpWood(),
            icon="wood_icon.png",description=self.building:GetLevelUpWood().."/"..wood},

        {resource_type = _("石料"),isVisible = self.building:GetLevelUpStone()>0,     isSatisfy = stone>self.building:GetLevelUpStone() ,
            icon="stone_icon.png",description=self.building:GetLevelUpStone().."/"..stone},

        {resource_type = _("铁矿"),isVisible = self.building:GetLevelUpIron()>0,      isSatisfy = iron>self.building:GetLevelUpIron() ,
            icon="iron_icon.png",description=self.building:GetLevelUpIron().."/"..iron},

        {resource_type = _("城民"),isVisible = self.building:GetLevelUpCitizen()>0,   isSatisfy = population>self.building:GetLevelUpCitizen() ,
            icon="citizen_44x50.png",description=self.building:GetLevelUpCitizen().."/"..population},

        {resource_type = _("建筑蓝图"),isVisible = self.building:GetLevelUpBlueprints()>0,isSatisfy = userData.materials.blueprints>self.building:GetLevelUpBlueprints() ,
            icon="blueprints_112x112.png",description=self.building:GetLevelUpBlueprints().."/"..userData.materials.blueprints},
        {resource_type = _("建造工具"),isVisible = self.building:GetLevelUpTools()>0,     isSatisfy = userData.materials.tools>self.building:GetLevelUpTools() ,
            icon="tools_112x112.png",description=self.building:GetLevelUpTools().."/"..userData.materials.tools},
        {resource_type = _("砖石瓦片"),isVisible = self.building:GetLevelUpTiles()>0,     isSatisfy = userData.materials.tiles>self.building:GetLevelUpTiles() ,
            icon="tiles_112x112.png",description=self.building:GetLevelUpTiles().."/"..userData.materials.tiles},
        {resource_type = _("滑轮组"),isVisible = self.building:GetLevelUpPulley()>0,    isSatisfy = userData.materials.pulley>self.building:GetLevelUpPulley() ,
            icon="pulley_112x112.png",description=self.building:GetLevelUpPulley().."/"..userData.materials.pulley},
    }

    if not self.requirement_listview then
        self.requirement_listview = WidgetRequirementListview.new({
            title = _("解锁需求"),
            height = 270,
            contents = requirements,
        }):addTo(self):pos(window.cx-274, window.top - 790)
    end
    self.requirement_listview:RefreshListView(requirements)
end

function GameUIUnlockBuilding:PopNotSatisfyDialog(listener,can_not_update_type)
    local dialog = FullScreenPopDialogUI.new()
    self:getParent():addChild(dialog,2002)
    if can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGH then
        local required_gems =self.building:getUpgradeRequiredGems()
        local owen_gem = City.resource_manager:GetGemResource():GetValue()
        if owen_gem<required_gems then
            dialog:SetTitle(_("提示"))
            dialog:SetPopMessage(UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH)
        else
            dialog:CreateOKButton(function()
                listener()
                self:removeFromParent(true)
            end)
            dialog:SetTitle(_("补充资源"))
            dialog:SetPopMessage(_("您当前没有足够的资源,是否花费魔法石立即补充"))
            dialog:CreateNeeds("Topaz-icon.png",required_gems)
        end
    elseif can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH then
        local required_gems =self.building:getUpgradeRequiredGems()
        dialog:CreateOKButton(function(sender,type)
            listener()
            self:removeFromParent(true)
        end)
        dialog:SetTitle(_("立即开始"))
        dialog:SetPopMessage(_("您当前没有空闲的建筑,是否花费魔法石立即完成上一个队列"))
        dialog:CreateNeeds("Topaz-icon.png",required_gems)
    else
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(can_not_update_type)
    end
end
function GameUIUnlockBuilding:SetUpgradeNowNeedGems()
    self.upgrade_now_need_gems_label:setString(self.building:getUpgradeNowNeedGems().."")
end
function GameUIUnlockBuilding:SetUpgradeTime()
    self.upgrade_time:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradeTimeToNextLevel()))
end
return GameUIUnlockBuilding











