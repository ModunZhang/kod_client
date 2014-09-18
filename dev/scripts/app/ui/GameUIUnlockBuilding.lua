local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local UpgradeBuilding = import("..entity.UpgradeBuilding")

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
    local bg = display.newScale9Sprite("full_screen_dialog_bg.png",display.cx, display.cy, cc.size(612,663)):addTo(self)
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
    local building_introduces_bg = display.newSprite("upgrade_introduce_bg.png", display.cx, display.cy+190):addTo(self)
    self.building_image = display.newScale9Sprite(self.building:GetType()..".png", 0, 0):addTo(building_introduces_bg)
    self.building_image:setAnchorPoint(cc.p(0,0))
    self.building_image:setScale(164/self.building_image:getContentSize().height)
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
        end):align(display.CENTER, display.cx-150, display.cy+100):addTo(self)
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
        end):align(display.CENTER, display.right-140, display.cy+100):addTo(self)
    -- 立即升级所需宝石
    display.newSprite("Topaz-icon.png", display.left+60, display.cy+40):addTo(self):setScale(0.5)
    self.upgrade_now_need_gems_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.left+80,display.cy+34):addTo(self)
    self:SetUpgradeNowNeedGems()
    --升级所需时间
    display.newSprite("upgrade_hourglass.png", display.cx+100, display.cy+40):addTo(self):setScale(0.6)
    self.upgrade_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx+125,display.cy+50):addTo(self)
    self:SetUpgradeTime()

    -- 科技减少升级时间
    self.buff_reduce_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "(-00:20:00)",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x068329)
    }):align(display.LEFT_CENTER,display.cx+120,display.cy+30):addTo(self)

    --升级需求listview
    local list_bg = display.newScale9Sprite("upgrade_requirement_background.png", display.cx, display.cy+18)
        :align(display.TOP_CENTER):addTo(self)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "升级需求",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER,display.cx,display.cy-10):addTo(self)
    self.requirement_listview = UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(0,0, 549, 284),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(list_bg,2)

    -- 缓存已经添加的升级条件项,供刷新时使用
    self.added_items = {}
    self:SetUpgradeRequirementListview()
end

function GameUIUnlockBuilding:InitBuildingIntroduces()
    self.building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 22,
        dimensions = cc.size(400, 90),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.left+180, display.cy+190):addTo(self)
    self:SetBuildingIntroduces()
end

function GameUIUnlockBuilding:SetBuildingIntroduces()
    local building_introduces_table = {
        ["toolShop"] = _("工具作坊提供常用材料的制作，升级能够提升每次制作的工具数量"),
        ["materialDepot"] = _("材料库房能够存储各种材料，等级越高，每种材料的存放上限越高。"),
        ["armyCamp"] = _("军帐提供出兵时的带兵上限，等级越高，每次出兵和防御时可派出的部队人口上限越大。"),
        ["barracks"] = _("兵营提供军事单位的招募，将城民转换成各种作战单位。升级提升每次招募的最大数量。"),
        ["blackSmith"] = _("铁匠铺打造和强化龙的装备。升级建筑提升装备打造速度。"),
        ["foundry"] = _("铸造坊提升可建造的矿工小屋和铁矿生产效率。周围建立更多的矿工小屋，可获得额外的铁矿产量。"),
        ["stoneMason"] = _("石匠作坊提升可建造的石匠小屋和石料的生产效率。周围建立更多的石匠小屋，可获得额外的石料产量。"),
        ["lumbermill"] = _("锯木坊提升可建造的木工小屋和木材生产效率。周围建立更多的木工小屋，可获得额外的木材产量。"),
        ["mill"] = _("磨坊提升可建造的农夫小屋和粮食生产效率。周围建立更多的农夫小屋，可获得额外的粮食产量。"),
        ["hospital"] = _("医院提供治愈伤兵的功能，升级能够提升伤兵的最大容量。"),
        ["townHall"] = _("市政厅提升可建造的住宅的数量，并提升城民的增长速度。周围建立更多的住宅，可获得额外的城民增长。"),
        ["academy"] = _("学院提供的科技能够提升城市生产和防御能力，等级越过研发速度越快。"),
        ["trainingGround"] = _("训练营提供步兵的相关科技，升级提升步兵招募速度。"),
        ["hunterhall"] = _("猎手大厅提供猎手的相关科技，升级提升猎手招募速度。"),
        ["stable"] = _("马厩提供骑兵的相关科技，升级提升骑兵的招募速度。"),
        ["workshop"] = _("车间提供投石车的相关科技，升级提升投石车的招募速度。"),
        ["prison"] = _("监狱有一定几率捕获来袭的敌军，升级能够提升关押敌军的时间。"),
        ["tradeGuild"] = _("贸易行会提供玩家资源和材料的交易平台。消耗运输小车挂出自己的资源需求，升级提升运输小车总量和生产速度。"),
    }
    for k,v in pairs(building_introduces_table) do
        if self.building:GetType()==k then
            self.building_introduces:setString(v)
        end
    end
end



