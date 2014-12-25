local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetDropList = import("..widget.WidgetDropList")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetInfo = import("..widget.WidgetInfo")
local WidgetSliderWithInput = import("..widget.WidgetSliderWithInput")

local UILib = import(".UILib")


local GameUITradeGuild = UIKit:createUIClass('GameUITradeGuild',"GameUIUpgradeBuilding")

local RESOURCE_TYPE = {
    [1] = "wood",
    [2] = "stone",
    [3] = "iron",
    [4] = "food",
}
local BUILD_MATERIAL_TYPE = {
    [1] = "blueprints",
    [2] = "tools",
    [3] = "tiles",
    [4] = "pulley",
}
local MARTIAL_MATERIAL_TYPE = {
    [1] = "trainingFigure",
    [2] = "bowTarget",
    [3] = "saddle",
    [4] = "ironPart",
}
local function __getBlackString(num)
    local s = ""
    for i=1,num do
        s = s.." "
    end
    return s
end

function GameUITradeGuild:ctor(city,building)
    local bn = Localize.building_name
    GameUITradeGuild.super.ctor(self,city,bn[building:GetType()],building)
end

function GameUITradeGuild:CreateBetweenBgAndTitle()
    GameUITradeGuild.super.CreateBetweenBgAndTitle(self)

    -- 购买页面
    self.buy_layer = display.newLayer()
    self:addChild(self.buy_layer)
    -- 我的商品页面
    self.my_goods_layer = display.newLayer()
    self:addChild(self.my_goods_layer)
end

function GameUITradeGuild:onEnter()
    GameUITradeGuild.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("购买"),
            tag = "buy",
        },
        {
            label = _("我的商品"),
            tag = "myGoods",
        },
    }, function(tag)
        self.buy_layer:setVisible(tag == 'buy')
        self.my_goods_layer:setVisible(tag == 'myGoods')
        if tag == 'buy' and not self.resource_drop_list then
            self:LoadBuyPage()
        end
        if tag == 'myGoods' and not self.my_goods_listview then
            self:LoadMyGoodsPage()
        end
    end):pos(window.cx, window.bottom + 34)

end

function GameUITradeGuild:onExit()
    GameUITradeGuild.super.onExit(self)
end

function GameUITradeGuild:LoadBuyPage()
    local layer = self.buy_layer
    self.resource_drop_list =  WidgetDropList.new(
        {
            {tag = "resource",label = "基本资源",default = true},
            {tag = "build_material",label = "建筑材料"},
            {tag = "martial_material",label = "军事材料"},
        },
        function(tag)
            if tag == 'resource' and not self.resource_layer then
                self.resource_layer, self.resource_listview , self.resource_options= self:LoadResource(self:GetGoodsDetailsByType(RESOURCE_TYPE),RESOURCE_TYPE)
                self.resource_options:getButtonAtIndex(1):setButtonSelected(true)
            end
            if tag == 'build_material' and not self.build_material_layer then
                self.build_material_layer, self.build_material_listview , self.build_material_options= self:LoadResource(self:GetGoodsDetailsByType(BUILD_MATERIAL_TYPE),BUILD_MATERIAL_TYPE)
                self.build_material_options:getButtonAtIndex(1):setButtonSelected(true)
            end
            if tag == 'martial_material' and not self.martial_material_layer then
                self.martial_material_layer, self.martial_material_listview , self.martial_material_options= self:LoadResource(self:GetGoodsDetailsByType(MARTIAL_MATERIAL_TYPE),MARTIAL_MATERIAL_TYPE)
                self.martial_material_options:getButtonAtIndex(1):setButtonSelected(true)
            end


            if self.resource_layer then
                self.resource_layer:setVisible(tag == 'resource')
            end
            if self.build_material_layer then
                self.build_material_layer:setVisible(tag == 'build_material')
            end
            if self.martial_material_layer then
                self.martial_material_layer:setVisible(tag == 'martial_material')
            end
        end
    )
    self.resource_drop_list:align(display.TOP_CENTER,window.cx,window.top-80):addTo(layer,2)
