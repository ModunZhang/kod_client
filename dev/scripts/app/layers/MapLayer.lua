local promise = import("..utils.promise")
local MapLayer = class("MapLayer", function(...)
    local layer = display.newLayer()
    layer:setAnchorPoint(0, 0)
    layer:setNodeEventEnabled(true)
    return layer
end)
local SPEED = 10
local min = math.min
local max = math.max
local abs = math.abs
----
function MapLayer:ctor(min_scale, max_scale)
    self.min_scale = min_scale
    self.max_scale = max_scale

    self.target_position = nil
    self.target_scale = nil
    self.move_callbacks = {}
    local node = display.newNode():addTo(self)
    node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        local target_position = self.target_position
        if target_position then
            local x, y, speed = unpack(target_position)
            local scene_mid_point = self:getParent():convertToNodeSpace(cc.p(display.cx, display.cy))
            local new_scene_mid_point = self:ConverToParentPosition(x, y)
            local dx, dy = scene_mid_point.x - new_scene_mid_point.x, scene_mid_point.y - new_scene_mid_point.y
            local normal = cc.pNormalize({x = dx, y = dy})
            local current_x, current_y = self:getPosition()
            local new_x, new_y = current_x + normal.x * speed, current_y + normal.y * speed
            local tx, ty = current_x + dx, current_y + dy
            if (tx - current_x) * (tx - new_x) <= 0 and (ty - current_y) * (ty - new_y) <= 0 then
                self.target_position = nil
                new_x, new_y = tx, ty
                local move_callbacks = self.move_callbacks
                if #move_callbacks > 0 then
                    (table.remove(move_callbacks, 1))()
                end
            end
            self:setPosition(cc.p(new_x, new_y))
        end
        local target_scale = self.target_scale
        if target_scale then
            local start_scale, end_scale = unpack(target_scale)
            local dt = end_scale - start_scale
            local old_scale = self:getScale()
            local newscale = old_scale + 0.01 * (dt > 0 and 1 or -1)
            if (end_scale - newscale) * dt <= 0 then
                self:ZoomTo(end_scale)
                target_scale = nil
            else
                self:ZoomTo(newscale)
            end
        end
    end)
    node:scheduleUpdate()
end
function MapLayer:onEnter()

end
function MapLayer:onExit()

end
function MapLayer:ConverToParentPosition(x, y)
    local world_point = self:convertToWorldSpace(cc.p(x, y))
    return self:getParent():convertToNodeSpace(world_point)
end
function MapLayer:MoveToPosition(map_x, map_y, speed_)
    if map_x and map_y then
        self.target_position = {map_x, map_y, speed_ or SPEED}
    else
        self.target_position = nil
    end
end
function MapLayer:StopMoveAnimation()
    self.target_position = nil
end
function MapLayer:GetLogicMap()
    return nil
end
function MapLayer:PromiseOfMove(map_x, map_y, speed_)
    self.move_callbacks = {}
    local move_callbacks = self.move_callbacks
    assert(#move_callbacks == 0)
    local p = promise.new()
    self:MoveToPosition(map_x, map_y, speed_)
    table.insert(move_callbacks, function()
        p:resolve()
    end)
    return p
end
function MapLayer:StopScaleAnimation()
    self.target_scale = nil
end
function MapLayer:ZoomToByAnimation(scale)
    self.target_scale = { self:getScale(), scale }
end
------zoom
function MapLayer:ZoomBegin()
    self.scale_current = self:getScale()
    return self
end
function MapLayer:ZoomTo(scale, x1, y1, x2, y2)
    self:ZoomBegin()
    self:ZoomBy(scale / self:getScale(), (x1 and x2) and (x1 + x2) * 0.5 or display.cx, (y1 and y2) and (y1 + y2) * 0.5 or display.cy)
    self:ZoomEnd()
    return self
end
function MapLayer:ZoomBy(scale, x, y)
    local scale_point = self:convertToNodeSpace(cc.p(x, y))
    self:setScale(min(max(self.scale_current * scale, self.min_scale), self.max_scale))
    local scene_mid_point = self:getParent():convertToWorldSpace(cc.p(x, y))
    local new_scene_mid_point = self:ConverToParentPosition(scale_point.x, scale_point.y)
    local cur_x, cur_y = self:getPosition()
    local new_position = cc.p(cur_x + scene_mid_point.x - new_scene_mid_point.x, cur_y + scene_mid_point.y - new_scene_mid_point.y)
    self:setPosition(new_position)
    self:OnSceneScale()
    return self
end
function MapLayer:ZoomEnd()
    self.scale_current = self:getScale()
    return self
end
function MapLayer:GetScaleRange()
    return self.min_scale, self.max_scale
end

-------
function MapLayer:GotoMapPositionInMiddle(x, y)
    local scene_mid_point = self:getParent():convertToNodeSpace(cc.p(display.cx, display.cy))
    local new_scene_mid_point = self:ConverToParentPosition(x, y)
    local dx, dy = scene_mid_point.x - new_scene_mid_point.x, scene_mid_point.y - new_scene_mid_point.y
    local current_x, current_y = self:getPosition()
    self:setPosition(cc.p(current_x + dx, current_y + dy))
end
function MapLayer:setPosition(position)
    local x, y = position.x, position.y
    local parent_node = self:getParent()
    local super = getmetatable(self)
    super.setPosition(self, position)
    local left_bottom_pos = self:GetLeftBottomPositionWithConstrain(x, y)
    local right_top_pos = self:GetRightTopPositionWithConstrain(x, y)
    local rx = x >= 0 and min(left_bottom_pos.x, right_top_pos.x) or max(left_bottom_pos.x, right_top_pos.x)
    local ry = y >= 0 and min(left_bottom_pos.y, right_top_pos.y) or max(left_bottom_pos.y, right_top_pos.y)
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
    assert(false, "你应该在子类实现这个函数 getContentSize")
end
function MapLayer:OnSceneMove()

end
function MapLayer:OnSceneScale()

end
return MapLayer






















