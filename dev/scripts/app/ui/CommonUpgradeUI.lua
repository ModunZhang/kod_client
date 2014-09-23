local SmallDialogUI = import(".SmallDialogUI")
local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local UpgradeBuilding = import("..entity.UpgradeBuilding")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")



local CommonUpgradeUI = class("CommonUpgradeUI", function ()
    return display.newLayer()
end)

function CommonUpgradeUI:ctor(city,building)
    self:setNodeEventEnabled(true)
    self.city = city
    self.building = building
end

-- Node Event
function CommonUpgradeUI:onEnter()
    -- print("CommonUpgradeUI onEnter->")
    self:InitCommonPart()
    self:InitUpgradePart()
    self:InitAccelerationPart()
    self.city:GetResourceManager():AddObserver(self)
    self:AddUpgradeListener()
end

function CommonUpgradeUI:onExit()
    -- print("CommonUpgradeUI onExit--->")
    self.city:GetResourceManager():RemoveObserver(self)
    self:RemoveUpgradeListener()
end

function CommonUpgradeUI:OnResourceChanged(resource_manager)
    self.upgrade_layer:isVisible()
    if self.upgrade_layer:isVisible() then
        -- print("资源更行，刷新相关数据， 现在是升级需求listview")
        self:SetUpgradeRequirementListview()
    end
end

function CommonUpgradeUI:AddUpgradeListener()

    self.building:AddUpgradeListener(self)
end

function CommonUpgradeUI:RemoveUpgradeListener()
    self.building:RemoveUpgradeListener(self)
end
function CommonUpgradeUI:OnBuildingUpgradingBegin( buidling, current_time )
    self:visibleChildLayers()
end
function CommonUpgradeUI:OnBuildingUpgradeFinished( buidling, finish_time )
    self:visibleChildLayers()
    self:SetBuildingLevel()
    self:SetUpgradeNowNeedGems()
    self:SetBuildingIntroduces()
    self:SetUpgradeTime()
end

function CommonUpgradeUI:OnBuildingUpgrading( buidling, current_time )
    local pro = self.acc_layer.ProgressTimer
    pro:setPercentage(self.building:GetElapsedTimeByCurrentTime(current_time)/self.building:GetUpgradeTimeToNextLevel()*100)
    self.acc_layer.upgrade_time_label:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradingLeftTimeByCurrentTime(current_time)))
    if self.building:GetUpgradingLeftTimeByCurrentTime(current_time)<=self.building.freeSpeedUpTime then
        self.acc_layer.acc_button:setButtonEnabled(false)
    else
        self.acc_layer.acc_button:setButtonEnabled(true)
    end
end

function CommonUpgradeUI:InitCommonPart()
    -- building level
    local level_bg = display.newSprite("upgrade_level_bg.png", display.cx, display.top-125):addTo(self)
    self.builging_level = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 26,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_BOTTOM, 540, 0)
        :addTo(level_bg)
    self:SetBuildingLevel()
    -- 建筑功能介绍
    local building_introduces_bg = display.newSprite("upgrade_introduce_bg.png", display.cx, display.top-190):addTo(self)
    self.building_image = display.newScale9Sprite(self.building:GetType()..".png", 0, 0):addTo(building_introduces_bg)
    self.building_image:setAnchorPoint(cc.p(0,0))
    self.building_image:setScale(164/self.building_image:getContentSize().height)
    self:InitBuildingIntroduces()
    --升级奖励部分
    -- title
    cc.ui.UIImage.new("upgrade_decoration.png"):align(display.CENTER, display.cx-145, display.top-260):addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("upgrade_decoration.png"):align(display.CENTER, display.cx+145, display.top-260):addTo(self)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("升级奖励"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, display.cx, display.top-260)
        :addTo(self)
    -- reward list bg
    display.newScale9Sprite("upgrade_introduce_bg.png", display.cx, display.top-330, cc.size(549,100)):addTo(self)
    self:SetUpgradeReward()
end

