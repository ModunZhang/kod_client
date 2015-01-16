local GameUIWatchTowerTroopDetail = import("..ui.GameUIWatchTowerTroopDetail")
local CityScene = import(".CityScene")
local OtherCityScene = class("OtherCityScene", CityScene)
function OtherCityScene:ctor(user, city)
    OtherCityScene.super.ctor(self, city)
    self.user = user
    self.city = city
end
function OtherCityScene:onEnter()
    OtherCityScene.super.onEnter(self)
    UIKit:newGameUI('GameUICityInfo', self.user):addToScene(self):setTouchSwallowEnabled(false)
end

function OtherCityScene:OnTouchClicked(pre_x, pre_y, x, y)
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if iskindof(building, "HelpedTroopsSprite") then
            local helped = self.city:GetHelpedByTroops()[building:GetIndex()]
            local type_ = GameUIWatchTowerTroopDetail.DATA_TYPE.HELP_DEFENCE
            UIKit:newGameUI("GameUIWatchTowerTroopDetail", type_, helped, self.user:Id()):addToCurrentScene(true)
        end
    end
end

return OtherCityScene
