local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetBuyGoods = import("..widget.WidgetBuyGoods")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local AllianceItemsManager = import("..entity.AllianceItemsManager")
local GameUIAllianceShop = UIKit:createUIClass('GameUIAllianceShop', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")
local Localize_item = import("..utils.Localize_item")
local shop = GameDatas.AllianceBuilding.shop


function GameUIAllianceShop:ctor(city,default_tab,building)
    GameUIAllianceShop.super.ctor(self, city, _("商店"))
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
    self.items_manager = self.alliance:GetItemsManager()
    self:InitUnLockItems()
end
function GameUIAllianceShop:InitUnLockItems()
    self.unlock_items = {}
    for i=1,self.building.level do
        local unlock = string.split(shop[i].itemsUnlock, ",")
        for i,v in ipairs(unlock) do
            self.unlock_items[v] = true
        end
    end
end
function GameUIAllianceShop:CheckSell(item_type)
    return self.unlock_items[item_type]
end
function GameUIAllianceShop:OnMoveInStage()
    GameUIAllianceShop.super.OnMoveInStage(self)
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
        if tag == 'stock' and not self.stock_listview then
            self:InitStockPart()
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitRecordPart()

    self.alliance:GetItemsManager():AddListenOnType(self,AllianceItemsManager.LISTEN_TYPE.ITEM_CHANGED)
    self.alliance:GetItemsManager():AddListenOnType(self,AllianceItemsManager.LISTEN_TYPE.ITEM_LOGS_CHANGED)

end
function GameUIAllianceShop:CreateBetweenBgAndTitle()
    GameUIAllianceShop.super.CreateBetweenBgAndTitle(self)

    -- goods_layer
    self.goods_layer = display.newLayer():addTo(self:GetView())
    -- stock_layer
    self.stock_layer = display.newLayer():addTo(self:GetView())
    -- goods_record_layer
    self.goods_record_layer = display.newLayer():addTo(self:GetView())
end
function GameUIAllianceShop:onExit()
    self.alliance:GetItemsManager():RemoveListenerOnType(self,AllianceItemsManager.LISTEN_TYPE.ITEM_CHANGED)
    self.alliance:GetItemsManager():RemoveListenerOnType(self,AllianceItemsManager.LISTEN_TYPE.ITEM_LOGS_CHANGED)
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

    local normal_items = self.items_manager:GetAllNormalItems()
    for i=1,#normal_items,row_count do
        local noraml_item = normal_items[i]
        if self:CheckSell(noraml_item:Name()) then
            local goods_item = __createListItem(list_width,goods_item_height)
            local node = display.newNode()
            node:setContentSize(cc.size(list_width,goods_item_height))
            local count = 1
            for index=i,i + row_count -1 do
                local goods = normal_items[index]
                if goods then
                    self:CreateGoodsBox(goods):addTo(node):pos(origin_x+(count-1)*(gap_x+box_width), goods_item_height/2)
                    count = count + 1
                else
                    break
                end
            end
            goods_item:addContent(node)
        end
    end

    -- 高级道具
    -- title
    local title_item = __createListItem(list_width,50)
    local title_bg = display.newSprite("title_purple_558x34.png")
    UIKit:ttfLabel({
        text = _("高级道具"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2):addTo(title_bg)
    title_item:addContent(title_bg)

    self.super_goods_boxes = {}

    -- 道具部分
    local super_items = self.items_manager:GetAllSuperItems()
    for i=1,#super_items,row_count do
        if self:CheckSell(super_items[i]:Name()) then
            local goods_item = __createListItem(list_width,goods_item_height)
            local node = display.newNode()
            node:setContentSize(cc.size(list_width,goods_item_height))
            local count = 1
            for index=i,i + row_count -1 do
                local goods = super_items[index]
                if goods then
                    local goods_box = self:CreateGoodsBox(goods):addTo(node):pos(origin_x+(count-1)*(gap_x+box_width), goods_item_height/2)
                    count = count + 1
                    if goods:IsAdvancedItem() then
                        self.super_goods_boxes[goods:Name()] = goods_box
                    end
                else
                    break
                end
            end
            goods_item:addContent(node)
        end
    end
    list:reload()
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

    -- 高级道具显示数量
    if goods:IsAdvancedItem() then
        -- 拥有数量
        local own_bg = display.newSprite("back_ground_42x48.png"):align(display.TOP_CENTER, 28, item_bg:getContentSize().height+4):addTo(item_bg)

        local own_label = UIKit:ttfLabel({
            text = goods:Count(),
            size = 18,
            color = 0xfff3ca,
            shadow = true
        }):align(display.CENTER, own_bg:getContentSize().width/2, own_bg:getContentSize().height/2+8):addTo(own_bg)

        function box_button:SetOwnCount( count )
            own_label:setString(count)
        end
    end

    local num_bg = display.newSprite("back_ground_118x36.png"):align(display.BOTTOM_CENTER, 0, -76)
        :addTo(box_button)
    display.newSprite("loyalty_128x128.png"):align(display.CENTER, 24, num_bg:getContentSize().height/2-2):addTo(num_bg):scale(34/128)
    UIKit:ttfLabel({
        text = goods:SellPriceInAlliance(),
        size = 22,
        color = 0x423f32,
    }):align(display.LEFT_CENTER, num_bg:getContentSize().width/2-10, num_bg:getContentSize().height/2-2):addTo(num_bg)
    return box_button
end

function GameUIAllianceShop:CreateStockGoodsBox(goods)
    local box_button = WidgetPushButton.new({normal = "back_ground_130x166.png",pressed = "back_ground_130x166.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                WidgetStockGoods.new(goods):addTo(self)
            end
        end)

    local item_bg = display.newSprite("box_118x118.png"):addTo(box_button):align(display.CENTER, 0, 18)
    local item_icon_color_bg = display.newSprite("box_item_100x100.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    -- tool image
    display.newSprite("tool_1.png"):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
        :addTo(item_bg):scale(0.8)
    local i_icon = display.newSprite("goods_26x26.png"):addTo(item_bg):align(display.CENTER, 15, 15)
    -- 拥有数量
    local own_bg = display.newSprite("back_ground_42x48.png"):align(display.TOP_CENTER, 28, item_bg:getContentSize().height+4):addTo(item_bg)

    local own_label = UIKit:ttfLabel({
        text = goods:Count(),
        size = 18,
        color = 0xfff3ca,
        shadow = true
    }):align(display.CENTER, own_bg:getContentSize().width/2, own_bg:getContentSize().height/2+8):addTo(own_bg)

    local num_bg = display.newSprite("back_ground_118x36.png"):align(display.BOTTOM_CENTER, 0, -76)
        :addTo(box_button)
    display.newSprite("honour_128x128.png"):align(display.CENTER, 24, num_bg:getContentSize().height/2-2):addTo(num_bg):scale(34/128)
    UIKit:ttfLabel({
        text = goods:BuyPriceInAlliance(),
        size = 22,
        color = 0x423f32,
    }):align(display.LEFT_CENTER, num_bg:getContentSize().width/2-10, num_bg:getContentSize().height/2-2):addTo(num_bg)
    function box_button:SetOwnCount(count)
        own_label:setString(count)
    end
    return box_button
end
function GameUIAllianceShop:InitStockPart()
    local layer = self.stock_layer
    local list_width = 558
    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(41, window.bottom_top,list_width , window.betweenHeaderAndTab),
    },false)
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx,window.bottom_top+20)
    self.stock_listview = list


    local function __createListItem(w,h)
        local item = list:newItem()
        item:setItemSize(w, h)
        list:addItem(item)
        return item
    end


    -- 道具部分
    local box_width = 130
    local goods_item_height = 176
    local origin_x = box_width/2
    local row_count = 4
    local gap_x = 10

    -- 高级道具
    -- title
    local title_item = __createListItem(list_width,50)
    local title_bg = display.newSprite("title_purple_558x34.png")
    UIKit:ttfLabel({
        text = _("高级道具"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2):addTo(title_bg)
    title_item:addContent(title_bg)

    -- 高级道具 box table
    self.stock_boxes = {}

    -- 道具部分
    local super_items = self.items_manager:GetAllSuperItems()
    for i=1,#super_items,row_count do
        if self:CheckSell(super_items[i]:Name()) then
            local goods_item = __createListItem(list_width,goods_item_height)
            local node = display.newNode()
            node:setContentSize(cc.size(list_width,goods_item_height))
            local count = 1
            for index=i,i + row_count -1 do
                local goods = super_items[index]
                if goods then
                    self.stock_boxes[goods:Name()] = self:CreateStockGoodsBox(goods):addTo(node):pos(origin_x+(count-1)*(gap_x+box_width), goods_item_height/2)
                    count = count + 1
                else
                    break
                end
            end
            goods_item:addContent(node)
        end
    end
    list:reload()
end

function GameUIAllianceShop:InitRecordPart()
    local layer = self.goods_record_layer
    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(41, window.bottom_top,568 , window.betweenHeaderAndTab-10),
    },false)
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx,window.bottom_top+20)
    self.record_list = list

    local item_logs = self.alliance:GetItemsManager():GetItemLogs()
    self.record_logs_items = {}
    for i,v in ipairs(item_logs) do
        self:CreateRecordItem(v)
    end

    self.record_list:reload()
end

function GameUIAllianceShop:CreateRecordItem(item_log,index)
    LuaUtils:outputTable("item_log", item_log)
    local item = self.record_list:newItem()
    local item_width,item_height = 568 , 110
    item:setItemSize(item_width, item_height)

    local content = display.newSprite("back_ground_568x110.png")

    local item_bg = display.newSprite("box_118x118.png"):addTo(content):align(display.CENTER, 58, item_height/2):scale(0.8)
    local item_icon_color_bg = display.newSprite("box_item_100x100.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    -- tool image
    display.newSprite("tool_1.png"):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
        :addTo(item_bg):scale(0.8)

    local record_type = item_log.type
    local color_1 = record_type == "addItem" and 0x007c23 or 0x7e0000
    local text_1 = record_type == "addItem" and _("补充") or _("购买")
    UIKit:ttfLabel({
        text = text_1..Localize_item.item_name[item_log.itemName].."X"..item_log.itemCount,
        size = 20,
        color = color_1,
    }):align(display.LEFT_CENTER, 140 , 70)
        :addTo(content)


    UIKit:ttfLabel({
        text = item_log.playerName,
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 140 , 30)
        :addTo(content)

    UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle2(item_log.time/1000),
        size = 20,
        color = 0x797154,
    }):align(display.LEFT_CENTER, 320 , 30)
        :addTo(content)

    item:addContent(content)
    self.record_list:addItem(item,index)

    self.record_logs_items[item_log.time..item_log.playerName] = item
end

function GameUIAllianceShop:OnItemsChanged(changed_map)
    for i,v in ipairs(changed_map[1]) do
        if self.stock_boxes and self.stock_boxes[v:Name()] then
            self.stock_boxes[v:Name()]:SetOwnCount(v:Count())
        end
        if self.super_goods_boxes and self.super_goods_boxes[v:Name()] then
            self.super_goods_boxes[v:Name()]:SetOwnCount(v:Count())
        end
    end
    for i,v in ipairs(changed_map[2]) do
        if self.stock_boxes and self.stock_boxes[v:Name()] then
            self.stock_boxes[v:Name()]:SetOwnCount(v:Count())
        end
        if self.super_goods_boxes and self.super_goods_boxes[v:Name()] then
            self.super_goods_boxes[v:Name()]:SetOwnCount(v:Count())
        end
    end
    for i,v in ipairs(changed_map[3]) do
        if self.stock_boxes and self.stock_boxes[v:Name()] then
            self.stock_boxes[v:Name()]:SetOwnCount(v:Count())
        end
        if self.super_goods_boxes and self.super_goods_boxes[v:Name()] then
            self.super_goods_boxes[v:Name()]:SetOwnCount(v:Count())
        end
    end
end

function GameUIAllianceShop:OnItemLogsChanged( changed_map )
    for i,v in ipairs(changed_map[1]) do
        self:CreateRecordItem(v,1)
    end

    for i,v in ipairs(changed_map[3]) do
        local record_item = self.record_logs_items[v.time..v.playerName]
        if record_item then
            self.record_list:removeItem(record_item)
        end
    end
    self.record_list:reload()
end
return GameUIAllianceShop














