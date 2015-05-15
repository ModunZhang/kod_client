local Sprite = import("..sprites.Sprite")
local CityScene = import(".CityScene")
local OtherCityScene = class("OtherCityScene", CityScene)
function OtherCityScene:ctor(user, city)
    OtherCityScene.super.ctor(self, city)
    self.user = user
    self.city = city
end
function OtherCityScene:onEnter()
    OtherCityScene.super.onEnter(self)
    UIKit:newGameUI('GameUICityInfo', self.user):AddToScene(self):setTouchSwallowEnabled(false)
end
--不处理任何场景建筑事件
function OtherCityScene:OnTouchClicked(pre_x, pre_y, x, y)
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        local buildings = {}
        if building:GetEntity():GetType() == "wall" then
            for i,v in ipairs(self:GetSceneLayer():GetWalls()) do
                table.insert(buildings, v)
            end
            for i,v in ipairs(self:GetSceneLayer():GetTowers()) do
                table.insert(buildings, v)
            end
        elseif building:GetEntity():GetType() == "tower" then
            buildings = {unpack(self:GetSceneLayer():GetTowers())}
        else
            buildings = {building}
        end

        app:lockInput(true)
        self:performWithDelay(function()
            app:lockInput(false)
        end, 0.5)

        Sprite:PromiseOfFlash(unpack(buildings))
    end
end

return OtherCityScene
