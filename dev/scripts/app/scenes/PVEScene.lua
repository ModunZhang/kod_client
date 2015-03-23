local Enum = import("..utils.Enum")
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
local PVEDefine = import("..entity.PVEDefine")
local PVEObject = import("..entity.PVEObject")
local PVELayer = import("..layers.PVELayer")
local GameUIPVEHome = import("..ui.GameUIPVEHome")
local UILib = import("..ui.UILib")
local MapScene = import(".MapScene")
local PVEScene = class("PVEScene", MapScene)

local timer = app.timer
function PVEScene:ctor(user)
    PVEScene.super.ctor(self)
    self.user = user
end
function PVEScene:onEnter()
    self:LoadAnimation()
    PVEScene.super.onEnter(self)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(self.user:GetPVEDatabase():GetCharPosition())
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetSceneLayer():ZoomTo(0.8)
    self:GetSceneLayer():MoveCharTo(self.user:GetPVEDatabase():GetCharPosition())

    GameUIPVEHome.new(self.user, self):addToScene(self, true):setTouchSwallowEnabled(false)
end
function PVEScene:onExit()
    PVEScene.super.onExit(self)
    NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData(), true)
end
function PVEScene:LoadAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,ani_file in pairs(UILib.pve_animation_files) do
        manager:addArmatureFileInfo(ani_file)
    end
end
function PVEScene:CreateSceneLayer()
    return PVELayer.new(self.user)
end
function PVEScene:GetHomePage()

end
function PVEScene:OnTouchClicked(pre_x, pre_y, x, y)
    -- 有动画就什么都不处理
    if self:GetSceneLayer():GetChar():getNumberOfRunningActions() > 0 then return end

    local logic_map = self:GetSceneLayer():GetLogicMap()
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(x, y))
    local new_x, new_y = logic_map:ConvertToLogicPosition(point.x, point.y)
    local old_x, old_y = logic_map:ConvertToLogicPosition(self:GetSceneLayer():GetChar():getPosition())

    -- 检查是不是在中心
    local point = self:GetSceneLayer():GetSceneNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    local logic_x, logic_y = logic_map:ConvertToLogicPosition(point.x, point.y)
    if logic_x ~= old_x or logic_y ~= old_y then
        local s = math.abs(logic_x - old_x) + math.abs(logic_y - old_y)
        self:GetSceneLayer():GotoLogicPoint(old_x, old_y, s * 3)
        return
    end
    -- 检查目标如果在原地，则打开原地的界面
    if new_x == old_x and new_y == old_y then
        return self:OpenUI(old_x, old_y)
    end
    --
    local is_offset_x = math.abs(new_x - old_x) > math.abs(new_y - old_y)
    local offset_x = is_offset_x and (new_x - old_x) / math.abs(new_x - old_x) or 0
    local offset_y = is_offset_x and 0 or (new_y - old_y) / math.abs(new_y - old_y)
    local tx, ty = old_x + offset_x, old_y + offset_y
    local width, height = logic_map:GetSize()

    if self:GetSceneLayer():CanMove(tx, ty) and self.user:HasAnyStength() then
        if not self.user:GetPVEDatabase():IsInTrap() then
            self.user:GetPVEDatabase():ReduceNextEnemyStep()
        end
        self.user:UseStrength(1)
        self:GetSceneLayer():MoveCharTo(tx, ty)
        local gid = self:GetSceneLayer():GetTileInfo(tx, ty)
        if gid > 0 then
            self:OpenUI(tx, ty)
        else
            self:CheckTrap()
        end
    elseif not self.user:HasAnyStength() then
        NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData(), true)
        WidgetUseItems.new():Create({
                        item_type = WidgetUseItems.USE_TYPE.STAMINA
                    }):addToCurrentScene()
    end
end
function PVEScene:OpenUI(x, y)
    local gid = self:GetSceneLayer():GetTileInfo(x, y)
    if gid <= 0 then return end
    self:PormiseOfCheckObject(x, y, gid):next(function()
        if gid == PVEDefine.START_AIRSHIP then
            WidgetPVEStartAirship.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.WOODCUTTER then
            WidgetPVEWoodcutter.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.QUARRIER then
            WidgetPVEQuarrier.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.MINER then
            WidgetPVEMiner.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.FARMER then
            WidgetPVEFarmer.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CAMP then
            WidgetPVECamp.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CRASHED_AIRSHIP then
            WidgetPVECrashedAirship.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.CONSTRUCTION_RUINS then
            WidgetPVEConstructionRuins.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.KEEL then
            WidgetPVEKeel.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.WARRIORS_TOMB then
            WidgetPVEWarriorsTomb.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.OBELISK then
            WidgetPVEObelisk.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.ANCIENT_RUINS then
            WidgetPVEAncientRuins.new(x, y, self.user):addToScene(self, true)
        elseif gid == PVEDefine.ENTRANCE_DOOR then
            WidgetPVEEntranceDoor.new(x, y, self.user):addToScene(self, true)
        end
    end)
end
function PVEScene:CheckTrap()
    if self.user:GetPVEDatabase():IsInTrap() then
        self:GetSceneLayer():PromiseOfTrap():next(function()
            self.user:ResetPveData()
            return NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData())
        end):next(function()
            local enemy = PVEObject.new(0, 0, 0, PVEDefine.TRAP, self:GetSceneLayer():CurrentPVEMap()):GetNextEnemy()
            UIKit:newGameUI('GameUIPVESendTroop',
                enemy.soldiers,-- pve 怪数据
                function(dragonType, soldiers)
                    local dargon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                    local attack_dragon = {
                        dragonType = dragonType,
                        currentHp = dargon:Hp(),
                        hpMax = dargon:GetMaxHP(),
                        totalHp = dargon:Hp(),
                        strength = dargon:TotalStrength(),
                        vitality = dargon:TotalVitality(),
                    }
                    local attack_soldier = LuaUtils:table_map(soldiers, function(k, v)
                        return k, {name = v.name,
                            star = 1,
                            morale = 100,
                            currentCount = v.count,
                            totalCount = v.count,
                            woundedCount = 0,
                            round = 0}
                    end)

                    local report = GameUtils:DoBattle(
                        {dragon = attack_dragon, soldiers = attack_soldier}
                        ,{dragon = enemy.dragon, soldiers = enemy.soldiers}
                    )
                    if report:IsAttackWin() then
                        self.user:SetPveData(report:GetAttackKDA(), enemy.rewards)
                    else
                        self.user:SetPveData(report:GetAttackKDA())
                    end
                    NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData()):next(function()
                        UIKit:newGameUI("GameUIReplay", report, function()
                            if report:IsAttackWin() then
                                GameGlobalUI:showTips(_("获得奖励"), enemy.rewards)
                            end
                        end):addToCurrentScene(true)
                    end):catch(function(err)
                        dump(err:reason())
                    end)
                end):addToCurrentScene(true)
        end)
        self.user:GetPVEDatabase():ResetNextEnemyCounter()
    end
end
function PVEScene:PormiseOfCheckObject(x, y, type)
    local object = self.user:GetCurrentPVEMap():GetObject(x, y)
    if not object or not object:Type() then
        self.user:GetCurrentPVEMap():ModifyObject(x, y, 0, type)
        self.user:ResetPveData()
        return NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData())
    else
        return cocos_promise.defer()
    end
end
return PVEScene






















