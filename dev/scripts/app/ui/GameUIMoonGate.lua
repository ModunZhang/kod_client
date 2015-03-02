--
-- Author: Kenny Dai
-- Date: 2015-01-14 20:59:24
--
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetInfo = import("..widget.WidgetInfo")
local UIScrollView = import(".UIScrollView")
local img_dir = "allianceHome/"

local GameUIMoonGate = UIKit:createUIClass('GameUIMoonGate', "GameUIWithCommonHeader")

function GameUIMoonGate:ctor(city,default_tab,building)
    GameUIMoonGate.super.ctor(self, city, _("联盟月门"))
    self.building = building
end

function GameUIMoonGate:onEnter()
    GameUIMoonGate.super.onEnter(self)
    self:InitKingCity()
end

function GameUIMoonGate:InitKingCity()
    local layer = self

    local map = display.newSprite(img_dir.."world_map.jpg"):align(display.CENTER, 610/2, 630/2)

    -- local button = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
    --     :setButtonLabel(UIKit:ttfLabel({
    --         text = "xxxx",
    --         size = 20,
    --         color = 0xffedae,
    --     }))
    --     :onButtonClicked(function(event)
    --         if event.name == "CLICKED_EVENT" then
    --         end
    --     end)
    --     :align(display.CENTER, 0,0)
    --     :addTo(map)
    local scrollView = UIScrollView.new({
        viewRect = cc.rect(0,0,610,630),
    })
        :addScrollNode(map)
        :setBounceable(false)
        :setDirection(UIScrollView.DIRECTION_BOTH)
        :align(display.CENTER,window.left+16,window.top_bottom-610)
        :addTo(self)
    local line = display.newSprite("box_620x628.png"):align(display.TOP_CENTER, window.cx, window.top_bottom+20)
        :addTo(layer)
    local shadowLayer = UIKit:shadowLayer():addTo(layer)
        :align(display.CENTER, window.left+15, window.bottom + 263)
    shadowLayer:setContentSize(cc.size(620,34))
    UIKit:ttfLabel({
        text = _("王城争霸 未开启"),
        size = 22,
        color = 0xebdba0
    }):addTo(shadowLayer):align(display.CENTER,620/2,17)
    display.newSprite("i_icon_24x24.png"):align(display.CENTER, 580, 17)
        :addTo(shadowLayer)
    
    local line = display.newSprite("line_624x58.png"):align(display.CENTER, window.cx, window.bottom + 248)
        :addTo(layer)

    WidgetInfo.new({
        info={
            {_("开战呢王城"),_("未知")},
            {_("当前占领者"),_("未知")},
            {_("地形"),_("未知")},
        },
        w = 546
    }):align(display.BOTTOM_CENTER, window.cx, window.bottom + 90)
        :addTo(layer)
    WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(layer)
        :align(display.CENTER, window.cx, window.bottom + 54)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("定位"),
            size = 24,
            color = 0xfff3c7
        }))
        :setButtonEnabled(false)
end


function GameUIMoonGate:onExit()
    GameUIMoonGate.super.onExit(self)
end

return GameUIMoonGate



