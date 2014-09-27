local TabButtons = import('.TabButtons')
local ResourceManager = import('..entity.ResourceManager')
local GameUIWarehouse = UIKit:createUIClass('GameUIWarehouse',"GameUIUpgradeBuilding")

local resource_type = {
    WOOD = ResourceManager.RESOURCE_TYPE.WOOD,
    FOOD = ResourceManager.RESOURCE_TYPE.FOOD,
    IRON = ResourceManager.RESOURCE_TYPE.IRON,
    STONE = ResourceManager.RESOURCE_TYPE.STONE,
    COIN = ResourceManager.RESOURCE_TYPE.COIN
}

function GameUIWarehouse:ctor(city,building)
    GameUIWarehouse.super.ctor(self,city,_("仓库"),building)
    -- self.building = building
    -- self.city = city
end

function GameUIWarehouse:CreateBetweenBgAndTitle()
    GameUIWarehouse.super.CreateBetweenBgAndTitle(self)
    self.resource_layer = display.newLayer()
    self:addChild(self.resource_layer)
end

function GameUIWarehouse:onEnter()
    GameUIWarehouse.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("资源"),
            tag = "resource",
        },
    },function(tag)
        if tag == 'resource' then
            self.resource_layer:setVisible(true)
        else
            self.resource_layer:setVisible(false)
        end
    end):pos(display.cx, display.top - 920)
    self:CreateResourceListView()
    self:InitAllResources()

end

-- 资源刷新
function GameUIWarehouse:OnResourceChanged(resource_manager)
    GameUIWarehouse.super.OnResourceChanged(self,resource_manager)
    local maxwood, maxfood, maxiron, maxstone = self.building:GetResourceValueLimit()
    local resource_max = {
        [ResourceManager.RESOURCE_TYPE.WOOD] = maxwood,
        [ResourceManager.RESOURCE_TYPE.FOOD] = maxfood,
        [ResourceManager.RESOURCE_TYPE.IRON] = maxiron,
        [ResourceManager.RESOURCE_TYPE.STONE] = maxstone,
    }
    if self.resource_items then
        for k,v in pairs(self.resource_items) do
            self:RefreshSpecifyResource(resource_manager:GetResourceByType(k),v,resource_max[k],City:GetCitizenByType(City.RESOURCE_TYPE_TO_BUILDING_TYPE[k]))
        end
    end
end

function GameUIWarehouse:RefreshSpecifyResource(resource,item,maxvalue,occupy_citizen)
    if maxvalue then
        item.ProgressTimer:setPercentage(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime())/maxvalue*100)
        item.resource_label:setString(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()).."/"..maxvalue)
        item.produce_capacity.value:setString(resource:GetProductionPerHour().."/h")
        item.occupy_citizen.value:setString(occupy_citizen.."")
    end
end


function GameUIWarehouse:CreateResourceListView()
    self.resource_listview = cc.ui.UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.cx-300, display.top-880, 600, 780),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.resource_layer)
end

function GameUIWarehouse:InitAllResources()
    local maxwood, maxfood, maxiron, maxstone = self.building:GetResourceValueLimit()
    local crm = City:GetResourceManager()
    local all_resources = {
        food = {
            resource_icon="food_icon.png",
            resource_limit_value=maxfood,
            resource_current_value=crm:GetFoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
            total_income=crm:GetFoodResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("farmer"),
            maintenance_cost=8888,
        },
        wood = {
            resource_icon="wood_icon.png",
            resource_limit_value=maxwood,
            resource_current_value=crm:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
            total_income=crm:GetFoodResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("woodcutter"),
        },
        stone = {
            resource_icon="stone_icon.png",
            resource_limit_value=maxstone,
            resource_current_value=crm:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
            total_income=crm:GetStoneResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("quarrier"),
        },
        iron = {
            resource_icon="iron_icon.png",
            resource_limit_value=maxiron,
            resource_current_value=crm:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
            total_income=crm:GetIronResource():GetProductionPerHour().."/h",
            occupy_citizen=City:GetCitizenByType("miner"),
        },
        coin = {
            resource_icon="coin_icon.png",
            resource_current_value=crm:GetCoinResource():GetValue(),
            total_income=8888,
            occupy_citizen=8888,
        },
    }
    self.resource_items = {}
    self.resource_items[resource_type.FOOD] = self:AddResourceItem(all_resources.food)
    self.resource_items[resource_type.WOOD] = self:AddResourceItem(all_resources.wood)
    self.resource_items[resource_type.STONE] = self:AddResourceItem(all_resources.stone)
    self.resource_items[resource_type.IRON] = self:AddResourceItem(all_resources.iron)
    self.resource_items[resource_type.COIN] = self:AddResourceItem(all_resources.coin)
end

function GameUIWarehouse:AddResourceItem(parms)
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
    content:addWidget(display.newSprite("icon_background_wareHouseUI.png",-230, 0))
    -- resou icon
    content:addWidget(display.newSprite(resource_icon,-230, 0))

    -- 构造分割线显示信息方法
    local function createTipItem(prams)
        -- 分割线
        local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(395,2))

        -- title
        cc.ui.UILabel.new(
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
        local bar = display.newSprite("Progress_bar_1.png"):addTo(content):pos(35,46)
        local progressFill = display.newSprite("Progress_bar_2.png")
        item.ProgressTimer = cc.ProgressTimer:create(progressFill)
        item.ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
        item.ProgressTimer:setBarChangeRate(cc.p(1,0))
        item.ProgressTimer:setMidpoint(cc.p(0,0))
        item.ProgressTimer:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
        item.ProgressTimer:setPercentage(resource_current_value/resource_limit_value*100)
        item.resource_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = resource_current_value.."/"..resource_limit_value,
            font = UIKit:getFontFilePath(),
            size = 20,
            align = ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0xfff3c7),
        }):addTo(bar)
        item.resource_label:setAnchorPoint(cc.p(0,0.5))
        item.resource_label:pos(item.resource_label:getContentSize().width/2+10, bar:getContentSize().height/2)


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
        item.tax = createTipItem({
            title = _("当前没有进行征税"),
            title_color = UIKit:hex2c3b(0x797154),
            value = total_income ,
            value_color = UIKit:hex2c3b(0x403c2f),
            x = 40,
            y = -10
        })
        content:addWidget(item.tax)
        --  空闲人口
        item.free_citizen = createTipItem({
            title = _("空闲人口"),
            title_color = UIKit:hex2c3b(0x797154),
            value = occupy_citizen ,
            value_color = UIKit:hex2c3b(0x403c2f),
            x = 40,
            y = -40
        })
        content:addWidget(item.free_citizen)
    end

    -- 使用道具增加资源按钮
    cc.ui.UIPushButton.new({normal = "button_wareHouseUI_normal.png",pressed = "button_wareHouseUI_pressed.png"})
        :onButtonClicked(function(event)
            dump(event)
        end):align(display.CENTER, item_width/2 -30, 0):addTo(content)
        :addChild(display.newSprite("add.png"))

    item:addContent(content)
    self.resource_listview:addItem(item)
    self.resource_listview:reload()

    return item
end

function GameUIWarehouse:Close()
    self:leftButtonClicked()
end

return GameUIWarehouse





