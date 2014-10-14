local NormalMapAnchorBottomLeftReverseY = class("NormalMapAnchorBottomLeftReverseY")
local floor = math.floor
local ceil = math.ceil
function NormalMapAnchorBottomLeftReverseY:ctor(map_info)
    self.tile_w = map_info.tile_w
    self.tile_h = map_info.tile_h
    self.half_w = self.tile_w / 2
    self.half_h = self.tile_h / 2
    self.map_width = map_info.map_width
    self.map_height = map_info.map_height
    self.base_x = map_info.base_x
    self.base_y = map_info.base_y
end
function NormalMapAnchorBottomLeftReverseY:ConvertToMapPosition(x, y)
    return self.base_x + self.half_w + x * self.tile_w, self.base_y - self.half_h - y * self.tile_h
end
function NormalMapAnchorBottomLeftReverseY:ConvertToLogicPosition(x, y)
    return floor((x - self.base_x) % 80), floor((y - self.base_y) % 80)
end
function NormalMapAnchorBottomLeftReverseY:ConvertToLocalPosition(x, y)
    return x * self.tile_w - self.half_w, y * self.tile_h + self.half_h
end



return NormalMapAnchorBottomLeftReverseY