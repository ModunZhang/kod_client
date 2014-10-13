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
    return self
end
function MapLayer:ZoomTo(scale)
    self:ZoomBegin()
    self:ZoomBy(scale / self:getScale())
    self:ZoomEnd()
    return self
end
function MapLayer:ZoomBy(scale)
    self:setScale(math.min(math.max(self.scale_current * scale, self.min_scale), self.max_scale))
    local scene_point = self:getParent():convertToWorldSpace(cc.p(display.cx, display.cy))
    local world_point = self:convertToWorldSpace(cc.p(self.scale_point.x, self.scale_point.y))
    local new_scene_point = self:getParent():convertToNodeSpace(world_point)
    local cur_x, cur_y = self:getPosition()
    local new_position = cc.p(cur_x + scene_point.x - new_scene_point.x, cur_y + scene_point.y - new_scene_point.y)
    self:setPosition(new_position)
    return self
end
function MapLayer:ZoomEnd()
    self.scale_point = nil
    self.scale_current = self:getScale()
    return self
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
    local parent_node = self:getParent()
    local world_position = parent_node:convertToWorldSpace(cc.p(x, y))
    world_position.x = world_position.x > display.left and display.left or world_position.x
    world_position.y = world_position.y > display.bottom and display.bottom or world_position.y
    local left_bottom_pos = parent_node:convertToNodeSpace(world_position)
    return left_bottom_pos
end
function MapLayer:GetRightTopPositionWithConstrain(x, y)
        -- 右上角是否超出
    local parent_node = self:getParent()
    local world_top_right_point = self:convertToWorldSpace(cc.p(self:getContentWidthAndHeight()))
    local scene_top_right_position = parent_node:convertToNodeSpace(world_top_right_point)
    local display_top_right_position = parent_node:convertToNodeSpace(cc.p(display.right, display.top))
    local dx = display_top_right_position.x - scene_top_right_position.x
    local dy = display_top_right_position.y - scene_top_right_position.y
    local right_top_pos = {
        x = scene_top_right_position.x < display_top_right_position.x and x + dx or x,
        y = scene_top_right_position.y < display_top_right_position.y and y + dy or y
    }
    return right_top_pos
end
function MapLayer:getContentWidthAndHeight()
    if not self.content_width or not self.content_height then
        local content_size = self:getContentSize()
        self.content_width, self.content_height = content_size.width, content_size.height
    end
    return self.content_width, self.content_height
end
function MapLayer:getContentSize()
    assert(false, "你应该在子类实现这个函数 GetLeftBottomPositionWithConstrain")
end
function MapLayer:OnSceneMove()

end

return MapLayer















