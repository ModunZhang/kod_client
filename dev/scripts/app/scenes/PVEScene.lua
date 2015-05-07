local Enum = import("..utils.Enum")
local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local WidgetUseItems = import("..widget.WidgetUseItems")
local WidgetPVEKeel = import("..widget.WidgetPVEKeel")
local WidgetPVECamp = import("..widget.WidgetPVECamp")
local WidgetPVEMiner = import("..widget.WidgetPVEMiner")
local WidgetPVEFarmer = import("..widget.WidgetPVEFarmer")
local WidgetPVEObelisk = import("..widget.WidgetPVEObelisk")
local WidgetPVEQuarrier = import("..widget.WidgetPVEQuarrier")
local WidgetPVEWoodcutter = import("..widget.WidgetPVEWoodcutter")
local WidgetPVEAncientRuins = import("..widget.WidgetPVEAncientRuins")
local WidgetPVEWarriorsTomb = import("..widget.WidgetPVEWarriorsTomb")
local WidgetPVEEntranceDoor = import("..widget.WidgetPVEEntranceDoor")
local WidgetPVEStartAirship = import("..widget.WidgetPVEStartAirship")
local WidgetPVECrashedAirship = import("..widget.WidgetPVECrashedAirship")
local WidgetPVEConstructionRuins = import("..widget.WidgetPVEConstructionRuins")
local WidgetDirectionSelect = import("..widget.WidgetDirectionSelect")
local PVEDefine = import("..entity.PVEDefine")
local PVEObject = import("..entity.PVEObject")
local PVELayer = import("..layers.PVELayer")
local GameUIPVEHome = import("..ui.GameUIPVEHome")
local UILib = import("..ui.UILib")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)
local DIRECTION_TAG = 911

local timer = app.timer
function PVEScene:ctor(user)
    self:LoadAnimation()
    PVEScene.super.ctor(self)
    self.user = user
end
function PVEScene:onEnter()
    PVEScene.super.onEnter(self)
    self:CreateHomePage()
    self.tutorial_layer = self:CreateTutorialLayer()
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(self.user:GetPVEDatabase():GetCharPosition())
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(0.8)
    self:GetSceneLayer():MoveCharTo(self.user:GetPVEDatabase():GetCharPosition())
    app:GetAudioManager():PlayGameMusic("PVEScene")
end
function PVEScene:onExit()
    PVEScene.super.onExit(self)
    self.user:ResetPveData()
    NetManager:getSetPveDataPromise(
        self.user:EncodePveDataAndResetFightRewardsData(),
        true
    ):fail(function()
        -- 失败回滚
        local location = DataManager:getUserData().pve.location
        self.user:GetPVEDatabase():SetCharPosition(location.x, location.y, location.z)
    end)
end
function PVEScene:LoadAnimation()
    UILib.loadSolidersAnimation()
    UILib.loadPveAnimation()
end
function PVEScene:CreateSceneLayer()
    return PVELayer.new(self.user)
end
function PVEScene:CreateHomePage()
    local home_page = GameUIPVEHome.new(self.user, self):AddToScene(self, true)
    home_page:setLocalZOrder(10)
    home_page:setTouchSwallowEnabled(false)
    return home_page
end
function PVEScene:GetHomePage()
    return self.home_page
end
function PVEScene:GetTutorialLayer()
    return self.tutorial_layer
end
function PVEScene:CreateDirectionArrow()
    if not self:getChildByTag(DIRECTION_TAG) then
        return WidgetDirectionSelect.new():pos(display.cx, display.cy)
            :addTo(self, 10, DIRECTION_TAG):EnableDirection():hide()
    end
end
function PVEScene:GetDirectionArrow()
    if not self:getChildByTag(DIRECTION_TAG) then
        return self:CreateDirectionArrow()
    end
    return self:getChildByTag(DIRECTION_TAG)
end
function PVEScene:DestroyDirectionArrow()
    self:removeChildByTag(DIRECTION_TAG)
