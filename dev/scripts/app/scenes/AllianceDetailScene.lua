local Alliance = import("..entity.Alliance")
local AllianceLayer = import("..layers.AllianceLayer")
local GameUIAllianceHome = import("..ui.GameUIAllianceHome")
local MapScene = import(".MapScene")
local AllianceDetailScene = class("AllianceDetailScene", MapScene)


function AllianceDetailScene:OnAllianceDataChanged_mapObjects(allianceData, deltaData)
    self:HandleMapObjects(allianceData.mapIndex, "remove", deltaData("mapObjects.edit"))
    self:HandleMapObjects(allianceData.mapIndex, "edit", deltaData("mapObjects.edit"))
    self:HandleMapObjects(allianceData.mapIndex, "add", deltaData("mapObjects.edit"))
end
function AllianceDetailScene:HandleMapObjects(mapIndex, op, ok, value)
    local alliance = Alliance_Manager:GetAllianceByCache(mapIndex)
    if not ok then return end
    if op == "edit" then
        for _,mapObj in pairs(value) do
            self:GetSceneLayer():RemoveMapObjectByIndex(mapIndex, mapObj, alliance)
        end
    elseif op == "add" then
        for _,mapObj in pairs(value) do
            self:GetSceneLayer():AddMapObjectByIndex(mapIndex, mapObj, alliance)
        end
    elseif op == "remove" then
        for _,mapObj in pairs(value) do
            self:GetSceneLayer():RemoveMapObjectByIndex(mapIndex, mapObj)
        end
    end
end

-- 
function AllianceDetailScene:OnAllianceDataChanged_marchEvents(allianceData, deltaData)
    -- 进攻
    self:HandleEvents("remove", false, deltaData("marchEvents.attackMarchEvents.remove"))
    self:HandleEvents("add", false, deltaData("marchEvents.attackMarchEvents.add"))
    self:HandleEvents("edit", false, deltaData("marchEvents.attackMarchEvents.edit"))
    -- 返回
    self:HandleEvents("remove", false, deltaData("marchEvents.attackMarchReturnEvents.remove"))
    self:HandleEvents("add", false, deltaData("marchEvents.attackMarchReturnEvents.add"))
    self:HandleEvents("edit", false, deltaData("marchEvents.attackMarchReturnEvents.edit"))
end
function AllianceDetailScene:HandleEvents(op, isReturn, ok, value)
    if not ok then return end
    if op == "add" 
    or op == "edit" then
        if isReturn then
            for _,event in pairs(value) do
                self:CreateOrUpdateOrDeleteCorpsByReturnEvent(event.id, event)
            end
        else
            for _,event in pairs(value) do
                self:CreateOrUpdateOrDeleteCorpsByEvent(event.id, event)
            end
        end
    elseif op == "remove" then
        for _,event in pairs(value) do
            self:GetSceneLayer():DeleteCorpsById(event.id)
        end
    end
end
-- other
function AllianceDetailScene:OnEnterMapIndex(mapData)
    for id,event in pairs(mapData.marchEvents.strikeMarchEvents) do
        self:CreateOrUpdateOrDeleteCorpsByEvent(id, event)
    end
    for id,event in pairs(mapData.marchEvents.strikeMarchReturnEvents) do
        self:CreateOrUpdateOrDeleteCorpsByReturnEvent(id,event)
    end
    for id,event in pairs(mapData.marchEvents.attackMarchEvents) do
        self:CreateOrUpdateOrDeleteCorpsByEvent(id, event)
    end
    for id,event in pairs(mapData.marchEvents.attackMarchReturnEvents) do
        self:CreateOrUpdateOrDeleteCorpsByReturnEvent(id,event)
    end
