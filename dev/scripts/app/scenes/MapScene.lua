local window = import("..utils.window")
local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local MapScene = class("MapScene", function()
    return display.newScene("MapScene")
end)

function MapScene:ctor()
    self.blur_count = 1
    self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
    self.scene_node = display.newClippingRegionNode(cc.rect(0, 0, display.width, display.height)):addTo(self)
    self.scene_node:setContentSize(cc.size(display.width, display.height))
    self.scene_layer = self:CreateSceneLayer():addTo(self:GetSceneNode(), 0)
    self.touch_layer = self:CreateMultiTouchLayer():addTo(self:GetSceneNode(), 1)
    self.scene_ui_layer = self:CreateSceneUILayer():addTo(self:GetSceneNode(), 2)
end
function MapScene:onEnter()

end
function MapScene:onExit()
    self.touch_judgment:destructor()
end
function MapScene:BlurRenderScene()
    self.blur_count = self.blur_count - 1
    if self.blur_count ~= 0 then
        return
    end
    if self.render_scene then
        self.render_scene:removeFromParent()
        self.render_scene = nil
    end
    self.render_scene = self:DumpScene():addTo(self):pos(display.cx, display.cy)
    self:GetSceneNode():hide()
end
function MapScene:DumpScene()
    local director = cc.Director:getInstance()
    local params = {filters = "CUSTOM", filterParams = json.encode({
        frag = "shaders/blur.fs",
        shaderName = "blur_scene",
        resolution = {display.width, display.height},
        blurRadius = 8,
        sampleNum = 4,
        time = director:getTotalFrames() * director:getAnimationInterval()
    })}
    return display.printscreen(self:GetSceneNode(), params)
end
function MapScene:ResetRenderState()
    self.blur_count = self.blur_count + 1
    if self.blur_count ~= 1 then
        return
    end
    self.render_scene:hide()
    self:GetSceneNode():show()
end
function MapScene:GetSceneNode()
    return self.scene_node
end
function MapScene:GetSceneUILayer()
    return self.scene_ui_layer
end
function MapScene:GetSceneLayer()
    return self.scene_layer
end
function MapScene:CreateSceneLayer()
    assert(false, "必须在子类实现生成场景的方法")
end
function MapScene:CreateMultiTouchLayer()
    local touch_layer = display.newLayer()
    touch_layer:setTouchEnabled(true)
    touch_layer:setTouchSwallowEnabled(true)
    touch_layer:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    self.handle = touch_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.event_manager:OnEvent(event)
        return true
    end)
    return touch_layer
end
function MapScene:OnOneTouch(pre_x, pre_y, x, y, touch_type)
    self:OneTouch(pre_x, pre_y, x, y, touch_type)
end
function MapScene:OneTouch(pre_x, pre_y, x, y, touch_type)
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
function MapScene:OnTwoTouch(x1, y1, x2, y2, event_type)
    local scene = self.scene_layer
    if event_type == "began" then
        scene:StopScaleAnimation()
        self.distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBegin()
    elseif event_type == "moved" then
        local new_distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBy(new_distance / self.distance)
    elseif event_type == "ended" then
        scene:ZoomEnd()
        self.distance = nil
        local low = scene.min_scale + 0.2
        local high = scene.max_scale + 0.2
        if scene:getScale() <= low then
            scene:ZoomToByAnimation(low)
        elseif scene:getScale() >= high then
            scene:ZoomToByAnimation(high)
        end
    end
end
-- TouchJudgment
function MapScene:OnTouchBegan(pre_x, pre_y, x, y)

end
function MapScene:OnTouchEnd(pre_x, pre_y, x, y)

end
function MapScene:OnTouchCancelled(pre_x, pre_y, x, y)

end
function MapScene:OnTouchMove(pre_x, pre_y, x, y)
    if self.distance then return end
    local parent = self.scene_layer:getParent()
    local old_point = parent:convertToNodeSpace(cc.p(pre_x, pre_y))
    local new_point = parent:convertToNodeSpace(cc.p(x, y))
    local old_x, old_y = self.scene_layer:getPosition()
    local diffX = new_point.x - old_point.x
    local diffY = new_point.y - old_point.y
    self.scene_layer:setPosition(cc.p(old_x + diffX, old_y + diffY))
end
function MapScene:OnTouchClicked(pre_x, pre_y, x, y)
    
end
function MapScene:OnTouchExtend(old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond)
    local parent = self.scene_layer:getParent()
    local speed = parent:convertToNodeSpace(cc.p(new_speed_x, new_speed_y))
    local x, y  = self.scene_layer:getPosition()
    local max_speed = 5
    speed.x = speed.x > max_speed and max_speed or speed.x
    speed.y = speed.y > max_speed and max_speed or speed.y
    local sp = self:convertToNodeSpace(cc.p(speed.x * millisecond, speed.y * millisecond))
    self.scene_layer:setPosition(cc.p(x + sp.x, y + sp.y))
end

return MapScene
