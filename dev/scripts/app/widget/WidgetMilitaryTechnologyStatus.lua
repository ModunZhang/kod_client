--
-- Author: Kenny Dai
-- Date: 2015-01-19 08:58:38
--

local WidgetProgress = import(".WidgetProgress")
local WidgetPushButton = import(".WidgetPushButton")

local WidgetMilitaryTechnologyStatus = class("WidgetMilitaryTechnologyStatus", function ()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    node:setContentSize(cc.size(556,106))
    return node
end)

function WidgetMilitaryTechnologyStatus:ctor()
    local width , height = 556,106
    -- 描述
    self.top_bg = display.newScale9Sprite("back_ground_398x97.png", 0, 0,cc.size(556,106),cc.rect(15,10,368,77))
        :addTo(self)
    local top_bg = self.top_bg

    self.normal_node = self:CreateNormalStatus()
    self.upgrading_node = self:CreateUpgradingStatus()
   self.upgrading_node:SetUpgradeTip("正在研发兵种科技")
    self:RefreshTop()
end
function WidgetMilitaryTechnologyStatus:CreateNormalStatus()
	local normal_node = display.newNode()
    normal_node:setContentSize(cc.size(556,106))
    normal_node:addTo(self):align(display.CENTER)
    UIKit:ttfLabel({
        text = _("研发队列空闲"),
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, normal_node:getContentSize().width/2,normal_node:getContentSize().height/2+20)
        :addTo(normal_node)
    UIKit:ttfLabel({
        text = _("请选择一个科技进行研发"),
        size = 20,
        color = 0x797154
    }):align(display.CENTER, normal_node:getContentSize().width/2,normal_node:getContentSize().height/2-20)
        :addTo(normal_node)
    return normal_node
end
function WidgetMilitaryTechnologyStatus:CreateUpgradingStatus()
	local upgrading_node = display.newNode()
    upgrading_node:setContentSize(cc.size(556,106))
    upgrading_node:addTo(self):align(display.CENTER)
     --进度条
    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), nil, nil, {
        icon_bg = "progress_bg_head_43x43.png",
        icon = "hourglass_39x46.png",
        bar_pos = {x = 0,y = 0}
    }):addTo(upgrading_node)
        :align(display.LEFT_CENTER, 34, 36)

    local upgrading_tip = UIKit:ttfLabel({
        size = 22,
        color = 0x403c2f
    }):align(display.LEFT_CENTER, 30,80)
        :addTo(upgrading_node)

    local speed_up_btn = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
            :setButtonLabel(UIKit:ttfLabel({
                text = _("加速"),
                size = 22,
                color = 0xffedae,
                shadow= true
            }))
            :align(display.CENTER, 474, 44):addTo(upgrading_node)

    function upgrading_node:SetProgressInfo(time_label, percent)
    	progress:SetProgressInfo(time_label, percent)
    end
    function upgrading_node:SetUpgradeTip(tip)
    	upgrading_tip:setString(tip)
    end
    function upgrading_node:OnSpeedUpClicked(func)
    	speed_up_btn:onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    func()
                end
            end)
    end
    return upgrading_node
end
function WidgetMilitaryTechnologyStatus:RefreshTop()
    if false then
    else
    	self.normal_node:setVisible(false)

    end
end
function WidgetMilitaryTechnologyStatus:onEnter()
    
end
function WidgetMilitaryTechnologyStatus:onExit()
    
end
return WidgetMilitaryTechnologyStatus