local WidgetChat = import("..widget.WidgetChat")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local WidgetHomeBottom = import("..widget.WidgetHomeBottom")
local GameUIAllianceHomeNew = UIKit:createUIClass('GameUIAllianceHomeNew')



function GameUIAllianceHomeNew:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIAllianceHomeNew:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIAllianceHomeNew:FadeToSelf(isFullDisplay)
    self:stopAllActions()
    if isFullDisplay then
        self:show()
        transition.fadeIn(self, {
            time = 0.2,
        })
    else
        transition.fadeOut(self, {
            time = 0.2,
            onComplete = function()
                self:hide()
            end,
        })
    end
end
function GameUIAllianceHomeNew:IsDisplayOn()
    return self.visible_count > 0
end

function GameUIAllianceHomeNew:ctor(city)
    GameUIAllianceHomeNew.super.ctor(self)
    self.city = city
end

function GameUIAllianceHomeNew:onEnter()
    GameUIAllianceHomeNew.super.onEnter(self)
    self.visible_count = 1
    self.bottom = self:CreateBottom()
    WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end
function GameUIAllianceHomeNew:CreateBottom()
    local bottom_bg = WidgetHomeBottom.new(self.city):addTo(self)
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
    self.chat = WidgetChat.new():addTo(bottom_bg)
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-11)
    return bottom_bg
end
function GameUIAllianceHomeNew:ChangeChatChannel(channel_index)
    self.chat:ChangeChannel(channel_index)
end

return GameUIAllianceHomeNew
