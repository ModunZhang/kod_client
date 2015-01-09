local WidgetPushButton = import(".WidgetPushButton")
local WidgetPopDialog = import(".WidgetPopDialog")
local UILib = import("..ui.UILib")

local BUY_AND_USE = 1
local USE = 2
local boxes = {
    city ={"box_buff_1.png","box_buff_1.png"},
    war ={"box_buff_2.png","box_buff_2.png"},
}
local WidgetBuffBox = class("WidgetBuffBox", function ()
    return display.newNode()
end)

function WidgetBuffBox:ctor(params)
    local width,height = 136,190
    self:setContentSize(cc.size(width,height))
    local buff_btn = WidgetPushButton.new(
        {normal = boxes[params.buff_category][1],pressed = boxes[params.buff_category][2]})
        :addTo(self)
        :align(display.CENTER, width/2, height/2+15)
        :onButtonClicked(function ( event )
            self:OpenActiveBuff()
        end)
    -- local layer = UIKit:shadowLayer():addTo(self)
    -- layer:setContentSize(cc.size(width,height))
    -- buff icon
    local buff_icon = display.newSprite(UILib.buff[params.buff_type])
        :align(display.CENTER,0,12)
        :addTo(buff_btn)
    buff_icon:scale(102/math.max(buff_icon:getContentSize().width,buff_icon:getContentSize().height))
    -- 信息框
    local info_bg = display.newSprite("back_ground_130x30.png")
        :align(display.CENTER, width/2, 15)
        :addTo(self)
    self.info_label = UIKit:ttfLabel(
        {
            text = "",
            size = 20,
            color = 0x403c2f
        }):align(display.CENTER, info_bg:getContentSize().width/2 ,info_bg:getContentSize().height/2)
        :addTo(info_bg)
end
function WidgetBuffBox:SetInfo(info,color)
    self.info_label:setString(info)
    if color then
        self.info_label:setColor(color)
    end
    return self
end

function WidgetBuffBox:OpenActiveBuff()
    local layer = WidgetPopDialog.new(350,_("激活增益效果"),display.top-240):addToCurrentScene()
    local body = layer:GetBody()

    local rb_size = body:getContentSize()
    
    local bar = display.newSprite("progress_bar_562x40_1.png"):addTo(body):align(display.CENTER, body:getContentSize().width/2, body:getContentSize().height-40)
	local progressTimer = UIKit:commonProgressTimer("progress_bar_562x40_2.png"):addTo(bar):align(display.CENTER, bar:getContentSize().width/2, bar:getContentSize().height/2)
	progressTimer:setPercentage(100)

	 -- 进度条头图标
    display.newSprite("progress_bg_head_43x43.png"):addTo(bar):pos(11, 20)
    display.newSprite("hourglass_39x46.png"):addTo(bar):pos(11, 20)
    -- time label
    local time_label = UIKit:ttfLabel(
        {
            text = _("00:25:32"),
            size = 22,
            color = 0xfff3c7,
            shadow = true
        }):align(display.LEFT_CENTER, 40, bar:getContentSize().height/2)
        :addTo(bar)
     UIKit:ttfLabel(
        {
            text = _("已激活"),
            size = 22,
            color = 0xfff3c7
        }):align(display.CENTER_RIGHT, bar:getContentSize().width-20, bar:getContentSize().height/2)
        :addTo(bar)

    UIKit:ttfLabel(
        {
            text = _("未激活"),
            size = 22,
            color = 0x403c2f
        }):align(display.CENTER_TOP, body:getContentSize().width/2, body:getContentSize().height-20)
        :addTo(body)
        :hide()
    self:CreateBuffItem({
        value = "9999",
        gem = true,
        first_label = _("体力强化药剂 1DAY"),
        second_label = _("使用后有一定20%几率降低龙50活力"),
        btn_type = BUY_AND_USE,
        listener = function (  )
            print("BUY_AND_USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-200)
    self:CreateBuffItem({
        value = "OWN 2",
        gem = false,
        first_label = _("体力强化药剂 7DAY"),
        second_label = _("使用后有一定20%几率降低龙50活力"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-340)

end
function WidgetBuffBox:CreateBuffItem(params)
    local body = display.newColorLayer(cc.c4b(0,0,0,0))
    body:setContentSize(cc.size(580,138))
    local prop_bg = display.newSprite("box_136x138.png"):align(display.LEFT_BOTTOM, 0,0):addTo(body)
    local prop_icon = display.newSprite("buff_tool.png")
        :align(display.CENTER, prop_bg:getContentSize().width/2,prop_bg:getContentSize().height/2)
        :addTo(prop_bg)
    prop_icon:scale(100/math.max(prop_icon:getContentSize().width,prop_icon:getContentSize().height))
    local num_bg = display.newSprite("vip_bg_2.png")
        :align(display.BOTTOM_CENTER, prop_bg:getContentSize().width/2,6)
        :addTo(prop_bg)
    local num_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0xffedae)
        })
        :addTo(num_bg)
    if params.gem then
        local gem_icon = display.newSprite("home/gem_1.png"):align(display.RIGHT_CENTER, 42,num_bg:getContentSize().height/2):addTo(num_bg):scale(0.5)
        num_label:align(display.LEFT_CENTER, 45, num_bg:getContentSize().height/2)
    else
        num_label:align(display.CENTER, num_bg:getContentSize().width/2, num_bg:getContentSize().height/2)
    end

    local des_bg = display.newSprite("vip_bg_3.png"):align(display.LEFT_BOTTOM, 126,6):addTo(body)

    local eff_label_1 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.first_label,
            font = UIKit:getFontFilePath(),
            size = 24,
            color = UIKit:hex2c3b(0x514d3e)
        }):align(display.LEFT_CENTER,140, 100)
        :addTo(body)
    local eff_label_2 = UIKit:ttfLabel(
        {
            text = params.second_label,
            size = 20,
            color = 0x797154,
            dimensions = cc.size(260,0)
        }):align(display.LEFT_TOP,140, 70)
        :addTo(body)
    local button_label_str,normal_img,pressed_img
    if params.btn_type == BUY_AND_USE then
        button_label_str,normal_img,pressed_img = _("购买使用"),"green_btn_up_148x58.png","green_btn_down_148x58.png"
    else
        button_label_str,normal_img,pressed_img = _("使用"),"yellow_btn_up_148x58.png","yellow_btn_down_148x58.png"
    end
    local button_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = button_label_str,
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    button_label:enableShadow()
    local button = WidgetPushButton.new(
        {normal = normal_img, pressed = pressed_img},
        {scale9 = false}
    ):setButtonLabel(button_label)
        :addTo(body):align(display.CENTER, 500,40)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                params.listener()
            end
        end)

    return body
end
return WidgetBuffBox




