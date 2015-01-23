local SmallDialogUI = import(".SmallDialogUI")
local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local UpgradeBuilding = import("..entity.UpgradeBuilding")
local MaterialManager = import("..entity.MaterialManager")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetAccelerateGroup = import("..widget.WidgetAccelerateGroup")

local SpriteConfig = import("..sprites.SpriteConfig")


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
    self:InitCommonPart()
    self:InitUpgradePart()
    self:InitAccelerationPart()
    self.city:GetResourceManager():AddObserver(self)

    self:AddUpgradeListener()
end

function CommonUpgradeUI:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    self:RemoveUpgradeListener()
end

function CommonUpgradeUI:OnResourceChanged(resource_manager)
    if self.building:GetNextLevel() == self.building:GetLevel() then
        return
    end
    self.upgrade_layer:isVisible()
    if self.upgrade_layer:isVisible() then
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
    local pro = self.acc_layer.ProgressTimer
    pro:setPercentage(self.building:GetElapsedTimeByCurrentTime(current_time)/self.building:GetUpgradeTimeToNextLevel()*100)
    self.acc_layer.upgrade_time_label:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradingLeftTimeByCurrentTime(current_time)))
    self:visibleChildLayers()
end
function CommonUpgradeUI:OnBuildingUpgradeFinished( buidling, finish_time )
    self:visibleChildLayers()
    self:SetBuildingLevel()
    self:SetUpgradeNowNeedGems()
    self:SetBuildingIntroduces()
    self:SetUpgradeTime()
    self:SetUpgradeEfficiency()
    local build_png = SpriteConfig[self.building:GetType()]:GetConfigByLevel(self.building:GetLevel()).png
    self.building_image:setTexture(build_png)
    if self.building:GetNextLevel() == self.building:GetLevel() then
        self.upgrade_layer:setVisible(false)
    end
end

function CommonUpgradeUI:OnBuildingUpgrading( buidling, current_time )
    local pro = self.acc_layer.ProgressTimer
    pro:setPercentage(self.building:GetElapsedTimeByCurrentTime(current_time)/self.building:GetUpgradeTimeToNextLevel()*100)
    self.acc_layer.upgrade_time_label:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradingLeftTimeByCurrentTime(current_time)))
    if not self.acc_layer.acc_button:isButtonEnabled() and
        self.building:GetFreeSpeedupTime()>=self.building:GetUpgradingLeftTimeByCurrentTime(app.timer:GetServerTime()) then
        self.acc_layer.acc_button:setButtonEnabled(true)
    end
end

function CommonUpgradeUI:InitCommonPart()
    -- building level
    local level_bg = display.newSprite("upgrade_level_bg.png", display.cx+80, display.top-125):addTo(self)
    self.builging_level = UIKit:ttfLabel({
        font = UIKit:getFontFilePath(),
        size = 26,
        color = 0xffedae,
        bold = true
    }):align(display.LEFT_CENTER, 20, level_bg:getContentSize().height/2)
        :addTo(level_bg)
    -- 建筑功能介绍
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-250, display.top-175)
        :addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-145, display.top-175)
        :addTo(self)
    local build_png = SpriteConfig[self.building:GetType()]:GetConfigByLevel(self.building:GetLevel()).png

    self.building_image = display.newSprite(build_png, 0, 0):addTo(self):pos(display.cx-196, display.top-158)
    self.building_image:setAnchorPoint(cc.p(0.5,0.5))
    if self.building:GetType()=="watchTower" or self.building:GetType()=="tower" then
        self.building_image:setScale(150/self.building_image:getContentSize().height)
    else
        self.building_image:setScale(124/self.building_image:getContentSize().width)
    end
    self:InitBuildingIntroduces()

    self:InitNextLevelEfficiency()
    self:SetBuildingLevel()
end