function CommonUpgradeUI:SetBuildingLevel()
    self.builging_level:setString(_("等级 ")..self.building:GetLevel())
end

function CommonUpgradeUI:InitBuildingIntroduces()
    self.building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 22,
        dimensions = cc.size(400, 90),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx-100, display.top-190):addTo(self)
    self:SetBuildingIntroduces()
end

function CommonUpgradeUI:SetBuildingIntroduces()
    local building_introduces_table = {
        ["keep"] = _("提升建筑等级上限\n可解锁地块数量:%d"),
        ["watchTower"] ={
            [1] = _("能够看到来袭部队，NPC titles，自己的出征部队，告诉你前来的部队的行军目的，达到时间"),
            [2] = _("显示敌方突袭你部队的龙的类型(之前显示“?”)"),
            [3] = _("显示突袭的龙的等级"),
            [4] = _("显示进攻的龙的等级"),
            [5] = _("显示突袭的龙的装备信息"),
            [6] = _("显示进攻的龙的装备信息"),
            [7] = _("显示突袭的龙的技能信息"),
            [8] = _("显示进攻的龙的技能信息"),
            [9] = _("显示进攻部队的兵种类型和排序"),
            [10] = _("显示进攻部队的兵种星级"),
            [11] = _("可以在敌方领土上预警到敌方部队来袭(之前只会在敌方穿过传送门后才预警，现在还会显示传送门到敌方玩家城市的路径)"),
            [12] = _("可以查看突袭的龙的力量和活力属性"),
            [13] = _("可以查看进攻的龙的力量和活力属性"),
            [14] = _("显示进攻部队的大致数量"),
            [15] = _("显示进攻敌方的科技水平(训练营地，猎手大厅，马厩，车间的科技研发值)"),
            [16] = _("可以在敌方领地上查看敌方玩家的城市布局和建筑等级等信息(不能点击建筑)"),
            [17] = _("显示进攻部队兵种的准确数量"),
            [18] = _("显示敌方进攻部队的战斗力预估(之前显示“?”)"),
            [19] = _("减少敌方行军速度10%"),
            [20] = _("增加己方行军速度10%"),
        },
        ["warehouse"] = _("提供木材, 石料, 铁矿, 粮食存储上限\n资源存放上限%d"),
        ["dragonEyrie"] = _("提升龙的体力恢复速度\n体力恢复速度+%d"),
        ["toolShop"] = _("提升每次生产材料的数量\n材料数量%d"),
        ["materialDepot"] = _("提供材料的存储上限\n每种材料存放上限%d"),
        ["armyCamp"] = _("提供出兵时派兵上限\n派兵上限%d"),
        ["barracks"] = _("增加每次招募数量\n每次可招募%d"),
        ["blackSmith"] = _("提升装备打造速度\n装备打造速度+%d"),
        ["foundry"] = _("可建造矿工小屋:%d\n铁矿产量+%d%%"),
        ["stoneMason"] = _("可建造石匠小屋:%d\n石料产量+%d%%"),
        ["lumbermill"] = _("可建造木工小屋:%d\n木材产量+%d%%"),
        ["mill"] = _("可建造农夫小屋:%d\n粮食产量+%d%%"),
        ["hospital"] = _("增加治愈伤兵的人数上限\n伤兵人数上限%d"),
        ["townHall"] = _("可建造住宅%d\n每次税收影响城民%d"),
        ["academy"] = _("提升科技研发速度\n研发速度+%d"),
        ["trainingGround"] = _("提升步兵招募速度\n步兵招募速度+%d"),
        ["hunterhall"] = _("提升猎手招募速度\n猎手招募速度+%d"),
        ["stable"] = _("提升骑兵招募速度\n骑兵招募速度+%d"),
        ["workshop"] = _("提升攻城器械速度\n攻城器械招募速度+%d"),
        ["wall"] = _("提升城墙生命值\n城墙生命值+%d"),
        ["tower"] = _("提升城墙攻击力\n城墙攻击力+%d"),
        ["prison"] = _("捕获敌军的几率%d\n关押敌军的时间%d"),
        ["tradeGuild"] = _("运输小车总数%d\n运输小车生产速度%d"),
        ["dwelling"] = _("提供城民上限%d\n城民恢复速度+%d"),
        ["woodcutter"] = _("占用城民%d\n木材产量+%d/每小时"),
        ["farmer"] = _("占用城民%d\n粮食产量+%d/每小时"),
        ["quarrier"] = _("占用城民%d\n石料产量+%d/每小时|"),
        ["miner"] = _("占用城民%d\n铁矿产量+%d/每小时|"),
    }
    if self.building:GetType()=="keep" then
        self.building_introduces:setString(string.format(building_introduces_table["keep"],self.building:GetUnlockPoint()))
    elseif self.building:GetType()=="warehouse" then
        self.building_introduces:setString(string.format(building_introduces_table["warehouse"],self.building:GetResourceValueLimit()))
    elseif self.building:GetType()=="armyCamp" then
        self.building_introduces:setString(string.format(building_introduces_table["armyCamp"],self.building:GetTroopPopulation()))
    elseif self.building:GetType()=="materialDepot" then
        self.building_introduces:setString(string.format(building_introduces_table["materialDepot"],self.building:GetMaxMaterial()))
    elseif self.building:GetType()=="foundry"
        or self.building:GetType()=="stoneMason"
        or self.building:GetType()=="lumbermill"
        or self.building:GetType()=="mill"
    then
        self.building_introduces:setString(string.format(building_introduces_table[self.building:GetType()],self.building:GetMaxHouseNum(),self.building:GetAddEfficency()*100))
    end
