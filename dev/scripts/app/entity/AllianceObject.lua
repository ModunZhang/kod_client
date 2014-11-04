local AllianceObject = class("AllianceObject")
local allianceBuildingType = GameDatas.AllianceInitData.buildingType
function AllianceObject:ctor(object_type, id, x, y)
    assert(object_type)
    self.object_type = object_type or "none"
    self.id = id
    self.x = x or 0
    self.y = y or 0
    self.w = allianceBuildingType[object_type].width
    self.h = allianceBuildingType[object_type].height
    self.level = 0
end
function AllianceObject:GetCategory()
    return allianceBuildingType[self:GetType()].category
end
function AllianceObject:Id()
    return self.id
end
function AllianceObject:SetLevel(level)
    self.level = level
end
function AllianceObject:Level()
    return self.level
end
function AllianceObject:GetSize()
    return self.w, self.h
end
function AllianceObject:GetType()
    return self.object_type
end
function AllianceObject:SetLogicPosition(x, y)
    self.x, self.y = x, y
end
function AllianceObject:GetLogicPosition()
    return self.x, self.y
end
function AllianceObject:GetMidLogicPosition()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return (start_x + end_x) / 2, (start_y + end_y) / 2
end
function AllianceObject:GetTopLeftPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return start_x, start_y
end
function AllianceObject:GetTopRightPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return end_x, start_y
end
function AllianceObject:GetBottomLeftPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return start_x, end_y
end
function AllianceObject:GetBottomRightPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return end_x, end_y
end
function AllianceObject:IsContainPoint(x, y)
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return x >= start_x and x <= end_x and y >= start_y and y <= end_y
end
function AllianceObject:GetGlobalRegion()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local start_x, end_x, start_y, end_y

    local is_orient_x = w > 0
    local is_orient_neg_x = not is_orient_x
    local is_orient_y = h > 0
    local is_orient_neg_y = not is_orient_y

    if is_orient_x then
        start_x, end_x = x - w + 1, x
    elseif is_orient_neg_x then
        start_x, end_x = x, x + math.abs(w) - 1
    end

    if is_orient_y then
        start_y, end_y = y - h + 1, y
    elseif is_orient_neg_y then
        start_y, end_y = y, y + math.abs(h) - 1
    end
    return start_x, end_x, start_y, end_y
end
return AllianceObject






