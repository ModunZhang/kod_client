local WidgetTab = import(".WidgetTab")
local WidgetEventTabButtons = class("WidgetEventTabButtons", function()
    local rect = cc.rect(0, 0, 491, 150 + 47)
    local node = display.newClippingRegionNode(rect)
    node.view_rect = rect
    node.locked = false
    node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
        if node.locked then
            return false
        end
        if ("began" == event.name or "moved" == event.name or "ended" == event.name)
            and node:isTouchInViewRect(event) then
            return true
        else
            return false
        end
    end)
    return node
end)
function WidgetEventTabButtons:isTouchInViewRect(event)
    local viewRect = self:convertToWorldSpace(cc.p(self.view_rect.x, self.view_rect.y))
    viewRect.width = self.view_rect.width
    viewRect.height = self.view_rect.height
    return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end


------
function WidgetEventTabButtons:ctor()
    self.item_array = {}
    local node = display.newNode():addTo(self)
    display.newLayer():addTo(node):pos(0, -150 + 47):setContentSize(cc.size(491, 150 + 47))
    self.node = node
    self.tab_buttons, self.tab_map = self:CreateTabButtons()
    self.tab_buttons:addTo(node, 2):pos(0, 0)
    self.back_ground = self:CreateBackGround():addTo(node)
    self:Reset()
    self:HighLightTab("build")
    self:InitAnimation()
end
-- 构造ui
function WidgetEventTabButtons:CreateTabButtons()
    local node = display.newNode()
    local icon_map = {
        { "material", "battle_39x38.png" },
        { "technology", "tech_39x38.png" },
        { "soldier", "soldier_39x38.png" },
        { "build", "build_39x38.png" },
    }
    local tab_map = {}
    local unit_width = 111
    local origin_x = unit_width * 4
    for i, v in ipairs(icon_map) do
        local tab_type = v[1]
        local tab_png = v[2]
        tab_map[tab_type] = WidgetTab.new({
            on = "tab_button_down_111x47.png",
            off = "tab_button_up_111x47.png",
            tab = tab_png
        }, unit_width, 47)
            :addTo(node):align(display.LEFT_BOTTOM,origin_x + (i - 5) * unit_width, 0)
            :OnTabPress(handler(self, self.OnTabClicked))
    end
    local btn = cc.ui.UIPushButton.new({normal = "hide_btn_up_48x47.png",
        pressed = "hide_btn_down_48x47.png"}):addTo(node)
        :align(display.LEFT_BOTTOM, 111*4, 0)
        :onButtonClicked(function(event)
            if not self:IsShow() then
                self:Show()
            else
                self:Hide()
            end
        end)
    self.arrow = cc.ui.UIImage.new("hide_18x19.png"):addTo(btn):align(display.CENTER, 48/2, 47/2)
    return node, tab_map
end
function WidgetEventTabButtons:CreateBackGround()
    return cc.ui.UIImage.new("back_ground_491x105.png", {scale9 = true,
        capInsets = cc.rect(10, 10, 491 - 20, 105 - 20)
    }):align(display.LEFT_BOTTOM):setLayoutSize(491, 50)
end
function WidgetEventTabButtons:CreateItem()
    return self:CreateProgressItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateBottom()
    return self:CreateOpenItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateProgressItem()
    local progress = display.newProgressTimer("progress_338x43.png", display.PROGRESS_TIMER_BAR)
    progress:setBarChangeRate(cc.p(1,0))
    progress:setMidpoint(cc.p(0,0))
    progress:setPercentage(100)

    local describe = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("城堡 (等级 2) 00:10:10"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xd1ca95)}):addTo(progress):align(display.LEFT_CENTER, 10, 43/2)

    local btn = cc.ui.UIPushButton.new({normal = "green_btn_up_142x39.png",
        pressed = "green_btn_down_142x39.png"}):addTo(progress)
        :align(display.LEFT_CENTER, 340, 43/2)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            end)

    cc.ui.UIImage.new("divide_line_489x2.png"):addTo(progress)
        :align(display.LEFT_BOTTOM, -4, -5)


    function progress:SetProgressInfo(str, percent)
        if describe:getString() ~= str then
            describe:setString(str)
        end
        self:setPercentage(percent)
        return self
    end
    function progress:OnClicked(func)
        btn:onButtonClicked(func)
        return self
    end

    return progress
end
function WidgetEventTabButtons:CreateOpenItem()
    local node = display.newNode()
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("查看已拥有的建筑"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xd1ca95)}):addTo(node):align(display.LEFT_CENTER, 10, 0)


    cc.ui.UIPushButton.new({normal = "blue_btn_up_142x39.png",
        pressed = "blue_btn_down_142x39.png"}):addTo(node)
        :align(display.LEFT_CENTER, 340, 0)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("打开"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            if not self.item_array[2] then
                self:InsertItemWithAnimation(function()
                    return self:CreateItem():SetProgressInfo("time_label", 50)
                end)
            else
                self:RemoveItemWithAnimation(2)
            end
            end)

    return node
end
-----
function WidgetEventTabButtons:Reset()
    for k, v in pairs(self.item_array) do
        v:removeFromParentAndCleanup(true)
    end
    self.item_array = {}
    self:ResizeBelowHorizon(0)
    self.node:unscheduleUpdate()
    self.node:stopAllActions()
    self:AdapterPosition()
    self:ResetPosition()
    self.arrow:flipY(true)
end
function WidgetEventTabButtons:ResetItemPosition()
    for i, v in ipairs(self.item_array) do
        v:pos(5, (i-1) * 50 + 25)
    end
