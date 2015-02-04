--
-- Author: Danny He
-- Date: 2014-11-20 21:51:12
--
--TODO:周期性的请求对方联盟数据
local AllianceScene = import(".AllianceScene")
local OtherAllianceScene = class("OtherAllianceScene", AllianceScene)
local REQUEST_SERVER_TIME = 30

function OtherAllianceScene:ctor(alliance)
	self.alliance_ = alliance
    self.time_intval = 0
	OtherAllianceScene.super.ctor(self)
    app.timer:AddListener(self)
end

function OtherAllianceScene:onEnter()
    OtherAllianceScene.super.onEnter(self)
end

function OtherAllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
end


function OtherAllianceScene:GetAlliance()
	return self.alliance_
end

function OtherAllianceScene:CreateAllianceUI()
 
	local home = UIKit:newGameUI('GameUIOtherAllianceHome',self:GetAlliance()):addToScene(self)
    self:GetSceneLayer():AddObserver(home)
    home:setTouchSwallowEnabled(false)
end
function OtherAllianceScene:GotoCurrectPosition()
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function OtherAllianceScene:onExit()
    app.timer:RemoveListener(self)
    OtherAllianceScene.super.onExit(self)
end

-- per 30s request server
function OtherAllianceScene:TimerRequestServer()
    print("请求联盟数据--->" .. os.time(),self:GetAlliance():Id())
    NetManager:getFtechAllianceViewDataPromose(self:GetAlliance():Id()):next(function(msg)
        local enemyAlliance = Alliance_Manager:DecodeAllianceFromJson(msg)
        --用新联盟刷新layer
        self.alliance_ = enemyAlliance
        self:RefreshAllianceMarchLine()
    end)
end
--特殊刷新行军路线-->服务器需要添加缺失的行军事件
function OtherAllianceScene:RefreshAllianceMarchLine()
    --TODO:待验证
    self:GetSceneLayer():InitAllianceEvent()
end

function OtherAllianceScene:OnTimer(current_time)
    self:GetAlliance():OnTimer(current_time)
    if self.time_intval >= REQUEST_SERVER_TIME then
        self.time_intval = 0
        self:TimerRequestServer()
    else
        self.time_intval = self.time_intval + 1
    end
end

return OtherAllianceScene