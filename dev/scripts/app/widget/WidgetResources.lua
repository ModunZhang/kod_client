local ResourceManager = import('..entity.ResourceManager')
local SoldierManager = import('..entity.SoldierManager')
local WidgetUseItems= import(".WidgetUseItems")
local WidgetPushButton = import('.WidgetPushButton')
local UIListView = import("..ui.UIListView")
local resource_type = {
    WOOD = ResourceManager.RESOURCE_TYPE.WOOD,
    FOOD = ResourceManager.RESOURCE_TYPE.FOOD,
    IRON = ResourceManager.RESOURCE_TYPE.IRON,
    STONE = ResourceManager.RESOURCE_TYPE.STONE,
    COIN = ResourceManager.RESOURCE_TYPE.COIN
}
local WidgetResources = class("WidgetResources", function ()
    return display.newLayer()
end)

function WidgetResources:ctor()
    self:setNodeEventEnabled(true)
    self.city = City
    self.building = self.city:GetFirstBuildingByType("warehouse")
end
function WidgetResources:onEnter()
    self:CreateResourceListView()
    self:InitAllResources()
    self.city:GetResourceManager():AddObserver(self)
    self.city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)
end
function WidgetResources:onExit()
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)
    self.city:GetResourceManager():RemoveObserver(self)
end
function WidgetResources:OnSoliderCountChanged(...)
    self.maintenance_cost.value:setString("-"..self.city:GetSoldierManager():GetTotalUpkeep())
end
-- 资源刷新
function WidgetResources:OnResourceChanged(resource_manager)
    local maxwood, maxfood, maxiron, maxstone = self.building:GetResourceValueLimit()
    local resource_max = {
        [ResourceManager.RESOURCE_TYPE.WOOD] = maxwood,
        [ResourceManager.RESOURCE_TYPE.FOOD] = maxfood,
        [ResourceManager.RESOURCE_TYPE.IRON] = maxiron,
        [ResourceManager.RESOURCE_TYPE.STONE] = maxstone,
    }
    if self.resource_items then
        for k,v in pairs(self.resource_items) do
            self:RefreshSpecifyResource(resource_manager:GetResourceByType(k),v,resource_max[k],City:GetCitizenByType(City.RESOURCE_TYPE_TO_BUILDING_TYPE[k]), k)
        end
    end
end

local city = City
local FOOD = ResourceManager.RESOURCE_TYPE.FOOD
function WidgetResources:RefreshSpecifyResource(resource,item,maxvalue,occupy_citizen, type_)
    if maxvalue then
        item.ProgressTimer:setPercentage(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime())/maxvalue*100)
        item.resource_label:setString(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()).."/"..maxvalue)
        if type_ == FOOD then
            item.produce_capacity.value:setString(city:GetResourceManager():GetFoodProductionPerHour().."/h")
        else
            item.produce_capacity.value:setString(resource:GetProductionPerHour().."/h")
        end
        item.occupy_citizen.value:setString(occupy_citizen.."")
    else
        item.resource_label:setString(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()))
        --  local townHall = self.city:GetFirstBuildingByType("townHall")
        -- local title_value = townHall:IsInImposing() and _("正在征税") or _("当前没有进行征税")
        -- item.tax.title:setString(title_value)
        -- local tax_time = townHall:IsInImposing() and GameUtils:formatTimeStyle1(townHall:GetTaxEvent():LeftTime(app.timer:GetServerTime())) or ""
        -- item.tax.value:setString(tax_time)
        -- item.free_citizen.value:setString(self.city:GetResourceManager():GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime()))
    end
