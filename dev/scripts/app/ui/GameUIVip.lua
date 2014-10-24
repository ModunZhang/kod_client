local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetBackGroundLucid = import("..widget.WidgetBackGroundLucid")
local GameUIVip = UIKit:createUIClass('GameUIVip',"GameUIWithCommonHeader")

function GameUIVip:ctor(city)
    GameUIVip.super.ctor(self,city,_("VIP"))
end

function GameUIVip:CreateBetweenBgAndTitle()
    GameUIVip.super.CreateBetweenBgAndTitle(self)
    self.main_layer = display.newLayer():addTo(self)
end

function GameUIVip:onEnter()
    GameUIVip.super.onEnter(self)
    self:InitVip()
end

function GameUIVip:InitVip()
    self:CreateAD():addTo(self.main_layer):align(display.CENTER_TOP, display.cx - 2, display.top-66)
    local exp_bar = self:CreateVipExpBar():addTo(self.main_layer):pos(display.cx-287, display.top-300)
    exp_bar:LightLevelBar(9,20)
    self:CreateVIPStatus()
end

-- 创建广告框
function GameUIVip:CreateAD()
    return display.newSprite("advertisement.png")
end

-- 创建vip等级经验条
function GameUIVip:CreateVipExpBar()
    local  head_width = 35 -- 两头经验圈宽度
    local  mid_width = 34 -- 中间各个经验圈宽度
    local  level_width = 26 -- 各个等级间的进度条的宽度

    local ExpBar = display.newNode()
    function ExpBar:AddLevelBar(level,bar)
        self.level_bar = self.level_bar or {}
        self.level_bar["level_bar_"..level] = bar
    end

    function ExpBar:AddLevelExpBar(level,exp_bar)
        self.exp_bar = self.exp_bar or {}
        self.exp_bar["exp_bar_"..level] = exp_bar
    end
    function ExpBar:AddLevelImage(level,image)
        self.level_images = self.level_images or {}
        self.level_images["level_image_"..level] = image
    end
    function ExpBar:CreateTip(image,level)
        local tip = display.newSprite(image)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("VIP"..level),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}):addTo(tip):align(display.CENTER, tip:getContentSize().width/2, 50)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("5000"),
            size = 16,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}):addTo(tip):align(display.CENTER, tip:getContentSize().width/2, 25)
        return tip
    end
    --[[
        设置经验条等级
        @param level 达到等级
        @param per 下一级升级当前百分比
    ]]
    function ExpBar:LightLevelBar(level,per)
        for i=1,level do
            self.level_images["level_image_"..i]:setVisible(true)
            self.level_bar["level_bar_"..i]:setVisible(true)
            if self.exp_bar["exp_bar_"..i-1] then
                self.exp_bar["exp_bar_"..i-1]:setPercentage(100)
            end
        end
        if per then
            self.exp_bar["exp_bar_"..level]:setPercentage(per)
        end
        if not self.tip_1 then
            self.tip_1 = self:CreateTip("vip_level_tip_bg_1.png",level):addTo(self):scale(0.9)

            if level<10 then
                self.tip_2 = self:CreateTip("vip_level_tip_bg_2.png",level+1):addTo(self):scale(0.9)
            end
        end
        local x = self.level_bar["level_bar_"..level]:getParent():getPosition()
        -- 由于两头的圈使用的图片宽度为单数，所以锚点都设置在了左边中心而不是中间圈那样的锚点在中心，此时需要tip框中心找到其中心位置
        x = x + ((level == 1 or level == 10) and 17 or 0)
        self.tip_1:align(display.BOTTOM_CENTER, x, 20)
        if level<10 then
            local x = self.level_bar["level_bar_"..level+1]:getParent():getPosition()
            x = x + ((level+1) == 10 and 17 or 0)
            self.tip_2:align(display.BOTTOM_CENTER, x, 20)
        else
            self:removeChild(self.tip_2)
        end
        -- 添加vip经验 指针
        if level<10 then
            x = x + (per and math.floor(level_width*per/100+head_width/2) or 0)
            if not self.vip_exp_point then
                self.vip_exp_point = display.newSprite("vip_point.png"):addTo(self)
                cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = _("99999"),
                    size = 14,
                    font = UIKit:getFontFilePath(),
                    color = UIKit:hex2c3b(0xfdfac2)}):addTo(self.vip_exp_point):align(display.LEFT_CENTER, 24, 10)
            end
            self.vip_exp_point:align(display.TOP_CENTER, x, -20)
        else
            if self.vip_exp_point then
                self:removeChild(self.vip_exp_point)
            end
        end

    end

    local function createProgressTimer()
        local progressFill = display.newSprite("vip_lv_bar_6.png")
        local ProgressTimer = cc.ProgressTimer:create(progressFill)
        ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
        ProgressTimer:setBarChangeRate(cc.p(1,0))
        ProgressTimer:setMidpoint(cc.p(0,0))
        return ProgressTimer
    end
    local current_x = 0
    for i=1,10 do
        local lv_bg
        if i==1 then
            lv_bg = display.newSprite("vip_lv_bar_1.png"):addTo(ExpBar):align(display.LEFT_CENTER, 0, 0)
            ExpBar:AddLevelBar(i,display.newSprite("vip_lv_bar_3.png"):addTo(lv_bg)
                :align(display.CENTER, lv_bg:getContentSize().width/2+3, lv_bg:getContentSize().height/2))
            current_x = current_x + head_width
            local exp = display.newSprite("vip_lv_bar_5.png"):addTo(ExpBar):align(display.CENTER, current_x+level_width/2, 0)
            local ProgressTimer = createProgressTimer():align(display.LEFT_CENTER, 0, exp:getContentSize().height/2):addTo(exp)
            -- ProgressTimer:setPercentage(100)
            ExpBar:AddLevelExpBar(i,ProgressTimer)
            current_x = current_x + level_width
        elseif i>1 and i<10 then
            lv_bg = display.newSprite("vip_lv_bar_2.png"):addTo(ExpBar):align(display.CENTER, current_x+mid_width/2, 0)
            local light = display.newSprite("vip_lv_bar_4.png"):addTo(lv_bg)
                :align(display.CENTER, lv_bg:getContentSize().width/2, lv_bg:getContentSize().height/2)
            light:setVisible(false)
            ExpBar:AddLevelBar(i,light)
            current_x = current_x + mid_width
            local exp = display.newSprite("vip_lv_bar_5.png"):addTo(ExpBar):align(display.CENTER, current_x+level_width/2, 0)
            local ProgressTimer = createProgressTimer():align(display.LEFT_CENTER, 0, exp:getContentSize().height/2):addTo(exp)
            -- ProgressTimer:setPercentage(100)
            ExpBar:AddLevelExpBar(i,ProgressTimer)

            current_x = current_x + level_width
        elseif i==10 then
            lv_bg = display.newSprite("vip_lv_bar_1.png"):addTo(ExpBar):align(display.LEFT_CENTER, current_x, 0)
            lv_bg:setFlippedX(true)
            local light = display.newSprite("vip_lv_bar_3.png"):addTo(lv_bg,1,i)
                :align(display.CENTER, lv_bg:getContentSize().width/2-3, lv_bg:getContentSize().height/2)
            light:setVisible(false)
            ExpBar:AddLevelBar(i,light)
            light:setFlippedX(true)
        end
        local level_image = display.newSprite(i..".png"):addTo(lv_bg,1,i*100)
            :align(display.CENTER, lv_bg:getContentSize().width/2, lv_bg:getContentSize().height/2)
            :scale(0.5)
        level_image:setVisible(false)
        ExpBar:AddLevelImage(i,level_image)
    end

    return ExpBar
