local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local PVELayer = import("..layers.PVELayer")
local PVEScene = class("PVEScene", MapScene)
function PVEScene:ctor()
    City:ResetAllListeners()
    Alliance_Manager:GetMyAlliance():ResetAllListeners()
    PVEScene.super.ctor(self)
end
function PVEScene:onEnter()
    PVEScene.super.onEnter(self)

    

    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(1)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "返回",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self, 10)
        :align(display.CENTER, display.left + 100, display.top - 100)
        :onButtonClicked(function()
            app:EnterMyCityScene()
        end):setTouchSwallowEnabled(true)
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
    if tx >= 0 and tx < width and ty >= 0 and ty < height then
        self:GetSceneLayer():WalkOn(tx, ty)
        object:pos(logic_map:ConvertToMapPosition(tx, ty))
        self:GetSceneLayer():GotoLogicPoint(tx, ty, 10)
    end
end
return PVEScene