end
function WidgetResources:CreateResourceListView()
    self.resource_listview = UIListView.new{
        bgScale9 = true,
        viewRect = cc.rect(display.cx-300, display.top-860, 600, 780),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
end

function WidgetResources:InitAllResources()
    local current_time = app.timer:GetServerTime()
    local maxwood, maxfood, maxiron, maxstone = self.building:GetResourceValueLimit()
    local crm = City:GetResourceManager()
    local all_resources = {
        food = {
            resource_icon="res_food_114x100.png",
            resource_limit_value=maxfood,
            resource_current_value=crm:GetFoodResource():GetResourceValueByCurrentTime(current_time),
            total_income=crm:GetFoodProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("farmer"),
            maintenance_cost="-"..self.city:GetSoldierManager():GetTotalUpkeep(),
            type = "food"
        },
        wood = {
            resource_icon="res_wood_114x100.png",
            resource_limit_value=maxwood,
            resource_current_value=crm:GetWoodResource():GetResourceValueByCurrentTime(current_time),
            total_income=crm:GetWoodResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("woodcutter"),
            type = "wood"
        },
        stone = {
            resource_icon="stone_icon.png",
            resource_limit_value=maxstone,
            resource_current_value=crm:GetStoneResource():GetResourceValueByCurrentTime(current_time),
            total_income=crm:GetStoneResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("quarrier"),
            type = "stone"
        },
        iron = {
            resource_icon="res_iron_114x100.png",
            resource_limit_value=maxiron,
            resource_current_value=crm:GetIronResource():GetResourceValueByCurrentTime(current_time),
            total_income=crm:GetIronResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("miner"),
            type = "iron"
        },
        coin = {
            resource_icon="coin_icon.png",
            resource_current_value=crm:GetCoinResource():GetResourceValueByCurrentTime(current_time),
            total_income=8888,
            occupy_citizen=self.city:GetResourceManager():GetPopulationResource():GetNoneAllocatedByTime(current_time),
            type = "coin"
        },
    }
    self.resource_items = {}
    self.resource_items[resource_type.FOOD] = self:AddResourceItem(all_resources.food)
    self.resource_items[resource_type.WOOD] = self:AddResourceItem(all_resources.wood)
    self.resource_items[resource_type.STONE] = self:AddResourceItem(all_resources.stone)
    self.resource_items[resource_type.IRON] = self:AddResourceItem(all_resources.iron)
    self.resource_items[resource_type.COIN] = self:AddResourceItem(all_resources.coin)
end

function WidgetResources:AddResourceItem(parms)
    local resource_icon = parms.resource_icon
    local resource_limit_value = parms.resource_limit_value
    local resource_current_value = parms.resource_current_value
    local total_income = parms.total_income
    local occupy_citizen = parms.occupy_citizen
    local maintenance_cost = parms.maintenance_cost

    local item = self.resource_listview:newItem()
    local item_width, item_height = 600,173
    item:setItemSize(item_width, item_height)
    local content = cc.ui.UIGroup.new()
    -- item 主背景
    content:addWidget(display.newSprite("Background_wareHouseUI.png",  0, 0))
    -- resource icon bg
    content:addWidget(display.newSprite("alliance_item_flag_box_126X126.png",-230, 0))
    -- resou icon
    content:addWidget(display.newSprite(resource_icon,-230, 0))

    -- 构造分割线显示信息方法
    local function createTipItem(prams)
        -- 分割线
        local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(395,2))

        -- title
        line.title = cc.ui.UILabel.new(
            {
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = prams.title,
                font = UIKit:getFontFilePath(),
                size = 20,
                color = prams.title_color
            }):align(display.LEFT_CENTER, 0, 12)
            :addTo(line)
        -- title value
        line.value = cc.ui.UILabel.new(
            {
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = prams.value,
                font = UIKit:getFontFilePath(),
                size = 20,
                color = prams.value_color
            }):align(display.RIGHT_CENTER, line:getCascadeBoundingBox().size.width, 12)
            :addTo(line)
        return line
    end

    if resource_limit_value then
        -- 进度条
        local bar = display.newSprite("progress_bar_382x40_1.png"):addTo(content):pos(35,46)
        local progressFill = display.newSprite("progress_bar_382x40_2.png")
        item.ProgressTimer = cc.ProgressTimer:create(progressFill)
        item.ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
        item.ProgressTimer:setBarChangeRate(cc.p(1,0))
        item.ProgressTimer:setMidpoint(cc.p(0,0))
        item.ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
        item.ProgressTimer:setPercentage(resource_current_value/resource_limit_value*100)
        item.resource_label = UIKit:ttfLabel({
            text = resource_current_value.."/"..resource_limit_value,
            size = 20,
            color = 0xfff3c7,
        }):addTo(bar):align(display.LEFT_CENTER,10 , bar:getContentSize().height/2)


        -- 单位产能
        item.produce_capacity = createTipItem({
            title = _("单位产能"),
            title_color = UIKit:hex2c3b(0x797154),
            value = total_income ,
            value_color = UIKit:hex2c3b(0x403c2f),
            x = 40,
            y = -10
        })
        content:addWidget(item.produce_capacity)
        --  占用人口
        item.occupy_citizen = createTipItem({
            title = _("占用人口"),
            title_color = UIKit:hex2c3b(0x797154),
            value = occupy_citizen ,
            value_color = UIKit:hex2c3b(0x403c2f),
            x = 40,
            y = -40
        })
        content:addWidget(item.occupy_citizen)
        if maintenance_cost then
            --  维护费用
            item.maintenance_cost = createTipItem({
                title = _("维护费用"),
                title_color = UIKit:hex2c3b(0x797154),
                value = maintenance_cost ,
                value_color = UIKit:hex2c3b(0x4ff0000),
                x = 40,
                y = -70
            })
            self.maintenance_cost = item.maintenance_cost
            content:addWidget(item.maintenance_cost)
        end

    else
        -- coin 显示不同信息
        -- 当前coin
        item.resource_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = resource_current_value.."",
            font = UIKit:getFontFilePath(),
            size = 24,
            align = ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x403c2f),
        }):align(display.LEFT_CENTER, -155, 40):addTo(content)
        -- item.resource_label:setAnchorPoint(cc.p(0,0.5))
        -- item.resource_label:pos(-125, 40)
        -- 是否在征税
        -- local townHall = self.city:GetFirstBuildingByType("townHall")
        -- local title_value = townHall:IsInImposing() and _("正在征税") or _("当前没有进行征税")
        -- local tax_time = townHall:IsInImposing() and GameUtils:formatTimeStyle1(townHall:GetTaxEvent():LeftTime(app.timer:GetServerTime())) or ""
        -- item.tax = createTipItem({
        --     title = title_value,
        --     title_color = UIKit:hex2c3b(0x797154),
        --     value = tax_time ,
        --     value_color = UIKit:hex2c3b(0x403c2f),
        --     x = 40,
        --     y = -10
        -- })
        -- content:addWidget(item.tax)
        --  空闲人口
        -- item.free_citizen = createTipItem({
        --     title = _("空闲人口"),
        --     title_color = UIKit:hex2c3b(0x797154),
        --     value = occupy_citizen ,
        --     value_color = UIKit:hex2c3b(0x403c2f),
        --     x = 40,
        --     y = -40
        -- })
        -- content:addWidget(item.free_citizen)
    end

    -- 使用道具增加资源按钮
    WidgetPushButton.new({normal = "button_wareHouseUI_normal.png",pressed = "button_wareHouseUI_pressed.png"})
        :onButtonClicked(function(event)
            print("string.split(resource_icon, )[1]",string.split(resource_icon, "_")[1])
            local items = ItemManager:GetItemByName(parms.type.."Class_1")
            WidgetUseItems.new():Create({item = items}):addToCurrentScene()
        end):align(display.CENTER, item_width/2 -30, 0):addTo(content)
        :addChild(display.newSprite("add.png"))

    item:addContent(content)
    self.resource_listview:addItem(item)
    self.resource_listview:reload()

    return item
end

return WidgetResources

