local GameUIWatchTowerTroopDetail = import("..ui.GameUIWatchTowerTroopDetail")
local CityScene = import(".CityScene")
local FriendCityScene = class("FriendCityScene", CityScene)
function FriendCityScene:ctor(user, city)
    FriendCityScene.super.ctor(self, city)
    self.user = user
    self.city = city
end
function FriendCityScene:onEnter()
    FriendCityScene.super.onEnter(self)
    UIKit:newGameUI('GameUICityInfo', self.user):addToScene(self):setTouchSwallowEnabled(false)
end

function FriendCityScene:OnTouchClicked(pre_x, pre_y, x, y)
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if iskindof(building, "HelpedTroopsSprite") then
            local helped = self.city:GetHelpedByTroops()[building:GetIndex()]
            local type_ = GameUIWatchTowerTroopDetail.DATA_TYPE.HELP_DEFENCE
            UIKit:newGameUI("GameUIWatchTowerTroopDetail", helped, type_, false):addToCurrentScene(true)
        end
    end
end

return FriendCityScene
