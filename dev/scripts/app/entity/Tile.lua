local Orient = import(".Orient")
local WallUpgradeBuilding = import(".WallUpgradeBuilding")
local Tile = class("Tile")


local location_map = {
    [1] = { x = 2, y = 2 },
    [2] = { x = 5, y = 2 },
    [3] = { x = 8, y = 2 },
}


function Tile:ctor(tile_info)
    assert(tile_info)
    assert(type(tile_info.x) == "number")
    assert(type(tile_info.y) == "number")
    assert(type(tile_info.locked) == "boolean")
    self.x = tile_info.x
    self.y = tile_info.y
    self.locked = tile_info.locked
    self.location_id = tile_info.location_id
end
function Tile:IsUnlocked()
    return not self.locked
end
function Tile:GetMidLogicPosition()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return (start_x + end_x) / 2, (start_y + end_y) / 2
end
function Tile:GetStartPos()
    return (self.x - 1) * 10, (self.y - 1) * 10
end
function Tile:GetEndPos()
    return (self.x - 1) * 10 + 9, (self.y - 1) * 10 + 9
end
-- function Tile:GetUpWall()
--     local start_x, start_y = self:GetStartPos()
--     local end_x, end_y = self:GetEndPos()
--     return WallUpgradeBuilding.new({ x = end_x - 1, y = start_y - 1, len = 8, orient = Orient.NEG_Y })
-- end
-- function Tile:GetRightWall()
--     local start_x, start_y = self:GetStartPos()
--     local end_x, end_y = self:GetEndPos()
--     return WallUpgradeBuilding.new({ x = end_x + 1, y = end_y - 1, len = 8, orient = Orient.X })
-- end
-- function Tile:GetDownWall()
--     local start_x, start_y = self:GetStartPos()
--     local end_x, end_y = self:GetEndPos()
--     return WallUpgradeBuilding.new({ x = end_x - 1, y = end_y + 1, len = 8, orient = Orient.Y })
-- end
-- function Tile:GetLeftWall()
--     local start_x, start_y = self:GetStartPos()
--     local end_x, end_y = self:GetEndPos()
--     return WallUpgradeBuilding.new({ x = start_x - 1, y = end_y - 1, len = 8, orient = Orient.NEG_X })
-- end
function Tile:IteratorWallsAroundSelf(func)
    table.foreachi(self:GetWallsAroundSelf(), func)
end
function Tile:GetWallsAroundSelf()
    return {
        self:GetUpWall(),
        self:GetDownWall(),
        self:GetLeftWall(),
        self:GetRightWall()
    }
end
function Tile:GetUpWall()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return WallUpgradeBuilding.new({ x = end_x - 2, y = start_y - 2, len = 6, orient = Orient.NEG_Y, building_type = "wall" })
end
function Tile:GetRightWall()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return WallUpgradeBuilding.new({ x = end_x + 2, y = end_y - 2, len = 6, orient = Orient.X, building_type = "wall" })
end
function Tile:GetDownWall()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return WallUpgradeBuilding.new({ x = end_x - 2, y = end_y + 2, len = 6, orient = Orient.Y, building_type = "wall" })
end
function Tile:GetLeftWall()
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return WallUpgradeBuilding.new({ x = start_x - 2, y = end_y - 2, len = 6, orient = Orient.NEG_X, building_type = "wall" })
end
function Tile:IsContainPosition(x, y)
    local start_x, start_y = self:GetStartPos()
    local end_x, end_y = self:GetEndPos()
    return x >= start_x and x <= end_x and y >= start_y and y <= end_y
end
function Tile:IsContainBuilding(building)
    return self:IsContainPosition(building.x, building.y)
end
function Tile:GetRelativePositionByBuilding(building)
    return self:GetRelativePositionByPos(building.x, building.y)
end
function Tile:GetRelativePositionByPos(x, y)
    local start_x, start_y = self:GetStartPos()
    return x - start_x, y - start_y
end
function Tile:GetBuildingLocation(building)
    return self:GetBuildingLocationByRelativePos(self:GetRelativePositionByBuilding(building))
end
function Tile:GetBuildingLocationByRelativePos(x, y)
    for k, v in pairs(location_map) do
        if x == v.x and y == v.y then
            return k
        end
    end
    return nil
end
function Tile:GetAbsolutePositionByLocation(location)
    local rx, ry = self:GetRelativePositionByLocation(location)
    local start_x, start_y = self:GetStartPos()
    return rx + start_x, ry + start_y
end
function Tile:GetRelativePositionByLocation(location)
    local position = location_map[location]
    return position.x, position.y
end



return Tile


