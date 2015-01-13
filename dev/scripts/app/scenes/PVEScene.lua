local Enum = import("..utils.Enum")
local WidgetPVEWoodcutter = import("..widget.WidgetPVEWoodcutter")
local PVELayer = import("..layers.PVELayer")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)

local OBJECT_TYPE = Enum("START_AIRSHIP",
    "WOODCUTTER",
    "QUARRIER",
    "MINER",
    "FARMER",
    "CAMP",
    "CRASHED_AIRSHIP",
    "CONSTRUCTION_RUINS",
    "KEEL",
    "WARRIORS_TOMB",
    "OBELISK",
    "ANCIENT_RUINS",
    "ENTRANCE_DOOR",
    "TREE",
    "HILL",
    "LAKE")


local timer = app.timer
function PVEScene:ctor(user)
    -- City:ResetAllListeners()
    -- Alliance_Manager:GetMyAlliance():ResetAllListeners()
    PVEScene.super.ctor(self)
    self.user = user
end
function PVEScene:onEnter()
    PVEScene.super.onEnter(self)
    UIKit:newGameUI('GameUIPVEHome', self.user):addToScene(self, true):setTouchSwallowEnabled(false)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(12, 12)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(0.8)
end
function PVEScene:CreateSceneLayer()
    return PVELayer.new()
end

function PVEScene:OnTouchClicked(pre_x, pre_y, x, y)
    local logic_map = self:GetSceneLayer():GetLogicMap()
    local object = self:GetSceneLayer().object
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(x, y))
    local new_x, new_y = logic_map:ConvertToLogicPosition(point.x, point.y)
    local old_x, old_y = logic_map:ConvertToLogicPosition(object:getPosition())

    -- 检查是不是在中心
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    local logic_x, logic_y = logic_map:ConvertToLogicPosition(point.x, point.y)
    if logic_x ~= old_x or logic_y ~= old_y then
        local s = math.abs(logic_x - old_x) + math.abs(logic_y - old_y)
        self:GetSceneLayer():GotoLogicPoint(old_x, old_y, s * 3)
        return
    end
    -- 检查目标
    if new_x == old_x and new_y == old_y then return end
    -- 检查是否还有体力
    local strength_resource = self.user:GetStrengthResource()
    local strength = strength_resource:GetResourceValueByCurrentTime(timer:GetServerTime())
    if strength <= 0 then return end
    -- 扣除体力
    strength_resource:ReduceResourceByCurrentTime(timer:GetServerTime(), 1)
    self.user:OnResourceChanged()
    --
    local is_offset_x = math.abs(new_x - old_x) > math.abs(new_y - old_y)
    local offset_x = is_offset_x and (new_x - old_x) / math.abs(new_x - old_x) or 0
    local offset_y = is_offset_x and 0 or (new_y - old_y) / math.abs(new_y - old_y)
    local tx, ty = old_x + offset_x, old_y + offset_y
    local width, height = logic_map:GetSize()
    if tx >= 2 and tx < width - 2 and ty >= 2 and ty < height - 2 then
        self:GetSceneLayer():LightOn(tx, ty)
        object:pos(logic_map:ConvertToMapPosition(tx, ty))
        self:GetSceneLayer():GotoLogicPoint(tx, ty, 10)

        local gid = self:GetSceneLayer():GetTileInfo(tx, ty)

        if gid == OBJECT_TYPE.WOODCUTTER then
            WidgetPVEWoodcutter.new():addToScene(self, true)
        end
    end
end
return PVEScene