end
function AllianceDetailScene:OnMapDataChanged(mapData, deltaData)
    local ok, value = deltaData("marchEvents.strikeMarchEvents")
    if ok then
        for id,_ in pairs(value) do
            local event = mapData.marchEvents.strikeMarchEvents[id]
            self:CreateOrUpdateOrDeleteCorpsByEvent(id, event)
        end
    end

    local ok, value = deltaData("marchEvents.strikeMarchReturnEvents")
    if ok then
        for id,_ in pairs(value) do
            local event = mapData.marchEvents.strikeMarchReturnEvents[id]
            self:CreateOrUpdateOrDeleteCorpsByReturnEvent(id, event)
        end
    end

    local ok, value = deltaData("marchEvents.attackMarchEvents")
    if ok then
        for id,_ in pairs(value) do
            local event = mapData.marchEvents.attackMarchEvents[id]
            self:CreateOrUpdateOrDeleteCorpsByEvent(id, event)
        end
    end

    local ok, value = deltaData("marchEvents.attackMarchReturnEvents")
    if ok then
        for id,_ in pairs(value) do
            local event = mapData.marchEvents.attackMarchReturnEvents[id]
            self:CreateOrUpdateOrDeleteCorpsByReturnEvent(id, event)
        end
    end
end
function AllianceDetailScene:OnAllianceMapChanged(allianceData, deltaData)
    if deltaData("mapObjects") then
        self:OnAllianceDataChanged_mapObjects(allianceData, deltaData)
    end
end
local function getAllyFromEvent(event, is_back)
    local MINE,FRIEND,ENEMY = 1,2,3
    if event.attackPlayerData.id == User:Id() then
        return MINE
    end
    local alliance_id = is_back and event.toAlliance.id or event.fromAlliance.id
    if alliance_id == Alliance_Manager:GetMyAlliance()._id then
        return FRIEND
    end
    return ENEMY
end
function AllianceDetailScene:CreateOrUpdateOrDeleteCorpsByEvent(id, event)
    if event == json.null then
        self:GetSceneLayer():DeleteCorpsById(id)
    elseif event then
        self:GetSceneLayer():CreateOrUpdateCorps(
            event.id,
            {x = event.fromAlliance.location.x, y = event.fromAlliance.location.y, index = event.fromAlliance.mapIndex},
            {x = event.toAlliance.location.x, y = event.toAlliance.location.y, index = event.toAlliance.mapIndex},
            event.startTime / 1000,
            event.arriveTime / 1000,
            event.attackPlayerData.dragon.type,
            event.attackPlayerData.soldiers,
            getAllyFromEvent(event),
            string.format("[%s]%s", event.fromAlliance.tag, event.attackPlayerData.name)
        )
    end
end
function AllianceDetailScene:CreateOrUpdateOrDeleteCorpsByReturnEvent(id, event)
    if event == json.null then
        self:GetSceneLayer():DeleteCorpsById(id)
    elseif event then
        self:GetSceneLayer():CreateOrUpdateCorps(
            event.id,
            {x = event.toAlliance.location.x, y = event.toAlliance.location.y, index = event.toAlliance.mapIndex},
            {x = event.fromAlliance.location.x, y = event.fromAlliance.location.y, index = event.fromAlliance.mapIndex},
            event.startTime / 1000,
            event.arriveTime / 1000,
            event.attackPlayerData.dragon.type,
            event.attackPlayerData.soldiers,
            getAllyFromEvent(event),
            string.format("[%s]%s", event.fromAlliance.tag, event.attackPlayerData.name)
        )
    end
end


function AllianceDetailScene:ctor(targetAllianceMapIndex,x,y)
    AllianceDetailScene.super.ctor(self)
    self.fetchtimer = display.newNode():addTo(self)
    self.amintimer = display.newNode():addTo(self)
    self.targetAllianceMapIndex = targetAllianceMapIndex
    self.goto_x = x
    self.goto_y = y
    self.visible_alliances = {}
    Alliance_Manager:ClearCache()
    Alliance_Manager:UpdateAllianceBy(Alliance_Manager:GetMyAlliance().mapIndex, Alliance_Manager:GetMyAlliance())
