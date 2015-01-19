--
-- Author: Danny He
-- Date: 2014-12-17 19:30:23
--
local GameUIUpgradeTechnology = UIKit:createUIClass("GameUIUpgradeTechnology")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local HEIGHT = 694
local window = import("..utils.window")
local MaterialManager = import("..entity.MaterialManager")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")

function GameUIUpgradeTechnology:ctor(productionTechnology)
    self.productionTechnology = productionTechnology
    GameUIUpgradeTechnology.super.ctor(self)
end

function GameUIUpgradeTechnology:GetProductionTechnology()
    return self.productionTechnology
end

function GameUIUpgradeTechnology:onEnter()
	GameUIUpgradeTechnology.super.onEnter(self)
	self:BuildUI()
    City:AddListenOnType(self,City.LISTEN_TYPE.PRODUCTION_DATA_CHANGED)
end

function GameUIUpgradeTechnology:onMoveOutStage()
    GameUIUpgradeTechnology.super.onMoveOutStage(self)
    City:RemoveListenerOnType(self,City.LISTEN_TYPE.PRODUCTION_DATA_CHANGED)
end

function GameUIUpgradeTechnology:OnProductionTechsDataChanged(changed_map)
    for _,tech in ipairs(changed_map.edited or {}) do
        if self:GetProductionTechnology():Index() == tech:Index() then
            self:RefreshUI()
        end
    end
end

function GameUIUpgradeTechnology:RefreshUI()
    local tech = self:GetProductionTechnology()
    self.lv_label:setString(self:GetProductionTechnology():GetLocalizedName() .. " " .. _("等级") .. " " .. self:GetProductionTechnology():Level())
    self.current_effect_val_label:setString(self:GetProductionTechnology():GetBuffEffectVal() * 100  .. "%")
    if not tech:IsReachLimitLevel() then
        self.next_effect_val_label:setString(self:GetProductionTechnology():GetNextLevelBuffEffectVal() * 100  .. "%")
        self.time_label:setString(GameUtils:formatTimeStyle1(self:GetProductionTechnology():GetLevelUpCost().buildTime))
        self.need_gems_label:setString(self:GetUpgradeNowGems())
        self:RefreshRequirementList()
    else
        self.time_label:hide()
        self.need_gems_label:hide()
        self.next_effect_val_label:hide()
        self.next_effect_desc_label:hide()
    end
end

function GameUIUpgradeTechnology:GetTechIcon()
    local bg = display.newSprite("technology_bg_116x116.png"):scale(0.95)
    local icon_image = self:GetProductionTechnology():GetImageName()
    display.newSprite(icon_image):addTo(bg):pos(58,58):scale(0.85)
    return bg
end

