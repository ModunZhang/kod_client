
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local window = import("..utils.window")

local GameUIAllianceWorld = class("GameUIAllianceWorld", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function GameUIAllianceWorld:ctor()
    self:setNodeEventEnabled(true)
    self.body = self:CreateBackGroundWithTitle()
        :align(display.CENTER, window.cx, window.top -500)
        :addTo(self)
    local map = display.newSprite("allianceHome/world_map.jpg"):scale(1.8)
    local scrollView = UIScrollView.new({
    	viewRect = cc.rect(0,0,556,541),
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        })
        :addScrollNode(map)
        -- :setBounceable(false)
        :setDirection(UIScrollView.DIRECTION_BOTH)
        :align(display.TOP_CENTER,26, self.body:getContentSize().height-569)
        :addTo(self.body)
    local bg1 = WidgetUIBackGround.new({
        width = 572,
        height = 557,
        top_img = "back_ground_580x12_top.png",
        bottom_img = "back_ground_580X12_bottom.png",
        mid_img = "back_ground_580X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    }):align(display.TOP_CENTER,304, self.body:getContentSize().height-20):addTo(self.body)
    -- 介绍
    local info_bg = WidgetUIBackGround.new({
        width = 568,
        height = 200,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.BOTTOM_CENTER,304, 90):addTo(self.body)
    local info_message = {
        {_("统治联盟"),"Kingdoms of Dragon"},
        {_("国王"),"孙悟空"},
        {_("开服时间"),"1 month 13 days"},
        {_("人口密度"),"Low"},
    }
    self.info_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(9, 10, 550, 180),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(info_bg)
    self:CreateInfoItem(info_message)
    -- 迁移按钮
    WidgetPushButton.new({normal = "blue_btn_up_142x39.png",pressed = "blue_btn_down_142x39.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("迁移"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, 100, 50):addTo(self.body)
    -- 首都按钮
    WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("首都"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, 508, 50):addTo(self.body)
end
function GameUIAllianceWorld:CreateInfoItem(info_message)
    local meetFlag = true

    local item_width, item_height = 550,46
    for k,v in pairs(info_message) do
        local item = self.info_listview:newItem()
        item:setItemSize(item_width, item_height)
        local content
        if meetFlag then
            content = display.newSprite("upgrade_resources_background_3.png"):scale(550/520)
        else
            content = display.newSprite("upgrade_resources_background_2.png"):scale(550/520)
        end
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x5d563f,
        }):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
        UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER, 510, item_height/2):addTo(content)
        meetFlag =  not meetFlag
        item:addContent(content)
        self.info_listview:addItem(item)
    end
    self.info_listview:reload()
end

function GameUIAllianceWorld:onEnter()
end

function GameUIAllianceWorld:onExit()
    UIKit:getRegistry().removeObject(self.__cname)
end

function GameUIAllianceWorld:CreateBackGroundWithTitle(  )
    local body = WidgetUIBackGround.new({height=880}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = _("世界地图"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    self.close_btn:addChild(display.newSprite("X_3.png"))
    return body
end

function GameUIAllianceWorld:addToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end

return GameUIAllianceWorld


