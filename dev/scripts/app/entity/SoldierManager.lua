local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special
local Enum = import("..utils.Enum")
local Localize = import("..utils.Localize")
local MultiObserver = import(".MultiObserver")
local MilitaryTechnology = import(".MilitaryTechnology")
local MilitaryTechEvents = import(".MilitaryTechEvents")
local SoldierStarEvents = import(".SoldierStarEvents")

local SoldierManager = class("SoldierManager", MultiObserver)

SoldierManager.LISTEN_TYPE = Enum(
    "MILITARY_TECHS_EVENTS_CHANGED",
    "MILITARY_TECHS_EVENTS_ALL_CHANGED",
    "MILITARY_TECHS_DATA_CHANGED",
    "SOLDIER_STAR_EVENTS_CHANGED",
    "OnSoldierStarEventsTimer",
    "OnMilitaryTechEventsTimer",
    "ALL_SOLDIER_STAR_EVENTS_CHANGED")

local militaryTechs_config = GameDatas.MilitaryTechs.militaryTechs

function SoldierManager:ctor(city)
    self.city = city
    self.user = self.city:GetUser()
    SoldierManager.super.ctor(self)
    self.soldier_map = {
        ["sentinel"] = 0,
        ["deathKnight"] = 0,
        ["lancer"] = 0,
        ["crossbowman"] = 0,
        ["horseArcher"] = 0,
        ["steamTank"] = 0,
        ["meatWagon"] = 0,
        ["catapult"] = 0,
        ["ballista"] = 0,
        ["ranger"] = 0,
        ["swordsman"] = 0,
        ["skeletonArcher"] = 0,
        ["demonHunter"] = 0,
        ["paladin"] = 0,
        ["priest"] = 0,
        ["skeletonWarrior"] = 0,
    }
    self.treatSoldiers_map = {
        ["ballista"] = 0,
        ["ranger"] = 0,
        ["catapult"] = 0,
        ["crossbowman"] = 0,
        ["horseArcher"] = 0,
        ["swordsman"] = 0,
        ["sentinel"] = 0,
        ["lancer"] = 0,
        ["skeletonWarrior"] = 0,
        ["skeletonArcher"] = 0,
        ["deathKnight"] = 0,
        ["meatWagon"] = 0,
    }
    self.soldierStars = {
        ["ballista"]    = 1,
        ["catapult"]    = 1,
        ["crossbowman"] = 1,
        ["horseArcher"] = 1,
        ["lancer"]     = 1,
        ["ranger"]     = 1,
        ["sentinel"]    = 1,
        ["swordsman"]   = 1,
    }
    self.soldierStarEvents = {}
    self.militaryTechEvents = {}
    self.militaryTechs = {}
end
function SoldierManager:GeneralMilitaryTechLocalPush(event)
    if ext and ext.localpush then
        local pushIdentity = event:Id()..event:Name()
        local title = string.format(_("%s完成"), event:GetLocalizeDesc())
        app:GetPushManager():UpdateTechnologyPush(event:FinishTime(),title,pushIdentity)
    end
end
function SoldierManager:CancelMilitaryTechLocalPush(event)
    if ext and ext.localpush then
        local pushIdentity = event:Id()..event:Name()
        app:GetPushManager():CancelTechnologyPush(pushIdentity)
    end
end
function SoldierManager:GeneralSoldierLocalPush(event)
    if ext and ext.localpush then
        local pushIdentity = event:Id()..event:Name()
        local title = string.format(_("%s完成"), event:GetLocalizeDesc())
        app:GetPushManager():UpdateSoldierPush(event:FinishTime(),title,pushIdentity)
    end
end
function SoldierManager:CancelSoldierLocalPush(event)
    if ext and ext.localpush then
        local pushIdentity = event:Id()..event:Name()
        app:GetPushManager():CancelSoldierPush(pushIdentity)
    end
