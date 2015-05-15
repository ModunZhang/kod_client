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
    UIKit:newGameUI('GameUICityInfo', self.user):AddToScene(self):setTouchSwallowEnabled(false)
end

function FriendCityScene:OnTouchClicked(pre_x, pre_y, x, y)
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if iskindof(building, "HelpedTroopsSprite") then
            local helped = self.city:GetHelpedByTroops()[building:GetIndex()]
            local user = self.city:GetUser()
            NetManager:getHelpDefenceTroopDetailPromise(user:Id(), helped.id):done(function(response)
                LuaUtils:outputTable("response", response)
                UIKit:newGameUI("GameUIHelpDefence",self.city, helped ,response.msg.troopDetail):AddToCurrentScene(true)
            end)
        end
    end
end

return FriendCityScene