function GameUIUpgradeTechnology:BuildUI()
	UIKit:shadowLayer():addTo(self)
	local bg_node =  WidgetUIBackGround.new({height = HEIGHT,isFrame = "no"}):addTo(self):align(display.TOP_CENTER, window.cx, window.top_bottom)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png"):align(display.BOTTOM_CENTER,304,HEIGHT - 15):addTo(bg_node)
	UIKit:closeButton():align(display.RIGHT_BOTTOM,600, 0):addTo(title_bar):onButtonClicked(function()
		self:leftButtonClicked()
	end)
	UIKit:ttfLabel({text = _("科技研发"),
		size = 22,
        color = 0xffedae
    }):align(display.CENTER,300, 22):addTo(title_bar)
    local box = display.newSprite("alliance_item_flag_box_126X126.png"):align(display.LEFT_TOP, 20, title_bar:getPositionY() - 20):addTo(bg_node)
    self.tech_bg = self:GetTechIcon():pos(63,63):addTo(box):scale(0.95)
    local title = display.newSprite("technology_title_438x30.png")
    	:align(display.LEFT_TOP,box:getPositionX()+box:getContentSize().width + 10, box:getPositionY())
    	:addTo(bg_node)
    self.lv_label = UIKit:ttfLabel({
    	text = self:GetProductionTechnology():GetLocalizedName() .. " " .. _("等级") .. " " .. self:GetProductionTechnology():Level(),
    	size = 22,
    	color= 0xffedae
    }):align(display.LEFT_CENTER, 20, 15):addTo(title)
    local line_2 = display.newScale9Sprite("dividing_line_594x2.png"):size(422,1)
    	:align(display.LEFT_BOTTOM,box:getPositionX()+box:getContentSize().width + 10, box:getPositionY()-box:getContentSize().height)
    	:addTo(bg_node)
    local next_effect_desc = UIKit:ttfLabel({
    	text = _("下一级"),
    	size = 20,
    	color= 0x797154
    }):align(display.LEFT_BOTTOM,line_2:getPositionX(), line_2:getPositionY() + 5):addTo(bg_node)
    self.next_effect_desc_label = next_effect_desc
    local next_effect_val_label = UIKit:ttfLabel({
    	text = "", --self:GetProductionTechnology():GetNextLevelBuffEffectVal() * 100  .. "%",
    	size = 22,
    	color= 0x403c2f
    }):align(display.RIGHT_BOTTOM,line_2:getPositionX()+line_2:getContentSize().width, next_effect_desc:getPositionY()):addTo(bg_node)
    self.next_effect_val_label = next_effect_val_label
    local line_1 = display.newScale9Sprite("dividing_line_594x2.png"):size(422,1)
    	:align(display.LEFT_BOTTOM,line_2:getPositionX(), line_2:getPositionY() + 40)
    	:addTo(bg_node)

    local current_effect_desc = UIKit:ttfLabel({
    	text = self:GetProductionTechnology():GetBuffLocalizedDesc(),
    	size = 20,
    	color= 0x797154
    }):align(display.LEFT_BOTTOM,line_1:getPositionX(), line_1:getPositionY() + 5):addTo(bg_node)
   	local current_effect_val_label = UIKit:ttfLabel({
    	text = "",--self:GetProductionTechnology():GetBuffEffectVal() * 100  .. "%",
    	size = 22,
    	color= 0x403c2f
    }):align(display.RIGHT_BOTTOM,line_1:getPositionX()+line_1:getContentSize().width, current_effect_desc:getPositionY()):addTo(bg_node)
    self.current_effect_val_label = current_effect_val_label
   local btn_now = UIKit:commonButtonWithBG(
    {
        w=250,
        h=65,
        style = UIKit.BTN_COLOR.GREEN,
        labelParams = {text = _("立即研发")},
        listener = function ()
            self:OnUpgradNowButtonClicked()
        end,
    }):align(display.LEFT_TOP, 30, line_2:getPositionY() - 30):addTo(bg_node)
    self.upgradeNowButton = btn_now

    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("研发")},
            listener = function ()
                self:OnUpgradButtonClicked()
            end,
        }
    ):align(display.RIGHT_TOP, line_2:getPositionX()+line_2:getContentSize().width, line_2:getPositionY() - 30)
     :addTo(bg_node)
    self.upgrade_button = btn_bg
    local gem = display.newSprite("Topaz-icon.png")
    	:addTo(bg_node)
    	:scale(0.5)
    	:align(display.LEFT_TOP, btn_now:getPositionX(), btn_now:getPositionY() - 65 - 10)

    self.need_gems_label = UIKit:ttfLabel({
    	text = "",--self:GetUpgradeNowGems(),
    	size = 20,
    	color= 0x403c2f
    }):align(display.LEFT_TOP,gem:getPositionX() + gem:getCascadeBoundingBox().width + 10, gem:getPositionY()):addTo(bg_node)


    --升级所需时间
    local time_icon = display.newSprite("upgrade_hourglass.png")
    	:addTo(bg_node)
    	:scale(0.6)
    	:align(display.LEFT_TOP, btn_bg:getPositionX() - 185,btn_bg:getPositionY() - 65 - 10)

    self.time_label = UIKit:ttfLabel({
    	text = "",--GameUtils:formatTimeStyle1(self:GetProductionTechnology():GetLevelUpCost().buildTime),
    	size = 18,
    	color= 0x403c2f
    }):align(display.LEFT_TOP, time_icon:getPositionX()+time_icon:getCascadeBoundingBox().width + 10, time_icon:getPositionY()):addTo(bg_node)

	self.buff_time_label = UIKit:ttfLabel({
		text = "(-00:20:00)",
		size = 18,
		color= 0x068329
	}):align(display.LEFT_TOP,time_icon:getPositionX()+time_icon:getCascadeBoundingBox().width + 10,time_icon:getPositionY()-20):addTo(bg_node)
    if not self:GetProductionTechnology():IsReachLimitLevel() then
        local requirements = self:GetUpgradeRequirements()
   	    self.listView = WidgetRequirementListview.new({
            title = _("研发需求"),
            height = 270,
            contents = requirements,
        }):addTo(bg_node):pos(30,40)
    end
    self:RefreshUI()
