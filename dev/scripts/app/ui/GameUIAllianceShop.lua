local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetBuyGoods = import("..widget.WidgetBuyGoods")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIAllianceShop = UIKit:createUIClass('GameUIAllianceShop', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")


function GameUIAllianceShop:ctor(city,default_tab,building)
    GameUIAllianceShop.super.ctor(self, city, _("商店"))
    self.default_tab = default_tab
    self.building = building
    self.items_manager = Alliance_Manager:GetMyAlliance():GetItemsManager()
end

function GameUIAllianceShop:onEnter()
    GameUIAllianceShop.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("商品"),
            tag = "goods",
            default = "goods" == self.default_tab,
        },
        {
            label = _("进货"),
            tag = "stock",
            default = "stock" == self.default_tab,
        },
        {
            label = _("商品记录"),
            tag = "record",
            default = "record" == self.default_tab,
        },
    }, function(tag)
        if tag == 'goods' then
            self.goods_layer:setVisible(true)
        else
            self.goods_layer:setVisible(false)
        end
        if tag == 'stock' then
            self.stock_layer:setVisible(true)
        else
            self.stock_layer:setVisible(false)
        end
        if tag == 'record' then
            self.goods_record_layer:setVisible(true)
        else
            self.goods_record_layer:setVisible(false)
        end
        if tag == 'goods' and not self.goods_listview then
            self:InitGoodsPart()
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitStockPart()
    self:InitRecordPart()
end
function GameUIAllianceShop:CreateBetweenBgAndTitle()
    GameUIAllianceShop.super.CreateBetweenBgAndTitle(self)

    -- goods_layer
    self.goods_layer = display.newLayer()
    self:addChild(self.goods_layer)
    -- stock_layer
    self.stock_layer = display.newLayer()
    self:addChild(self.stock_layer)
    -- goods_record_layer
    self.goods_record_layer = display.newLayer()
    self:addChild(self.goods_record_layer)
end
function GameUIAllianceShop:onExit()
    GameUIAllianceShop.super.onExit(self)