end

-- set upgrade reward
function CommonUpgradeUI:SetUpgradeReward()
    -- TODO 暂时模拟升级奖励类型和数据
    local reward_table = {
        {reward_type = "surface",icon="upgrade_surface.png",value="X 100"},
        {reward_type = "exp",icon="upgrade_experience_icon.png",value="X 10000"},
        {reward_type = "power",icon="upgrade_power_icon.png",value="X 1000000"},
    }
    local reward_listview_width ,reward_listview_height= 544,95
    local item_icon_height = 62
    local reward_listview = cc.ui.UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.cx - 272, display.top-378, reward_listview_width, reward_listview_height),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(self)
    local function createItem(icon,value)
        local item = reward_listview:newItem()
        local content = cc.ui.UIGroup.new()
        local item_icon = display.newSprite(icon):align(display.CENTER, 0, 10)
        item_icon:setScale(item_icon_height/item_icon:getContentSize().height)
        item_icon:addTo(content)
        local num_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER,0,-item_icon_height/2):addTo(content)
        local content_width = math.max(num_label:getContentSize().width,item_icon:getContentSize().width*item_icon_height/item_icon:getContentSize().height)
        item:setItemSize(content_width,num_label:getContentSize().height+item_icon_height+10)
        item:addContent(content)

        return item
    end
    local created_item_table = {}
    local used_width = 0
    for k,v in pairs(reward_table) do
        local item = createItem(v.icon,v.value)
        created_item_table[k] = item
        local item_width = item:getItemSize()
        used_width = used_width + item_width
    end
    -- 计算出合理的各个item之间的间距，再添加进listview
    local usable_width = reward_listview_width - used_width
    for k,v in pairs(created_item_table) do
        local item_width,item_height = v:getItemSize()
        v:setItemSize(item_width+usable_width/#created_item_table,item_height)
        reward_listview:addItem(v)
    end

    reward_listview:reload()

end

function CommonUpgradeUI:InitUpgradePart()
    -- 升级页
    -- local color_layer = display.newColorLayer(cc.c4b(255,0,0,255)):addTo(self)
    -- color_layer:setContentSize(cc.size(display.width,display.height-385))
    self.upgrade_layer = display.newLayer()
    self.upgrade_layer:setContentSize(cc.size(display.width,display.height-385))
    self:addChild(self.upgrade_layer)
    -- upgrade now button
    cc.ui.UIPushButton.new({normal = "upgrade_green_button_normal.png",pressed = "upgrade_green_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("立即升级"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local upgrade_listener = function()
                    local location = City:GetLocationIdByBuildingType(self.building:GetType())
                    if location then
                        NetManager:instantUpgradeBuildingByLocation(City:GetLocationIdByBuildingType(self.building:GetType()), function(...) end)
                    else
                        local tile = City:GetTileWhichBuildingBelongs(self.building)
                        local house_location = tile:GetBuildingLocation(self.building)
                        NetManager:instantUpgradeHouseByLocation(tile.location_id, house_location, function(...) end)
                    end
                    print(self.building:GetType().."---------------- upgrade now button has been  clicked ")
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(true)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                end
            end
        end):align(display.CENTER, display.cx-150, display.top-430):addTo(self.upgrade_layer)
    -- upgrade button
    cc.ui.UIPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("升级"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local upgrade_listener = function()
                    local location = City:GetLocationIdByBuildingType(self.building:GetType())
                    if location then
                        NetManager:upgradeBuildingByLocation(City:GetLocationIdByBuildingType(self.building:GetType()), function(...) end)
                    else
                        local tile = City:GetTileWhichBuildingBelongs(self.building)
                        local house_location = tile:GetBuildingLocation(self.building)
                        NetManager:upgradeHouseByLocation(tile.location_id, house_location, function(...) end)
                    end
                    print(self.building:GetType().."---------------- upgrade  button has been  clicked ")
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(false)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                end
            end
        end):align(display.CENTER, display.cx+180, display.top-430):addTo(self.upgrade_layer)
    -- 立即升级所需宝石
    display.newSprite("Topaz-icon.png", display.cx - 260, display.top-490):addTo(self.upgrade_layer):setScale(0.5)
    self.upgrade_now_need_gems_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx - 240,display.top-494):addTo(self.upgrade_layer)
    self:SetUpgradeNowNeedGems()
    --升级所需时间
    display.newSprite("upgrade_hourglass.png", display.cx+100, display.top-490):addTo(self.upgrade_layer):setScale(0.6)
    self.upgrade_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx+125,display.top-480):addTo(self.upgrade_layer)
    self:SetUpgradeTime()

    -- 科技减少升级时间
    self.buff_reduce_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "(-00:20:00)",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x068329)
    }):align(display.LEFT_CENTER,display.cx+120,display.top-500):addTo(self.upgrade_layer)

    --升级需求listview
    self:SetUpgradeRequirementListview()



    -- TODO
    self:visibleChildLayers()

    -- self.upgrade_layer:setVisible(false)