function GameUIUnlockBuilding:SetUpgradeRequirementListview()
    local wood = City.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local iron = City.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local stone = City.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local population = City.resource_manager:GetPopulationResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())


    local userData = DataManager:getUserData()
    requirements = {
        {resource_type = "wood",isVisible = self.building:GetLevelUpWood()>0,      isSatisfy = wood>self.building:GetLevelUpWood(),
            icon="wood_icon.png",description=self.building:GetLevelUpWood().."/"..wood},

        {resource_type = "stone",isVisible = self.building:GetLevelUpStone()>0,     isSatisfy = stone>self.building:GetLevelUpStone() ,
            icon="stone_icon.png",description=self.building:GetLevelUpStone().."/"..stone},

        {resource_type = "iron",isVisible = self.building:GetLevelUpIron()>0,      isSatisfy = iron>self.building:GetLevelUpIron() ,
            icon="iron_icon.png",description=self.building:GetLevelUpIron().."/"..iron},

        {resource_type = "citizen",isVisible = self.building:GetLevelUpCitizen()>0,   isSatisfy = population>self.building:GetLevelUpCitizen() ,
            icon="iron_icon.png",description=self.building:GetLevelUpCitizen().."/"..population},

        {resource_type = "blueprints",isVisible = self.building:GetLevelUpBlueprints()>0,isSatisfy = userData.materials.blueprints>self.building:GetLevelUpBlueprints() ,
            icon="iron_icon.png",description=self.building:GetLevelUpBlueprints().."/"..userData.materials.blueprints},
        {resource_type = "tools",isVisible = self.building:GetLevelUpTools()>0,     isSatisfy = userData.materials.tools>self.building:GetLevelUpTools() ,
            icon="iron_icon.png",description=self.building:GetLevelUpTools().."/"..userData.materials.tools},
        {resource_type = "tiles",isVisible = self.building:GetLevelUpTiles()>0,     isSatisfy = userData.materials.tiles>self.building:GetLevelUpTiles() ,
            icon="iron_icon.png",description=self.building:GetLevelUpTiles().."/"..userData.materials.tiles},
        {resource_type = "pulley",isVisible = self.building:GetLevelUpPulley()>0,    isSatisfy = userData.materials.pulley>self.building:GetLevelUpPulley() ,
            icon="iron_icon.png",description=self.building:GetLevelUpPulley().."/"..userData.materials.pulley},
    }


    --有两种背景色的达到要求的显示条，通过meeFlag来确定选取哪一个
    local meetFlag = true

    for k,v in pairs(requirements) do
        -- print(k,v)
        if v.isVisible then
            -- 需求已添加，则更新最新资源数据
            if self.added_items[v.resource_type] then
                -- print("需求已添加，则更新最新资源数据 ",v.resource_type)
                local added_resource = self.added_items[v.resource_type]
                local content = added_resource:getContent()
                if v.isSatisfy then
                    if meetFlag then
                        content.bg:setTexture("upgrade_resources_background_3.png")
                    else
                        content.bg:setTexture("upgrade_resources_background_2.png")
                    end
                    -- 符合条件，添加钩钩图标
                    content.mark:setTexture("upgrade_mark.png")
                    meetFlag =  not meetFlag
                else
                    content.bg:setTexture("upgrade_resources_background_red.png")
                    -- 不符合条提案，添加X图标
                    content.mark:setTexture("upgrade_prohibited.png")
                end
                content.resource_value:setString(v.description)
            else
                -- 添加新条件
                -- print("添加新条件",v.resource_type)
                local item = self.requirement_listview:newItem()
                local item_width,item_height = 547,47
                item:setItemSize(item_width,item_height)
                local content = cc.ui.UIGroup.new()
                --  筛选不同背景颜色 bg
                if v.isSatisfy then
                    if meetFlag then
                        content.bg = display.newSprite("upgrade_resources_background_3.png", 0, 0):addTo(content)
                    else
                        content.bg = display.newSprite("upgrade_resources_background_2.png", 0, 0):addTo(content)
                    end
                    -- 符合条件，添加钩钩图标
                    content.mark = display.newSprite("upgrade_mark.png", item_width/2-25, 0):addTo(content)
                    meetFlag =  not meetFlag
                else
                    content.bg = display.newSprite("upgrade_resources_background_red.png", 0, 0):addTo(content)
                    -- 不符合条提案，添加X图标
                    content.mark = display.newSprite("upgrade_prohibited.png", item_width/2-25, 0):addTo(content)
                end
                -- 资源类型icon
                local resource_type_icon = display.newSprite(v.icon, -item_width/2+35, 0):addTo(content)
                resource_type_icon:setScale(0.4)
                content.resource_value = cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = v.description,
                    font = UIKit:getFontFilePath(),
                    size = 24,
                    color = UIKit:hex2c3b(0x403c2f)
                }):align(display.LEFT_CENTER,-200,0):addTo(content)
                item:addContent(content)
                self.requirement_listview:addItem(item)
                self.added_items[v.resource_type] = item
                self.requirement_listview:reload()
            end
        else
            -- 刷新时已经没有此项条件时，删除之前添加的项
            if self.added_items[v.resource_type] then
                -- print("刷新时已经没有此项条件时，删除之前添加的项",v.resource_type)
                self.requirement_listview:removeItem(self.added_items[v.resource_type])
                self.requirement_listview:reload()
            end
        end
    end
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
        dialog:CreateOKButton(function(sender,type)
            listener()
            self:removeFromParent(true)
        end)
        dialog:SetTitle(_("立即开始"))
        dialog:SetPopMessage(_("您当前没有空闲的建筑,是否花费魔法石立即完成上一个队列"))
        dialog:CreateNeeds("Topaz-icon.png",required_gems)
            :seekWidgetByName(dialog,"LC_Dialogue_Label"):setText(_("您当前没有空闲的建筑,是否花费魔法石立即完成上一个队列"))
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