end
function GameUITradeGuild:LoadResource(goods_details,goods_type)
    local layer =self:CreateLayer():addTo(self.buy_layer)
    -- self.resource_layer = self:CreateLayer():addTo(self.buy_layer)
    -- local layer = self.resource_layer
    local size = layer:getContentSize()
    local w,h = size.width,size.height


    -- 展示出售中的资源列表
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a101000),
        viewRect = cc.rect(0, 0, 568, 520),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(layer):align(display.BOTTOM_CENTER,window.width/2,20)
    -- self.resource_listview = list_view
    -- 列名
    UIKit:ttfLabel(
        {
            text = _("资源")..__getBlackString(10).._("数量")..__getBlackString(10).._("资源小车")..__getBlackString(10).._("总价"),
            size = 20,
            color = 0x797154
        }):align(display.LEFT_CENTER,50, 570)
        :addTo(layer)

    -- 资源选择框
    local options = self:CreateOptions(goods_details)
        :pos(40, h-120):addTo(layer)
        :onButtonSelectChanged(function(event)
            -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
            -- dump(event.target)
            -- print("--",event.target:getButtonAtIndex(event.selected):SetValue(9191919))
            self:RefreshSellListView(goods_type,event.selected)
        end)
    -- options:getButtonAtIndex(1):setButtonSelected(true)

    return layer,list_view,options
end
function GameUITradeGuild:RefreshSellListView(goods_type,selected)
    local list_view = self:GetSellListViewByGoodsType(goods_type)
    list_view:removeAllItems()
    for i=1,10 do
        self:CreateSellItemForListView(list_view,
            {
                icon=goods_type[selected],
                num=60000,
                amount=50000,
                dolly=6,
            }
        )
    end
    list_view:reload()
end
function GameUITradeGuild:CreateSellItemForListView(listView,params)
    local item = listView:newItem()
    local item_width,item_height = 568,64
    item:setItemSize(item_width, item_height)
    -- item:setMargin({left=0,top=0,bottom=0,right=0})
    local content = display.newSprite("back_ground_568x64.png")
    item:addContent(content)
    listView:addItem(item)
    -- 商品icon
    local icon_bg = display.newSprite("back_ground_58x54.png")
        :align(display.LEFT_CENTER, 6, content:getContentSize().height/2)
        :addTo(content)
    local icon_image = display.newSprite(self:GetGoodsIcon(listView,params.icon))
        :align(display.CENTER, icon_bg:getContentSize().width/2, icon_bg:getContentSize().height/2)
        :addTo(icon_bg)
    -- 缩放icon到合适大小
    local max = math.max(icon_image:getContentSize().width,icon_image:getContentSize().height)
    icon_image:scale(50/max)
    -- 商品数量
    UIKit:ttfLabel(
        {
            text = GameUtils:formatNumber(params.num),
            size = 20,
            color = 0x403c2f
        }):align(display.CENTER, 120 ,content:getContentSize().height/2)
        :addTo(content)
    -- 需要资源小车数量
    UIKit:ttfLabel(
        {
            text = params.dolly,
            size = 20,
            color = 0x403c2f
        }):align(display.CENTER, 230 ,content:getContentSize().height/2)
        :addTo(content)
    -- 银币icon
    display.newSprite("icon_coin_26x24.png")
        :align(display.CENTER, 310, content:getContentSize().height/2)
        :addTo(content)
    -- 总价
    UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(params.amount),
            size = 20,
            color = 0x403c2f
        }):align(display.LEFT_CENTER, 330 ,content:getContentSize().height/2)
        :addTo(content)
    -- 购买
    WidgetPushButton.new(
        {normal = "yellow_btn_up_108x48.png",pressed = "yellow_btn_down_108x48.png"})
        :addTo(content)
        :align(display.RIGHT_CENTER, content:getContentSize().width - 10, content:getContentSize().height/2)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("购买"),
            size = 24,
            color = 0xffedae,
            shadow = true
        }))
        :onButtonClicked(function(event)
            listView:removeItem(item)
        end)
