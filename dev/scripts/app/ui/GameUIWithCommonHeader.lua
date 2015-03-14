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
    self:CreateBetweenBgAndTitle()
    self:CreateTitle(self.title)
    self.home_btn = self:CreateHomeButton()
    self.gem_label = self:CreateShopButton(function()
        end)
    self.city:GetResourceManager():AddObserver(self)

    local scene = display.getRunningScene()
    if scene.GetHomePage and scene:GetHomePage() then
        scene:GetHomePage():DisplayOff()
    end
end
function GameUIWithCommonHeader:CreateBetweenBgAndTitle()
    print("->创建backgroud和title之间的中间层显示")
end
function GameUIWithCommonHeader:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    GameUIWithCommonHeader.super.onExit(self)

    local scene = display.getRunningScene()
    if scene.GetHomePage and scene:GetHomePage() then
        scene:GetHomePage():DisplayOn()
    end
end
function GameUIWithCommonHeader:OnResourceChanged(resource_manager)
    self.gem_label:setString(string.formatnumberthousands(self.city:GetUser():GetGemResource():GetValue()))
end


return GameUIWithCommonHeader

