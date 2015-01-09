local CityScene = import(".CityScene")
local OtherCityScene = class("OtherCityScene", CityScene)
function OtherCityScene:ctor(user, city)
    OtherCityScene.super.ctor(self, city)
    self.user = user
end
function OtherCityScene:onEnter()
    OtherCityScene.super.onEnter(self)
    UIKit:newGameUI('GameUICityInfo', self.user):addToScene(self):setTouchSwallowEnabled(false)
end

return OtherCityScene
