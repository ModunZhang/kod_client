local PVELayer = import("..layers.PVELayer")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)
function PVEScene:ctor()
    -- City:ResetAllListeners()
    -- Alliance_Manager:GetMyAlliance():ResetAllListeners()
    PVEScene.super.ctor(self)
end
function PVEScene:onEnter()
    PVEScene.super.onEnter(self)
    UIKit:newGameUI('GameUIPVEHome'):addToScene(self, true):setTouchSwallowEnabled(false)



    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(0.5)
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
    if new_x == old_x and new_y == old_y then return end
    --
    local is_offset_x = math.abs(new_x - old_x) > math.abs(new_y - old_y)
    local offset_x = is_offset_x and (new_x - old_x) / math.abs(new_x - old_x) or 0
    local offset_y = is_offset_x and 0 or (new_y - old_y) / math.abs(new_y - old_y)
    local tx, ty = old_x + offset_x, old_y + offset_y
    local width, height = logic_map:GetSize()
    if tx >= 2 and tx < width - 2 and ty >= 2 and ty < height - 2 then
        self:GetSceneLayer():WalkOn(tx, ty)
        object:pos(logic_map:ConvertToMapPosition(tx, ty))
        self:GetSceneLayer():GotoLogicPoint(tx, ty, 10)
    end
end
return PVEScene




















