local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local Orient = import("..entity.Orient")
local BuildingSprite = class("BuildingSprite", function()
    return display.newNode()
end)


BuildingSprite.SPRITE_TAG = 6



-- 地表测试
BuildingSprite.BASE_TAG = 1
BuildingSprite.BASE_Z = 1
BuildingSprite.BASE_BUTTON_Z = 100
BuildingSprite.BASE_LABEL_Z = 101
function BuildingSprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("tile.png", 10)
    for ix = start_x, end_x do
        for iy = start_y, end_y do
            local sprite = display.newSprite(base_node:getTexture(), CCRectMake(0, 0, 80, 56))
            sprite:setPosition(cc.p(self.belong_scene.iso_map:ConvertToLocalPosition(ix, iy)))
            base_node:addChild(sprite)
        end
    end
    return base_node
end
function BuildingSprite:GenerateBaseTiles(w, h)
    local base_node = self:newBatchNode(w, h)
    self:addChild(base_node, BuildingSprite.BASE_Z, BuildingSprite.BASE_TAG)
end
function BuildingSprite:DestroyBaseTiles()
    self:getChildByTag(BuildingSprite.BASE_TAG):removeFromParentAndCleanup(true)
end
function BuildingSprite:GetLocalRegion(w, h)
    local start_x, end_x, start_y, end_y
    local is_orient_x = w > 0
    local is_orient_neg_x = not is_orient_x
    local is_orient_y = h > 0
    local is_orient_neg_y = not is_orient_y
    if is_orient_x then
        start_x, end_x = 0, w - 1
    elseif is_orient_neg_x then
        start_x, end_x = w + 1, 0
    end
    if is_orient_y then
        start_y, end_y = 0, h - 1
    elseif is_orient_neg_y then
        start_y, end_y = h + 1, 0
    end
    return start_x, end_x, start_y, end_y
end


-- 事件通知
function BuildingSprite:OnSceneMove()
    local wp = self:getParent():convertToWorldSpace(cc.p(self:GetCenterPosition()))
    if self.lock_button then
        self.lock_button:OnSceneMove(wp)
    end
    if self.confirm_button then
        self.confirm_button:OnSceneMove(wp)
    end
    if self.dialog then
        self.dialog:OnSceneMove(wp)
    end
end
function BuildingSprite:OnOrientChanged(old_orient, new_orient, new_w, new_h)
    self:DestroyBaseTiles()
    self:GenerateBaseTiles(new_w, new_h)
    self:getChildByTag(self.SPRITE_TAG):setFlipX(new_orient == Orient.X)
    self:getChildByTag(self.SPRITE_TAG):setPosition(cc.p(sprite:isFlipX() and -60 or 60, 210))
end
function BuildingSprite:OnLogicPositionChanged(x, y)
    self:setPosition(self.belong_scene.iso_map:ConvertToMapPosition(x, y))
    self:OnSceneMove()
end
function BuildingSprite:OnBuildingUpgradingBegin(building, time)
    self.label:setString(building:GetType().." "..building:GetLevel())
end
function BuildingSprite:OnBuildingUpgradeFinished(building, time)
    self.label:setString(building:GetType().." "..building:GetLevel())
end
function BuildingSprite:OnBuildingUpgrading(building, time)
    self.label:setString("upgrading "..building:GetLevel().."\n"..math.round(building:GetUpgradingLeftTimeByCurrentTime(time)))
end
function BuildingSprite:OnTileLocked(city, tile_x, tile_y)
    local tile = city:GetTileWhichBuildingBelongs(self:GetEntity())
    if city:IsUnLockedAtIndex(tile.x, tile.y) then
        self:TranslateToUnlock()
    elseif city:IsTileCanbeUnlockAt(tile.x, tile.y) then
        self:TranslateToLock()
    else
        self:TranslateToCanNotUnlock()
    end
end
function BuildingSprite:OnTileUnlocked(city, tile_x, tile_y)
    function FunctionUpgradingSprite:OnTileChanged(city, tile)
    local current_tile = city:GetTileWhichBuildingBelongs(self:GetEntity())
    if current_tile:IsUnlocked() then
        self:TranslateToUnlock()
    elseif self:GetEntity():IsUpgrading() then 
        self:TranslateToUpgrading()
    elseif city:IsTileCanbeUnlockAt(current_tile.x, current_tile.y) then
        if city:GetFirstBuildingByType("keep"):GetFreeUnlockPoint(city) > 0 then
            self:TranslateToCanbeUnlock()
        else
            self:TranslateToCanNotBeUnlock()
        end 
    else
        self:TranslateToCanNotBeUnlock()
    end
end
end
-- 委托
function BuildingSprite:IsContainPoint(x, y)
    return self.building:IsContainPoint(x, y)
