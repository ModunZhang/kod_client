local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local WorldLayer = import("..layers.WorldLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIWorldMap = UIKit:createUIClass('GameUIWorldMap')
local alliancemap_buff = GameDatas.AllianceMap.buff
local intInit = GameDatas.AllianceInitData.intInit
local bigMapLength_value = intInit.bigMapLength.value
local ALLIANCE_WIDTH = intInit.allianceRegionMapWidth.value
local ALLIANCE_HEIGHT= intInit.allianceRegionMapHeight.value
function GameUIWorldMap:ctor(fromIndex, toIndex, mapIndex)
	GameUIWorldMap.super.ctor(self)
    self.__type  = UIKit.UITYPE.BACKGROUND
    self.scene_node = display.newNode():addTo(self)
    self.scene_layer = WorldLayer.new(self):addTo(self.scene_node, 0)
    self.touch_layer = self:CreateMultiTouchLayer():addTo(self.scene_node, 1)
    self.mask_layer = display.newLayer():addTo(self.scene_node, 2):hide()
    self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
    self.fromIndex = fromIndex
    self.toIndex = toIndex
    self.mapIndex = mapIndex
end
function GameUIWorldMap:onEnter()
    local mapIndex = self.mapIndex or Alliance_Manager:GetMyAlliance().mapIndex
    local x,y = self:GetSceneLayer():IndexToLogic(mapIndex)
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
    self.round_info = self:LoadRoundInfo(mapIndex)
    -- 返回按钮
    local world_map_btn_bg = display.newSprite("background_86x86.png")
    :addTo(self):align(display.LEFT_BOTTOM,display.left + 8,display.bottom + 246)
    local size = world_map_btn_bg:getContentSize()
    self.loading = display.newSprite("loading.png")
                   :addTo(world_map_btn_bg,1)
                   :pos(size.width-20,10)
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
    end, 0.2)