end
function GameUITradeGuild:GetGoodsIcon(listView,icon)
    if listView == self.resource_listview then
        return UILib.resource[icon]
    elseif listView == self.build_material_listview then
        return UILib.materials[icon]
    elseif listView == self.martial_material_listview then
        return UILib.materials[icon]
    end
end
function GameUITradeGuild:GetGoodsDetailsByType(goods_type)
    if goods_type==RESOURCE_TYPE then
        return {
            {
                UILib.resource.wood,
                12
            },
            {
                UILib.resource.stone,
                20000
            },
            {
                UILib.resource.iron,
                100000
            },
            {
                UILib.resource.food,
                3399
            },
        }
    elseif goods_type==BUILD_MATERIAL_TYPE then
        return {
            {
                UILib.materials.blueprints,
                7932174
            },
            {
                UILib.materials.tools,
                1341
            },
            {
                UILib.materials.tiles,
                13
            },
            {
                UILib.materials.pulley,
                3443
            },
        }
    elseif goods_type==MARTIAL_MATERIAL_TYPE then
        return {
            {
                UILib.materials.trainingFigure,
                54321
            },
            {
                UILib.materials.bowTarget,
                54321
            },
            {
                UILib.materials.saddle,
                54321
            },
            {
                UILib.materials.ironPart,
                54321
            },
        }
    end

end
function GameUITradeGuild:GetSellListViewByGoodsType(goods_type)
    if goods_type==RESOURCE_TYPE then
        return self.resource_listview
    elseif goods_type==BUILD_MATERIAL_TYPE then
        return self.build_material_listview
    elseif goods_type==MARTIAL_MATERIAL_TYPE then
        return self.martial_material_listview
    end
end
function GameUITradeGuild:CreateOptions(params)
    local checkbox_image = {
        off = "box_120x120_1.png",
        on = "box_132x132.png",
    }
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT)

    for i,v in ipairs(params) do
        local checkBoxButton = cc.ui.UICheckBoxButton.new(checkbox_image)
            :align(display.CENTER)
        local icon = display.newSprite(v[1])
            :align(display.CENTER,0,0)
            :addTo(checkBoxButton):scale(0.8)
        group:addButton(checkBoxButton)
        local num_bg = display.newSprite("number_bg_98x26.png")
            :align(display.BOTTOM_CENTER, 0, -checkBoxButton:getCascadeBoundingBox().size.height/2+10)
            :addTo(checkBoxButton)
        local num_value = UIKit:ttfLabel(
            {
                text = GameUtils:formatNumber(v[2]),
                size = 18,
                color = 0xfff9b5
            }):align(display.CENTER, num_bg:getContentSize().width/2 ,num_bg:getContentSize().height/2)
            :addTo(num_bg)

        -- 封装一下各个选项，以便之后刷新选项最新数值
        function checkBoxButton:SetValue(num)
            local new_value = GameUtils:formatNumber(num)
            if new_value ~= num_value:getString() then
                num_value:setString(new_value)
                -- print("SetValue")
            end
        end
    end
    group:setButtonsLayoutMargin(0, 27, 0, 0)

    return group
end
function GameUITradeGuild:CreateLayer()
    local layer = display.newColorLayer(cc.c4b(12,12,12,0))
    local layer_w,layer_h = window.width,window.betweenHeaderAndTab-62
    layer:setContentSize(cc.size(layer_w,layer_h))
    layer:pos(window.left,window.bottom_top+4)
    return layer