end

function GameUIVip:CreateVIPStatus()
    local status_bg = WidgetUIBackGround.new(528):addTo(self.main_layer)
        :align(display.BOTTOM_CENTER, display.cx, display.top-940)
    local bg_size = status_bg:getContentSize()
    -- 透明边框
    WidgetBackGroundLucid.new(320):addTo(status_bg)
        :align(display.TOP_CENTER, bg_size.width/2, bg_size.height-20)

    local title_bg = display.newSprite("vip_title.png"):addTo(status_bg)
        :align(display.BOTTOM_CENTER, bg_size.width/2, bg_size.height-15)
    local title =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("未激活VIP"),
        size = 22,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xffedae)}):addTo(title_bg)
        :align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)
    -- 增加VIP点数按钮
    local increase_vip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("增加VIP点数"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    increase_vip_label:enableShadow()
    WidgetPushButton.new(
        {normal = "yellow_button_highlight_190x46.png", pressed = "yellow_button_190x46.png"},
        {scale9 = false}
    ):setButtonLabel(increase_vip_label)
        :addTo(status_bg):align(display.CENTER, 120, bg_size.height-50)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end)
    -- 激活VIP按钮
    local active_vip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("激活VIP"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    active_vip_label:enableShadow()
    WidgetPushButton.new(
        {normal = "yellow_button_highlight_190x46.png", pressed = "yellow_button_190x46.png"},
        {scale9 = false}
    ):setButtonLabel(active_vip_label)
        :addTo(status_bg):align(display.CENTER, bg_size.width-120, bg_size.height-50)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end)

    -- title
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("状态"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, bg_size.width/2, 150)
        :addTo(status_bg)

    self.current_vip_level = self:CreateDividing({
        width = 594,
        title = _("当前VIP等级"),
        value = _("LV 3"),
        title_color =  UIKit:hex2c3b(0x797154),
        value_color =  UIKit:hex2c3b(0x403c2f),
    }):align(display.CENTER, bg_size.width/2, 100)
        :addTo(status_bg)
    self.next_login = self:CreateDividing({
        width = 594,
        title = _("下一次登录"),
        value = _("+150 VIP 点数"),
        title_color =  UIKit:hex2c3b(0x797154),
        value_color =  UIKit:hex2c3b(0x403c2f),
    }):align(display.CENTER, bg_size.width/2, 60)
        :addTo(status_bg)
    self.current_vip_level = self:CreateDividing({
        width = 594,
        title = _("连续登录"),
        value = _("5天"),
        title_color =  UIKit:hex2c3b(0x797154),
        value_color =  UIKit:hex2c3b(0x403c2f),
    }):align(display.CENTER, bg_size.width/2, 20)
        :addTo(status_bg)
    local vip_button_group = self:CreateVIPButtons(1):addTo(status_bg)
    vip_button_group:pos(bg_size.width/2 - vip_button_group:getContentSize().width/2, 200)
