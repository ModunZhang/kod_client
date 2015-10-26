local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local WorldLayer = import("..layers.WorldLayer")
local GameUIWorldMap = UIKit:createUIClass('GameUIWorldMap')

function GameUIWorldMap:ctor()
	GameUIWorldMap.super.ctor(self)
    self.scene_node = display.newNode():addTo(self)
    self.scene_layer = WorldLayer.new(self):addTo(self.scene_node, 0)
    self.touch_layer = self:CreateMultiTouchLayer():addTo(self.scene_node, 1)
	self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
end
function GameUIWorldMap:onEnter()
	self:GotoPosition(0,0)
	self:ScheduleLoadMap()

    -- 返回按钮
    local world_map_btn_bg = display.newSprite("background_86x86.png"):addTo(self):align(display.LEFT_BOTTOM,display.left + 10,display.bottom + 25):scale(0.85)
    -- local inWorldScene = display.getRunningScene().__cname == "WorldScene"
    local world_map_btn = UIKit:ButtonAddScaleAction(cc.ui.UIPushButton.new({normal ='icon_world_retiurn_88x88.png'})
        :onButtonClicked(function()
           self:LeftButtonClicked()
        end)
    ):align(display.CENTER,world_map_btn_bg:getContentSize().width/2 , world_map_btn_bg:getContentSize().height/2)
        :addTo(world_map_btn_bg)
end
function GameUIWorldMap:GotoPosition(x,y)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(x,y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function GameUIWorldMap:ScheduleLoadMap()
	self:GetSceneLayer():LoadAlliance()
	self.load_map_node = display.newNode():addTo(self)
end
function GameUIWorldMap:LoadMap()
	if self:IsFingerOn() then
		return
	end
	self.load_map_node:stopAllActions()
	self.load_map_node:performWithDelay(function()
		self:GetSceneLayer():LoadAlliance()
	end, 0.5)
end
function GameUIWorldMap:GetSceneLayer()
	return self.scene_layer
end
function GameUIWorldMap:CreateMultiTouchLayer()
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
function GameUIWorldMap:OnOneTouch(pre_x, pre_y, x, y, touch_type)
    self:OneTouch(pre_x, pre_y, x, y, touch_type)
end
function GameUIWorldMap:OneTouch(pre_x, pre_y, x, y, touch_type)
    if touch_type == "began" then
        self.touch_judgment:OnTouchBegan(pre_x, pre_y, x, y)
        self.scene_layer:StopMoveAnimation()
        return true
    elseif touch_type == "moved" then
        self.touch_judgment:OnTouchMove(pre_x, pre_y, x, y)
    elseif touch_type == "ended" then
        self.touch_judgment:OnTouchEnd(pre_x, pre_y, x, y)
    elseif touch_type == "cancelled" then
        self.touch_judgment:OnTouchCancelled(pre_x, pre_y, x, y)
    end
end
function MapScene:OnTouchCancelled(pre_x, pre_y, x, y)
    print("OnTouchCancelled")
end
function GameUIWorldMap:OnTwoTouch(x1, y1, x2, y2, event_type)
	local scene = self.scene_layer
    if event_type == "began" then
        scene:StopScaleAnimation()
        self.distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBegin(x1, y1, x2, y2)
    elseif event_type == "moved" then
        local new_distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBy(new_distance / self.distance, (x1 + x2) * 0.5, (y1 + y2) * 0.5)
    elseif event_type == "ended" then
        scene:ZoomEnd()
        self.distance = nil
    end
end
--
function GameUIWorldMap:OnTouchBegan(pre_x, pre_y, x, y)

end
function GameUIWorldMap:OnTouchEnd(pre_x, pre_y, x, y, ismove)
	if not ismove then
		self:LoadMap()
	end
end
function GameUIWorldMap:OnTouchMove(pre_x, pre_y, x, y)
	self.load_map_node:stopAllActions()
	if self.distance then return end
    local parent = self.scene_layer:getParent()
    local old_point = parent:convertToNodeSpace(cc.p(pre_x, pre_y))
    local new_point = parent:convertToNodeSpace(cc.p(x, y))
    local old_x, old_y = self.scene_layer:getPosition()
    local diffX = new_point.x - old_point.x
    local diffY = new_point.y - old_point.y
    self.scene_layer:setPosition(cc.p(old_x + diffX, old_y + diffY))
end
function GameUIWorldMap:OnTouchExtend(old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond, is_end)
	local parent = self.scene_layer:getParent()
    local speed = parent:convertToNodeSpace(cc.p(new_speed_x, new_speed_y))
    local x, y = self.scene_layer:getPosition()
    local max_speed = 5
    local sp = self:convertToNodeSpace(cc.p(speed.x * millisecond, speed.y * millisecond))
    speed.x = speed.x > max_speed and max_speed or speed.x
    speed.y = speed.y > max_speed and max_speed or speed.y
    self.scene_layer:setPosition(cc.p(x + sp.x, y + sp.y))

    if is_end then
		self:LoadMap()
	end
end
function GameUIWorldMap:OnTouchClicked(pre_x, pre_y, x, y)
    if self:IsFingerOn() then
        return
    end
    local click_object,index = self:GetSceneLayer():GetClickedObject(x, y)
    if click_object or index then
        UIKit:newWidgetUI("WidgetWorldAllianceInfo",click_object,index):AddToCurrentScene()
    end
end
function GameUIWorldMap:IsFingerOn()
    return self.event_manager:TouchCounts() ~= 0
end
function GameUIWorldMap:OnSceneScale()
end
function GameUIWorldMap:OnSceneMove()
end

return GameUIWorldMap