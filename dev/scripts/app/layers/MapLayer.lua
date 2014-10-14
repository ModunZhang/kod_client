local MapLayer = class("MapLayer", function(...)
    local layer = display.newLayer()
    layer:setAnchorPoint(0, 0)
    return layer
end)

----
function MapLayer:ctor(min_scale, max_scale)
    self.min_scale = min_scale
    self.max_scale = max_scale
end
------zoom
function MapLayer:ZoomBegin()
    self.scale_point = self:convertToNodeSpace(cc.p(display.cx, display.cy))
    self.scale_current = self:getScale()
end
function MapLayer:ZoomTo(scale)
    self:ZoomBegin()
    self:ZoomBy(scale / self:getScale())
    self:ZoomEnd()
end
function MapLayer:ZoomBy(scale)
    self:setScale(math.min(math.max(self.scale_current * scale, self.min_scale), self.max_scale))
    local scene_point = self:getParent():convertToWorldSpace(cc.p(display.cx, display.cy))
    local world_point = self:convertToWorldSpace(cc.p(self.scale_point.x, self.scale_point.y))
    local new_scene_point = self:getParent():convertToNodeSpace(world_point)
    local cur_x, cur_y = self:getPosition()
    local new_position = cc.p(cur_x + scene_point.x - new_scene_point.x, cur_y + scene_point.y - new_scene_point.y)
    self:setPosition(new_position)
end
function MapLayer:ZoomEnd()
    self.scale_point = nil
    self.scale_current = self:getScale()
end

-------
function MapLayer:setPosition(position)
    local x, y = position.x, position.y
    local parent_node = self:getParent()
    local super = getmetatable(self)
    super.setPosition(self, position)
    local left_bottom_pos = self:GetLeftBottomPositionWithConstrain(x, y)
    local right_top_pos = self:GetRightTopPositionWithConstrain(x, y)
    local rx = x >= 0 and math.min(left_bottom_pos.x, right_top_pos.x) or math.max(left_bottom_pos.x, right_top_pos.x)
    local ry = y >= 0 and math.min(left_bottom_pos.y, right_top_pos.y) or math.max(left_bottom_pos.y, right_top_pos.y)
    super.setPosition(self, cc.p(rx, ry))
    self:OnSceneMove()
end
function MapLayer:GetLeftBottomPositionWithConstrain(x, y)
    assert(false, "你应该在子类实现这个函数 GetLeftBottomPositionWithConstrain")
end
function MapLayer:GetRightTopPositionWithConstrain(x, y)
    assert(false, "你应该在子类实现这个函数 GetLeftBottomPositionWithConstrain")
end
function MapLayer:getContentWidthAndHeight()
    assert(false, "你应该在子类实现这个函数 GetLeftBottomPositionWithConstrain")
end
function MapLayer:getContentSize()
    assert(false, "你应该在子类实现这个函数 GetLeftBottomPositionWithConstrain")
end
function MapLayer:OnSceneMove()

end

return MapLayer