end
function AllianceDetailScene:onEnter()
    AllianceDetailScene.super.onEnter(self)
    local alliance = Alliance_Manager:GetMyAlliance()
    self:GotoAllianceByIndex(self.targetAllianceMapIndex or alliance.mapIndex)
    if self.goto_x and self.goto_y then
        self:GotoPosition(self.goto_x,self.goto_y)
    end
    self.home_page = self:CreateHomePage()
    self:GetSceneLayer():ZoomTo(0.82)
    alliance:AddListenOnType(self, "mapObjects")
    alliance:AddListenOnType(self, "marchEvents")
    Alliance_Manager:SetAllianceHandle(self)


    for _,events in pairs(alliance.marchEvents) do
        for _,v in ipairs(events) do
            self:CreateOrUpdateOrDeleteCorpsByEvent(v.id, v)
        end
    end
end
function AllianceDetailScene:onExit()
    if self.current_allinace_index then
        NetManager:getLeaveMapIndexPromise(self.current_allinace_index)
    end
    Alliance_Manager:SetAllianceHandle(nil)
    Alliance_Manager:ClearCache()
    Alliance_Manager:ResetCurrentMapData()
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, "mapObjects")
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, "marchEvents")
end
function AllianceDetailScene:FetchAllianceDatasByIndex(index, func)
    if self.current_allinace_index and self.current_allinace_index ~= index then
        NetManager:getLeaveMapIndexPromise(self.current_allinace_index)
        self.current_allinace_index = nil
    end
    if Alliance_Manager:GetMyAlliance().mapIndex == index then
        self.fetchtimer:stopAllActions()
        self.amintimer:stopAllActions()
        self.current_allinace_index = nil
    elseif self.current_allinace_index ~= index then
        self.fetchtimer:stopAllActions()
        self.amintimer:stopAllActions()
        self.fetchtimer:performWithDelay(function()
            NetManager:getEnterMapIndexPromise(index)
                :done(function(response)
                    self.current_allinace_index = index
                    Alliance_Manager:UpdateAllianceBy(index, response.msg.allianceData)
                    Alliance_Manager:OnEnterMapIndex(response.msg.mapData)
                    if type(func) == "function" then
                        func(response.msg)
                    end
                    self.amintimer:stopAllActions()
                    self.amintimer:schedule(function()
                        NetManager:getAmInMapIndexPromise(self.current_allinace_index)
                    end, 10)
                    self.home_page:RefreshTop(true)
                end)
        end, 0.5)
    end
end
function AllianceDetailScene:CreateHomePage()
    local home_page = GameUIAllianceHome.new(Alliance_Manager:GetMyAlliance()):addTo(self)
    home_page:setTouchSwallowEnabled(false)
    return home_page
end
function AllianceDetailScene:GetHomePage()
    return self.home_page
end
function AllianceDetailScene:CreateSceneLayer()
    return AllianceLayer.new(self)
end
function AllianceDetailScene:GotoAllianceByIndex(index)
    self:GotoAllianceByXY(self:GetSceneLayer():IndexToLogic(index))
    self:FetchAllianceDatasByIndex(index, function(data)
        self:GetSceneLayer():LoadAllianceByIndex(index, data.allianceData)
    end)
