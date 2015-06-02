--
-- Author: Kenny Dai
-- Date: 2015-06-02 11:22:39
--
local GameUIChest = UIKit:createUIClass("GameUIChest")

function GameUIChest:ctor(item,awards,tips,ani)
    GameUIChest.super.ctor(self)
    self.item = item
    self.awards = awards
    self.tips = tips
    self.ani = ani
end

function GameUIChest:onEnter()
    GameUIChest.super.onEnter(self)
    local box = ccs.Armature:create(self.ani):addTo(self):align(display.CENTER, display.cx-50, display.cy)
        :scale(0.5)
    box:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.start then
        elseif movementType == ccs.MovementEventType.complete then
            GameGlobalUI:showTips(_("获得"),self.tips)
            self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                if event.name == "ended" then
                   self:LeftButtonClicked()
                end
                return true
            end)
        elseif movementType == ccs.MovementEventType.loopComplete then
        end
    end)

    box:getAnimation():play("Animation1", -1, 0)
end

function GameUIChest:onExit()
    GameUIChest.super.onExit(self)
end

return GameUIChest


