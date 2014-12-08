local GameUIBase = import('.GameUIBase')
local GameUIWithCommonHeader = class('GameUIWithCommonHeader', GameUIBase)

local visible_count = 1
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
    local page = home_page or (display.getRunningScene().__cname == "AllianceScene" and display.getRunningScene():GetHomePage())

    if page then
        print(visible_count)
        visible_count = visible_count - 1
        if visible_count == 0 then
            page:setVisible(false)
        end
    end
end
function GameUIWithCommonHeader:CreateBetweenBgAndTitle()
    print("->创建backgroud和title之间的中间层显示")
end
function GameUIWithCommonHeader:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    GameUIWithCommonHeader.super.onExit(self)
    local page = home_page or (display.getRunningScene().__cname == "AllianceScene" and display.getRunningScene():GetHomePage())

    if page then
        visible_count = visible_count + 1
        if visible_count > 0 then
            page:setVisible(true)
        end
    end
end
function GameUIWithCommonHeader:OnResourceChanged(resource_manager)
    self.gem_label:setString(string.formatnumberthousands(resource_manager:GetGemResource():GetValue()))
end


return GameUIWithCommonHeader