end
function AllianceDetailScene:GotoAllianceByXY(x, y)
    local point = self:GetSceneLayer():ConvertLogicPositionToAlliancePosition(x,y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function AllianceDetailScene:GotoPosition(x,y)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(x,y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function AllianceDetailScene:OnTouchEnd(pre_x, pre_y, x, y, ismove)
    if not ismove then
        if self.current_allinace_index ~= self:GetSceneLayer():GetMiddleAllianceIndex() then

        end
    end
end
function AllianceDetailScene:OnTouchMove(...)
    AllianceDetailScene.super.OnTouchMove(self, ...)
end
function AllianceDetailScene:OnTouchExtend(old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond, is_end)
    AllianceDetailScene.super.OnTouchExtend(self, old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond, is_end)
    if is_end then
        local index = self:GetSceneLayer():GetMiddleAllianceIndex()
    end
end
function AllianceDetailScene:OnTouchClicked(pre_x, pre_y, x, y)
    if self:IsFingerOn() then
        return
    end
    local mapObj = self:GetSceneLayer():GetClickedObject(x, y)
    if mapObj then
        local alliance = Alliance_Manager:GetAllianceByCache(mapObj.index)
        if alliance then
            print(mapObj.index, mapObj.x, mapObj.y, mapObj.name)
            -- UIKit:newGameUI("GameUIAllianceBase", alliance, mapObj.x, mapObj.y, mapObj.name):AddToCurrentScene(true)
            if Alliance:GetMapObjectType(mapObj) ~= "building" then
                self:EnterNotAllianceBuilding(alliance,mapObj)
            else
                self:EnterAllianceBuilding(alliance,mapObj)
            end
        end
    end
end
function AllianceDetailScene:OnSceneMove()
    AllianceDetailScene.super.OnSceneMove(self)
    self:UpdateVisibleAllianceBg()
    self:UpdateCurrrentAlliance()
    self:UpdateHomePage()
end
function AllianceDetailScene:UpdateVisibleAllianceBg()
    local old_visibles = self.visible_alliances
    local new_visibles = {}
    for _,k in pairs(self:GetSceneLayer():GetVisibleAllianceIndexs()) do
        if not old_visibles[k] then
            self:GetSceneLayer():LoadAllianceByIndex(k, Alliance_Manager:GetAllianceByCache(k))
            new_visibles[k] = true
        end
        new_visibles[k] = true
    end
    self.visible_alliances = new_visibles
end
function AllianceDetailScene:UpdateCurrrentAlliance()
    local index = self:GetSceneLayer():GetMiddleAllianceIndex()
    self:FetchAllianceDatasByIndex(index, function(data)
        self:GetSceneLayer():LoadAllianceByIndex(index, data.allianceData)
    end)
end
function AllianceDetailScene:UpdateHomePage()
    if self:GetHomePage() then
        self:GetHomePage():UpdateCoordinate(self:GetSceneLayer():GetMiddlePosition())
    end
end
function AllianceDetailScene:EnterAllianceBuilding(alliance,mapObj)
    if mapObj.name then
        local building_name = mapObj.name
        local class_name = ""
        if building_name == 'shrine' then
            class_name = "GameUIAllianceShrineEnter"
        elseif building_name == 'palace' then
            class_name = "GameUIAlliancePalaceEnter"
        elseif building_name == 'shop' then
            class_name = "GameUIAllianceShopEnter"
        elseif building_name == 'orderHall' then
            class_name = "GameUIAllianceOrderHallEnter"
        elseif building_name == 'watchTower' then
            class_name = "GameUIAllianceWatchTowerEnter"
        else
            print("没有此建筑--->",building_name)
            return
        end
        UIKit:newGameUI(class_name,mapObj,alliance):AddToCurrentScene(true)
    end
end

function AllianceDetailScene:EnterNotAllianceBuilding(alliance,mapObj)
    local isMyAlliance = true
    local type_ = Alliance:GetMapObjectType(mapObj)
    print("type_=====",type_)
    dump(type_)
    local class_name = ""

    if tolua.type(type_) == 'table' then
        if alliance.mapIndex == Alliance_Manager:GetMyAlliance().mapIndex then
            class_name = "GameUIAllianceEnterBase"
        else
            return
        end
    elseif type_ == 'member' then
        app:GetAudioManager():PlayBuildingEffectByType("keep")
        class_name = "GameUIAllianceCityEnter"
    elseif type_ == 'decorate' then
        -- class_name = "GameUIAllianceDecorateEnter"
        return
    elseif type_ == 'village' then
        app:GetAudioManager():PlayBuildingEffectByType("warehouse")
        class_name = "GameUIAllianceVillageEnter"
        -- if not alliance:FindAllianceVillagesInfoByObject(mapObj) then -- 废墟
        --     class_name = "GameUIAllianceRuinsEnter"
        -- end
    elseif type_ == 'monster' then
        if not alliance:FindAllianceMonsterInfoByObject(mapObj) then
            return
        end
        class_name = "GameUIAllianceMosterEnter"
    end
    UIKit:newGameUI(class_name,mapObj or type_,alliance):AddToCurrentScene(true)

end
return AllianceDetailScene

















