local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPVEDialog = class("WidgetPVEDialog", WidgetPopDialog)


function WidgetPVEDialog:ctor(x, y, user)
    self.x = x
    self.y = y
    self.user = user
    self.pve_map = user:GetCurrentPVEMap()
    self.object = self.pve_map:GetObject(x, y)
    WidgetPVEDialog.super.ctor(self, 250, self:GetTitle(), display.cy + 150)
    self.dialog = display.newNode():addTo(self:GetBody())
    self.pve_map:AddObserver(self)
end
function WidgetPVEDialog:onEnter()
    WidgetPVEDialog.super.onEnter(self)
    self:Refresh()
end
function WidgetPVEDialog:onExit()
    WidgetPVEDialog.super.onExit(self)
    self.pve_map:RemoveObserver(self)
end
function WidgetPVEDialog:GetCurrentUser()
    return self.user
end
function WidgetPVEDialog:GetPVEMap()
    return self.pve_map
end
function WidgetPVEDialog:GetObject()
    return self.object
end
function WidgetPVEDialog:OnObjectChanged(object)
    local x, y = object:Position()
    if self.x == x and self.y == y then
        self:Refresh()
    end
end
function WidgetPVEDialog:Refresh()
    self.dialog:removeAllChildren()
    local size = self:GetBody():getContentSize()
    local w,h = size.width, size.height
    local dialog = self.dialog
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 50, h*0.5 + 20)
        :addTo(dialog):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 50 + 133, h*0.5 + 20)
        :addTo(dialog)
    display.newSprite(self:GetIcon()):addTo(dialog):pos(50 + 133 * 0.5, h*0.5 + 20)

    --
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(dialog):pos(50 + 133 * 0.5, h*0.5 - 80)
    local size = level_bg:getContentSize()
    UIKit:ttfLabel({
        text = self:GetBrief(),
        size = 20,
        color = 0x514d3e,
    }):addTo(level_bg):align(display.CENTER, size.width/2 , size.height/2)

    --
    UIKit:ttfLabel({
        text = self:GetDesc(),
        size = 18,
        color = 0x797154,
        dimensions = cc.size(300,0)
    }):align(display.LEFT_TOP, 220, h*0.5 + 50):addTo(dialog)

    --
    local param = self:SetUpButtons()
    for i = #param, 1, -1 do
        cc.ui.UIPushButton.new({normal = "btn_138x110.png",pressed = "btn_pressed_138x110.png"})
            :addTo(dialog):pos(w - (#param - i + 0.5) * 138, - 110*0.5 + 10):setButtonLabel(UIKit:ttfLabel({
            text = param[i].label,
            size = 25,
            color = 0xffedae}))
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    if type(param[i].callback) == "function" then
                        cocos_promise.deffer(function()
                            param[i].callback()
                        end)
                    else
                        self:removeFromParent()
                    end
                end
            end)
    end
end
function WidgetPVEDialog:GetIcon()
    return "airship_106x81.png"
end
function WidgetPVEDialog:GetTitle()
    return ""
end
function WidgetPVEDialog:GetBrief()
    if self:GetObject():IsUnSearched() then
        return _('未探索')
    elseif self:GetObject():IsSearched() then
        return _("已探索")
    else
        return string.format("%s%d%s", _("还剩"), self:GetObject():Left(), _("层"))
    end
end
function WidgetPVEDialog:GetDesc()
    return ""
end
function WidgetPVEDialog:SetUpButtons()
    return { { label = _("离开") } }
end
function WidgetPVEDialog:UseStrength(num)
    local user = self:GetCurrentUser()
    local strength_resource = user:GetStrengthResource()
    local strength = strength_resource:GetResourceValueByCurrentTime(app.timer:GetServerTime())
    if strength < num then return end
    strength_resource:ReduceResourceByCurrentTime(app.timer:GetServerTime(), 3)
    user:OnResourceChanged()
    return true
end
function WidgetPVEDialog:AddStrength(num)
    local user = self:GetCurrentUser()
    user:GetStrengthResource():AddResourceByCurrentTime(app.timer:GetServerTime(), num)
    user:OnResourceChanged()
    return true
end
function WidgetPVEDialog:Search()
    local x, y = self:GetObject():Position()
    local searched = self:GetObject():Searched()
    self:GetPVEMap():ModifyObject(x, y, searched + 1)
    self:GetPVEMap():GetDatabase():Dump()
end



return WidgetPVEDialog