end


function GameUIUpgradeTechnology:RefreshRequirementList()
    local requirements = self:GetUpgradeRequirements()
    self.listView:RefreshListView(requirements)
end

function GameUIUpgradeTechnology:GetUpgradeRequirements()
    local requirements = {}
    local cost =  self:GetProductionTechnology():GetLevelUpCost()
    local coin = City.resource_manager:GetCoinResource():GetValue()
    table.insert(requirements, 
        {
            resource_type = _("银币"),
            isVisible = cost.coin >0,
            isSatisfy = coin >= cost.coin,
            icon="coin_icon_1.png",
            description= GameUtils:formatNumber(cost.coin).."/"..GameUtils:formatNumber(coin)
        })
    table.insert(requirements, 
        {
            resource_type = _("建筑蓝图"),
            isVisible = cost.blueprints>0,
            isSatisfy = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["blueprints"]>=cost.blueprints,
            icon="blueprints_112x112.png",
            description= GameUtils:formatNumber(cost.blueprints).."/"..GameUtils:formatNumber(City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["blueprints"])
        })
    table.insert(requirements, 
        {
            resource_type = _("建造工具"),
            isVisible = cost.tools>0,
            isSatisfy = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tools"]>=cost.tools,
            icon="tools_112x112.png",
            description= GameUtils:formatNumber(cost.tools).."/"..GameUtils:formatNumber(City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tools"])
        }) 
    table.insert(requirements, 
        {
            resource_type = _("砖石瓦片"),
            isVisible = cost.tiles>0,
            isSatisfy = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tiles"]>=cost.tiles,
            icon="tiles_112x112.png",
            description= GameUtils:formatNumber(cost.tiles).."/"..GameUtils:formatNumber(City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tiles"])
        })
    table.insert(requirements, 
        {
            resource_type = _("滑轮组"),
            isVisible = cost.pulley>0,
            isSatisfy = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["pulley"]>=cost.pulley,
            icon="pulley_112x112.png",
            description= GameUtils:formatNumber(cost.pulley).."/"..GameUtils:formatNumber(City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["pulley"])
        })
    return requirements
end

function GameUIUpgradeTechnology:OnUpgradNowButtonClicked()
    local canUpgrade,msg = self:CheckCanUpgradeNow()
    if canUpgrade then
        NetManager:getUpgradeProductionTechPromise(self:GetProductionTechnology():Name(),true):next(function(msg)

        end)
    else
        UIKit:showMessageDialog(_("提示"),msg, function()end)
    end
end

function GameUIUpgradeTechnology:OnUpgradButtonClicked()
    local gems_cost,msg = self:CheckCanUpgradeActionReturnGems()
    if gems_cost == 0 then
        NetManager:getUpgradeProductionTechPromise(self:GetProductionTechnology():Name(),false):next(function(msg)
            self:leftButtonClicked()
        end)
    else
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示")):SetPopMessage(msg)
            :CreateOKButton({
                listener =  function ()
                    self:ForceUpgrade(gems_cost)
                end})
            :CreateNeeds("Topaz-icon.png",gems_cost)
            :AddToCurrentScene(true)
    end
end

function GameUIUpgradeTechnology:ForceUpgrade(gem_cost)
    if  User:GetGemResource():GetValue() < gem_cost then
         UIKit:showMessageDialog(_("提示"),_("宝石不足"), function()end)
    else
         NetManager:getUpgradeProductionTechPromise(self:GetProductionTechnology():Name(),false):next(function(msg)
            self:leftButtonClicked()
        end)
    end
end

--计算需要的资源
----------------------------------------------------------------------------------------------------------------

function GameUIUpgradeTechnology:GetNeedResourceAndMaterialsAndTime(tech)
    local cost = tech:GetLevelUpCost() 
    if not cost then return {},{},0 end
    return 
        {
            coin = cost.coin
        },
        {
            blueprints = cost.blueprints,
            tools      = cost.tools,
            pulley      = cost.pulley,
        },
        cost.buildTime
end

function GameUIUpgradeTechnology:GetUpgradeNowGems()
    local resource,material,time = self:GetNeedResourceAndMaterialsAndTime(self:GetProductionTechnology())
    local resource_gems = DataUtils:buyResource(resource,{})
    local material_gems = DataUtils:buyMaterial(material,{})
    local time_gems = DataUtils:getGemByTimeInterval(time)
    return resource_gems + material_gems + time_gems
end

function GameUIUpgradeTechnology:CheckCanUpgradeNow()
    if City:HaveProductionTechEvent() then
        local event = City:GetProductionTechEventsArray()[1]
        if event and event:Name() == self:GetProductionTechnology():Name() then
            return false,_("该科技正在升级中，如需立即完成请对其加速")
        end
    end
    return User:GetGemResource():GetValue() >= self:GetUpgradeNowGems(),_("宝石不足")
end

function GameUIUpgradeTechnology:GetUpgradeGemsIfResourceNotEnough()
    local coin = City.resource_manager:GetCoinResource():GetValue()
    local materialManager = City:GetMaterialManager()
    local resource,material,__ = self:GetNeedResourceAndMaterialsAndTime(self:GetProductionTechnology())
    local resource_gems = DataUtils:buyResource(resource,{coin = coin})
    local blueprints = materialManager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["blueprints"]
    local tools = materialManager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["tools"]
    local pulley = materialManager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)["pulley"]
    local material_gems = DataUtils:buyMaterial(material,{blueprints = blueprints,tools = tools,pulley = pulley})
    return resource_gems + material_gems
end

function GameUIUpgradeTechnology:GetUpgradeGemsIfQueueNotEnough()
    if City:HaveProductionTechEvent() then
        local event = City:GetProductionTechEventsArray()[1]
        return DataUtils:getGemByTimeInterval(event:GetTime())
    end
end

function GameUIUpgradeTechnology:CheckCanUpgradeActionReturnGems()
    local gems_cost,msg = 0,0,""
    if City:HaveProductionTechEvent() then
        gems_cost = self:GetUpgradeGemsIfQueueNotEnough()
        msg = _("已有科技升级队列,如需升级此科技需加速完成该队列花费宝石") .. gems_cost
    end
    local resource_gems = self:GetUpgradeGemsIfResourceNotEnough()
    if resource_gems ~= 0 then
        gems_cost = resource_gems + gems_cost
        msg = msg .. "\n" .. _("升级所需物品不足,如需升级此科技需要花费宝石购买所缺物品") .. resource_gems
    end
    return gems_cost,msg
end

return GameUIUpgradeTechnology