end
function SoldierManager:OnUserDataChanged(user_data,current_time, deltaData)
    local is_fully_update = deltaData == nil
    if is_fully_update then
        local soldiers = {}
        local woundedSoldiers = {}
        local soldierStars = {}
        soldiers = user_data.soldiers
        woundedSoldiers = user_data.woundedSoldiers
        soldierStars = user_data.soldierStars
    end
    local is_delta_update = not is_fully_update and deltaData.soldiers ~= nil
    if is_delta_update then
        local soldier_map = self.soldier_map
        local changed = {}
        local old_soldier = {}
        for k, new in pairs(deltaData.soldiers) do
            local old = soldier_map[k]
            soldier_map[k] = new
            table.insert(changed, k)
            old_soldier[k] = {old = old,new = new}
        end
        if #changed > 0 then
            -- 士兵增加提示
            if display.getRunningScene().__cname ~= "MainScene" then
                local get_list = ""
                for k,v in pairs(old_soldier) do
                    local add = v.new-v.old
                    if add>0 then
                        local m_name = Localize.soldier_name[k]
                        get_list = get_list .. (get_list == "" and "" or ",") .. m_name .. "X"..add
                    end
                end
                if get_list ~="" then
                    if deltaData.treatSoldierEvents and deltaData.treatSoldierEvents.remove then
                        GameGlobalUI:showTips(_("治愈士兵完成"),get_list)
                    elseif deltaData.soldierEvents and deltaData.soldierEvents.remove then
                        GameGlobalUI:showTips(_("招募士兵完成"),get_list)
                    end
                end
            end
        end
    end

    is_delta_update = not is_fully_update and deltaData.militaryTechs ~= nil
    --军事科技
    if is_fully_update then
        -- self:OnMilitaryTechsDataChanged(user_data.militaryTechs)
        -- self:OnMilitaryTechEventsChanged(user_data.militaryTechEvents)
        -- self:OnSoldierStarEventsChanged(user_data.soldierStarEvents)
    elseif is_delta_update then
        -- self:OnPartOfMilitaryTechsDataChanged(deltaData.militaryTechs)
    end


    is_delta_update = not is_fully_update and deltaData.militaryTechEvents ~= nil
    if is_delta_update then
        -- self:__OnMilitaryTechEventsChanged(deltaData.militaryTechEvents)
    end

    -- 士兵升星
    is_delta_update = not is_fully_update and deltaData.soldierStarEvents ~= nil
    if is_delta_update then
        -- self:__OnSoldierStarEventsChanged(deltaData.soldierStarEvents)
    end

end

-- function SoldierManager:OnMilitaryTechsDataChanged(militaryTechs)
--     if not militaryTechs then return end
--     self.militaryTechs = {}
--     for name,v in pairs(militaryTechs) do
--         local militaryTechnology = MilitaryTechnology.new()
--         militaryTechnology:UpdateData(name,v)
--         self.militaryTechs[name] = militaryTechnology
--     end

--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED, function(listener)
--         listener:OnMilitaryTechsDataChanged(self,self.militaryTechs)
--     end)
-- end
-- function SoldierManager:OnPartOfMilitaryTechsDataChanged(militaryTechs)
--     local changed_map = {}
--     for k,v in pairs(militaryTechs) do
--         if self.militaryTechs[k] then
--             self.militaryTechs[k]:UpdateData(k,v)
--             changed_map[k] = self.militaryTechs[k]
--         end
--     end
--     for k,v in pairs(changed_map) do
--         GameGlobalUI:showTips(_("军事科技升级完成"),v:GetTechLocalize().."Lv"..v:Level())
--     end
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED, function(listener)
--         listener:OnMilitaryTechsDataChanged(self,changed_map)
--     end)
-- end
-- function SoldierManager:OnMilitaryTechEventsChanged(militaryTechEvents)
--     if not militaryTechEvents then return end
--     self.militaryTechEvents = {}
--     for i,v in ipairs(militaryTechEvents) do
--         local event = MilitaryTechEvents.new()
--         event:UpdateData(v)
--         event:AddObserver(self)
--         self.militaryTechEvents[event:Id()] = event
--         self:GeneralMilitaryTechLocalPush(event)
--     end
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_ALL_CHANGED, function(listener)
--         listener:OnMilitaryTechEventsAllChanged(self,self.militaryTechEvents)
--     end)
-- end
-- function SoldierManager:__OnMilitaryTechEventsChanged(__militaryTechEvents)
--     if not __militaryTechEvents then return end
--     local added,edited,removed = {},{},{}
--     local changed_map = {added,edited,removed}
--     local add = __militaryTechEvents.add
--     local edit = __militaryTechEvents.edit
--     local remove = __militaryTechEvents.remove
--     if add then
--         for k,data in pairs(add) do
--             local event = MilitaryTechEvents.new()
--             event:UpdateData(data)
--             self.militaryTechEvents[event:Id()] = event
--             event:AddObserver(self)
--             table.insert(added, event)

