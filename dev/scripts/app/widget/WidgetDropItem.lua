local Enum = import("..utils.Enum")
local ClipHeight = 188
local Animate_Time_Inteval = 0.1
local WidgetDropItem = class("WidgetDropItem",function()
    return display.newNode()
end)

WidgetDropItem.STATE = Enum("open","close")

function WidgetDropItem:ctor(params, callback)
    self.params = params
    self.state_ = self.STATE.close
    self.callback = callback
    self:onEnter()
end

function WidgetDropItem:onEnter()
    local header = display.newSprite("drop_down_box_content_562x58.png"):align(display.LEFT_BOTTOM,2,0):addTo(self)
    self.header = header
    local button = cc.ui.UIPushButton.new({normal = "drop_down_box_button_normal_52x44.png",pressed = "drop_down_box_button_light_52x44.png"})
        :align(display.RIGHT_BOTTOM, 554,7):addTo(header)
        :onButtonClicked(handler(self, self.OnBoxButtonClicked))
    self.arrow = display.newSprite("drop_down_box_icon_3128.png"):addTo(button):pos(-26,22)
    self.title_label = UIKit:ttfLabel({
        text = self.params.title,
        size = 20,
        color = 0x5d563f
    }):align(display.LEFT_CENTER, 20, 29):addTo(header)
end


function WidgetDropItem:GetState()
    return self.state_
end

function WidgetDropItem:OnBoxButtonClicked( event )
    if self.lock_ then return end
    self.lock_ = true
    if self:GetState() == self.STATE.close then
        self:OnOpen()
    else
        self:OnClose()
    end
end
function WidgetDropItem:OnClose()
    self.content_box:removeFromParent()
    self.content_box = nil
    self.state_ = self.STATE.close
    self.lock_ = false
    self.arrow:flipY(false)
    if type(self.callback) == "function" then
        self.callback(nil, true)
    end
end
function WidgetDropItem:OnOpen(ani)
    self.state_ = self.STATE.open
    self.lock_ = false
    self.arrow:flipY(true)
    if type(self.callback) == "function" then
        self.callback(self:GetContent(), ani == nil and true or ani)
    end
end
function WidgetDropItem:GetContent()
    if not self.content_box then
        self.content_box = display.newScale9Sprite("drop_down_box_bg_572x304.png"):align(display.CENTER_TOP):addTo(self, -1)
    end
    return self.content_box
end

function WidgetDropItem:align(anchorPoint, x, y)
    display.align(self,anchorPoint,x,y)
    local anchorPoint = display.ANCHOR_POINTS[anchorPoint]
    local header = self.header
    local size = header:getContentSize()
    local header_anchorPoint = header:getAnchorPoint()
    header:setPosition(header:getPositionX()+size.width*(header_anchorPoint.x - anchorPoint.x),header:getPositionY()+size.height*(header_anchorPoint.y - anchorPoint.y))
    return self
end

return WidgetDropItem





