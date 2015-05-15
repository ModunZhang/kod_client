local Sprite = import("..sprites.Sprite")
local CityScene = import(".CityScene")
local FriendCityScene = class("FriendCityScene", CityScene)
function FriendCityScene:ctor(user, city, location)
    FriendCityScene.super.ctor(self, city)
    self.user = user
    self.city = city
    self.location = location
end
function FriendCityScene:onEnter()
    FriendCityScene.super.onEnter(self)
    UIKit:newGameUI('GameUICityInfo', self.user, self.location):AddToScene(self):setTouchSwallowEnabled(false)
end

function FriendCityScene:OnTouchClicked(pre_x, pre_y, x, y)
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

        Sprite:PromiseOfFlash(unpack(buildings)):next(function()
            if iskindof(building, "HelpedTroopsSprite") then
                local helped = self.city:GetHelpedByTroops()[building:GetIndex()]
                local user = self.city:GetUser()
                NetManager:getHelpDefenceTroopDetailPromise(user:Id(), helped.id):done(function(response)
                    LuaUtils:outputTable("response", response)
                    UIKit:newGameUI("GameUIHelpDefence",self.city, helped ,response.msg.troopDetail):AddToCurrentScene(true)
                end)
            end
        end)
    end
end

return FriendCityScene

