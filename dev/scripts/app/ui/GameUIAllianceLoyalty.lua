
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")

local GameUIAllianceLoyalty = class("GameUIAllianceLoyalty", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function GameUIAllianceLoyalty:ctor()
    self:setNodeEventEnabled(true)
    self.body = self:CreateBackGroundWithTitle()
        :align(display.CENTER, window.cx, window.top -400)
        :addTo(self)
    local go_shop_btn = WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"})
        :align(display.CENTER,self.body:getContentSize().width/2,60)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local building = Alliance_Manager:GetMyAlliance():GetAllianceMap():FindAllianceBuildingInfoByName("shop")
                UIKit:newGameUI('GameUIAllianceShop',City,"upgrade",building):addToCurrentScene(true)
                self:removeFromParent(true)
            end
        end)
        :setButtonLabel("normal", UIKit:ttfLabel({
            text = _("   前往\n联盟商店"),
            size = 20,
            color = 0xfff3c7,
            shadow = true
        }))
        :addTo(self.body)
    -- 背景框
    local bg = WidgetUIBackGround.new({
        width = 572,
        height = 178,
        top_img = "back_ground_top_2.png",
        bottom_img = "back_ground_bottom_2.png",
        mid_img = "back_ground_mid_2.png",
        u_height = 10,
        b_height = 10,
        m_height = 1,
    }):align(display.TOP_CENTER, self.body:getContentSize().width/2, self.body:getContentSize().height-30)
        :addTo(self.body)
    local tips = {
        _("忠诚值是玩家自己的属性，退出联盟后依然保留"),
        _("忠诚值可以在联盟商店中购买道具"),
        _("向联盟捐赠资源可以增加忠诚值"),
        _("帮助盟友加速科技研发和建筑升级的时间"),
    }
    local  origin_y = 150
    local count = 0
    for _,v in pairs(tips) do
        self:CreateTipItem(v):align(display.CENTER, 20, origin_y - count* 40)
            :addTo(bg)
        count = count + 1
    end
end

function GameUIAllianceLoyalty:CreateTipItem(tip)
    local star = display.newSprite("star_23X23.png")
    UIKit:ttfLabel({
        text = tip,
        size = 18,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 30, star:getContentSize().height/2)
        :addTo(star)
    return star
end
function GameUIAllianceLoyalty:onEnter()
end

function GameUIAllianceLoyalty:onExit()
    UIKit:getRegistry().removeObject(self.__cname)
end

function GameUIAllianceLoyalty:CreateBackGroundWithTitle(  )
    local body = WidgetUIBackGround.new({height=340}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = _("忠诚值"),
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
    return body
end

function GameUIAllianceLoyalty:addToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end

return GameUIAllianceLoyalty
