end
function GameUITradeGuild:LoadMyGoodsPage()
    local layer = self.my_goods_layer
    -- 资源小车 btn
    local car_btn = WidgetPushButton.new(
        {normal = "box_124x124.png",pressed = "box_124x124.png"})
        :addTo(layer)
        :align(display.CENTER, window.left + 110 , window.top - 150)
        :onButtonClicked(function(event)
            self:OpenDollyIntro()
        end)
    -- 资源小车 icon
    display.newSprite("icon_dolly_110x95.png"):addTo(car_btn)
        :align(display.CENTER, 0,0):scale(0.9)

    -- i icon
    display.newSprite("goods_26x26.png"):addTo(car_btn)
        :align(display.BOTTOM_LEFT, -car_btn:getCascadeBoundingBox().size.width/2+6, -car_btn:getCascadeBoundingBox().size.height/2+6)

    --title bg
    local title_bg = display.newSprite("title_blue_408x30.png"):addTo(layer)
        :align(display.CENTER, window.cx +70 , window.top- 108)
    --title label
    UIKit:ttfLabel(
        {
            text = _("架子车"),
            size = 22,
            color = 0xffedae
        }):align(display.LEFT_CENTER,10, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    UIKit:createLineItem(
        {
            width = 388,
            text_1 = _("数量"),
            text_2 = _("200/500"),
        }
    ):align(display.CENTER,window.cx +70 , window.top- 166)
        :addTo(layer)
    UIKit:createLineItem(
        {
            width = 388,
            text_1 = _("每小时制造"),
            text_2 = _("20"),
        }
    ):align(display.CENTER,window.cx +70 , window.top- 204)
        :addTo(layer)

    -- 我的商品列表
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a101000),
        viewRect = cc.rect(0, 0, 568, 625),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(layer):align(display.BOTTOM_CENTER,window.cx,window.bottom_top+20)
    self.my_goods_listview = list_view
    -- 加载我的商品
    self:LoadMyGoodsList()
end
function GameUITradeGuild:LoadMyGoodsList()
    local list = self.my_goods_listview
    -- 获取最大出售队列数
    local max_list_length = self:GetMaxSellListNum()
    for i = 1 , max_list_length do
        self:CreateSellItem(list,i)
    end
    list:reload()