end
function GameUIWorldMap:LoadRoundInfo(mapIndex)
    local node = display.newSprite("background_768x152.png"):align(display.BOTTOM_CENTER, display.cx, display.bottom):addTo(self)
    if display.width > 640 then
        node:scale(display.width/node:getContentSize().width)
    end
    node:setTouchEnabled(true)
    node:setTouchSwallowEnabled(true)
    node.mapIndex = mapIndex
    local mini_map_button = WidgetPushButton.new({normal = "mini_map_146x124.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newWidgetUI("WidgetAllianceMapBuff",node.mapIndex):AddToCurrentScene()
            end
        end):align(display.LEFT_BOTTOM, 80 , 8)
        :addTo(node)
    mini_map_button:setTouchSwallowEnabled(true)

    local current_round_bg = display.newSprite("background_red_558x42.png"):align(display.LEFT_TOP, mini_map_button:getPositionX() + 36 , mini_map_button:getPositionY() + mini_map_button:getCascadeBoundingBox().size.height + 5)
        :addTo(node)
    local current_round_label = UIKit:ttfLabel({
        text = DataUtils:getMapRoundByMapIndex(mapIndex),
        size = 22,
        color = 0xfed36c,
    }):align(display.CENTER, current_round_bg:getContentSize().width/2, current_round_bg:getContentSize().height/2)
        :addTo(current_round_bg)


    local info_bg = display.newSprite("background_330x78.png"):align(display.LEFT_TOP, mini_map_button:getPositionX() + mini_map_button:getCascadeBoundingBox().size.width  , mini_map_button:getPositionY() + mini_map_button:getCascadeBoundingBox().size.height/2 + 20)
        :addTo(node)
    -- 野怪等级
    local monster_bg = display.newSprite("background_318x38.png"):align(display.LEFT_TOP, 0 ,info_bg:getContentSize().height)
        :addTo(info_bg)
    UIKit:ttfLabel({
        text = _("野怪等级"),
        size = 18,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 8, monster_bg:getContentSize().height/2)
        :addTo(monster_bg)
    local monster_levels = UIKit:ttfLabel({
        text = " 10 - 14",
        size = 20,
        color = 0xa1dd00,
    }):align(display.RIGHT_CENTER, monster_bg:getContentSize().width , monster_bg:getContentSize().height/2)
        :addTo(monster_bg)
    -- BUFF数量
    local buff_bg = display.newSprite("background_318x38.png"):align(display.LEFT_BOTTOM, 0,0)
        :addTo(info_bg)
    UIKit:ttfLabel({
        text = _("增益效果数量"),
        size = 18,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 8, buff_bg:getContentSize().height/2 )
        :addTo(buff_bg)
    local buff_num_label = UIKit:ttfLabel({
        text = "0",
        size = 20,
        color = 0xa1dd00,
    }):align(display.RIGHT_CENTER, buff_bg:getContentSize().width , buff_bg:getContentSize().height/2)
        :addTo(buff_bg)
    -- 详情按钮
    local details_button = WidgetPushButton.new({normal = "yellow_btn_up_134x56.png",pressed = "yellow_btn_down_134x56.png"})
        :setButtonLabel(
            UIKit:commonButtonLable({
                text = _("详情")
            })
        ):onButtonClicked(function()
            UIKit:newWidgetUI("WidgetAllianceMapBuff",node.mapIndex):AddToCurrentScene()
        end)
        :align(display.CENTER,630,46)
        :addTo(node)
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
    -- 自己所在联盟位置
    local self_position_sprite = display.newSprite("icon_my_alliance_position_4x4.png"):addTo(mini_map_button)
    self_position_sprite:runAction(
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
        local buff = alliancemap_buff[map_round]
        buff_num_label:setString(DataUtils:getMapBuffNumByMapIndex(mapIndex))
        current_round_label:setString(string.format(_("%d 圈"),map_round + 1))
        local levels = string.split(buff["monsterLevel"],"_")
        monster_levels:setString(string.format("Lv%s~Lv%s",levels[1],levels[2]))
        local bigMapLength = bigMapLength_value
        local offset_x,offset_y = x / bigMapLength, 1 - y / bigMapLength
        current_position_sprite:setPosition(124 * offset_x, 124 * offset_y)
    end

    scheduleAt(self,function ()
        local x,y = self.scene_layer:ConvertScreenPositionToLogicPosition(display.cx,display.cy)
        local mapIndex = self.scene_layer:LogicToIndex(x, y) 
        node:RefreshRoundInfo(mapIndex,x, y)
        local my_mapIndex = Alliance_Manager:GetMyAlliance().mapIndex
        local bigMapLength = bigMapLength_value
        local x,y = self.scene_layer:IndexToLogic(my_mapIndex) 
        local offset_x,offset_y = x / bigMapLength, 1 - y / bigMapLength
        self_position_sprite:setPosition(124 * offset_x, 124 * offset_y)
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
    -- local scene = self.scene_layer
    -- if event_type == "began" then
    --     scene:StopScaleAnimation()
    --     self.distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    --     scene:ZoomBegin(x1, y1, x2, y2)
    -- elseif event_type == "moved" then
    --     local new_distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
    --     scene:ZoomBy(new_distance / self.distance, (x1 + x2) * 0.5, (y1 + y2) * 0.5)
    -- elseif event_type == "ended" then
    --     scene:ZoomEnd()
    --     self.distance = nil
    -- end
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
    UIKit:newWidgetUI("WidgetWorldAllianceInfo",click_object,index,true):AddToCurrentScene()
end
function GameUIWorldMap:IsFingerOn()
    return self.event_manager:TouchCounts() ~= 0
end
function GameUIWorldMap:OnSceneScale()
end
function GameUIWorldMap:OnSceneMove()
    local indexes = self:GetSceneLayer():GetAvailableIndex()
    for i,v in ipairs(indexes) do
        self:GetSceneLayer():LoadLevelBg(v)
    end
end

return GameUIWorldMap