end
function PVEScene:OnTouchClicked(pre_x, pre_y, x, y)
    -- 有动画就什么都不处理
    if not PVEScene.super.OnTouchClicked(self, pre_x, pre_y, x, y) then return end
    if self:GetSceneLayer():GetChar():getNumberOfRunningActions() > 0 then return end

    -- 获取当前点
    -- 检查是不是在中心
    local old_x, old_y = self:GetCurrentPos()
    local logic_x, logic_y = self:GetCenterPos()
    if logic_x ~= old_x or logic_y ~= old_y then
        local s = math.abs(logic_x - old_x) + math.abs(logic_y - old_y)
        return self:GetSceneLayer():GotoLogicPoint(old_x, old_y, s * 3)
    end

    -- 检查目标如果在原地，则打开原地的界面
    local new_x, new_y = self:GetClickedPos(x, y)
    if new_x == old_x and new_y == old_y and self:CheckCanMoveTo(old_x, old_y) then
        return self:OpenUI(old_x, old_y)
    end
    -- 检查行走偏移, 得到目标点
    local is_offset_x = math.abs(new_x - old_x) > math.abs(new_y - old_y)
    local offset_x = is_offset_x and (new_x - old_x) / math.abs(new_x - old_x) or 0
    local offset_y = is_offset_x and 0 or (new_y - old_y) / math.abs(new_y - old_y)
    local tx, ty = old_x + offset_x, old_y + offset_y

    -- 检查fte
    if not self:CheckCanMoveDelta(offset_x, offset_y) then return end

    if self:GetSceneLayer():CanMove(tx, ty) and 
        self.user:HasAnyStength() then
        -- 能走的话检查fte
        
        if not self.user:GetPVEDatabase():IsInTrap() then
            self.user:GetPVEDatabase():ReduceNextEnemyStep()
        end

        self.user:UseStrength(1)
        self:GetSceneLayer():MoveCharTo(tx, ty)

        if self:GetSceneLayer():GetTileInfo(tx, ty) > 0 and 
            self:CheckCanMoveTo(tx, ty) then
            self:OpenUI(tx, ty)
        else
            self:CheckTrap()
        end
    elseif not self.user:HasAnyStength() then
        -- 没体力则买体力
        if self.user:GetStaminaUsed() > 0 then
            self.user:ResetPveData()
            NetManager:getSetPveDataPromise(
                self.user:EncodePveDataAndResetFightRewardsData()
            ):fail(function()
                -- 失败回滚
                local location = DataManager:getUserData().pve.location
                self.user:GetPVEDatabase():SetCharPosition(location.x, location.y, location.z)
                self:GetSceneLayer():MoveCharTo(self.user:GetPVEDatabase():GetCharPosition())
            end)
        end
        WidgetUseItems.new():Create({
            item_type = WidgetUseItems.USE_TYPE.STAMINA
        }):AddToCurrentScene()
    end
end
function PVEScene:OpenUI(x, y)
    local gid = self:GetSceneLayer():GetTileInfo(x, y)
    if gid <= 0 then return end
    self:PormiseOfCheckObject(x, y, gid):done(function()
        if gid == PVEDefine.START_AIRSHIP then
            WidgetPVEStartAirship.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.WOODCUTTER then
            WidgetPVEWoodcutter.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.QUARRIER then
            WidgetPVEQuarrier.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.MINER then
            WidgetPVEMiner.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.FARMER then
            WidgetPVEFarmer.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.CAMP then
            WidgetPVECamp.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.CRASHED_AIRSHIP then
            WidgetPVECrashedAirship.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.CONSTRUCTION_RUINS then
            WidgetPVEConstructionRuins.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.KEEL then
            WidgetPVEKeel.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.WARRIORS_TOMB then
            WidgetPVEWarriorsTomb.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.OBELISK then
            WidgetPVEObelisk.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.ANCIENT_RUINS then
            WidgetPVEAncientRuins.new(x, y, self.user):AddToScene(self, true)
        elseif gid == PVEDefine.ENTRANCE_DOOR then
            WidgetPVEEntranceDoor.new(x, y, self.user):AddToScene(self, true)
        end
    end)
end
function PVEScene:CheckTrap()
    if self.user:GetPVEDatabase():IsInTrap() then
        self:GetSceneLayer():PromiseOfTrap():next(function()
            local trap_obj = PVEObject.new(0, 0, 0, PVEDefine.TRAP, self:GetSceneLayer():CurrentPVEMap())
            local enemy = trap_obj:GetNextEnemy()
            UIKit:newGameUI('GameUIPVESendTroop',
                enemy.soldiers,-- pve 怪数据
                function(dragonType, soldiers)
                    local dragon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                    local attack_dragon = {
                        level = dragon:Level(),
                        dragonType = dragonType,
                        currentHp = dragon:Hp(),
                        hpMax = dragon:GetMaxHP(),
                        strength = dragon:TotalStrength(),
                        vitality = dragon:TotalVitality(),
                        dragon = dragon
                    }
                    local attack_soldier = LuaUtils:table_map(soldiers, function(k, v)
                        return k, {
                            name = v.name,
                            star = v.star,
                            count = v.count
                        }
                    end)

                    local report = GameUtils:DoBattle(
                        {dragon = attack_dragon, soldiers = attack_soldier},
                        {dragon = enemy.dragon, soldiers = enemy.soldiers},
                        trap_obj:GetMap():Terrain()
                    )
                    if report:IsAttackWin() then
                        self.user:SetPveData(report:GetAttackKDA(), enemy.rewards)
                    else
                        self.user:SetPveData(report:GetAttackKDA())
                    end
                    NetManager:getSetPveDataPromise(
                        self.user:EncodePveDataAndResetFightRewardsData()
                    ):done(function()
                        UIKit:newGameUI("GameUIReplayNew", report, function()
                            if report:IsAttackWin() then
                                GameGlobalUI:showTips(_("获得奖励"), enemy.rewards)
                            end
                        end):AddToCurrentScene(true)
                    end)
                end):AddToCurrentScene(true)
        end)
        self.user:GetPVEDatabase():ResetNextEnemyCounter()
    end
