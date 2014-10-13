local window = import("..utils.window")
local AllianceLayer = import("..layers.AllianceLayer")
local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local WidgetPushButton = import("..widget.WidgetPushButton")
local AllianceScene = class("AllianceScene", function()
    return display.newScene("AllianceScene")
end)

function AllianceScene:ctor()
    self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
end
function AllianceScene:onEnter()
    

    self.alliance_layer = self:CreateSceneLayer()
    self.touch_layer = self:CreateMultiTouchLayer()

    local button = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"}
        ,{scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.cx, window.cy)
        :onButtonClicked(function()
            app:enterScene("CityScene")
        end)
end
function AllianceScene:onExit()
    City:ResetAllListeners()
end

function AllianceScene:CreateSceneLayer()
    local scene = AllianceLayer.new()
    :addTo(self, 0, 1)
    :ZoomTo(0.7)
    return scene
end
function AllianceScene:CreateMultiTouchLayer()
    local touch_layer = display.newLayer():addTo(self)
    touch_layer:setTouchEnabled(true)
    touch_layer:setTouchSwallowEnabled(true)
    touch_layer:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    self.handle = touch_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.event_manager:OnEvent(event)
        return true
    end)
    return touch_layer
end


function AllianceScene:OnOneTouch(pre_x, pre_y, x, y, touch_type)
    self:OneTouch(pre_x, pre_y, x, y, touch_type)
end
function AllianceScene:OneTouch(pre_x, pre_y, x, y, touch_type)
    if touch_type == "began" then
        self.touch_judgment:OnTouchBegan(pre_x, pre_y, x, y)
        return true
    elseif touch_type == "moved" then
        self.touch_judgment:OnTouchMove(pre_x, pre_y, x, y)
    elseif touch_type == "ended" then
        self.touch_judgment:OnTouchEnd(pre_x, pre_y, x, y)
    elseif touch_type == "cancelled" then
        self.touch_judgment:OnTouchCancelled(pre_x, pre_y, x, y)
    end
end
function AllianceScene:OnTwoTouch(x1, y1, x2, y2, event_type)
    local scene = self.alliance_layer
    if event_type == "began" then
        self.distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBegin()
    elseif event_type == "moved" then
        local new_distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBy(new_distance / self.distance)
        if scene:getScale() < 0.5 then
            self.scene_ui_layer:HideLevelUpNode()
        else
            self.scene_ui_layer:ShowLevelUpNode()
        end
    elseif event_type == "ended" then
        scene:ZoomEnd()
        self.distance = nil
    end
end
-- TouchJudgment
function AllianceScene:OnTouchBegan(pre_x, pre_y, x, y)
end
function AllianceScene:OnTouchEnd(pre_x, pre_y, x, y)
end
function AllianceScene:OnTouchCancelled(pre_x, pre_y, x, y)
end
function AllianceScene:OnTouchMove(pre_x, pre_y, x, y)
    if self.distance then return end
    local parent = self.alliance_layer:getParent()
    local old_point = parent:convertToNodeSpace(cc.p(pre_x, pre_y))
    local new_point = parent:convertToNodeSpace(cc.p(x, y))
    local old_x, old_y = self.alliance_layer:getPosition()
    local diffX = new_point.x - old_point.x
    local diffY = new_point.y - old_point.y
    self.alliance_layer:setPosition(cc.p(old_x + diffX, old_y + diffY))
end
function AllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
    
end
function AllianceScene:OnTouchExtend(old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond)
    local parent = self.alliance_layer:getParent()
    local speed = parent:convertToNodeSpace(cc.p(new_speed_x, new_speed_y))
    local x, y  = self.alliance_layer:getPosition()
    local max_speed = 5
    speed.x = speed.x > max_speed and max_speed or speed.x
    speed.y = speed.y > max_speed and max_speed or speed.y
    local sp = self:convertToNodeSpace(cc.p(speed.x * millisecond, speed.y * millisecond))
    self.alliance_layer:setPosition(cc.p(x + sp.x, y + sp.y))
end

return AllianceScene































