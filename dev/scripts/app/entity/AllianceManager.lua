local Alliance = import(".Alliance")
local AllianceManager = class("AllianceManager")

function AllianceManager:ctor()
    self.my_alliance = Alliance.new()
    self.my_alliance:SetIsMyAlliance(true)
    self.alliance_caches = {}
    self.my_alliance_mapData = {
        marchEvents = {
            strikeMarchEvents = {} ,
            strikeMarchReturnEvents = {} ,
            attackMarchEvents = {},
            attackMarchReturnEvents = {} ,
        },
        villageEvents = {}
    }
    self:ResetCurrentMapData()
end
function AllianceManager:GetMyAllianceMapData()
    return self.my_alliance_mapData
end
function AllianceManager:GetVillageEventsByMapId(alliance, mapId)
    for k,v in pairs(alliance.villageEvents) do
        if v.villageData.id == mapId then
            return v
        end
    end
    for k,v in pairs(self.my_alliance_mapData.villageEvents) do
        if v ~= json.null and v.villageData.id == mapId then
            return v
        end
    end
    for k,v in pairs(self:GetCurrentMapData().villageEvents) do
        if v ~= json.null and v.villageData.id == mapId then
            return v
        end
    end
end
function AllianceManager:GetAllianceByCache(key)
    local cache_alliance = self.alliance_caches[key]
    if cache_alliance and self:GetMyAlliance()._id ~= cache_alliance._id then
        setmetatable(cache_alliance, Alliance)
    end
    return cache_alliance
end
function AllianceManager:RemoveAllianceCache(key)
    self.alliance_caches[key] = nil
end
function AllianceManager:UpdateAllianceBy(key, alliance)
    if alliance == json.null then
        self.alliance_caches[key] = nil
    else
        self.alliance_caches[key] = alliance
        self.alliance_caches[alliance._id] = alliance
    end
end
function AllianceManager:ClearCache()
    self.alliance_caches = {}
end
function AllianceManager:GetCurrentMapData()
    return self.currentMapData
end
function AllianceManager:ResetCurrentMapData()
    self.currentMapData = {
        marchEvents = {
            strikeMarchEvents = {} ,
            strikeMarchReturnEvents = {} ,
            attackMarchEvents = {},
            attackMarchReturnEvents = {} ,
        },
        villageEvents = {},
    }
end
function AllianceManager:OnEnterMapIndex(mapIndex, data)
    self:UpdateAllianceBy(mapIndex, data.allianceData)
    self.currentMapData = data.mapData
    if not self.handle then return end
    self.handle.OnEnterMapIndex(self.handle, mapIndex, data)
end
local function removeJsonNull(t)
    for k,v in pairs(t) do
        if v == json.null then
            t[k] = nil
        end
    end 
end
function AllianceManager:OnMapDataChanged(mapIndex, currentMapData, deltaData)
    if not self.handle then return end
    self.handle.OnMapDataChanged(self.handle, self:GetAllianceByCache(mapIndex), currentMapData, deltaData)
    removeJsonNull(currentMapData.villageEvents)
    for _,t in pairs(currentMapData.marchEvents) do
        removeJsonNull(t)
    end
end
function AllianceManager:OnMapAllianceChanged(allianceData, deltaData)
    if not self.handle then return end
    self.handle.OnMapAllianceChanged(self.handle, allianceData, deltaData)
end
function AllianceManager:SetAllianceHandle(handle)
    self.handle = handle
end


function AllianceManager:HasBeenJoinedAlliance()
    return DataManager:getUserData().countInfo.firstJoinAllianceRewardGeted or
        not self:GetMyAlliance():IsDefault()
end

function AllianceManager:GetMyAlliance()
    return self.my_alliance
end

function AllianceManager:OnUserDataChanged(user_data,time,deltaData)
    local allianceId = user_data.allianceId
    local my_alliance = self:GetMyAlliance()
    if (allianceId == json.null or not allianceId) and not my_alliance:IsDefault() then
        self.my_alliance_mapData = {
            marchEvents = {
                strikeMarchEvents = {} ,
                strikeMarchReturnEvents = {} ,
                attackMarchEvents = {},
                attackMarchReturnEvents = {} ,
            },
            villageEvents = {}
        }
        my_alliance:Reset()
        app:GetChatManager():emptyAllianceChannel()
        DataManager:setUserAllianceData(json.null)
    end
