--
-- Author: Danny He
-- Date: 2014-10-27 21:33:54
--
local Enum = import("app.utils.Enum")
local property = import("app.utils.property")
local MultiObserver = import("app.entity.MultiObserver")
local DragonManager = class("DragonManager", MultiObserver)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local Dragon = import(".Dragon")
local promise = import("..utils.promise")
DragonManager.promise_callbacks = {}
local DragonEvent = import(".DragonEvent")

DragonManager.DRAGON_TYPE_INDEX = Enum("redDragon","greenDragon","blueDragon")
DragonManager.LISTEN_TYPE = Enum("OnHPChanged","OnBasicChanged","OnDragonHatched","OnDragonEventChanged","OnDragonEventTimer","OnDefencedDragonChanged")


function DragonManager:ctor()
    DragonManager.super.ctor(self)
    self.dragons_hp = {}
    self.dragon_events = {}
end

function DragonManager:GetDragonByIndex(index)
    local dragon_type = DragonManager.DRAGON_TYPE_INDEX[index]
    return self:GetDragon(dragon_type)
end

function DragonManager:GetDragon(dragon_type)
    if not dragon_type then return nil end
    return self.dragons_[dragon_type]
end
--获取驻防的龙
function DragonManager:GetDefenceDragon()
    for k,dragon in pairs(self:GetDragons()) do
        if dragon:IsDefenced() then
            return dragon
        end
    end
    return nil
end

function DragonManager:GetPowerfulDragonType()
    local dragonWidget = 0
    local dragonType = ""
    for k,dragon in pairs(self:GetDragons()) do
        if dragon:GetWeight() > dragonWidget then
            dragonWidget = dragon:GetWeight()
            dragonType = k
        end
    end
    return dragonType
end

function DragonManager:GetCanFightPowerfulDragonType()
    local dragonWidget = 0
    local dragonType = ""
    for k,dragon in pairs(self:GetDragons()) do
        if dragon:Status()=="free" and not dragon:IsDead() then
            if dragon:GetWeight() > dragonWidget then
                dragonWidget = dragon:GetWeight()
                dragonType = k
            end
        end
    end
    return dragonType
end

function DragonManager:AddDragon(dragon)
    self.dragons_[dragon:Type()] = dragon
end

function DragonManager:GetDragons()
    return self.dragons_
end
-- 获取战力高-低的龙list
function DragonManager:GetDragonsSortWithPowerful()
    local dragon_list = {}
    for k,v in pairs(self.dragons_) do
        if v:Ishated() then
            table.insert(dragon_list, v)
        end
    end
    table.sort( dragon_list, function(a,b)
        return a:GetWeight() > b:GetWeight()
    end )
    return dragon_list
end

function DragonManager:OnUserDataChanged(user_data, current_time, location_id, sub_location_id,hp_recovery_perHour)
    self:RefreshDragonData(user_data.dragons,current_time,hp_recovery_perHour)
    self:RefreshDragonEvents(user_data.dragonEvents)
    self:RefreshDragonEvents__(user_data.__dragonEvents)
end

function DragonManager:GetDragonEventByDragonType(dragon_type)
    return self.dragon_events[dragon_type]
end

function DragonManager:RefreshDragonEvents(dragonEvents)
    if not dragonEvents then return end
    for _,v in ipairs(dragonEvents) do
        if not self.dragon_events[v.dragonType] then
            local dragonEvent = DragonEvent.new()
            dragonEvent:UpdateData(v)
            self.dragon_events[dragonEvent:DragonType()] = dragonEvent
            dragonEvent:AddObserver(self)
        end
    end
end

function DragonManager:IteratorDragonEvents(func)
    for _,dragonEvent in pairs(self.dragon_events) do
        func(dragonEvent)
    end
end

function DragonManager:RefreshDragonEvents__(__dragonEvents)
    if not __dragonEvents then return end
    local changed_map = GameUtils:Event_Handler_Func(
        __dragonEvents
        ,function(event_data)
            local dragonEvent = DragonEvent.new()
            dragonEvent:UpdateData(event_data)
            self.dragon_events[dragonEvent:DragonType()] = dragonEvent
            dragonEvent:AddObserver(self)
            return dragonEvent
        end
        ,function(event_data)
        --TODO:修改孵化事件
        end
        ,function(event_data)
            if self.dragon_events[event_data.dragonType] then
                local dragonEvent = self.dragon_events[event_data.dragonType]
                dragonEvent:Reset()
                self.dragon_events[event_data.dragonType] = nil
                dragonEvent = DragonEvent.new()
                dragonEvent:UpdateData(event_data)
                return dragonEvent
            end
        end
    )
    self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnDragonEventChanged,function(lisenter)
        lisenter.OnDragonEventChanged(lisenter,GameUtils:pack_event_table(changed_map))
    end)
