local AllianceLayer = import("..layers.AllianceLayer")
local MapScene = import(".MapScene")
local AllianceDetailScene = class("AllianceDetailScene", MapScene)

function AllianceDetailScene:ctor()
    AllianceDetailScene.super.ctor(self)
    self.fetchtimer = display.newNode():addTo(self)
    self.visible_alliances = {}
    self.alliance_caches = {}
    self:UpdateAllianceBy(Alliance_Manager:GetMyAlliance().mapIndex, Alliance_Manager:GetMyAlliance())
end
function AllianceDetailScene:onEnter()
    AllianceDetailScene.super.onEnter(self)
    self:GotoAllianceByIndex(Alliance_Manager:GetMyAlliance().mapIndex)
end
function AllianceDetailScene:FetchAllianceDatasByIndex(index, func)
    self.fetchtimer:stopAllActions()
    self.fetchtimer:performWithDelay(function()
        if Alliance_Manager:GetMyAlliance().mapIndex ~= index then
            NetManager:getEnterMapIndexPromise(index):done(function(response)
            	self.current_allinace_index = index
                self:UpdateAllianceBy(index, response.msg.allianceData)
                if type(func) == "function" then
                	func(response.msg)
                end
            end)
        else
            -- assert(false, "不能获取自己的联盟数据!")
        end
    end, 0.5)
end
function AllianceDetailScene:GetHomePage()

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
    self:GetSceneLayer():GetClickedObject(x, y)
end
function AllianceDetailScene:OnSceneMove()
    AllianceDetailScene.super.OnSceneMove(self)
    self:UpdateVisibleAllianceBg()
    self:UpdateCurrrentAlliance()
end
function AllianceDetailScene:UpdateVisibleAllianceBg()
    local old_visibles = self.visible_alliances
    local new_visibles = {}
    for _,k in pairs(self:GetSceneLayer():GetVisibleAllianceIndexs()) do
        if not old_visibles[k] then
            self:GetSceneLayer():LoadAllianceByIndex(k, self:GetAllianceByCache(k))
            new_visibles[k] = true
        end
        new_visibles[k] = true
    end
    self.visible_alliances = new_visibles
end
function AllianceDetailScene:UpdateCurrrentAlliance()
	local index = self:GetSceneLayer():GetMiddleAllianceIndex()
	if index ~= self.current_allinace_index then
		self:FetchAllianceDatasByIndex(index, function(data)
	    	self:GetSceneLayer():LoadAllianceByIndex(index, data.allianceData)
	    end)
	end
end
function AllianceDetailScene:GetAllianceByCache(key)
    return self.alliance_caches[key]
end
function AllianceDetailScene:RemoveAllianceCache(key)
    self.alliance_caches[key] = nil
end
function AllianceDetailScene:UpdateAllianceBy(key, alliance)
	if alliance == json.null then
		self.alliance_caches[key] = nil
	else
    	self.alliance_caches[key] = alliance
    	self.alliance_caches[alliance._id] = alliance
	end
end



return AllianceDetailScene