end
function GameUITradeGuild:CreateSellItem(list,index)
    local item = list:newItem()
    local item_width,item_height = 568 ,154
    item:setItemSize(item_width,item_height)
    local content = WidgetUIBackGround.new({width=568, height=154},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    item:addContent(content)
    list:addItem(item)

    -- 基础的元素
    -- 商品背景框
    local goods_bg = display.newSprite("box_124x124.png")
        :align(display.LEFT_CENTER, 6, item_height/2)
        :addTo(content)
    local title_bg = display.newSprite("title_blue_430x30.png")
        :align(display.TOP_CENTER, 344, item_height-20)
        :addTo(content)
    local title_label = UIKit:ttfLabel(
        {
            text = "",
            size = 22,
            color = 0xffedae
        }):align(display.LEFT_CENTER,10, title_bg:getContentSize().height/2)
        :addTo(title_bg)

    local goods = self:GetOnSellGoods()[index]
    if goods then
        title_label:setString(_("出售")..Localize.fight_reward[goods.goods_type])
        -- goods icon
        local goods_icon = display.newSprite(UILib.resource[goods.goods_type])
            :align(display.CENTER, goods_bg:getContentSize().width/2, goods_bg:getContentSize().height/2)
            :addTo(goods_bg)
        goods_icon:scale(84/math.max(goods_icon:getContentSize().width,goods_icon:getContentSize().height))
        -- 商品数量背景框
        local goods_num_bg = display.newSprite("number_bg_98x26.png")
            :align(display.BOTTOM_CENTER, goods_bg:getContentSize().width/2, 13)
            :addTo(goods_bg)
        UIKit:ttfLabel(
            {
                text = GameUtils:formatNumber(goods.good_num),
                size = 18,
                color = 0xfff9b5
            }):align(display.CENTER,goods_num_bg:getContentSize().width/2, goods_num_bg:getContentSize().height/2)
            :addTo(goods_num_bg)

        -- 交易状态
        UIKit:ttfLabel(
            {
                text = goods.goods_status == "onSell" and _("等待交易") or _("交易成功"),
                size = 20,
                color = 0x797154
            }):align(display.LEFT_CENTER,140, item_height-80)
            :addTo(content)

        -- 商品出售价格
        -- 银币icon
        display.newSprite("icon_coin_26x24.png")
            :align(display.CENTER, 150, item_height-120)
            :addTo(content)
        -- 总价
        UIKit:ttfLabel(
            {
                text = string.formatnumberthousands(goods.good_price),
                size = 20,
                color = 0x403c2f
            }):align(display.LEFT_CENTER, 170 ,item_height-120)
            :addTo(content)

        -- 下架或获得交易银币按钮
        WidgetPushButton.new(
            {normal = goods.goods_status == "selled" and "yellow_btn_up_148x58.png" or "red_btn_up_148x58.png",
                pressed = goods.goods_status == "selled" and "yellow_btn_down_148x58.png" or "red_btn_down_148x58.png"})
            :addTo(content)
            :align(display.RIGHT_CENTER, item_width- 10, 50)
            :setButtonLabel(UIKit:ttfLabel({
                text = goods.goods_status == "selled" and _("获得") or _("下架") ,
                size = 22,
                color = 0xffedae,
                shadow = true
            }))
            :onButtonClicked(function(event)
                if goods.goods_status == "selled" then

                else

                end
            end)
    else
        if index<=self:GetUnlockedSellListNum() then
            title_label:setString(_("空闲"))
            UIKit:ttfLabel(
                {
                    text = _("选择你多余的资源或者材料进行出售"),
                    size = 20,
                    color = 0x403c2f,
                    dimensions = cc.size(200,0)
                }):align(display.LEFT_TOP, 140 ,item_height-60)
                :addTo(content)
            WidgetPushButton.new(
                {normal = "blue_btn_up_148x58.png" ,
                    pressed = "blue_btn_down_148x58.png"})
                :addTo(content)
                :align(display.RIGHT_CENTER, item_width- 10, 50)
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("出售") ,
                    size = 22,
                    color = 0xffedae,
                    shadow = true
                }))
                :onButtonClicked(function(event)
                    self:OpenSellDialog()
                end)
        else
            title_label:setString(_("未解锁"))
            UIKit:ttfLabel(
                {
                    text = _("需要贸易行会 LV 20"),
                    size = 20,
                    color = 0x403c2f,
                    dimensions = cc.size(200,0)
                }):align(display.LEFT_TOP, 140 ,item_height-60)
                :addTo(content)
            display.newSprite("lock_80x104.png")
                :align(display.CENTER, goods_bg:getContentSize().width/2, goods_bg:getContentSize().height/2)
                :addTo(goods_bg)
        end
    end
end
function GameUITradeGuild:GetMaxSellListNum()
    return 4
end
function GameUITradeGuild:GetUnlockedSellListNum()
    return 3
end
function GameUITradeGuild:GetOnSellGoods()
    return {
        {
            goods_type = "food",
            goods_status = "onSell",
            good_num = 258889,
            good_price = 72721,
        },
        {
            goods_type = "wood",
            goods_status = "selled",
            good_num = 258889,
            good_price = 72721,
        },
    }