end
function GameUIAllianceShop:InitGoodsPart()
    local layer = self.goods_layer
    local list_width = 558
    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(41, window.bottom_top,list_width , window.betweenHeaderAndTab),
    },false)
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx,window.bottom_top+20)
    self.goods_listview = list

    local function __createListItem(w,h)
        local item = list:newItem()
        item:setItemSize(w, h)
        list:addItem(item)
        return item
    end

    -- 普通道具
    -- title
    local title_item = __createListItem(list_width,50)
    local title_bg = display.newSprite("title_blue_558x34.png")
    UIKit:ttfLabel({
        text = _("普通道具"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2):addTo(title_bg)
    title_item:addContent(title_bg)

    -- 道具部分
    local box_width = 130
    local goods_item_height = 176
    local origin_x = box_width/2
    local row_count = 4
    local gap_x = 10

    local buff_items = self.items_manager:GetBuffItems()
    for i=1,#buff_items,row_count do
        local goods_item = __createListItem(list_width,goods_item_height)
        local node = display.newNode()
        node:setContentSize(cc.size(list_width,goods_item_height))
        local count = 1
        for index=i,i + row_count -1 do
            local goods = buff_items[index]
            if goods then
                self:CreateGoodsBox(goods):addTo(node):pos(origin_x+(count-1)*(gap_x+box_width), goods_item_height/2)
                count = count + 1
            else
                break
            end
        end
        goods_item:addContent(node)
    end
    list:reload()
end

function GameUIAllianceShop:AddAllGoods(listview,all_goods,creatBoxFunc)
    local width = 550
    local item_width,item_height = width,200
    local one_box_width = 150
    local gap_x = (width - 3 * one_box_width)/2
    print("gap_x=",gap_x)
    local item_row = display.newNode()
    local count = -1
    for _,goods in pairs(all_goods) do
        count = count + 1
        creatBoxFunc(self,goods):align(display.CENTER, count*one_box_width+one_box_width/2+count*gap_x-275, 20)
            :addTo(item_row)
        if count == 2 then
            count = -1
            local item = listview:newItem()
            item:setItemSize(item_width, item_height)
            item:addContent(item_row)
            listview:addItem(item)
            item_row = display.newNode()
        end
    end
    listview:reload()
end

function GameUIAllianceShop:CreateGoodsBox(goods)
    local box_button = WidgetPushButton.new({normal = "back_ground_130x166.png",pressed = "back_ground_130x166.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                WidgetBuyGoods.new(goods):addTo(self)
            end
        end)

    local item_bg = display.newSprite("box_118x118.png"):addTo(box_button):align(display.CENTER, 0, 18)
    local item_icon_color_bg = display.newSprite("box_item_100x100.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    -- tool image
    display.newSprite("tool_1.png"):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
        :addTo(item_bg):scale(0.8)
    local i_icon = display.newSprite("goods_26x26.png"):addTo(item_bg):align(display.CENTER, 15, 15)

    local num_bg = display.newSprite("back_ground_118x36.png"):align(display.BOTTOM_CENTER, 0, -76)
        :addTo(box_button)
    display.newSprite("loyalty_1.png"):align(display.CENTER, 24, num_bg:getContentSize().height/2-2):addTo(num_bg):scale(0.8)
    UIKit:ttfLabel({
        text = goods:Count(),
        size = 22,
        color = 0x423f32,
    }):align(display.LEFT_CENTER, num_bg:getContentSize().width/2-10, num_bg:getContentSize().height/2-2):addTo(num_bg)
    return box_button
end

function GameUIAllianceShop:CreateStockGoodsBox(goods)
    local goods_img
    if goods.tool_type==1 then
        goods_img = "tool_box_blue.png"
    elseif goods.tool_type==2 then
        goods_img = "tool_box_green.png"
    else
        goods_img = "tool_box_red.png"
    end
    local box_button = WidgetPushButton.new({normal = goods_img,pressed = goods_img})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                WidgetStockGoods.new(100):addTo(self)
            end
        end)

    -- tool image
    display.newSprite(goods.image):align(display.CENTER, 0, 0)
        :addTo(box_button)

    local stock_mark_bg = display.newSprite("stock_mark_bg.png"):align(display.LEFT_TOP, -60, 68)
        :addTo(box_button)
    local mark_label = UIKit:ttfLabel({
        text = "888",
        size = 18,
        color = 0xf6e5a8,
    }):align(display.CENTER, 21, 28):addTo(stock_mark_bg)
    local num_bg = display.newSprite("number_bg_138x52.png"):align(display.TOP_CENTER, 0, -65)
        :addTo(box_button)
    display.newSprite("honour.png"):align(display.CENTER, 30, 26):addTo(num_bg)
    UIKit:ttfLabel({
        text = goods.num,
        size = 22,
        color = 0x423f32,
    }):align(display.LEFT_CENTER, 65, 26):addTo(num_bg)
    return box_button
end
function GameUIAllianceShop:InitStockPart()
    local ordinary_goods_body = self:CreateBackGroundWithTitle({
        title_bg = "report_title.png",
        height = 464,
        title_1 = _("普通道具")
    }):align(display.TOP_CENTER, window.cx, window.top-130):addTo(self.stock_layer)
    self.stock_ordinary_goods_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(29, 10, 550, 435),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(ordinary_goods_body)
    local all_goods = {
        {
            image="tool_1.png",
            tool_type = 1,
            num = 4000,
        },
        {
            image="tool_1.png",
            tool_type = 2,
            num = 4000,
        },
        {
            image="tool_1.png",
            tool_type = 3,
            num = 4000,
        },
        {
            image="tool_1.png",
            tool_type = 1,
            num = 4000,
        },
        {
            image="tool_1.png",
            tool_type = 2,
            num = 4000,
        },
        {
            image="tool_1.png",
            tool_type = 3,
            num = 4000,
        },
    }
    self:AddAllGoods(self.stock_ordinary_goods_listview,all_goods,self.CreateStockGoodsBox)


    local special_goods_body = self:CreateBackGroundWithTitle({
        title_bg = "title_purple_600x52.png",
        height = 234,
        title_1 = _("特殊道具")
    }):align(display.BOTTOM_CENTER, window.cx, window.bottom+90):addTo(self.stock_layer)
    self.stock_special_goods_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(29, 10, 550, 210),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(special_goods_body)
    self:AddAllGoods(self.stock_special_goods_listview,all_goods,self.CreateStockGoodsBox)

end

function GameUIAllianceShop:InitRecordPart()
    self.stock_special_goods_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-277, display.top-880, 560, 780),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.goods_record_layer)
    self:CreateRecordItem()
    self:CreateRecordItem()

    self.stock_special_goods_listview:reload()
end

function GameUIAllianceShop:CreateRecordItem()
    local item = self.stock_special_goods_listview:newItem()
    local item_width,item_height = 560 , 112
    item:setItemSize(item_width, item_height)

    local content = display.newNode()
    local tool_bg = display.newSprite("tool_box_104X106.png"):align(display.CENTER, -228, 0):addTo(content)
    local tool_img = display.newSprite("tool_1.png")
        :align(display.CENTER, tool_bg:getContentSize().width/2, tool_bg:getContentSize().height/2)
        :addTo(tool_bg):scale(0.7)

    local info_bg = WidgetUIBackGround.new({
        width = 426,
        height = 96,
        top_img = "back_ground_426x14_top_1.png",
        bottom_img = "back_ground_426x14_top_1.png",
        mid_img = "back_ground_426x1_mid_1.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,50, 0):addTo(content)
    UIKit:ttfLabel({
        text = _("补充 ItemName X11"),
        size = 20,
        color = 0x007c23,
    }):align(display.LEFT_CENTER, 20 , 70)
        :addTo(info_bg)
    local level_img = display.newSprite("leader.png")
        :align(display.CENTER, 30,30)
        :addTo(info_bg)

    UIKit:ttfLabel({
        text = _("Player name"),
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 50 , 30)
        :addTo(info_bg)

    UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle2(app.timer:GetServerTime()),
        size = 20,
        color = 0x797154,
    }):align(display.LEFT_CENTER, 200 , 30)
        :addTo(info_bg)

    item:addContent(content)
    self.stock_special_goods_listview:addItem(item)
end

function GameUIAllianceShop:CreateBackGroundWithTitle(params)
    local body = WidgetUIBackGround.new({height=params.height}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite(params.title_bg):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = params.title_1,
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    if params.title_2 then
        title_label:align(display.LEFT_CENTER, 60, title:getContentSize().height/2+2)
        UIKit:ttfLabel({
            text = params.title_2,
            size = 20,
            color = 0xb7af8e,
        }):align(display.RIGHT_CENTER, title:getContentSize().width-60, title:getContentSize().height/2+2)
            :addTo(title)
    end
    return body
end
return GameUIAllianceShop




