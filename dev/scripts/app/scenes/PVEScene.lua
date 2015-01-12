local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local PVELayer = import("..layers.PVELayer")
local PVEDefine = import("..layers.PVEDefine")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)

local OBJECT_TYPE = PVEDefine.object_type
local OBJECT_IMAGE = PVEDefine.object_image
local OBJECT_DESC = PVEDefine.object_desc
local OBJECT_TITLE = PVEDefine.object_title
local OBJECT_OP = PVEDefine.object_op



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
    if new_x == old_x and new_y == old_y then return end
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

        if gid then
            WidgetPVEDialog.new({
                btn = OBJECT_OP[gid],
                image = OBJECT_IMAGE[gid],
                desc = OBJECT_DESC[gid],
                title = "我是"..OBJECT_TITLE[gid],
            }, 250, OBJECT_TITLE[gid], display.cy + 150):addToScene(self, true)
        end
    end
end
return PVEScene