end

function CommonUpgradeUI:SetUpgradeNowNeedGems()
    self.upgrade_now_need_gems_label:setString(self.building:getUpgradeNowNeedGems().."")
end

function CommonUpgradeUI:SetUpgradeTime()
    self.upgrade_time:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradeTimeToNextLevel()))
end

function CommonUpgradeUI:SetUpgradeRequirementListview()
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

    if not self.requirement_listview then
        self.requirement_listview = WidgetRequirementListview.new({
            title = _("升级需求"),
            height = 333,
            contents = requirements,
        }):addTo(self):pos(display.cx-275, display.top-855)
    end
    self.requirement_listview:RefreshListView(requirements)
end

function CommonUpgradeUI:InitAccelerationPart()
    self.acc_layer = display.newLayer()
    self.acc_layer:setContentSize(cc.size(display.width,display.height-385))
    self:addChild(self.acc_layer)

    -- 正在升级文本说明
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = string.format(_("正在升级 %s 到Level %d"),_(self.building:GetType()),self.building:GetLevel()+1),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER, display.cx - 275, display.cy+70)
        :addTo(self.acc_layer)
    -- 升级倒数时间进度条
    --进度条
    local bar = display.newSprite("upgrade_progress_bar_1.png"):addTo(self.acc_layer):pos(display.cx-90, display.cy+20)
    local progressFill = display.newSprite("upgrade_progress_bar_2.png")
    self.acc_layer.ProgressTimer = cc.ProgressTimer:create(progressFill)
    local pro = self.acc_layer.ProgressTimer
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    pro:setPercentage(0)
    self.acc_layer.upgrade_time_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        -- text = "",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfff3c7),
    }):addTo(bar)
    self.acc_layer.upgrade_time_label:setAnchorPoint(cc.p(0,0.5))
    self.acc_layer.upgrade_time_label:pos(self.acc_layer.upgrade_time_label:getContentSize().width/2+10, bar:getContentSize().height/2)
    -- 进度条头图标
    display.newSprite("upgrade_progress_bar_icon_bg.png", display.cx - 256, display.cy+20):addTo(self.acc_layer)
    display.newSprite("upgrade_hourglass.png", display.cx - 256, display.cy+20):addTo(self.acc_layer):setScale(0.8)
    -- 免费加速按钮
    self:CreateFreeSpeedUpBuildingUpgradeButton()
    -- 可免费加速提示
    -- 背景框
    display.newSprite("upgrade_introduce_bg.png", display.cx, display.cy-60):addTo(self.acc_layer)
    self.acc_tip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        dimensions = cc.size(530, 80),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER, display.cx - 270, display.cy-60)
        :addTo(self.acc_layer)
    self:SetAccTipLabel()
    -- 按时间加速区域
    self:CreateAccButtons()
    self:visibleChildLayers()

