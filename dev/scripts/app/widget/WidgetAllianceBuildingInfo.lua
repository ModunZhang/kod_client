local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import("..ui.UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetAllianceBuildingInfo = class("WidgetAllianceBuildingInfo", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function WidgetAllianceBuildingInfo:ctor()
    local body = WidgetUIBackGround.new({height=544}):addTo(self):align(display.TOP_CENTER,display.cx,display.top-150)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height)
        :addTo(body)
    local title_label = UIKit:ttfLabel(
        {
            text = _("建筑详情"),
            size = 22,
            color = 0xffedae
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    WidgetPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-10, title:getContentSize().height-10)
        :addTo(title):addChild(display.newSprite("X_3.png"))
    -- 建筑详情介绍
    UIKit:ttfLabel(
        {
            text = _("联盟的核心建筑，升级可提升联盟人数上限，想占领城市征税，更改联盟地形"),
            size = 20,
            align = cc.ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(360,0),
            color = 0x797154
        }):align(display.TOP_CENTER, rb_size.width/2, rb_size.height-40)
        :addTo(body)

    
    -- 帮助列表
    local info_bg = WidgetUIBackGround.new({
        width = 568,
        height = 382,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,rb_size.width/2, rb_size.height/2-40):addTo(body)
    self.help_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(9, 10, 550, 362),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(info_bg)
end

return WidgetAllianceBuildingInfo

