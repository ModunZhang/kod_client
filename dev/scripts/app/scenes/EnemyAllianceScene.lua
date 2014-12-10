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
    print("请求联盟数据--->" .. os.time(),self:GetAlliance():Id())
    NetManager:getFtechAllianceViewDataPromose(self:GetAlliance():Id()):next(function(msg)
        local enemyAlliance = Alliance_Manager:DecodeAllianceFromJson(msg)
        --用新联盟刷新layer
        self.alliance_ = enemyAlliance
        self:RefreshAllianceMarchLine()
    end)
end
--特殊刷新行军路线-->服务器需要添加缺失的行军事件
function EnemyAllianceScene:RefreshAllianceMarchLine()
    self:GetSceneLayer():CreateCorpsFromMrachEventsIf()
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