end

function DragonManager:OnDragonEventTimer(dragonEvent)
    self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnDragonEventTimer,function(lisenter)
        lisenter.OnDragonEventTimer(lisenter,dragonEvent)
    end)
end

function DragonManager:RefreshDragonData( dragons,resource_refresh_time,hp_recovery_perHour)
    if not dragons then return end
    if not self.dragons_ then -- 初始化龙信息
        self.dragons_ = {}
        for k,v in pairs(dragons) do
            local dragon = Dragon.new(k,v.strength,v.vitality,v.status,v.star,v.level,v.exp,v.hp or 0)
            dragon:UpdateEquipmetsAndSkills(v)
            self:AddDragon(dragon)
            self:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
        end
    else
        --遍历更新龙信息
        if not dragons then return end
        local need_notify_defence = false
        for k,v in pairs(dragons) do
            local dragon = self:GetDragon(k)
            if dragon then
                local dragonIsHated_ = dragon:Ishated()
                local isDefenced = dragon:IsDefenced()
                dragon:Update(v) -- include UpdateEquipmetsAndSkills
                if not need_notify_defence then
                    need_notify_defence = isDefenced ~= dragon:IsDefenced()
                end
                if dragonIsHated_ ~= dragon:Ishated() then
                    self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnDragonHatched,function(lisenter)
                        lisenter.OnDragonHatched(lisenter,dragon)
                    end)
                else
                    self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnBasicChanged,function(lisenter)
                        lisenter.OnBasicChanged(lisenter)
                    end)
                end
            end
            self:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
        end
        if need_notify_defence then
            self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnDefencedDragonChanged,function(lisenter)
                    lisenter.OnDefencedDragonChanged(lisenter,self:GetDefenceDragon())
            end)
        end
    end
    self:CheckFinishEquipementDragonPormise()
end


function DragonManager:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
    if dragon:Ishated() then
        local hp_resource = self:AddHPResource(dragon:Type())
        hp_resource:UpdateResource(resource_refresh_time,dragon:Hp())
        hp_resource:SetProductionPerHour(resource_refresh_time,hp_recovery_perHour)
        hp_resource:SetValueLimit(dragon:GetMaxHP())
    end
end

-- HP
function DragonManager:AddHPResource(dragon_type)
    if not self:GetHPResource(dragon_type) then
        self.dragons_hp[dragon_type] = AutomaticUpdateResource.new()
    end
    return self:GetHPResource(dragon_type)
end


function DragonManager:GetHPResource(dragon_type)
    return self.dragons_hp[dragon_type]
end

function DragonManager:GetCurrentHPValueByDragonType(dragon_type)
    if not self:GetHPResource(dragon_type) then
        return -1
    end
    return self:GetHPResource(dragon_type):GetResourceValueByCurrentTime(app.timer:GetServerTime())
end

function DragonManager:UpdateHPResourceByTime(current_time)
    for _, v in pairs(self.dragons_hp) do
        v:OnTimer(current_time)
    end
end

function DragonManager:OnTimer(current_time)
    self:UpdateHPResourceByTime(current_time)
    self:OnHPChanged()
    self:IteratorDragonEvents(function(dragonEvent)
        dragonEvent:OnTimer(current_time)
    end)
end

function DragonManager:OnHPChanged()
    self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnHPChanged,function(lisenter)
        lisenter.OnHPChanged(lisenter)
    end)
end

--充能每次消耗的能量值
function DragonManager:GetEnergyCost()
    return 20
end

--新手引导
function DragonManager:PromiseOfFinishEquipementDragon()
    local p = promise.new()
    table.insert(self.promise_callbacks, function(dragon)
        if dragon:Ishated() then
            for _,eq in pairs(dragon:Equipments()) do
                if eq:IsLoaded() then
                    return p:resolve()
                end
            end
        end
    end)
    return p
end

function DragonManager:CheckFinishEquipementDragonPormise()
    for _,dragon in pairs(self:GetDragons()) do
        if #self.promise_callbacks > 0 and self.promise_callbacks[1](dragon) then
            table.remove(self.promise_callbacks, 1)
        end
    end

end

return DragonManager

