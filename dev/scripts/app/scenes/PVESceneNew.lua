local PVELayerNew = import("..layers.PVELayerNew")
local MapScene = import(".MapScene")
local PVESceneNew = class("PVESceneNew", MapScene)
function PVESceneNew:ctor()
    PVESceneNew.super.ctor(self)
end
function PVESceneNew:CreateSceneLayer()
    return PVELayerNew.new(self)
end


return PVESceneNew






















