local window = import("..utils.window")
local WidgetBackGroundWithInnerTitle = import("..widget.WidgetBackGroundWithInnerTitle")
local WidgetBuffBox = import("..widget.WidgetBuffBox")
local GameUIBuff = UIKit:createUIClass('GameUIBuff', "GameUIWithCommonHeader")

function GameUIBuff:ctor(city)
    GameUIBuff.super.ctor(self, city, _("增益"))
end

function GameUIBuff:onEnter()
    GameUIBuff.super.onEnter(self)
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 845),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self):align(display.BOTTOM_CENTER,window.cx,window.bottom+40)
    self.list = list_view
    self:CityBuff()
    self:WarBuff()
    list_view:reload()
end
function GameUIBuff:CityBuff()
    local content = self:CreateItem(_("城市增益效果"),WidgetBackGroundWithInnerTitle.TITLE_COLOR.BLUE)
    self:InitBuffs(
        {
            {
                category = "city",
                type = "buff1",
            },
            {
                category = "city",
                type = "buff2",
            },
            {
                category = "city",
                type = "buff3",
            },
            {
                category = "city",
                type = "buff4",
            },
            {
                category = "city",
                type = "buff5",
            },
            {
                category = "city",
                type = "buff6",
            },
            {
                category = "city",
                type = "buff7",
            },
            {
                category = "city",
                type = "buff8",
            },
            {
                category = "city",
                type = "buff9",
            }
        }
        ,content)

    -- WidgetBuffBox.new({
    --     buff_category = "city",
    --     buff_type = "buff3",
    -- }):addTo(self)
    --     :align(display.CENTER,display.cx,display.cy)
    --     :SetInfo("未解锁")
    -- WidgetBuffBox.new({
    --     buff_type = "war"
    --     }):addTo(self)
    -- :align(display.LEFT_CENTER,display.cx,display.cy)
end
function GameUIBuff:WarBuff()
    local content = self:CreateItem(_("战争增益效果"),WidgetBackGroundWithInnerTitle.TITLE_COLOR.RED)
    self:InitBuffs(
        {
            {
                category = "war",
                type = "buff1",
            },
            {
                category = "war",
                type = "buff2",
            },
            {
                category = "war",
                type = "buff3",
            },
            {
                category = "war",
                type = "buff4",
            },
            {
                category = "war",
                type = "buff5",
            },
            {
                category = "war",
                type = "buff6",
            },
            {
                category = "war",
                type = "buff7",
            },
            {
                category = "war",
                type = "buff8",
            },
            {
                category = "war",
                type = "buff9",
            }
        }
        ,content)
end
function GameUIBuff:CreateItem(title,title_color)
    local list = self.list
    local item = list:newItem()
    local item_width,item_height = 568,650
    item:setItemSize(item_width,item_height)
    local content = WidgetBackGroundWithInnerTitle.new(650,title,title_color)
    item:addContent(content)
    list:addItem(item)
    return content
end
function GameUIBuff:InitBuffs(buffs,container)
    local total_width = 568
    local edge_distance = 19
    local buff_width ,buff_height= 136,190
    local margin_x = (total_width - 2*edge_distance - 3*buff_width)/2
    local origin_x = edge_distance + buff_width/2
    local origin_y = 510
    local gap_y = buff_height + 10
    for i,v in ipairs(buffs) do
        WidgetBuffBox.new({
            buff_category = v.category,
            buff_type = v.type,
        }):addTo(container)
            :align(display.CENTER,origin_x + ((i-1)%3)*(margin_x+buff_width),origin_y - math.floor((i-1)/3)*gap_y)
            :SetInfo("未解锁")
    end
end

function GameUIBuff:OpenActiveVIP()
    local layer = WidgetPopDialog.new(350,_("激活增益效果"),display.top-240):addToCurrentScene()
    local body = layer:GetBody()

    local rb_size = body:getContentSize()
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("如果当前VIP已被激活，使用激活VIP道具提供的时间将会自动叠加"),
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(500,100),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER_TOP, body:getContentSize().width/2, body:getContentSize().height-40)
        :addTo(body)
    self:CreateVIPItem({
        value = "9999",
        gem = true,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = BUY_AND_USE,
        listener = function (  )
            print("BUY_AND_USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-260)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-390)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-520)
end
function GameUIBuff:onExit()
    GameUIBuff.super.onExit(self)
end

return GameUIBuff