end
function PVEScene:PormiseOfCheckObject(x, y, type)
    local object = self.user:GetCurrentPVEMap():GetObjectByCoord(x, y)
    if not object or not object:Type() then
        self.user:GetCurrentPVEMap():ModifyObject(x, y, 0, type)
        self.user:ResetPveData()
        return NetManager:getSetPveDataPromise(
            self.user:EncodePveDataAndResetFightRewardsData()
        ):fail(function()
            -- 失败回滚
            local location = DataManager:getUserData().pve.location
            self.user:GetPVEDatabase():SetCharPosition(location.x, location.y, location.z)
            self:GetSceneLayer():MoveCharTo(self.user:GetPVEDatabase():GetCharPosition())
        end)
    else
        return cocos_promise.defer()
    end
end
function PVEScene:OnTwoTouch()

end
function PVEScene:GetCurrentPos()
    local logic_map = self:GetSceneLayer():GetLogicMap()
    local char_x,char_y = self:GetSceneLayer():GetChar():getPosition()
    return logic_map:ConvertToLogicPosition(char_x, char_y)
end
function PVEScene:GetClickedPos(x, y)
    local logic_map = self:GetSceneLayer():GetLogicMap()
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(x, y))
    return logic_map:ConvertToLogicPosition(point.x, point.y)
end
function PVEScene:GetCenterPos()
    local logic_map = self:GetSceneLayer():GetLogicMap()
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    return logic_map:ConvertToLogicPosition(point.x, point.y)
end
function PVEScene:CheckCanMoveDelta(ox, oy)
    if not self.move_data then return true end
    local x,y = self:GetCurrentPos()
    return math.abs(x + ox - self.move_data.x) <= math.abs(x - self.move_data.x) and
        math.abs(y + oy - self.move_data.y) <= math.abs(y - self.move_data.y)
end
function PVEScene:CheckCanMoveTo(x, y)
    if not self.move_data then return true end
    if self.move_data.callback(x, y) then 
        self.move_data = nil
        self:CheckDirection()
        return true
    end
    self:CheckDirection()
end
function PVEScene:PromiseOfMoveTo(x, y)
    local p = promise.new()
    self.move_data = {
        callback = function(x_, y_)
            if x == x_ and y == y_ then
                p:resolve()
                return true
            end
        end,
        x = x,
        y = y,
    }
    self:CheckDirection()
    return p
end
function PVEScene:CheckDirection()
    if self.move_data then
        local x,y = self:GetCurrentPos()
        if x == self.move_data.x and y == self.move_data.y then
            self:GetDirectionArrow():hide()
        else
            local left = x - self.move_data.x > 0
            local right = x - self.move_data.x < 0
            local up = y - self.move_data.y < 0
            local down = y - self.move_data.y > 0
            self:GetDirectionArrow():show()
                :EnableDirection(left, right, up, down)
        end
    else
        self:GetDirectionArrow():hide()
    end
end

-- fte
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function PVEScene:onEnterTransitionFinish()
    self:RunFte()
end
function PVEScene:RunFte()
    local cx,cy = self:GetCurrentPos()
    local str = (cx == 9 and cy == 12) and _("请点击目标") or _("这里是我们的目的地，点击屏幕左侧向左移动")
    
    local x,y = self:GetSceneLayer():GetFog(9, 12):getPosition()
    self:GetSceneLayer():GetFteLayer().arrow = WidgetFteArrow.new(str)
        :addTo(self:GetSceneLayer():GetFteLayer())
        :TurnDown():align(display.BOTTOM_CENTER, x + 45, y + 80)

    self:GetTutorialLayer():Enable()
    return promise.all(UIKit:PromiseOfOpen("WidgetPVEMiner"), 
        self:PromiseOfMoveTo(9, 12)):next(function()
        if self:GetSceneLayer():GetFteLayer().arrow then
            self:GetSceneLayer():GetFteLayer().arrow:removeFromParent()
        end
        self:GetSceneLayer():GetFteLayer().arrow = nil
    end):next(function(results)
        return results[1]:PormiseOfFte()
    end):next(function()
        self:GetTutorialLayer():Disable()
    end)
end

return PVEScene