end
function WidgetEventTabButtons:InitAnimation()
    self.timer = 0
    self.old_heigth = 0
    self.diff_height = 0
    local total_timer = 0.3
    local width = self.back_ground:getContentSize().width
    self.node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        self.timer = self.timer + dt
        if self.timer >= total_timer then
            self.timer = total_timer
            self:OnResizeEnd()
            self:Lock(false)
        end
        local current_height = self.old_heigth + self.diff_height * (self.timer / total_timer)
        self.back_ground:setContentSize(cc.size(width, current_height))

        if self:IsShow() then
            self.tab_buttons:setPositionY(current_height)
        end
    end)
end
function WidgetEventTabButtons:IsInAnimation()
    return self.timer > 0 or self.node:getNumberOfRunningActions() > 0
end


-- 操作
function WidgetEventTabButtons:GetItem(pos)
    return self.item_array[pos]
end
function WidgetEventTabButtons:InsertItemWithAnimation(get_item_func, pos)
    self:ResizeOnHorizonWithAnimation(self:Length(#self.item_array + 1), function()
        self:InsertItem(get_item_func(), pos)
    end)
end
function WidgetEventTabButtons:InsertItem(item, pos)
    item:addTo(self.back_ground, 2)
    if pos then
        table.insert(self.item_array, pos, item)
    else
        table.insert(self.item_array, item)
    end
    self:ResetItemPosition()
end
function WidgetEventTabButtons:RemoveItemWithAnimation(pos)
    self:RemoveItem(pos)
    self:ResizeOnHorizonWithAnimation(self:Length(#self.item_array))
end
function WidgetEventTabButtons:RemoveItem(pos)
    if pos then
        self.item_array[pos]:removeFromParentAndCleanup(true)
        table.remove(self.item_array, pos)
    end
    self:ResetItemPosition()
end




-- 玩家操作动画
function WidgetEventTabButtons:ShowTab(tab)
    self:HighLightTab(tab)
    self:ForceShow()
end
function WidgetEventTabButtons:HighLightTab(tab)
    for k, v in pairs(self.tab_map) do
        if k ~= tab then
            v:Enable(true)
            v:SetStatus(false)
        else
            v:Enable(false)
            v:SetStatus(true)
        end
    end
end
function WidgetEventTabButtons:OnTabClicked(widget, is_pressed)
    assert(is_pressed)
    for _, v in pairs(self.tab_map) do
        if v ~= widget then
            v:Enable(true)
            v:SetStatus(false)
        else
            v:Enable(false)
        end
    end
    self:ForceShow()
end
function WidgetEventTabButtons:ForceShow()
    if self:IsShow() then
        self:Switch()
    else
        self:Show()
    end
end
function WidgetEventTabButtons:Lock(lock)
    self.locked = lock
end
function WidgetEventTabButtons:IsShow()
    return not self.arrow:isFlippedY()
end
function WidgetEventTabButtons:IsHide()
    return self.arrow:isFlippedY()
end
function WidgetEventTabButtons:ResizeOnHorizonWithAnimation(new_height, callback)
    local height = new_height < 50 and 50 or new_height
    self.timer = 0
    self.old_heigth = self.back_ground:getContentSize().height
    self.diff_height = height - self.old_heigth
    self.node:unscheduleUpdate()
    self.node:scheduleUpdate()
    self:Lock(true)
    self.callback = callback
end
function WidgetEventTabButtons:OnResizeEnd()
    self.node:unscheduleUpdate()
    if self.callback then
        self:callback()
        self.callback = nil
    end
end
function WidgetEventTabButtons:ResizeBelowHorizon(new_height)
    local height = new_height < 50 and 50 or new_height
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, height))
    self.node:setPositionY(- height)
    self.tab_buttons:setPositionY(height)
    self:OnResizeEnd()
end
function WidgetEventTabButtons:Length(array_len)
    return array_len * 50
end
function WidgetEventTabButtons:AdapterPosition()
    self.tab_buttons:setPositionY(self.back_ground:getContentSize().height)
end
function WidgetEventTabButtons:ResetPosition()
    self.node:setPositionY(- self.back_ground:getContentSize().height)
end
function WidgetEventTabButtons:Show()
    self.node:stopAllActions()
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, size.height))
    self.tab_buttons:setPositionY(size.height)
    self:Lock(true)
    self:Reload()
    transition.moveTo(self.node,
        {x = 0, y = 0, time = 0.3,
            easing = "sineIn",
            onComplete = function()
                self:OnShowEnd()
            end})
end
function WidgetEventTabButtons:Hide()
    self.node:stopAllActions()
    self:Lock(true)
    transition.moveTo(self.node,
        {x = 0, y = -self.back_ground:getContentSize().height, time = 0.3,
            easing = "sineIn",
            onComplete = function()
                self:OnHideEnd()
            end})
end
function WidgetEventTabButtons:Switch()
    self.node:stopAllActions()
    self:Lock(true)
    transition.moveTo(self.node,
        {x = 0, y = -self.back_ground:getContentSize().height, time = 0.3,
            easing = "sineIn",
            onComplete = function()
                self:OnHideEnd()
                self:Show()
            end})
end
function WidgetEventTabButtons:OnShowEnd()
    self.arrow:flipY(false)
    self:Lock(false)
end
function WidgetEventTabButtons:OnHideEnd()
    self.arrow:flipY(true)
    self:Lock(false)
end
function WidgetEventTabButtons:Reload()
    self:Reset()
    for k, v in pairs(self.tab_map) do
        if v:IsPressed() then
            if k == "build" then
                self:InsertItem(self:CreateBottom())
                self:InsertItem(self:CreateBottom())
                self:ResizeBelowHorizon(self:Length(#self.item_array))
            end
            break
        end
    end
end



return WidgetEventTabButtons