end

function CommonUpgradeUI:CreateFreeSpeedUpBuildingUpgradeButton()
    local  IMAGES  = {
        normal = "upgrade_free_1.png",
        pressed = "upgrade_free_2.png",
        disabled = "upgrade_free_3.png",
    }
    self.acc_layer.acc_button = cc.ui.UIPushButton.new(IMAGES, {scale9 = true})
        :setButtonSize(169, 86)
        :setButtonLabel("normal", ui.newTTFLabel({
            text = _("免费加速"),
            size = 24
        }))
        :setButtonLabel("pressed", ui.newTTFLabel({
            text = _("免费加速"),
            size = 24,
        }))
        :setButtonLabel("disabled", ui.newTTFLabel({
            text = _("免费加速"),
            size = 24,
        })):onButtonClicked(function(event)
        -- print("服务器还未提供免费加速接口，暂时用作直接使用宝石加速")
        NetManager:sendMsg("keep 5", NOT_HANDLE)

        end):align(display.CENTER, display.cx+185, display.cy+45):addTo(self.acc_layer)
    self.acc_layer.acc_button:setButtonEnabled(false)
end

function CommonUpgradeUI:SetAccTipLabel()
    --TODO 设置对应的提示 ，现在是临时的
    self.acc_tip_label:setString(_("小于5min时，可使用免费加速\n激活VIP X后，小于5min时可使用免费加速"))
end