function CommonUpgradeUI:SetBuildingLevel()
    self.builging_level:setString(_("等级 ")..self.building:GetLevel())
    if self.building:GetNextLevel() == self.building:GetLevel() then
        self.next_level:setString(_("等级已满 "))
    else
        self.next_level:setString(_("等级 ")..self.building:GetNextLevel())
    end
end

function CommonUpgradeUI:InitBuildingIntroduces()
    self.building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        dimensions = cc.size(380, 90),
        color = UIKit:hex2c3b(0x797154)
    }):align(display.LEFT_CENTER,display.cx-110, display.top-190):addTo(self)
    self:SetBuildingIntroduces()
end
function CommonUpgradeUI:SetBuildingIntroduces()
    local bd = Localize.building_description
    self.building_introduces:setString(bd[self.building:GetType()])
end


function CommonUpgradeUI:InitNextLevelEfficiency()
    -- 下一级 框
    local bg  = display.newSprite("upgrade_next_level_bg.png", window.left+114, window.top-310):addTo(self)
    local bg_size = bg:getContentSize()
    self.next_level = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER,bg_size.width/2,bg_size.height/2):addTo(bg)

    local efficiency_bg = display.newSprite("back_ground_398x97.png", window.cx+74, window.top-310):addTo(self)
    local efficiency_bg_size = efficiency_bg:getContentSize()
    self.efficiency = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        dimensions = cc.size(380,40),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(efficiency_bg):align(display.LEFT_CENTER)
    self.efficiency:pos(10,efficiency_bg_size.height/2)
    self:SetUpgradeEfficiency()
end

