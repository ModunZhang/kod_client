local Enum = import("..utils.Enum")
local WidgetPVEKeel = import("..widget.WidgetPVEKeel")
local WidgetPVECamp = import("..widget.WidgetPVECamp")
local WidgetPVEMiner = import("..widget.WidgetPVEMiner")
local WidgetPVEFarmer = import("..widget.WidgetPVEFarmer")
local WidgetPVEObelisk = import("..widget.WidgetPVEObelisk")
local WidgetPVEQuarrier = import("..widget.WidgetPVEQuarrier")
local WidgetPVEWoodcutter = import("..widget.WidgetPVEWoodcutter")
local WidgetPVEAncientRuins = import("..widget.WidgetPVEAncientRuins")
local WidgetPVEWarriorsTomb = import("..widget.WidgetPVEWarriorsTomb")
local WidgetPVEEntranceDoor = import("..widget.WidgetPVEEntranceDoor")
local WidgetPVEStartAirship = import("..widget.WidgetPVEStartAirship")
local WidgetPVECrashedAirship = import("..widget.WidgetPVECrashedAirship")
local WidgetPVEConstructionRuins = import("..widget.WidgetPVEConstructionRuins")
local PVEDefine = import("..entity.PVEDefine")
local PVEObject = import("..entity.PVEObject")
local PVELayer = import("..layers.PVELayer")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)

local timer = app.timer
function PVEScene:ctor(user)
    User:ResetAllListeners()
    City:ResetAllListeners()
    Alliance_Manager:GetMyAlliance():ResetAllListeners()
    self.user = user
    PVEScene.super.ctor(self)
end
function PVEScene:onEnter()
    PVEScene.super.onEnter(self)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(self.user:GetPVEDatabase():GetCharPosition())
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(0.8)
    self:GetSceneLayer():MoveCharTo(self.user:GetPVEDatabase():GetCharPosition())

    UIKit:newGameUI('GameUIPVEHome', self.user):addToScene(self, true):setTouchSwallowEnabled(false)
end
function PVEScene:CreateSceneLayer()
    return PVELayer.new(self.user)
end
function PVEScene:CheckObject(x, y, type)
    if not self.user:GetCurrentPVEMap():GetObject(x, y) then
        self.user:GetCurrentPVEMap():ModifyObject(x, y, 0, type)
    end
end
function PVEScene:OnTouchClicked(pre_x, pre_y, x, y)
    local logic_map = self:GetSceneLayer():GetLogicMap()
    local char = self:GetSceneLayer():GetChar()
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(x, y))
    local new_x, new_y = logic_map:ConvertToLogicPosition(point.x, point.y)
    local old_x, old_y = logic_map:ConvertToLogicPosition(char:getPosition())

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
        self:GetSceneLayer():MoveCharTo(tx, ty)
        local gid = self:GetSceneLayer():GetTileInfo(tx, ty)
        if gid > 0 then
            self:CheckObject(tx, ty, gid)
        end
        if gid == PVEDefine.START_AIRSHIP then
            WidgetPVEStartAirship.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.WOODCUTTER then
            WidgetPVEWoodcutter.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.QUARRIER then
            WidgetPVEQuarrier.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.MINER then
            WidgetPVEMiner.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.FARMER then
            WidgetPVEFarmer.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CAMP then
            WidgetPVECamp.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CRASHED_AIRSHIP then
            WidgetPVECrashedAirship.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CONSTRUCTION_RUINS then
            WidgetPVEConstructionRuins.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.KEEL then
            WidgetPVEKeel.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.WARRIORS_TOMB then
            WidgetPVEWarriorsTomb.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.OBELISK then
            WidgetPVEObelisk.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.ANCIENT_RUINS then
            WidgetPVEAncientRuins.new(tx, ty, self.user):addToScene(self, true)
        elseif gid == PVEDefine.ENTRANCE_DOOR then
            WidgetPVEEntranceDoor.new(tx, ty, self.user):addToScene(self, true)
        end
        self.user:GetPVEDatabase():Dump()
    end
end
return PVEScene