function CommonUpgradeUI:CreateAccButtons()
    -- 8个加速按钮单独放置在一个layer上方便处理事件
    self.acc_button_layer = display.newLayer()
    self.acc_button_layer:addTo(self)
    self.acc_button_layer:setTouchSwallowEnabled(false)
    self.acc_button_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
        if event.name=="began" then
            self:ResetAccButtons()
        end
        return true
    end, 1)
    local gap_x , gap_y= 148,140
    self.acc_button_table = {}
    self.time_button_tbale = {}
    for i=1,8 do
        -- 按钮背景框
        display.newSprite("upgrade_props_box.png", display.cx-220 + gap_x*math.mod(i,4), display.cy-160-gap_y*math.floor((i-1)/4)):addTo(self.acc_layer)
        -- 花销数值背景
        local cost_bg = display.newSprite("upgrade_number.png", display.cx-220 + gap_x*math.mod(i,4), display.cy-230-gap_y*math.floor((i-1)/4)):addTo(self.acc_layer)
        -- 花销数值
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "X 600",
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, display.cx-220+gap_x*math.mod(i,4), display.cy-230-gap_y*math.floor((i-1)/4))
            :addTo(self.acc_layer)
        -- 时间按钮
        local time_button = cc.ui.UIPushButton.new({normal = "upgrade_time_"..i..".png"})
        -- 确认加速按钮
        local acc_button = cc.ui.UIPushButton.new({normal = "upgrade_acc_button_1.png",pressed="upgrade_acc_button_2.png"})
        time_button:onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:ResetAccButtons()
                acc_button:setVisible(true)
                time_button:setVisible(false)
                self:getParent():addChild(SmallDialogUI.new(
                    {
                        listener = function ()
                            acc_button:setVisible(false)
                            time_button:setVisible(true)
                        end,
                        x = math.floor((i-1)/4)==0 and cost_bg:getPositionX() or
                        math.floor((i-1)/4)==1 and acc_button:getPositionX(),
                        y = math.floor((i-1)/4)==0 and cost_bg:getPositionY()-cost_bg:getContentSize().height/2 or
                        math.floor((i-1)/4)==1 and acc_button:getPositionY()+acc_button:getCascadeBoundingBox().size.height/2,
                        tips1 = _("使用立即减少升级时间"),
                        tips2 = _("使用立即减少5Min时间消耗"),
                        direction = math.floor((i-1)/4), -- 0表示dialog的箭头指向上方，1反之
                    }
                ),2)
            end
        end):align(display.CENTER, display.cx-220+gap_x*math.mod(i,4), display.cy-160-gap_y*math.floor((i-1)/4)):addTo(self.acc_button_layer)
        time_button:setScale(0.7)
        acc_button:onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

                acc_button:setVisible(false)
                time_button:setVisible(true)

                -- print("确定按钮呗点中")
            end
        end):align(display.CENTER, display.cx-220+gap_x*math.mod(i,4), display.cy-160-gap_y*math.floor((i-1)/4)):addTo(self.acc_button_layer)
        acc_button:setVisible(false)
        self.acc_button_table[i] = acc_button
        self.time_button_tbale[i] = time_button
    end

    self:visibleChildLayers()
end

-- 设置各个layers显示状态
function CommonUpgradeUI:visibleChildLayers()
    if self.acc_button_layer then
        self.acc_button_layer:setVisible(self.building:IsUpgrading())
    end
    if self.upgrade_layer then
        self.upgrade_layer:setVisible(not self.building:IsUpgrading())
    end
    if self.acc_layer then
        self.acc_layer:setVisible(self.building:IsUpgrading())
    end
end

function CommonUpgradeUI:ResetAccButtons()
    for k,v in pairs(self.time_button_tbale) do
        v:setVisible(true)
    end
    for k,v in pairs(self.acc_button_table) do
        v:setVisible(false)
    end
end

function CommonUpgradeUI:PopNotSatisfyDialog(listener,can_not_update_type)
    local dialog = FullScreenPopDialogUI.new()
    self:getParent():addChild(dialog,100,101)
    if can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGH then
        local required_gems =self.building:getUpgradeRequiredGems()
        local owen_gem = City.resource_manager:GetGemResource():GetValue()
        if owen_gem<required_gems then
            dialog:SetTitle(_("提示"))
            dialog:SetPopMessage(UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH)
        else
            dialog:CreateOKButton(function()
                listener()
                self:getParent():leftButtonClicked()
            end)
            dialog:SetTitle(_("补充资源"))
            dialog:SetPopMessage(_("您当前没有足够的资源,是否花费魔法石立即补充"))
            dialog:CreateNeeds("Topaz-icon.png",required_gems)
        end
    elseif can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH then
        dialog:CreateOKButton(function(sender,type)
            listener()
            self:getParent():leftButtonClicked()
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

return CommonUpgradeUI






<<<<<<< Updated upstream



=======
>>>>>>> Stashed changes