end
function BuildingSprite:GetCenterPosition()
    local x, y = self:getPosition()
    local w, h = self:GetSize()
    local local_center_x, local_center_y = self.belong_scene.iso_map:ConvertToLocalPosition((w - 1) / 2, (h - 1) / 2)
    return x + local_center_x, y + local_center_y
end
function BuildingSprite:SetLogicPosition(logic_x, logic_y)
    self.building:SetLogicPosition(logic_x, logic_y)
end
function BuildingSprite:GetLogicPosition()
    return self.building.x, self.building.y
end
function BuildingSprite:GetSize()
    return self.building.w, self.building.h
end
function BuildingSprite:GetOrient()
    return self.building:GetOrient()
end
function BuildingSprite:SetOrient(orient)
    self.building:SetOrient(orient)
end

--
function BuildingSprite:GetEntity()
    return self.building
end
function BuildingSprite:ctor(building_info)
    self.building = building_info.building
    self.belong_scene = building_info.belong_scene
    --
    self.locked = building_info.locked == nil and true or building_info.locked
    self.can_be_unlock = building_info.can_be_unlock == nil and false or building_info.can_be_unlock
    self.lock_button = building_info.lock_button
    self.confirm_button = building_info.confirm_button
    self.dialog = building_info.dialog
    self:SetLockState(self.locked)
    --
    assert(self.building)
    self.building:AddBaseListener(self)
    if self.building.AddUpgradeListener then
        self.building:AddUpgradeListener(self)
    end

    self:GenerateBaseTiles(self:GetSize())

    if self.building then
        local label = ui.newTTFLabel({ text = "text" , x = 0, y = 0 })
        label:setPosition(cc.p(self:GetCenterPosition()))
        label:setFontSize(50)
        self:addChild(label, self.BASE_LABEL_Z, 111)
        self.label = label
        level = (self.building:GetType() == "ruins" or self.building:GetType() == "wall") and "" or self.building:GetLevel()
        label:setString(self.building:GetType().." "..level)
        if self.building:GetType() ~= "ruins" then
        -- label:setString("")
        else
        -- label:setString("")
        end
        -- label:setVisible(false)
    end

    local sprite
    if self.lock_button then
        self.lock_button.building_sprite = self
    end
    if self.confirm_button then
        self.confirm_button.building_sprite = self
    end
    if self.building then
        if self.building:GetType() == "wall" then
            if self.building:GetOrient() == Orient.X then
                if self.building:IsGate() then
                    sprite = display.newSprite("sprites/walls/gate.png")
                    sprite:setPosition(100, 120)
                else
                    sprite = display.newSprite("sprites/walls/wall_x.png")
                    sprite:setPosition(100, 120)
                end
            elseif self.building:GetOrient() == Orient.Y then
                sprite = display.newSprite("sprites/walls/wall_x.png")
                sprite:setPosition(-100, 120)
                sprite:setFlipX(true)
            elseif self.building:GetOrient() == Orient.NEG_X then
                sprite = display.newSprite("sprites/walls/wall_neg_x.png")
                sprite:setPosition(100, 120)
            elseif self.building:GetOrient() == Orient.NEG_Y then
                sprite = display.newSprite("sprites/walls/wall_neg_x.png")
                sprite:setPosition(-100, 120)
                sprite:setFlipX(true)
            end

        elseif self.building:GetType() == "tower" then
            if self.building:GetOrient() == Orient.X then
                sprite = display.newSprite("sprites/walls/tower_x.png")
                sprite:setPosition(60,92)
            elseif self.building:GetOrient() == Orient.Y then
                sprite = display.newSprite("sprites/walls/tower_x.png")
                sprite:setPosition(-60,92)
                sprite:setFlipX(true)
            elseif self.building:GetOrient() == Orient.NEG_X then
                sprite = display.newSprite("sprites/walls/tower_neg_x.png")
                sprite:setPosition(60,92)
            elseif self.building:GetOrient() == Orient.NEG_Y then
                sprite = display.newSprite("sprites/walls/tower_neg_x.png")
                sprite:setPosition(-60,92)
                sprite:setFlipX(true)
            elseif self.building:GetOrient() == Orient.RIGHT then
                sprite = display.newSprite("sprites/walls/tower_left.png")
                sprite:setPosition(-70,55)
                sprite:setFlipX(true)
            elseif self.building:GetOrient() == Orient.DOWN then
                sprite = display.newSprite("sprites/walls/tower_down.png")
                sprite:setPosition(0,92)
            elseif self.building:GetOrient() == Orient.LEFT then
                sprite = display.newSprite("sprites/walls/tower_left.png")
                sprite:setPosition(70,55)
            elseif self.building:GetOrient() == Orient.UP then
                sprite = display.newSprite("sprites/walls/tower_up.png")
                sprite:setPosition(0,-2)
            elseif self.building:GetOrient() == Orient.NONE then
                sprite = display.newSprite("sprites/walls/tower.png")
                sprite:setPosition(0, 50)
            end
        elseif self.building:GetType() == "keep" then
            sprite = display.newSprite("sprites/buildings/keep.png")
            sprite:setPosition(0, 450)
        elseif self.building:GetType() == "dragonEyrie" then
            sprite = display.newSprite("sprites/buildings/dragonEyrie.png")
            sprite:setPosition(0, 350)
        elseif self.building:GetType() == "academy" then
            sprite = display.newSprite("sprites/buildings/academy.png")
            sprite:setPosition(0, 250)
        elseif self.building:GetType() == "hunterHall" then
            sprite = display.newSprite("sprites/buildings/hunterHall.png")
            sprite:setPosition(0, 250)
        elseif self.building:GetType() == "stable" then
            sprite = display.newSprite("sprites/buildings/stable.png")
            sprite:setPosition(0, 250)
        elseif self.building:GetType() == "trainGround" then
            sprite = display.newSprite("sprites/buildings/trainGround.png")
            sprite:setPosition(0, 250)
        elseif self.building:GetType() == "workShop" then
            sprite = display.newSprite("sprites/buildings/workShop.png")
            sprite:setPosition(0, 250)
        elseif self.building:GetType() == "watchTower" then
            sprite = display.newSprite("sprites/buildings/watchTower.png")
            sprite:setPosition(-20, 320)
        elseif self.building:GetType() == "blackSmith" or
            self.building:GetType() == "academy" or
            self.building:GetType() == "workShop" or
            self.building:GetType() == "warehouse" or
            self.building:GetType() == "townHall" or
            self.building:GetType() == "stable" or
            self.building:GetType() == "hospital" or
            self.building:GetType() == "materialDepot" or
            self.building:GetType() == "armyCamp" or
            self.building:GetType() == "toolShop" or
            self.building:GetType() == "trainingGround" or
            self.building:GetType() == "foundry" or
            self.building:GetType() == "stoneMason" or
            self.building:GetType() == "lumbermill" or
            self.building:GetType() == "hunterHall" or
            self.building:GetType() == "tradeGuild" or
            self.building:GetType() == "barracks" or
            self.building:GetType() == "mill" or
            self.building:GetType() == "prison"
        then
            sprite = display.newSprite("sprites/buildings/armyCamp.png")
            sprite:setPosition(0, 180)
        elseif self.building:GetType() == "water_well" or
            self.building:GetType() == "woodcutter" or
            self.building:GetType() == "quarrier" or
            self.building:GetType() == "farmer" or
            self.building:GetType() == "dwelling" or
            self.building:GetType() == "miner"
        then
            sprite = display.newSprite("water_well.png")
            sprite:setPosition(0, 100)
        elseif self.building:GetType() == "Deco_Building_Horsestatue"
        then
            sprite = display.newSprite("Deco_Building_Horsestatue.png")
            sprite:setPosition(self.building:GetOrient() ~= Orient.Y and -60 or 60, 210)
            sprite:setFlipX(self.building:GetOrient() ~= Orient.Y)
        elseif self.building:GetType() == "ruins"
        then
            local index = (math.floor(math.random() * 1000) % 3) + 1
            local ruin_png = "sprites/buildings/ruin_"..index..".png"
            sprite = display.newSprite(ruin_png)
            sprite:setPosition(cc.p(0, 80))
        end
    end
    
    self:addChild(sprite, 2, self.SPRITE_TAG)

    if self.building:GetType() == "wall" or self.building:GetType() == "tower" then
        sprite:setVisible(false)
        self:getChildByTag(BuildingSprite.BASE_TAG):setVisible(true)
        self.locked = false
        if self.building:GetType() == "wall" and
            (self.building:GetOrient() == Orient.X or
            self.building:GetOrient() == Orient.Y or
            self.building:GetOrient() == Orient.NEG_X or
            self.building:GetOrient() == Orient.NEG_Y) then
            sprite:setVisible(true)
        end

        if self.building:GetType() == "tower" and
            (self.building:GetOrient() == Orient.X or
            self.building:GetOrient() == Orient.Y or
            self.building:GetOrient() == Orient.NEG_X or
            self.building:GetOrient() == Orient.NEG_Y or
            self.building:GetOrient() == Orient.RIGHT or
            self.building:GetOrient() == Orient.DOWN or
            self.building:GetOrient() == Orient.UP or
            self.building:GetOrient() == Orient.LEFT or
            self.building:GetOrient() == Orient.NONE) then
            sprite:setVisible(true)
        end
    else
        self:getChildByTag(BuildingSprite.BASE_TAG):setVisible(false)
    end


    if self.locked then
        -- sprite:setVisible(true)
    end




    self.states = {}
    self.states.state_can_not_be_unlock = {
        OnEnter = function()
            self:HideLock()
            self:HideDialog()
            self:HideConfirm()
            self:Gray()
            self:getChildByTag(BuildingSprite.SPRITE_TAG):setVisible(false)
        end,
        OnExit = function()
            self:Normal()
        end}

    self.states.state_can_be_unlock = {
        OnEnter = function()
            print("state_can_be_unlock")
            self:ShowLock()
            self:HideDialog()
            self:HideConfirm()
            self:Normal()
            self:getChildByTag(BuildingSprite.SPRITE_TAG):setVisible(false)
        end,
        OnExit = function()
        end}

    self.states.state_confirm = {
        OnEnter = function()
            self:HideLock()
            self:ShowDialog("unlock this building")
            self:ShowConfirm()
            self:Normal()
            self:getChildByTag(BuildingSprite.SPRITE_TAG):setVisible(false)
        end,
        OnExit = function()
        end}

    self.states.state_unlocked = {
        OnEnter = function()
            self:HideLock()
            self:HideDialog()
            self:HideConfirm()
            self:Normal()
            self:getChildByTag(BuildingSprite.SPRITE_TAG):setVisible(true)
        end,
        OnExit = function()
        end}

    if self.locked then
        if building_info.can_be_unlock then
            self.current_state = self.states.state_can_be_unlock
        else
            self.current_state = self.states.state_can_not_be_unlock
        end
    else
        self.current_state = self.states.state_unlocked
    end
    self.current_state.OnEnter()