end
function GameUITradeGuild:OpenDollyIntro()
    local layer = WidgetPopDialog.new(350,_("架子车"),display.top-240):addToCurrentScene()
    local body = layer:GetBody()
    local w,h = body:getContentSize().width,body:getContentSize().height

     -- 资源小车 btn
    local dolly_icon_bg = display.newSprite("box_124x124.png")
        :addTo(body)
        :align(display.CENTER, 80,h-90)
        
    -- 资源小车 icon
    display.newSprite("icon_dolly_110x95.png"):addTo(dolly_icon_bg)
        :align(display.CENTER, dolly_icon_bg:getContentSize().width/2,dolly_icon_bg:getContentSize().height/2)
        :scale(0.9)
    -- 资源小车介绍
    UIKit:ttfLabel({
            text = _("购买其他玩家出售商品需要马车来运输，马车不足册无法购买。在学院提升马车的科技，能够提高每个马车容纳资源和材料的数量"),
            size = 20,
            color = 0x797154,
            dimensions = cc.size(400,0)
        }):addTo(body)
    :align(display.TOP_LEFT, 160, h-30)

     WidgetInfo.new({
        info={
            {_("容纳资源"),"1000"},
            {_("容纳材料"),"1"},
        },
        h =100
    }):align(display.TOP_CENTER, w/2 , h-160)
        :addTo(body)
    -- 确定
    WidgetPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"}
    ):addTo(body)
        :align(display.CENTER, w/2,50)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("确定"),
            size = 24,
            color = 0xffedae,
            shadow = true
        }))
        :onButtonClicked(function(event)
                layer:removeFromParent(true)
            end)