end

function GameUIVip:CreateVIPButtons(level)
    local button_group = display.newLayer()
    button_group:setContentSize(cc.size(560,240))

    local gap_x = 112
    for i=1,10 do
        local button
        if i<=level then
            button = WidgetPushButton.new(
                {normal = "vip_unlock.png", pressed = "vip_unlock.png"},
                {scale9 = false}
            ):addTo(button_group):align(display.LEFT_BOTTOM, (math.mod(i-1,5))*gap_x, 130-math.floor((i-1)/5)*130)
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then

                    end
                end)
        else
            button = WidgetPushButton.new(
                {normal = "vip_lock.png", pressed = "vip_lock.png"},
                {scale9 = false}
            ):addTo(button_group):align(display.LEFT_BOTTOM, (math.mod(i-1,5))*gap_x, 130-math.floor((i-1)/5)*130)
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then

                    end
                end)

        end
        display.newSprite(i..".png"):addTo(button)
            :align(display.CENTER, 56,50)
    end
    return button_group
end

-- 构造分割线显示信息方法
function GameUIVip:CreateDividing(prams)
    -- 分割线
    local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(prams.width,2))

    -- title
    local title = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = prams.title,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = prams.title_color
        }):align(display.LEFT_CENTER, 10, 12)
        :addTo(line)
    -- title value
    local value = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = prams.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = prams.value_color
        }):align(display.RIGHT_CENTER, line:getCascadeBoundingBox().size.width-10, 12)
        :addTo(line)

    function line:SetValue( string )
        value:setString(string)
        return self
    end
    return line
end

return GameUIVip






