end
-- gui 操作
function BuildingSprite:IsLocked()
    return self.locked
end
function BuildingSprite:SetLockState(locked)
    self.locked = locked
end
function BuildingSprite:ShowConfirm()
    if self.confirm_button then
        self.confirm_button:setEnabled(true)
    end
end
function BuildingSprite:HideConfirm()
    if self.confirm_button then
        self.confirm_button:setEnabled(false)
    end
end
function BuildingSprite:ShowLock()
    if self.lock_button then
        self.lock_button:setEnabled(true)
    end
end
function BuildingSprite:HideLock()
    if self.lock_button then
        self.lock_button:setEnabled(false)
    end
end
function BuildingSprite:ShowDialog(text)
    if self.dialog then
        self.dialog:setEnabled(true)
        self.dialog:getChildByTag(139):setText(text)
        if self.time_handle then
            scheduler.unscheduleGlobal(self.time_handle)
            self.time_handle = nil
        end
        self.time_handle = scheduler.performWithDelayGlobal(function()
            self:HideDialog()
        end, 2)
    end
end
function BuildingSprite:HideDialog()
    if self.dialog then
        self.dialog:setEnabled(false)
    end
end
function BuildingSprite:Gray()
    TraverseCCArray(self:getChildByTag(BuildingSprite.BASE_TAG), function(child, i)
        child:setColor(ccc3(128, 128, 128))
    end)
    self:getChildByTag(BuildingSprite.SPRITE_TAG):setColor(ccc3(128, 128, 128))
