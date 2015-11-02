local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local WorldLayer = import("..layers.WorldLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIWorldMap = UIKit:createUIClass('GameUIWorldMap')
local intInit = GameDatas.AllianceInitData.intInit
local aliance_buff = GameDatas.AllianceMap.buff

function GameUIWorldMap:ctor(fromIndex, toIndex)
	GameUIWorldMap.super.ctor(self)
    self.__type  = UIKit.UITYPE.BACKGROUND
    self.scene_node = display.newNode():addTo(self)
    self.scene_layer = WorldLayer.new(self):addTo(self.scene_node, 0)
    self.touch_layer = self:CreateMultiTouchLayer():addTo(self.scene_node, 1)
    self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
    self.fromIndex = fromIndex
    self.toIndex = toIndex
end
function GameUIWorldMap:onEnter()
    local x,y = self:GetSceneLayer():IndexToLogic(Alliance_Manager:GetMyAlliance().mapIndex)
	self:GotoPosition(x,y)
    -- top
    local top_bg = display.newSprite("background_500x84.png"):align(display.TOP_CENTER, display.cx, display.top-20):addTo(self)
    UIKit:ttfLabel({
        text = _("世界地图"),
        size = 32,
        color = 0xffedae,
    }):align(display.CENTER, top_bg:getContentSize().width/2, top_bg:getContentSize().height/2)
        :addTo(top_bg)

    -- bottom 所在位置信息
    self.round_info = self:LoadRoundInfo(Alliance_Manager:GetMyAlliance().mapIndex)
    -- 返回按钮
    local world_map_btn_bg = display.newSprite("background_86x86.png")
    :addTo(self):align(display.LEFT_BOTTOM,display.left + 10,display.bottom + 135):scale(0.85)
    local size = world_map_btn_bg:getContentSize()
    self.loading = display.newSprite("loading.png"):addTo(self)
                    :pos(display.left + 10 + size.width/2 * 0.85, display.bottom + 150)
    self:HideLoading()
    
    -- local inWorldScene = display.getRunningScene().__cname == "WorldScene"
    local world_map_btn = UIKit:ButtonAddScaleAction(cc.ui.UIPushButton.new({normal ='icon_world_retiurn_88x88.png'})
        :onButtonClicked(function()
            self:LeftButtonClicked()
        end)
    ):align(display.CENTER,world_map_btn_bg:getContentSize().width/2 , world_map_btn_bg:getContentSize().height/2)
        :addTo(world_map_btn_bg)

    self.load_map_node = display.newNode():addTo(self)
    if self.fromIndex and self.toIndex then
        self:GetSceneLayer():MoveAllianceFromTo(self.fromIndex, self.toIndex)
    else
        self:GetSceneLayer():LoadAlliance()
    end
end
function GameUIWorldMap:ShowLoading()
    if self.loading:isVisible() and 
        self.loading:getNumberOfRunningActions() > 0 then 
        return 
    end
    self.loading:show():rotation(math.random(360)):stopAllActions()
    self.loading:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
end
function GameUIWorldMap:HideLoading()
    self.loading:hide():stopAllActions()
end
function GameUIWorldMap:GotoPosition(x,y)
    local point = self:GetSceneLayer():ConverToScenePosition(x,y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function GameUIWorldMap:LoadMap()
    if self:IsFingerOn() then
        return
    end
    self:ShowLoading()
    self.load_map_node:stopAllActions()
    self.load_map_node:performWithDelay(function()
        self:GetSceneLayer():LoadAlliance()
    end, 0.5)
end
function GameUIWorldMap:LoadRoundInfo(mapIndex)
    local node = display.newSprite("background_768x292.png"):align(display.BOTTOM_CENTER, display.cx, display.bottom):addTo(self)
    node.mapIndex = mapIndex
    local mini_map_button = WidgetPushButton.new({normal = "mini_map_146x124.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newWidgetUI("WidgetAllianceMapBuff",node.mapIndex):AddToCurrentScene()
            end
        end):align(display.LEFT_BOTTOM, 84 , 10)
        :addTo(node)
    mini_map_button:setTouchSwallowEnabled(true)

    local current_round_bg = display.newSprite("background_red_558x42.png"):align(display.LEFT_TOP, mini_map_button:getPositionX() + 30 , mini_map_button:getPositionY() + mini_map_button:getCascadeBoundingBox().size.height + 5)
        :addTo(node)
    local current_round_label = UIKit:ttfLabel({
        text = DataUtils:getMapRoundByMapIndex(mapIndex),
        size = 22,
        color = 0xfed36c,
    }):align(display.CENTER, current_round_bg:getContentSize().width/2, current_round_bg:getContentSize().height/2)
        :addTo(current_round_bg)

    -- 野怪等级
    local monster_bg = display.newSprite("background_464x38.png"):align(display.LEFT_TOP, mini_map_button:getPositionX() + 70 , mini_map_button:getPositionY() + mini_map_button:getCascadeBoundingBox().size.height/2 + 18)
        :addTo(node)
    UIKit:ttfLabel({
        text = _("野怪等级"),
        size = 18,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 60, monster_bg:getContentSize().height/2)
        :addTo(monster_bg)
    local monster_levels = UIKit:ttfLabel({
        text = " 10 - 14",
        size = 20,
        color = 0xa1dd00,
    }):align(display.RIGHT_CENTER, monster_bg:getContentSize().width - 55, monster_bg:getContentSize().height/2)
        :addTo(monster_bg)
    -- BUFF数量
    local buff_bg = display.newSprite("background_464x38.png"):align(display.LEFT_TOP, monster_bg:getPositionX() , monster_bg:getPositionY() - 39)
        :addTo(node)
    UIKit:ttfLabel({
        text = _("增益效果数量"),
        size = 18,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 60, buff_bg:getContentSize().height/2 )
        :addTo(buff_bg)
    local buff_num_label = UIKit:ttfLabel({
        text = "0",
        size = 20,
        color = 0xa1dd00,
    }):align(display.RIGHT_CENTER, buff_bg:getContentSize().width - 55, buff_bg:getContentSize().height/2)
        :addTo(buff_bg)

    -- 屏幕中心点在小地图的位置
    local current_position_sprite = display.newSprite("icon_current_position_8x10.png"):addTo(mini_map_button)
        -- :align(display.RIGHT_CENTER)
    current_position_sprite:runAction(
        cc.RepeatForever:create(
            transition.sequence{
                cc.ScaleTo:create(0.5/2, 1.2),
                cc.ScaleTo:create(0.5/2, 1.1),
            }
        )
    )

    function node:RefreshRoundInfo(mapIndex,x, y)
        self.mapIndex = mapIndex
        local map_round = DataUtils:getMapRoundByMapIndex(mapIndex)
        local buff = aliance_buff[map_round]
        local buff_num = 0
        for i,v in pairs(buff) do
            if i ~="monsterLevel" and i ~= "round" and v > 0 then
                buff_num = buff_num + 1
            end
        end
        buff_num_label:setString(buff_num)
        current_round_label:setString(string.format(_("%d 圈"),map_round + 1))
        local levels = string.split(buff["monsterLevel"],"_")
        monster_levels:setString(string.format("Lv%s~Lv%s",levels[1],levels[2]))
        local bigMapLength = intInit.bigMapLength.value
        local offset_x,offset_y = x / bigMapLength, 1 - y / bigMapLength
        local mini_map_size = mini_map_button:getCascadeBoundingBox().size
        current_position_sprite:setPosition(124 * offset_x, 124 * offset_y)
    end

    scheduleAt(self,function ()
        local x,y = self.scene_layer:ConvertScreenPositionToLogicPosition(display.cx,display.cy)
        local mapIndex = self.scene_layer:LogicToIndex(x, y) 
        node:RefreshRoundInfo(mapIndex,x, y)
    end,0.5)

    return node
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
function GameUIWorldMap:OnTouchCancelled(pre_x, pre_y, x, y)
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
function GameUIWorldMap:OnTouchEnd(pre_x, pre_y, x, y, ismove, isclick)
	if not ismove and not isclick then
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
    if not index then
        return
    end
    UIKit:newWidgetUI("WidgetWorldAllianceInfo",click_object,index):AddToCurrentScene()
end
function GameUIWorldMap:IsFingerOn()
    return self.event_manager:TouchCounts() ~= 0
end
function GameUIWorldMap:OnSceneScale()
end
function GameUIWorldMap:OnSceneMove()
end

return GameUIWorldMap