end
function GameUITradeGuild:OpenSellDialog()
    local tradeGuildUI = self
    local body = WidgetPopDialog.new(624,_("出售资源")):addToCurrentScene():GetBody()
    -- 资源，材料出售价格区间
    local PRICE_SCOPE = {
        resource = {
            min = 100,
            max = 1000
        },
        material = {
            min = 1000,
            max = 5000
        }
    }
    -- body 方法
    function body:CreateOrRefreshSliders(params)
        local max_num = params.max_num
        local min_num = params.min_num
        local min_unit_price = params.min_unit_price
        local max_unit_price = params.max_unit_price
        local unit = params.unit
        local goods_icon = params.goods_icon

        local layer = self.layer
        if self.sell_num_item then
            layer:removeChild(self.sell_num_item, true)
        end
        if self.sell_price_item then
            layer:removeChild(self.sell_price_item, true)
        end
        local size = layer:getContentSize()

        local w,h = size.width,size.height

        -- 出售商品数量拖动条
        self.sell_num_item = self:CreateSliderItem(
            {
                title = _("出售"),
                unit = unit == 1000 and "K" or "",
                max = max_num,
                min = min_num,
                icon = goods_icon,
                onSliderValueChanged = function ( value )
                    self:SetTotalPrice(value*self.sell_price_item:GetValue())
                end
            }
        ):align(display.TOP_CENTER,w/2,h-140):addTo(layer)

        -- 商品单价拖动条
        self.sell_price_item = self:CreateSliderItem(
            {
                title = _("单价"),
                max = max_unit_price,
                min = min_unit_price,
                icon = "coin_icon_1.png",
                onSliderValueChanged = function ( value )
                    self:SetTotalPrice(value*self.sell_num_item:GetValue())
                end
            }
        ):align(display.TOP_CENTER,w/2,h-286):addTo(layer)
    end
    function body:LoadSellResource(goods_type)
        local goods_details = tradeGuildUI:GetGoodsDetailsByType(goods_type)
        local layer =self:CreateSellLayer()
        local size = layer:getContentSize()
        local w,h = size.width,size.height
        self.layer = layer
        -- 总价
        UIKit:ttfLabel(
            {
                text = _("总价"),
                size = 22,
                color = 0x403c2f,
            }):align(display.CENTER, 54 ,50)
            :addTo(layer)
        -- 银币icon
        display.newSprite("icon_coin_26x24.png")
            :align(display.CENTER, 100, 50)
            :addTo(layer)
        -- 总价
        self.total_price_label = UIKit:ttfLabel(
            {
                text = string.formatnumberthousands(1020),
                size = 20,
                color = 0x403c2f
            }):align(display.LEFT_CENTER, 134 ,50)
            :addTo(layer)

        -- 出售
        self.sell_btn = WidgetPushButton.new(
            {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"},
            {scale9 = false},
            {
                disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
            }
        ):addTo(layer)
            :align(display.RIGHT_CENTER, w-20,50)
            :setButtonLabel(UIKit:ttfLabel({
                text = _("出售"),
                size = 24,
                color = 0xffedae,
                shadow = true
            }))
            :onButtonClicked(function(event)
                local tag = body.drop_list:GetSelectdTag()
                print("---------tag==",tag)
                local options,goods_type
                if tag == 'resource' then
                    options = body.resource_options
                    goods_type = RESOURCE_TYPE
                end
                if tag == 'build_material' then
                    options = body.build_material_options
                    goods_type = BUILD_MATERIAL_TYPE
                end
                if tag == 'martial_material' then
                    options = body.martial_material_options
                    goods_type = MARTIAL_MATERIAL_TYPE
                end
                local selected = options.currentSelectedIndex_
                print("-------selected",selected)
                print("-------GetTotalPrice",body:GetTotalPrice())
                print("-------goods_type",goods_type[selected])
            end)


        -- 资源选择框
        local options = tradeGuildUI:CreateOptions(goods_details)
            :pos(26, h-120):addTo(layer)
            :onButtonSelectChanged(function(event)
                -- printf("Option %d selected, Option %d unselected", event.selected, event.last)
                -- dump(event.target)
                -- print("--",event.target:getButtonAtIndex(event.selected):SetValue(9191919))


                local max_num,min_num,min_unit_price,max_unit_price,unit = self:GetPriceAndNum(goods_type,event.selected)
                print("goods_icon====",self:GetGoodsIcon(goods_type,event.selected))
                self:CreateOrRefreshSliders(
                    {
                        max_num=max_num,
                        min_num=min_num,
                        min_unit_price=min_unit_price,
                        max_unit_price=max_unit_price,
                        unit=unit,
                        goods_icon = self:GetGoodsIcon(goods_type,event.selected),
                    }
                )
                self:SetTotalPrice( self.sell_num_item:GetValue()*self.sell_price_item:GetValue())
            end)

        return layer,options
    end
    function body:GetPriceAndNum(goods_type,index)
        local max_num,min_num,min_unit_price,max_unit_price,unit
        local goods_details = tradeGuildUI:GetGoodsDetailsByType(goods_type)[index]
        if goods_type == RESOURCE_TYPE then
            unit = 1000
            min_unit_price = PRICE_SCOPE.resource.min
            max_unit_price = PRICE_SCOPE.resource.max

            max_num = math.floor(goods_details[2]/unit)
            min_num = max_num>1 and 1 or 0
        else
            min_unit_price = PRICE_SCOPE.material.min
            max_unit_price = PRICE_SCOPE.material.max

            max_num = goods_details[2]
            min_num = max_num>1 and 1 or 0

        end
        return max_num,min_num,min_unit_price,max_unit_price,unit
    end
    function body:GetGoodsIcon(goods_type,index)
        if goods_type == RESOURCE_TYPE then
            return UILib.resource[goods_type[index]]
        elseif goods_type == BUILD_MATERIAL_TYPE then
            return UILib.materials[goods_type[index]]
        elseif goods_type == MARTIAL_MATERIAL_TYPE then
            return UILib.materials[goods_type[index]]
        end
    end
    function body:SetTotalPrice(value)
        self.total_price_label:setString(string.formatnumberthousands(value))
        self.total_price = value
        self.sell_btn:isButtonEnabled()
        if self.sell_btn:isButtonEnabled() ~= (value~=0) then
            self.sell_btn:setButtonEnabled(value~=0)
        end
    end
    function body:GetTotalPrice()
        return self.total_price
    end
    function body:CreateSellLayer()
        local layer = display.newColorLayer(cc.c4b(12,12,12,0))
        local layer_w,layer_h = 608,520
        layer:setContentSize(cc.size(layer_w,layer_h))
        layer:pos(0,10)
        return layer
    end
    function body:CreateSliderItem(parms)
        local item_width,item_height=580,136
        -- 背景框
        local item = WidgetUIBackGround.new({width=item_width,height=item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_4)
        -- 拖动条背景框
        local slider_bg = WidgetUIBackGround.new({width=574,height=80},WidgetUIBackGround.STYLE_TYPE.STYLE_3)
            :align(display.BOTTOM_CENTER,item_width/2,4)
            :addTo(item)
        -- title
        UIKit:ttfLabel(
            {
                text = parms.title,
                size = 22,
                color = 0x403c2f,
            }):align(display.LEFT_TOP, 20 ,item_height-15)
            :addTo(item)
        -- slider
        local slider = WidgetSliderWithInput.new({max = parms.max,min=parms.min,unit = parms.unit})
            :addTo(slider_bg)
            :align(display.CENTER, slider_bg:getContentSize().width/2, parms.min==0 and 40 or 60)
            :OnSliderValueChanged(function(event)
                parms.onSliderValueChanged(math.floor(event.value))
            end)
            :LayoutValueLabel(WidgetSliderWithInput.STYLE_LAYOUT.TOP,80)

        -- icon
        local x,y = slider:GetEditBoxPostion()
        if parms.icon then
            item.icon = display.newSprite(parms.icon)
                :align(display.CENTER, x-80, y)
                :addTo(slider)
            local icon = item.icon
            local max = math.max(icon:getContentSize().width,icon:getContentSize().height)
            icon:scale(40/max)
        end
        function item:SetIcon(icon)
            local icon = item.icon
            if icon then
                icon:setTexture(icon)
            else
                item.icon = display.newSprite(parms.icon)
                    :align(display.CENTER, x-80, y)
                    :addTo(slider)
                local max = math.max(icon:getContentSize().width,icon:getContentSize().height)
                icon:scale(40/max)
            end
        end
        function item:GetValue()
            return slider:GetValue()
        end
        return item
    end

    -- body 方法




    local body_width,body_height = 608,624
    body.drop_list =  WidgetDropList.new(
        {
            {tag = "resource",label = "基本资源",default = true},
            {tag = "build_material",label = "建筑材料"},
            {tag = "martial_material",label = "军事材料"},
        },
        function(tag)
            if tag == 'resource' and not body.resource_layer then
                body.resource_layer, body.resource_options= body:LoadSellResource(RESOURCE_TYPE)
                body.resource_options:getButtonAtIndex(1):setButtonSelected(true)
                body.resource_layer:addTo(body)
            end
            if tag == 'build_material' and not body.build_material_layer then
                body.build_material_layer,  body.build_material_options= body:LoadSellResource(BUILD_MATERIAL_TYPE)
                body.build_material_options:getButtonAtIndex(1):setButtonSelected(true)
                body.build_material_layer:addTo(body)
            end
            if tag == 'martial_material' and not body.martial_material_layer then
                body.martial_material_layer,  body.martial_material_options= body:LoadSellResource(MARTIAL_MATERIAL_TYPE)
                body.martial_material_options:getButtonAtIndex(1):setButtonSelected(true)
                body.martial_material_layer:addTo(body)
            end


            if body.resource_layer then
                body.resource_layer:setVisible(tag == 'resource')
            end
            if body.build_material_layer then
                body.build_material_layer:setVisible(tag == 'build_material')
            end
            if body.martial_material_layer then
                body.martial_material_layer:setVisible(tag == 'martial_material')
            end
        end
    )
    body.drop_list:align(display.TOP_CENTER,body_width/2,body_height-30):addTo(body,2)
end

return GameUITradeGuild


