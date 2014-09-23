local Enum = import("..utils.Enum")
local Observer = import(".Observer")
local MaterialsManager = class("MaterialsManager", Observer)


MaterialsManager.MATERIAL_TYPE = Enum("BUILD", "SOLDIER", "DRAGON")

function MaterialsManager:ctor()
    MaterialsManager.super.ctor(self)
end
function MaterialsManager:GetMaterialByType(RESOURCE_TYPE)
    return self.resources[RESOURCE_TYPE]
end
function MaterialsManager:OnMaterialsChanged()
    self:NotifyObservers(function(listener)
        listener:OnMaterialsChanged(self)
    end)
end



return MaterialsManager





