--
-- Author: Danny He
-- Date: 2014-11-20 21:51:12
--
--TODO:周期性的请求对方联盟数据
local AllianceScene = import(".AllianceScene")
local EnemyAllianceScene = class("EnemyAllianceScene", AllianceScene)
local GameUIAllianceEnter = import("..ui.GameUIAllianceEnter")
local REQUEST_SERVER_TIME = 30

function EnemyAllianceScene:ctor(alliance,mode)
	self.alliance_ = alliance
    self.time_intval = 0
    self.mode_ = mode or GameUIAllianceEnter.MODE.Enemy
	EnemyAllianceScene.super.ctor(self)
    app.timer:AddListener(self)
end

function EnemyAllianceScene:onEnter()
    EnemyAllianceScene.super.onEnter(self)
    self:RefreshAllianceMarchLine() --第一次进入 手动刷新行军路线
end

function EnemyAllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
  
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if building:GetEntity():GetType() ~= "building" then
            if self:GetMode() == GameUIAllianceEnter.MODE.Enemy then
                if building:GetEntity():GetCategory() == "member" or building:GetEntity():GetCategory() == "village" then
                    UIKit:newGameUI('GameUIAllianceEnter',self:GetAlliance(),building:GetEntity(),self:GetMode()):addToCurrentScene(true)
                end
            else
                if building:GetEntity():GetCategory() == "member" then
                    UIKit:newGameUI('GameUIAllianceEnter',self:GetAlliance(),building:GetEntity(),self:GetMode()):addToCurrentScene(true)
                end
            end
        else
            local building_info = building:GetEntity():GetAllianceBuildingInfo()
            print("index x y ",x,y,building_info.name)
            LuaUtils:outputTable("building_info", building_info)
            UIKit:newGameUI('GameUIAllianceEnter',self:GetAlliance(),building_info,self:GetMode()):addToCurrentScene(true)
        end
    end
end

function EnemyAllianceScene:GetMode()
    return self.mode_
end

function EnemyAllianceScene:GetAlliance()
	return self.alliance_
end

function EnemyAllianceScene:CreateAllianceUI()
    if self:GetMode() == GameUIAllianceEnter.MODE.Enemy then
	    local home = UIKit:newGameUI('GameUIEnemyAllianceHome',self:GetAlliance()):addToScene(self)
        self:GetSceneLayer():AddObserver(home)
        home:setTouchSwallowEnabled(false)
    else

    end
end

function EnemyAllianceScene:onExit()
    app.timer:RemoveListener(self)
    EnemyAllianceScene.super.onExit(self)
end

-- per 30s request server
function EnemyAllianceScene:TimerRequestServer()
    print("请求联盟数据--->",self:GetAlliance():Id())
    NetManager:getFtechAllianceViewDataPromose(self:GetAlliance():Id()):next(function()
        self:RefreshAllianceMarchLine()
    end)
end
--特殊刷新行军路线
function EnemyAllianceScene:RefreshAllianceMarchLine()
    local alliance_layer = self:GetSceneLayer()
    local alliance_shire = self:GetAlliance():GetAllianceShrine()
    table.foreachi(alliance_shire:GetMarchEvents(),function(_,merchEvent)
        if not alliance_layer:IsExistCorps(merchEvent:Id()) then
            alliance_layer:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end
    end)
    table.foreachi(alliance_shire:GetMarchReturnEvents(),function(_,merchEvent)
        if not alliance_layer:IsExistCorps(merchEvent:Id()) then
            alliance_layer:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end
    end)
    local alliance_moonGate = self:GetAlliance():GetAllianceMoonGate()
    table.foreachi(alliance_moonGate:GetMoonGateMarchEvents(),function(_,merchEvent)
        if not alliance_layer:IsExistCorps(merchEvent:Id()) then
            alliance_layer:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end
    end)
    table.foreachi(alliance_moonGate:GetMoonGateMarchReturnEvents(),function(_,merchEvent)
        if not alliance_layer:IsExistCorps(merchEvent:Id()) then
            alliance_layer:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end
    end)
    table.foreachi(self:GetAlliance():GetHelpDefenceMarchEvents(),function(_,helpDefenceMarchEvent)
        if not alliance_layer:IsExistCorps(helpDefenceMarchEvent:Id()) then
            alliance_layer:CreateCorps( 
                helpDefenceMarchEvent:Id(),
                helpDefenceMarchEvent:FromLocation(),
                helpDefenceMarchEvent:TargetLocation(),
                helpDefenceMarchEvent:StartTime(),
                helpDefenceMarchEvent:ArriveTime()
            )
        end
    end)

    table.foreachi(self:GetAlliance():GetHelpDefenceReturnMarchEvents(),function(_,helpDefenceMarchReturnEvent)
        if not alliance_layer:IsExistCorps(helpDefenceMarchReturnEvent:Id()) then
            alliance_layer:CreateCorps( 
                helpDefenceMarchReturnEvent:Id(),
                helpDefenceMarchReturnEvent:FromLocation(),
                helpDefenceMarchReturnEvent:TargetLocation(),
                helpDefenceMarchReturnEvent:StartTime(),
                helpDefenceMarchReturnEvent:ArriveTime()
            )
        end
    end)

    self:GetAlliance():IteratorCityBeAttackedMarchEvents(function(cityBeAttackedMarchEvent)
        if not alliance_layer:IsExistCorps(cityBeAttackedMarchEvent:Id()) then
            alliance_layer:CreateCorps( 
                cityBeAttackedMarchEvent:Id(),
                cityBeAttackedMarchEvent:FromLocation(),
                cityBeAttackedMarchEvent:TargetLocation(),
                cityBeAttackedMarchEvent:StartTime(),
                cityBeAttackedMarchEvent:ArriveTime()
            )
        end
    end)
    self:GetAlliance():IteratorCityBeAttackedMarchReturnEvents(function(cityBeAttackedMarchReturnEvent)
        if not alliance_layer:IsExistCorps(cityBeAttackedMarchReturnEvent:Id()) then
            self:CreateCorps( 
                cityBeAttackedMarchReturnEvent:Id(),
                cityBeAttackedMarchReturnEvent:FromLocation(),
                cityBeAttackedMarchReturnEvent:TargetLocation(),
                cityBeAttackedMarchReturnEvent:StartTime(),
                cityBeAttackedMarchReturnEvent:ArriveTime()
            )
        end
    end)
end

function EnemyAllianceScene:OnTimer(current_time)
    self:GetAlliance():OnTimer(current_time)
    if self.time_intval >= REQUEST_SERVER_TIME then
        self.time_intval = 0
        self:TimerRequestServer()
    else
        self.time_intval = self.time_intval + 1
    end
end

return EnemyAllianceScene