end

function AllianceManager:OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    self:GetMyAlliance():OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    -- local my_alliance_status = self:GetMyAlliance().basicInfo.status
    -- local isRelogin_action = deltaData == nil and alliance_data
    -- local scene_name = display.getRunningScene().__cname
    -- if (scene_name == 'AllianceBattleScene' or scene_name == 'AllianceScene') and isRelogin_action  then
    --     if not UIKit:GetUIInstance('GameUIWarSummary') then
    --         app:EnterMyAllianceScene()
    --     end
    -- else
    --     -- self:RefreshAllianceSceneIf(my_alliance_status)
    -- end
end


function AllianceManager:setMapIndexData(mapIndexData)
    self.mapIndexData = mapIndexData
end
local terrainStyle = GameDatas.AllianceMap.terrainStyle
function AllianceManager:getMapDataByIndex(index)
    local key = self.mapIndexData[tostring(index)]
    for _,v in pairs(terrainStyle) do
        if v.index == key then
            local terrain, style = unpack(string.split(v.style, "_"))
            return terrain, tonumber(style)
        end
    end
end
function AllianceManager:setMapDataByIndex(index, data)
    self.mapIndexData[tostring(index)] = data
end
-- json decode to a alliance
function AllianceManager:DecodeAllianceFromJson( json_data )
    local alliance = Alliance.new()
    alliance:OnAllianceDataChanged(json_data)
    return alliance
end
--判断是否进入对战地图
function AllianceManager:RefreshAllianceSceneIf(old_alliance_status)
    local my_alliance = self:GetMyAlliance()
    local my_alliance_status = my_alliance.basicInfo.status
    if old_alliance_status == my_alliance_status then return end
    local scene_name = display.getRunningScene().__cname
    if (my_alliance_status == 'protect') then
        self.tipUserWar = false
        -- if self:HaveEnemyAlliance() then
        --     self:GetEnemyAlliance():Reset()
        -- end
        if old_alliance_status == "" then return end
        print("==========>RefreshAllianceSceneIf", old_alliance_status, my_alliance_status, my_alliance:LastAllianceFightReport())
        if scene_name == 'AllianceBattleScene' or scene_name == 'AllianceScene' or scene_name == 'MyCityScene' then
            if not UIKit:GetUIInstance('GameUIWarSummary') and my_alliance:LastAllianceFightReport() then
                UIKit:newGameUI("GameUIWarSummary"):AddToCurrentScene(true)
            end
        end
    end
    if (my_alliance_status == 'prepare' or my_alliance_status == 'fight') then
        if scene_name == 'AllianceScene' then
            if not self.tipUserWar then
                self.tipUserWar = true
                if not UIKit:isMessageDialogShowWithUserData("__alliance_war_tips__") then
                    UIKit:showMessageDialog(nil,_("联盟对战已开始，您将进入自己联盟对战地图。"),function()
                        app:EnterMyAllianceScene()
                    end,nil,false,nil,"__alliance_war_tips__")
                end
            end
        elseif scene_name == 'MyCityScene' then
            if not self.tipUserWar then
                self.tipUserWar = true
                if not UIKit:isMessageDialogShowWithUserData("__alliance_war_tips__") then
                    UIKit:showMessageDialogWithParams({
                        content = _("联盟对战已开始，您将进入自己联盟对战地图。"),
                        ok_callback = function()
                            app:EnterMyAllianceScene()
                        end,
                        cancel_callback = function()end,
                        auto_close = false,
                        user_data = '__alliance_war_tips__'
                    })
                end
            end
        elseif scene_name == 'MainScene' then
            if not self.tipUserWar then
                self.tipUserWar = true
                local dialog = UIKit:getMessageDialogWithParams({
                    content = _("联盟对战已开始，您将进入自己联盟对战地图。"),
                    ok_callback = function()
                        app:EnterMyAllianceScene()
                    end,
                    cancel_callback = function()end,
                    auto_close = false,
                    user_data = '__alliance_war_tips__'
                })
                UIKit:addMessageDialogWillShow(dialog)
            end
        end
    end

end

return AllianceManager


