local GameUIBase = import('.GameUIBase')
local GameUIWithCommonHeader = class('GameUIWithCommonHeader', GameUIBase)

function GameUIWithCommonHeader:ctor(city, title)
    GameUIWithCommonHeader.super.ctor(self)
    self.title = title
    self.city = city
end

function GameUIWithCommonHeader:onEnter()
    GameUIWithCommonHeader.super.onEnter(self)
    self:CreateBackGround()
    self:CreateTitle(self.title)
    self:CreateHomeButton()
    self.gem_label = self:CreateShopButton()
    local city = self.city
    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
end
function GameUIWithCommonHeader:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    GameUIWithCommonHeader.super.onExit(self)
end
function GameUIWithCommonHeader:OnResourceChanged(resource_manager)
    self.gem_label:setString(GameUtils:formatNumber(resource_manager:GetGemResource():GetValue()))
end


return GameUIWithCommonHeader