end
function BuildingSprite:Normal()
    TraverseCCArray(self:getChildByTag(BuildingSprite.BASE_TAG), function(child, i)
        child:setColor(ccc3(255, 255, 255))
    end)
    self:getChildByTag(BuildingSprite.SPRITE_TAG):setColor(ccc3(255, 255, 255))
end
-- 建筑状态
function BuildingSprite:IsInConfirmState()
    return self:IsInState("state_confirm")
end
function BuildingSprite:IsInCanNotUnlockState()
    return self:IsInState("state_can_not_be_unlock")
end
function BuildingSprite:IsInLockState()
    return self:IsInState("state_can_be_unlock")
end
function BuildingSprite:IsInUnlockState()
    return self:IsInState("state_unlocked")
end
function BuildingSprite:IsInState(state_name)
    return self.current_state == self.states[state_name]
end
function BuildingSprite:TranslateToUnlock()
    self:TranslateToState("state_unlocked")
end
function BuildingSprite:TranslateToLock()
    self:TranslateToState("state_can_be_unlock")
end
function BuildingSprite:TranslateToConfirm()
    self:TranslateToState("state_confirm")
end
function BuildingSprite:TranslateToCanNotUnlock()
    self:TranslateToState("state_can_not_be_unlock")
end
function BuildingSprite:TranslateToCurrent()
    local state = self.current_state
    state.OnExit()
    state.OnEnter()
end
function BuildingSprite:TranslateToState(state_name)
    local state = self.states[state_name]
    if self.current_state == nil then
        self.current_state = state
        self.current_state.OnEnter()
    else
        self.current_state.OnExit()
        self.current_state = state
        if self.current_state then
            self.current_state.OnEnter()
        end
    end
end

return BuildingSprite
















