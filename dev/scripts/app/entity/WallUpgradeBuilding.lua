local Orient = import("..entity.Orient")
local UpgradeBuilding = import(".UpgradeBuilding")
local WallUpgradeBuilding = class("WallUpgradeBuilding", UpgradeBuilding)
local config_wall = GameDatas.BuildingFunction.wall
function WallUpgradeBuilding:ctor(wall_info)
    WallUpgradeBuilding.super.ctor(self, wall_info)
    self.len = wall_info.len
    self.w, self.h = self:GetSize()
end
function WallUpgradeBuilding:UniqueKey()
    return self:GetType()
end
function WallUpgradeBuilding:CopyValueFrom(building)
    WallUpgradeBuilding.super.CopyValueFrom(self, building)
    self.len = building.len
    self.w, self.h = building:GetSize()
    self.is_gate = building.is_gate
end
function WallUpgradeBuilding:GetSize()
    if self.orient == Orient.X then
        return 1, self.len
    elseif self.orient == Orient.NEG_X then
        return 1, self.len
    elseif self.orient == Orient.Y then
        return self.len, 1
    elseif self.orient == Orient.NEG_Y then
        return self.len, 1
    end
    assert(false)
end
function WallUpgradeBuilding:IsGate()
    return self.is_gate
end
function WallUpgradeBuilding:SetGate()
    self.is_gate = true
end
function WallUpgradeBuilding:GetMidLogicPosition()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return (start_x + end_x) / 2, (start_y + end_y) / 2
end
function WallUpgradeBuilding:GetStartPos()
    local wall = self
    if wall.orient == Orient.NEG_Y then
        return wall.x - wall.len, wall.y
    elseif wall.orient == Orient.X then
        return wall.x, wall.y - wall.len
    elseif wall.orient == Orient.Y then
         return wall.x + 1, wall.y
    elseif wall.orient == Orient.NEG_X then
        return wall.x, wall.y + 1
    end
    assert(false)
end
function WallUpgradeBuilding:GetEndPos()
    local wall = self
    local end_pos = {}
    if wall.orient == Orient.NEG_Y then
        return wall.x + 1, wall.y
    elseif wall.orient == Orient.X then
        return wall.x, wall.y + 1
    elseif wall.orient == Orient.Y then
        return wall.x - wall.len, wall.y
    elseif wall.orient == Orient.NEG_X then
        return wall.x, wall.y - wall.len
    end
    assert(false)
end
function WallUpgradeBuilding:IsNearByOtherWall(other_wall)
    local wall = self
    return (wall.x == other_wall.x and math.abs(wall.y - other_wall.y) <= 3)
        or (wall.y == other_wall.y and math.abs(wall.x - other_wall.x) <= 3)
end
function WallUpgradeBuilding:IsEndJoinStartWithOtherWall(other_wall)
    local start_x, start_y = other_wall:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return math.abs(start_x - end_x) + math.abs(start_y - end_y) <= 7
end
function WallUpgradeBuilding:IntersectWithOtherWall(other_wall)
    local wall1 = self
    local wall2 = other_wall
    if wall1.orient == wall2.orient then
        local end_x, end_y = wall1:GetEndPos()
        local start_x, start_y = wall2:GetStartPos()
        return { x = math.max(start_x, end_x), y = math.max(start_y, end_y), orient = wall2.orient }
    elseif wall1.orient == Orient.X and wall2.orient == Orient.Y then
        return {x = wall1.x, y = wall2.y, orient = Orient.DOWN}
    elseif wall1.orient == Orient.Y and wall2.orient == Orient.NEG_X then
        return {x = wall2.x, y = wall1.y, orient = Orient.LEFT}
    elseif wall1.orient == Orient.NEG_X and wall2.orient == Orient.NEG_Y then
        return {x = wall1.x, y = wall2.y, orient = Orient.UP}
    elseif wall1.orient == Orient.NEG_Y and wall2.orient == Orient.X then
        return {x = wall2.x, y = wall1.y, orient = Orient.RIGHT}
    elseif wall1.orient == Orient.Y and wall2.orient == Orient.X then
        return {x = wall2.x, y = wall1.y, orient = Orient.NONE}
    elseif wall1.orient == Orient.X and wall2.orient == Orient.NEG_Y then
        return {x = wall1.x, y = wall2.y, orient = Orient.NONE, sub_orient = Orient.RIGHT}
    elseif wall1.orient == Orient.NEG_X and wall2.orient == Orient.Y then
        return {x = wall1.x, y = wall2.y, orient = Orient.NONE, sub_orient = Orient.LEFT}
    end
    assert(false)
end
function WallUpgradeBuilding:OnUserDataChanged(user_data, current_time)
    if self:IsGate() and user_data.wallEvents then
        local level = self:GetLevel()
        local event = user_data.wallEvents[1]
        local finishTime = event == nil and 0 or event.finishTime / 1000
        local wall_info = user_data.wall
        self:OnEvent(event)
        self:OnHandle(wall_info.level, finishTime)
    end
end
function WallUpgradeBuilding:GetWallConfig()
    return config_wall[self:GetLevel()]
end


return WallUpgradeBuilding


