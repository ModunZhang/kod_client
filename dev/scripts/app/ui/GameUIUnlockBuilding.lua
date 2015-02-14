local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local UpgradeBuilding = import("..entity.UpgradeBuilding")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local MaterialManager = import("..entity.MaterialManager")
local SpriteConfig = import("..sprites.SpriteConfig")


local GameUIUnlockBuilding = class("GameUIUnlockBuilding", WidgetPopDialog)

function GameUIUnlockBuilding:ctor( city, tile )
    GameUIUnlockBuilding.super.ctor(self,650,_("解锁建筑"),display.top-160)
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
function GameUIUnlockBuilding:onEnter()
    UIKit:CheckOpenUI(self)
end
function GameUIUnlockBuilding:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
end
function GameUIUnlockBuilding:Init()
    -- bg
    local bg = self.body
    -- 建筑功能介绍
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-250, display.top-265)
        :addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-145, display.top-265)
        :addTo(self)

    local build_png = SpriteConfig[self.building:GetType()]:GetConfigByLevel(self.building:GetLevel()).png
    self.building_image = display.newScale9Sprite(build_png, display.cx-197, display.top-245):addTo(self)
    self.building_image:setAnchorPoint(cc.p(0.5,0.5))
    self.building_image:setScale(124/self.building_image:getContentSize().width)
    self:InitBuildingIntroduces()

    -- upgrade now button
    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=250,
            h=65,
            style = UIKit.BTN_COLOR.GREEN,
            labelParams = {text = _("立即解锁")},
            listener = function ()
                local upgrade_listener = function()
                    local location_id = City:GetLocationIdByBuildingType(self.building:GetType())
                    NetManager:getInstantUpgradeBuildingByLocationPromise(location_id)
                        :catch(function(err)
                            dump(err:reason())
                        end)
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(true)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                    self:removeFromParent(true)
                end
            end,
        }
    ):pos(display.cx-150, display.top-380)
        :addTo(self)


    self.upgrade_btn = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams = {text = _("解锁")},
            listener = function ()
                local upgrade_listener = function()
                    local location_id = City:GetLocationIdByBuildingType(self.building:GetType())
                    NetManager:getUpgradeBuildingByLocationPromise(location_id)
                    self:removeFromParent(true)
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(false)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                end
            end,
        }
    ):pos(display.cx+180, display.top-380)
        :addTo(self)

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
    local building = self.building

    -- local userData = DataManager:getUserData()
    local has_materials =City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)
    local pre_condition = building:IsBuildingUpgradeLegal()
    local requirements = {
        {resource_type = _("建造队列"),isVisible = true, isSatisfy = #City:GetUpgradingBuildings()<1,
            icon="hammer_31x33.png",description=GameUtils:formatNumber(#City:GetUpgradingBuildings()).."/1"},
        {resource_type = _("前置条件"),isVisible = pre_condition, isSatisfy = not pre_condition,
            icon="hammer_31x33.png",description = pre_condition},
        {resource_type = _("木材"),isVisible = self.building:GetLevelUpWood()>0,      isSatisfy = wood>self.building:GetLevelUpWood(),
            icon="wood_icon.png",description=self.building:GetLevelUpWood().."/"..wood},

        {resource_type = _("石料"),isVisible = self.building:GetLevelUpStone()>0,     isSatisfy = stone>self.building:GetLevelUpStone() ,
            icon="stone_icon.png",description=self.building:GetLevelUpStone().."/"..stone},

        {resource_type = _("铁矿"),isVisible = self.building:GetLevelUpIron()>0,      isSatisfy = iron>self.building:GetLevelUpIron() ,
            icon="iron_icon.png",description=self.building:GetLevelUpIron().."/"..iron},

        {resource_type = _("城民"),isVisible = self.building:GetLevelUpCitizen()>0,   isSatisfy = population>self.building:GetLevelUpCitizen() ,
            icon="citizen_44x50.png",description=self.building:GetLevelUpCitizen().."/"..population},

        {resource_type = _("建筑蓝图"),isVisible = self.building:GetLevelUpBlueprints()>0,isSatisfy = has_materials.blueprints>self.building:GetLevelUpBlueprints() ,
            icon="blueprints_112x112.png",description=self.building:GetLevelUpBlueprints().."/"..has_materials.blueprints},
        {resource_type = _("建造工具"),isVisible = self.building:GetLevelUpTools()>0,     isSatisfy = has_materials.tools>self.building:GetLevelUpTools() ,
            icon="tools_112x112.png",description=self.building:GetLevelUpTools().."/"..has_materials.tools},
        {resource_type = _("砖石瓦片"),isVisible = self.building:GetLevelUpTiles()>0,     isSatisfy = has_materials.tiles>self.building:GetLevelUpTiles() ,
            icon="tiles_112x112.png",description=self.building:GetLevelUpTiles().."/"..has_materials.tiles},
        {resource_type = _("滑轮组"),isVisible = self.building:GetLevelUpPulley()>0,    isSatisfy = has_materials.pulley>self.building:GetLevelUpPulley() ,
            icon="pulley_112x112.png",description=self.building:GetLevelUpPulley().."/"..has_materials.pulley},
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
        local owen_gem = City:GetUser():GetGemResource():GetValue()
        if owen_gem<required_gems then
            dialog:SetTitle(_("提示"))
            dialog:SetPopMessage(UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH)
        else
            dialog:CreateOKButton(
                {
                    listener = function()
                        listener()
                    end
                }
            )
            dialog:SetTitle(_("补充资源"))
            dialog:SetPopMessage(_("您当前没有足够的资源,是否花费魔法石立即补充"))
            dialog:CreateNeeds("Topaz-icon.png",required_gems)
        end
    elseif can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH then
        local required_gems =self.building:getUpgradeRequiredGems()
        dialog:CreateOKButton(
            {
                listener = function()
                    listener()
                end
            })
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


-- fte
function GameUIUnlockBuilding:Find()
    return cocos_promise.defer(function()
        return self.upgrade_btn
    end)
end


return GameUIUnlockBuilding