function CommonUpgradeUI:SetUpgradeEfficiency()
    local bd = Localize.building_description
    local building = self.building
    local efficiency
    if self.building:GetType()=="keep" then
        efficiency = string.format("%s%d,%s%d,%s+%d",bd.unlock,building:GetNextLevelUnlockPoint(),bd.troopPopulation,building:GetNextLevelTroopPopulation(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="dragonEyrie" then
        efficiency = string.format("%s%d,%s+%d",bd.vitalityRecoveryPerHour,building:GetNextLevelVitalityRecoveryPerHour(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="watchTower" then
        efficiency = string.format("%s",bd["watchTower_"..self.building:GetLevel()])
    elseif self.building:GetType()=="warehouse" then
        efficiency = string.format("%s%d,%s+%d",bd.warehouse_max,building:GetResourceNextLevelValueLimit(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="toolShop" then
        efficiency = string.format("%s%d%s,%s+%d",bd.poduction,building:GetNextLevelPoducttion(),bd.poduction_1,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="materialDepot" then
        efficiency = string.format("%s%d,%s+%d",bd.maxMaterial,building:GetNextLevelMaxMaterial(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="armyCamp" then
        efficiency = string.format("%s%d,%s+%d",bd.armyCamp_troopPopulation,building:GetNextLevelTroopPopulation(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="barracks" then
        efficiency = string.format("%s%d,%s+%d",bd.maxRecruit,building:GetNextLevelMaxRecruitSoldierCount(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="blackSmith" then
        efficiency = string.format("%s%d%%,%s+%d",bd.blackSmith_efficiency,building:GetNextLevelEfficiency()*100,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="foundry" then
        efficiency = string.format("%s+%d,%s+%d%%,%s+%d",bd.foundry_miner,building:GetNextLevelMaxHouseNum(),bd.foundry_addEfficency,building:GetNextLevelAddEfficency()*100,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="lumbermill" then
        efficiency = string.format("%s+%d,%s+%d%%,%s+%d",bd.lumbermill_woodcutter,building:GetNextLevelMaxHouseNum(),bd.lumbermill_addEfficency,building:GetNextLevelAddEfficency()*100,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="mill" then
        efficiency = string.format("%s+%d,%s+%d%%,%s+%d",bd.mill_farmer,building:GetNextLevelMaxHouseNum(),bd.mill_addEfficency,building:GetNextLevelAddEfficency()*100,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="stoneMason" then
        efficiency = string.format("%s+%d,%s+%d%%,%s+%d",bd.stoneMason_quarrier,building:GetNextLevelMaxHouseNum(),bd.stoneMason_addEfficency,building:GetNextLevelAddEfficency()*100,bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="hospital" then
        efficiency = string.format("%s%d,%s+%d",bd.maxCasualty,building:GetNextLevelMaxCasualty(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="townHall" then
        efficiency = string.format("%s%d",bd.townHall_dwelling,building:GetNextLevelDwellingNum())
    elseif self.building:GetType()=="dwelling" then
        efficiency = string.format("%s%d,%s+%d,%s+%d",bd.dwelling_citizen,building:GetNextLevelCitizen(),bd.recoveryCitizen,building:GetNextLevelRecoveryCitizen(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="woodcutter" then
        efficiency = string.format("%s%d,%s+%d",bd.woodcutter_poduction,building:GetNextLevelProductionPerHour(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="farmer" then
        efficiency = string.format("%s%d,%s+%d",bd.farmer_poduction,building:GetNextLevelProductionPerHour(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="quarrier" then
        efficiency = string.format("%s%d,%s+%d",bd.quarrier_poduction,building:GetNextLevelProductionPerHour(),bd.power,building:GetNextLevelPower())
    elseif self.building:GetType()=="miner" then
        efficiency = string.format("%s%d,%s+%d",bd.miner_poduction,building:GetNextLevelProductionPerHour(),bd.power,building:GetNextLevelPower())
    else
        efficiency = (_("本地化未添加"))
    end
    self.efficiency:setString(efficiency)
end

function CommonUpgradeUI:InitUpgradePart()
    -- 升级页
    if self.building:GetNextLevel() == self.building:GetLevel() then
        return
    end
    self.upgrade_layer = display.newLayer()
    self.upgrade_layer:setContentSize(cc.size(display.width,575))
    self:addChild(self.upgrade_layer)
    -- upgrade now button
    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=250,
            h=65,
            style = UIKit.BTN_COLOR.GREEN,
            labelParams = {text = _("立即升级")},
            listener = function ()
                local upgrade_listener = function()
                    if self.building:GetType()=="tower" then
                        NetManager:getInstantUpgradeTowerByLocationPromise(self.building:TowerId())
                            :catch(function(err)
                                dump(err:reason())
                            end)
                    elseif self.building:GetType()=="wall" then
                        NetManager:getInstantUpgradeWallByLocationPromise()
                            :catch(function(err)
                                dump(err:reason())
                            end)
                    else
                        local location = City:GetLocationIdByBuildingType(self.building:GetType())
                        if location then

                            local location_id = City:GetLocationIdByBuildingType(self.building:GetType())
                            NetManager:getInstantUpgradeBuildingByLocationPromise(location_id)
                                :catch(function(err)
                                    dump(err:reason())
                                end)
                        else
                            local tile = City:GetTileWhichBuildingBelongs(self.building)
                            local house_location = tile:GetBuildingLocation(self.building)

                            NetManager:getInstantUpgradeHouseByLocationPromise(tile.location_id, house_location)
                                :catch(function(err)
                                    dump(err:reason())
                                end)
                        end
                    end
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(true)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                end
            end,
        }
    ):pos(display.cx-150, display.top-410)
        :addTo(self.upgrade_layer)

    -- upgrade button
    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("升级")},
            listener = function ()
                local upgrade_listener = function()
                    if self.building:GetType()=="tower" then
                        NetManager:getUpgradeTowerByLocationPromise(self.building:TowerId())
                            :catch(function(err)
                                dump(err:reason())
                            end)
                    elseif self.building:GetType()=="wall" then
                        NetManager:getUpgradeWallByLocationPromise()
                            :catch(function(err)
                                dump(err:reason())
                            end)
                    else
                        local location = City:GetLocationIdByBuildingType(self.building:GetType())
                        if location then
                            local location_id = City:GetLocationIdByBuildingType(self.building:GetType())
                            NetManager:getUpgradeBuildingByLocationPromise(location_id)
                                :catch(function(err)
                                    dump(err:reason())
                                end)
                        else
                            local tile = City:GetTileWhichBuildingBelongs(self.building)
                            local house_location = tile:GetBuildingLocation(self.building)

                            NetManager:getUpgradeHouseByLocationPromise(tile.location_id, house_location)
                                :catch(function(err)
                                    dump(err:reason())
                                end)
                        end
                    end
                    self:getParent():leftButtonClicked()
                end

                local can_not_update_type = self.building:IsAbleToUpgrade(false)
                if can_not_update_type then
                    self:PopNotSatisfyDialog(upgrade_listener,can_not_update_type)
                else
                    upgrade_listener()
                end
            end,
        }
    ):pos(display.cx+180, display.top-410)
        :addTo(self.upgrade_layer)

    self.upgrade_btn = btn_bg.button

    -- 立即升级所需宝石
    display.newSprite("Topaz-icon.png", display.cx - 260, display.top-470):addTo(self.upgrade_layer):setScale(0.5)
    self.upgrade_now_need_gems_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx - 240,display.top-474):addTo(self.upgrade_layer)
    self:SetUpgradeNowNeedGems()
    --升级所需时间
    display.newSprite("upgrade_hourglass.png", display.cx+100, display.top-470):addTo(self.upgrade_layer):setScale(0.6)
    self.upgrade_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx+125,display.top-460):addTo(self.upgrade_layer)
    self:SetUpgradeTime()

    -- 科技减少升级时间
    self.buff_reduce_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "(-00:20:00)",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x068329)
    }):align(display.LEFT_CENTER,display.cx+120,display.top-480):addTo(self.upgrade_layer)

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


    local requirements = {
        {resource_type = _("建造队列"),isVisible = true, isSatisfy = #City:GetUpgradingBuildings()<1,
            icon="hammer_31x33.png",description=GameUtils:formatNumber(#City:GetUpgradingBuildings()).."/1"},
        {resource_type = _("城堡等级"),isVisible = self.building:GetType()~="keep", isSatisfy =  self.building:GetLevel()<=City:GetFirstBuildingByType("keep"):GetLevel(),
            icon="hammer_31x33.png",description=self.building:GetLevel().."/"..City:GetFirstBuildingByType("keep"):GetLevel()},
        {resource_type = _("木材"),isVisible = self.building:GetLevelUpWood()>0,      isSatisfy = wood>self.building:GetLevelUpWood(),
            icon="wood_icon.png",description=GameUtils:formatNumber(self.building:GetLevelUpWood()).."/"..GameUtils:formatNumber(wood)},

        {resource_type = _("石料"),isVisible = self.building:GetLevelUpStone()>0,     isSatisfy = stone>self.building:GetLevelUpStone() ,
            icon="stone_icon.png",description=GameUtils:formatNumber(self.building:GetLevelUpStone()).."/"..GameUtils:formatNumber(stone)},

        {resource_type = _("铁矿"),isVisible = self.building:GetLevelUpIron()>0,      isSatisfy = iron>self.building:GetLevelUpIron() ,
            icon="iron_icon.png",description=GameUtils:formatNumber(self.building:GetLevelUpIron()).."/"..GameUtils:formatNumber(iron)},

        {resource_type = _("城民"),isVisible = self.building:GetLevelUpCitizen()>0,   isSatisfy = population>self.building:GetLevelUpCitizen() ,
            icon="citizen_44x50.png",description=GameUtils:formatNumber(self.building:GetLevelUpCitizen()).."/"..GameUtils:formatNumber(population)},

        {resource_type = _("建筑蓝图"),isVisible = self.building:GetLevelUpBlueprints()>0,isSatisfy = self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["blueprints"]>self.building:GetLevelUpBlueprints() ,
            icon="blueprints_112x112.png",description=GameUtils:formatNumber(self.building:GetLevelUpBlueprints()).."/"..GameUtils:formatNumber(self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["blueprints"])},
        {resource_type = _("建造工具"),isVisible = self.building:GetLevelUpTools()>0,     isSatisfy = self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tools"]>self.building:GetLevelUpTools() ,
            icon="tools_112x112.png",description=GameUtils:formatNumber(self.building:GetLevelUpTools()).."/"..GameUtils:formatNumber(self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tools"])},
        {resource_type =_("砖石瓦片"),isVisible = self.building:GetLevelUpTiles()>0,     isSatisfy = self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tiles"]>self.building:GetLevelUpTiles() ,
            icon="tiles_112x112.png",description=GameUtils:formatNumber(self.building:GetLevelUpTiles()).."/"..GameUtils:formatNumber(self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tiles"])},
        {resource_type = _("滑轮组"),isVisible = self.building:GetLevelUpPulley()>0,    isSatisfy = self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["pulley"]>self.building:GetLevelUpPulley() ,
            icon="pulley_112x112.png",description=GameUtils:formatNumber(self.building:GetLevelUpPulley()).."/"..GameUtils:formatNumber(self.city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["pulley"])},
    }

    if not self.requirement_listview then
        self.requirement_listview = WidgetRequirementListview.new({
            title = _("升级需求"),
            height = 298,
            contents = requirements,
        }):addTo(self.upgrade_layer):pos(display.cx-272, display.top-846)
    end
    self.requirement_listview:RefreshListView(requirements)
end

function CommonUpgradeUI:InitAccelerationPart()
    if self.building:GetNextLevel() == self.building:GetLevel() then
        return
    end
    self.acc_layer = display.newLayer()
    self.acc_layer:setContentSize(cc.size(display.width,575))
    self:addChild(self.acc_layer)

    -- 正在升级文本说明
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = string.format(_("正在升级 %s 到等级 %d"),Localize.getBuildingLocalizedKeyByBuildingType(self.building:GetType()),self.building:GetLevel()+1),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER, display.cx - 275, display.top - 410)
        :addTo(self.acc_layer)
    -- 升级倒数时间进度条
    --进度条
    local bar = display.newSprite("progress_bar_364x40_1.png"):addTo(self.acc_layer):pos(display.cx-90, display.top - 460)
    local progressFill = display.newSprite("progress_bar_364x40_2.png")
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
    self.acc_layer.upgrade_time_label:pos(self.acc_layer.upgrade_time_label:getContentSize().width/2+40, bar:getContentSize().height/2)
    if self.building:IsUpgrading() then
        pro:setPercentage(self.building:GetElapsedTimeByCurrentTime(app.timer:GetServerTime())/self.building:GetUpgradeTimeToNextLevel()*100)
        self.acc_layer.upgrade_time_label:setString(GameUtils:formatTimeStyle1(self.building:GetUpgradingLeftTimeByCurrentTime(app.timer:GetServerTime())))
    end

    -- 进度条头图标
    display.newSprite("upgrade_progress_bar_icon_bg.png", display.cx - 260, display.top - 460):addTo(self.acc_layer)
    display.newSprite("upgrade_hourglass.png", display.cx - 260, display.top - 460):addTo(self.acc_layer):setScale(0.8)
    -- 免费加速按钮
    self:CreateFreeSpeedUpBuildingUpgradeButton()
    -- 可免费加速提示
    -- 背景框
    WidgetUIBackGround.new({width = 546,height=90},WidgetUIBackGround.STYLE_TYPE.STYLE_3):align(display.CENTER,  display.cx, display.top - 540):addTo(self.acc_layer)
    -- display.newSprite("upgrade_introduce_bg.png", display.cx, display.top - 540):addTo(self.acc_layer)
    self.acc_tip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        dimensions = cc.size(530, 80),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER, display.cx - 270, display.top - 540)
        :addTo(self.acc_layer)
    self:SetAccTipLabel()
    -- 按时间加速区域
    self:CreateAccButtons()
    self:visibleChildLayers()

end

function CommonUpgradeUI:CreateFreeSpeedUpBuildingUpgradeButton()
    local  IMAGES  = {
        normal = "purple_btn_up_148x76.png",
        pressed = "purple_btn_down_148x76.png",
    }
    self.acc_layer.acc_button = WidgetPushButton.new(IMAGES, {scale9 = false},
        {
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(ui.newTTFLabel({
            text = _("免费加速"),
            size = 24,
            color = UIKit:hex2c3b(0xffedae)
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local eventType = ""
                if self.city:IsFunctionBuilding(self.building) then
                    eventType = "buildingEvents"
                elseif self.city:IsHouse(self.building) then
                    eventType = "houseEvents"
                elseif self.city:IsGate(self.building) then
                    eventType = "wallEvents"
                elseif self.city:IsTower(self.building) then
                    eventType = "towerEvents"
                end
                NetManager:getFreeSpeedUpPromise(eventType,self.building:UniqueUpgradingKey())
                    :catch(function(err)
                        dump(err:reason())
                    end)
            end
        end):align(display.CENTER, display.cx+185, display.top - 435):addTo(self.acc_layer)
    self.acc_layer.acc_button:setButtonEnabled(false)

end

function CommonUpgradeUI:SetAccTipLabel()
    --TODO 设置对应的提示 ，现在是临时的
    self.acc_tip_label:setString(_("小于5分钟时，可使用免费加速.激活VIP X后，小于5分钟时可使用免费加速"))
end

function CommonUpgradeUI:CreateAccButtons()
    -- 8个加速按钮单独放置在一个layer上方便处理事件
    self.acc_button_layer = WidgetAccelerateGroup.new(WidgetAccelerateGroup.SPEEDUP_TYPE.BUILDING):addTo(self.acc_layer):align(display.BOTTOM_CENTER,window.cx,window.bottom_top+10)
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
        local owen_gem = City:GetUser():GetGemResource():GetValue()
        dialog:SetTitle(_("补充资源"))
        dialog:SetPopMessage(_("您当前没有足够的资源,是否花费魔法石立即补充"))

        if owen_gem<required_gems then
            dialog:CreateNeeds("Topaz-icon.png",required_gems,0x7e0000)
            dialog:CreateOKButton(
                {
                    listener = function()
                        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
                        self:getParent():leftButtonClicked()
                    end
                }
            )
        else
            dialog:CreateNeeds("Topaz-icon.png",required_gems)
            dialog:CreateOKButton(
                {
                    listener = function()
                        listener()
                        self:getParent():leftButtonClicked()
                    end
                }
            )
        end
    elseif can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH then
        local required_gems = self.building:getUpgradeRequiredGems()
        dialog:CreateOKButton(
            {
                listener = function()
                    listener()
                end
            }
        )
        dialog:SetTitle(_("立即开始"))
        dialog:SetPopMessage(_("您当前没有空闲的建筑,是否花费魔法石立即完成上一个队列"))
        dialog:CreateNeeds("Topaz-icon.png",required_gems)
    elseif can_not_update_type==UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH then
        local required_gems = self.building:getUpgradeRequiredGems()
        dialog:CreateOKButton(
            {
                listener = function(sender,type)
                    listener()
                end
            }
        )
        dialog:SetTitle(_("立即开始"))
        dialog:SetPopMessage(can_not_update_type)
        dialog:CreateNeeds("Topaz-icon.png",required_gems)
    else
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(can_not_update_type)
    end
end

return CommonUpgradeUI