local GameUIFteAcademy = UIKit:createUIClass('GameUIFteAcademy',"GameUIAcademy")


function GameUIFteAcademy:ctor(...)
    GameUIFteAcademy.super.ctor(self, ...)
    self.__type  = UIKit.UITYPE.BACKGROUND
end

--fte
local mockData = import("..fte.mockData")
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function GameUIFteAcademy:Find()
    local t
    self.city:IteratorTechs(function(index,tech)
        if tech:Name() == "forestation" then
            t = tech
        end
    end)
    return self:GetItem(t)
end
function GameUIFteAcademy:PromiseOfFte()
    self.scrollView:getScrollNode():setTouchEnabled(false)
    self.scrollView.touchNode_:setTouchEnabled(false)
    self:Find():setTouchSwallowEnabled(true)
    
    self:GetFteLayer():SetTouchObject(self:Find())
    local r = self:Find():getCascadeBoundingBox()
    local arrow = WidgetFteArrow.new(_("查看详情")):addTo(self:GetFteLayer()):TurnRight()
        :align(display.RIGHT_CENTER, r.x - 10, r.y + r.height/2)


    -- return self:PromsieOfExit("GameUIFteAcademy")
end


return GameUIFteAcademy


