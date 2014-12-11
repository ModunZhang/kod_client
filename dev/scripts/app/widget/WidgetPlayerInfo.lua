local WidgetPushButton = import(".WidgetPushButton")
local window = import("..utils.window")
local WidgetPlayerInfo = class("WidgetPlayerInfo", function ()
    return display.newLayer()
end)
function WidgetPlayerInfo:ctor()
    self:setNodeEventEnabled(true)
    return true
end
function WidgetPlayerInfo:onEnter()
    self:AddPlayerHead()
    self:AddNameBar()
    self:AddExpProgress()
    self:AddPowerAndID()
    self:AddPlayerInfo()
    self:AddMedal()
    self:AddDamnation()
end
function WidgetPlayerInfo:onExit()

end
-- 玩家头像，点击弹出选择新头像弹出框
function WidgetPlayerInfo:AddPlayerHead()
    local head_btn = WidgetPushButton.new(
        {normal = "home/player_bg.png", pressed = "home/player_bg.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:OpenSelectHeadIcon()
        end
    end)
        :addTo(self):align(display.LEFT_TOP, window.left+40, window.top-100)
        
        local vip_level_bg = display.newSprite("playerIcon_default.png"):addTo(head_btn)
        :align(display.CENTER,64,-50)
        :scale(0.8)
    -- vip level
    local vip_level_bg = display.newSprite("home/vip_level_bg.png"):addTo(head_btn)
        :align(display.TOP_CENTER,64,-102)

    UIKit:ttfLabel({
            text = _("VIP ")..88,
            size = 18,
            color = 0xe19319,
            shadow = true
        }):align(display.CENTER,vip_level_bg:getContentSize().width/2,38)
            :addTo(vip_level_bg)
end
-- 选择新头像弹出框
function WidgetPlayerInfo:OpenSelectHeadIcon()

end
-- 玩家姓名，提供更改玩家姓名接口
function WidgetPlayerInfo:AddNameBar()
	local name_bg = display.newSprite("title_blue_430x30.png")
	:align(display.LEFT_CENTER, window.left+176, window.top-120)
	:addTo(self)
	local name_label = UIKit:ttfLabel({
            -- text = DataManager:getUserData().basicInfo.name,
            text = "临时数据-姓名",
            size = 20,
            color = 0xffedae
        }):align(display.LEFT_CENTER,10,name_bg:getContentSize().height/2)
            :addTo(name_bg)
    -- 修改名字按钮
    WidgetPushButton.new(
        {normal = "alliance_notice_icon_26x26.png", pressed = "alliance_notice_icon_26x26.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:ChangeNameDialog()
        end
    end)
        :addTo(name_bg):align(display.RIGHT_CENTER, name_bg:getContentSize().width-30, name_bg:getContentSize().height/2)
end
-- 更改玩家姓名弹出框
function WidgetPlayerInfo:ChangeNameDialog()

end
-- 经验等级进度条
function WidgetPlayerInfo:AddExpProgress()
	--进度条
    local bar = display.newSprite("progress_bar_410x40_1.png"):addTo(self)
    :pos(window.cx, window.top-160)
    local progressFill = display.newSprite("progress_bar_410x40_2.png")
    local pro = cc.ProgressTimer:create(progressFill)
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    pro:setPercentage(30)
end
-- power ID
function WidgetPlayerInfo:AddPowerAndID()

end
-- 玩家信息
function WidgetPlayerInfo:AddPlayerInfo()

end
-- 勋章
function WidgetPlayerInfo:AddMedal()

end
-- 诅咒
function WidgetPlayerInfo:AddDamnation()

end
return WidgetPlayerInfo

