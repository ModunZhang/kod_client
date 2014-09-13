local TabButtons = import('.TabButtons')
local ResourceManager = import('..entity.ResourceManager')
local GameUIWarehouse = UIKit:createUIClass('GameUIWarehouse')

local resource_type = {
        WOOD = ResourceManager.RESOURCE_TYPE.WOOD,
        FOOD = ResourceManager.RESOURCE_TYPE.FOOD,
        IRON = ResourceManager.RESOURCE_TYPE.IRON,
        STONE = ResourceManager.RESOURCE_TYPE.STONE,
        COIN = ResourceManager.RESOURCE_TYPE.COIN
    }

function GameUIWarehouse:ctor(building)
    GameUIWarehouse.super.ctor(self)
    self.building = building
    local top_bg = display.newSprite("back_ground.png")
        :align(display.LEFT_TOP, display.left, display.top - 40)
        :addTo(self)
end

function GameUIWarehouse:onEnter()
    GameUIWarehouse.super.onEnter(self)
    self.resource_layer = display.newLayer()
    self:addChild(self.resource_layer)
    self:CreateTitle()
    self:CreateHomeButton()
    self:CreateShopButton()
    self:CreateTabButtons()
    self:CreateResourceListView()
    self:InitAllResources()

    City:GetResourceManager():AddObserver(self)
end

-- 资源刷新
function GameUIWarehouse:OnResourceChanged(resource_manager)
    local maxwood, maxfood, maxiron, maxstone = self.building:GetResourceValueLimit()
    local resource_max = {
        [ResourceManager.RESOURCE_TYPE.WOOD] = maxwood,
        [ResourceManager.RESOURCE_TYPE.FOOD] = maxfood,
        [ResourceManager.RESOURCE_TYPE.IRON] = maxiron,
        [ResourceManager.RESOURCE_TYPE.STONE] = maxstone,
    }

    for k,v in pairs(self.resource_items) do
        self:RefreshSpecifyResource(resource_manager:GetResourceByType(k),v,resource_max[k],City:GetCitizenByType(City.RESOURCE_TYPE_TO_BUILDING_TYPE[k]))
    end

    -- self:RefreshSpecifyResource(resource_manager:GetFoodResource(),self.food_item,maxfood,City:GetCitizenByType("farmer"))
    -- self:RefreshSpecifyResource(resource_manager:GetWoodResource(),self.wood_item,maxwood,City:GetCitizenByType("woodcutter"))
    -- self:RefreshSpecifyResource(resource_manager:GetStoneResource(),self.stone_item,maxstone,City:GetCitizenByType("quarrier"))
    -- self:RefreshSpecifyResource(resource_manager:GetIronResource(),self.iron_item,maxiron,City:GetCitizenByType("miner"))
    -- self:RefreshSpecifyResource(resource_manager:GetCoinResource(),self.coin_item)
end

function GameUIWarehouse:RefreshSpecifyResource(resource,item,maxvalue,occupy_citizen)
    if maxvalue then
        item.ProgressTimer:setPercentage(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime())/maxvalue*100)
        item.resource_label:setString(resource:GetResourceValueByCurrentTime(app.timer:GetServerTime()).."/"..maxvalue)
        item.produce_capacity.value:setString(resource:GetProductionPerHour().."/h")
        item.occupy_citizen.value:setString(occupy_citizen.."")
    end
end

function GameUIWarehouse:CreateHomeButton()
    self.homeButton = cc.ui.UIPushButton.new({normal = "common_ui_title_button_normal.png",pressed = "common_ui_title_button_pressed.png"})
        :onButtonClicked(function(event)
            self:Close()
        end):align(display.LEFT_TOP, display.left , display.top):addTo(self)
    cc.ui.UIImage.new("Back_button_icon.png")
        :align(display.CENTER,self.homeButton:getCascadeBoundingBox().size.width/2-10,-self.homeButton:getCascadeBoundingBox().size.height/2+10)
        :addTo(self.homeButton)
end

function GameUIWarehouse:CreateTitle()
    cc.ui.UIImage.new("Title.png")
        :align(display.TOP_CENTER,display.cx,display.top)
        :addTo(self)
    self.title_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("资源仓库"),
        font = UIKit:getFontFilePath(),
        size = 30,
        color = UIKit:hex2c3b(0xffedae),
    }):align(display.CENTER, display.cx, display.top-35):addTo(self)

end

function GameUIWarehouse:CreateShopButton()
    self.gem_button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up.png",pressed = "gem_btn_down.png"}
    ):onButtonClicked(function(event)
        dump(event)
    end):addTo(self)
    self.gem_button:align(display.RIGHT_TOP, display.right, display.top)
    cc.ui.UIImage.new("home/gem.png")
        :addTo(self.gem_button)
        :pos(-75, -64)

    local gem_num_bg = cc.ui.UIImage.new("gem_num_bg.png"):addTo(self.gem_button):pos(-85, -85)
    local pos = gem_num_bg:getAnchorPointInPoints()
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = ""..City.resource_manager:GetGemResource():GetValue(),
        font = UIKit:getFontFilePath(),
        size = 14,
        color = UIKit:hex2c3b(0xfdfac2)})
        :addTo(gem_num_bg)
        :align(display.CENTER, 40, 12)
end

function GameUIWarehouse:CreateTabButtons()
    local tab_buttons = TabButtons.new({
        {
            label = _("升级"),
            tag = "base",
            default = true,
        },
        {
            label = _("资源"),
            tag = "resource",
        },
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
        if tag == "base" then
            self.resource_layer:setVisible(false)
        elseif tag == "resource" then
            self.resource_layer:setVisible(true)
        end
    end):addTo(self):pos(display.cx, display.bottom + 40)
end

function GameUIWarehouse:CreateResourceListView()
    self.resource_listview = cc.ui.UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+20, display.bottom+80, 600, display.height-180),
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
        local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(display.width-245,2))

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
    City:GetResourceManager():RemoveObserver(self)
    self:leftButtonClicked()
end

return GameUIWarehouse