--             self:GeneralMilitaryTechLocalPush(event)
--         end
--     end
--     if edit then
--         for k,data in pairs(edit) do
--             local event = self.militaryTechEvents[data.id]
--             event:UpdateData(data)
--             table.insert(edited, event)
--             self:GeneralMilitaryTechLocalPush(event)
--         end
--     end
--     if remove then
--         for k,data in pairs(remove) do
--             local event = self.militaryTechEvents[data.id]
--             event:Reset()
--             self.militaryTechEvents[data.id] = nil
--             event = MilitaryTechEvents.new()
--             event:UpdateData(data)
--             table.insert(removed, event)
--             self:CancelMilitaryTechLocalPush(event)
--         end
--     end
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED, function(listener)
--         listener:OnMilitaryTechEventsChanged(self,changed_map)
--     end)
-- end
-- function SoldierManager:OnSoldierStarEventsChanged(soldierStarEvents)
--     if not soldierStarEvents then return end
--     self.soldierStarEvents = {}
--     for i,v in ipairs(soldierStarEvents) do
--         local event = SoldierStarEvents.new()
--         event:UpdateData(v)
--         event:AddObserver(self)
--         self.soldierStarEvents[event:Id()] = event
--         self:GeneralSoldierLocalPush(event)
--     end
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.ALL_SOLDIER_STAR_EVENTS_CHANGED, function(listener)
--         listener:OnAllSoldierStarEventsChanged(self,self.soldierStarEvents)
--     end)
-- end
-- function SoldierManager:__OnSoldierStarEventsChanged(__soldierStarEvents)
--     if not __soldierStarEvents then return end
--     local added,edited,removed = {},{},{}
--     local changed_map = {added,edited,removed}
--     local add = __soldierStarEvents.add
--     local edit = __soldierStarEvents.edit
--     local remove = __soldierStarEvents.remove
--     if add then
--         for k,data in pairs(add) do
--             local event = SoldierStarEvents.new()
--             event:UpdateData(data)
--             event:AddObserver(self)
--             self.soldierStarEvents[event:Id()] = event
--             table.insert(added, event)
--             self:GeneralSoldierLocalPush(event)
--         end
--     end
--     if edit then
--         for k,data in pairs(edit) do
--             local event = self.soldierStarEvents[data.id]
--             event:UpdateData(data)
--             table.insert(edited, event)
--             self:GeneralSoldierLocalPush(event)
--         end
--     end
--     if remove then
--         for k,data in pairs(remove) do
--             local event = self.soldierStarEvents[data.id]
--             event:Reset()
--             self.soldierStarEvents[data.id] = nil
--             local event = SoldierStarEvents.new()
--             event:UpdateData(data)
--             table.insert(removed, event)
--             self:CancelSoldierLocalPush(event)
--         end
--     end

--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED, function(listener)
--         listener:OnSoldierStarEventsChanged(self,changed_map)
--     end)
-- end
-- function SoldierManager:OnSoldierStarEventsTimer(star_event)
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.OnSoldierStarEventsTimer,function(listener)
--         listener.OnSoldierStarEventsTimer(listener,star_event)
--     end)
-- end
-- function SoldierManager:OnMilitaryTechEventsTimer(tech_event)
--     self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.OnMilitaryTechEventsTimer,function(listener)
--         listener.OnMilitaryTechEventsTimer(listener,tech_event)
--     end)
-- end
return SoldierManager

































