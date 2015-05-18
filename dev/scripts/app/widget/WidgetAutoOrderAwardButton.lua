--
-- Author: Danny He
-- Date: 2015-05-13 15:32:17
--
local WidgetAutoOrderAwardButton = class("WidgetAutoOrderAwardButton",cc.ui.UIPushButton)
local config_online = GameDatas.Activities.online
local UILib = import("..ui.UILib")

function WidgetAutoOrderAwardButton:ctor(animation_object)
	WidgetAutoOrderAwardButton.super.ctor(self,{normal = "activity_68x78.png"})
	time = time or 0
	self:SetTimeInfo(time)
	local countInfo = User:GetCountInfo()
    local onlineTime = (countInfo.todayOnLineTime - countInfo.lastLoginTime)/1000
	self.online_time = onlineTime
	self:setNodeEventEnabled(true)
	self.animation_object = animation_object
	self:onButtonClicked(handler(self, self.OnAwradButtonClicked))
end


function WidgetAutoOrderAwardButton:OnAwradButtonClicked(event)
	UIKit:newGameUI("GameUIActivityRewardNew",2):AddToCurrentScene(true)
end

function WidgetAutoOrderAwardButton:GetItemImage(reward_type,item_key)
    if reward_type == 'soldiers' then
        return UILib.soldier_image[item_key][1]
    elseif reward_type == 'resource' 
        or reward_type == 'special' 
        or reward_type == 'speedup' 
        or reward_type == 'buff' 
        or reward_type == 'buff' then
        return UILib.item[item_key]
    end
end

function WidgetAutoOrderAwardButton:SetTimeInfo(time) 
	if self.time_label then
		if math.floor(time) > 0 then
			self.time_label:setString(os.date("!%H:%M:%S",time))
			self.time_label:show()
		else
			self.time_label:hide()
		end
	else
		if time > 0 then
			local label = UIKit:ttfLabel({
				text = os.date("!%H:%M:%S",time),
				size = 20,
				align = cc.TEXT_ALIGNMENT_LEFT,
			})
			label:addTo(self):align(display.CENTER,0,-45)
			self.time_label = label
		end
	end
end
--放到使用的地方
function WidgetAutoOrderAwardButton:onEnter()
	app.timer:AddListener(self)
end

function WidgetAutoOrderAwardButton:onCleanup()
	app.timer:RemoveListener(self)
end

function WidgetAutoOrderAwardButton:OnTimer(dt)
	if not self.can_get and self.timePoint then
		local time = self.online_time + dt
		local diff_time = config_online[self.timePoint].onLineMinutes * 60 - time
		if  math.floor(diff_time) > 0 then
			self:SetTimeInfo(diff_time)
		else
			if self.time_label then self.time_label:hide() end
			self:CheckState()
		end
	end
end

function WidgetAutoOrderAwardButton:OnCountInfoChanged()
	self:CheckVisible()
end

function WidgetAutoOrderAwardButton:StarAction()
	print("WidgetAutoOrderAwardButton:StarAction---->")
	self:StopAction()
	self.sprite_[1]:runAction(self:GetShakeAction())
end

function WidgetAutoOrderAwardButton:StopAction()
	print("WidgetAutoOrderAwardButton:StopAction---->")
	self.sprite_[1]:stopAllActions()
	self.sprite_[1]:setRotation(0)
	
end

function WidgetAutoOrderAwardButton:GetShakeAction()
    local t = 0.025
    local r = 5
    local action = transition.sequence({
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cca.delay(1),
    })
    return cca.repeatForever(action)
end

-- For WidgetAutoOrder
function WidgetAutoOrderAwardButton:CheckVisible()
	self:CheckState()
	return self.visible___ 
end

function WidgetAutoOrderAwardButton:GetElementSize()
	return self:getCascadeBoundingBox().size
end
-- For Data
function WidgetAutoOrderAwardButton:GetNextTimePoint()
	local onlineTime = DataUtils:getPlayerOnlineTimeMinutes()
	for __,v in ipairs(config_online) do
		if v.onLineMinutes <= onlineTime then
			if not self:IsTimePointRewarded(v.timePoint) then
				return v.timePoint,true
			end
		else
			return v.timePoint,false
		end
	end
	return nil,nil
end

function WidgetAutoOrderAwardButton:CheckState()
	local timePoint,animation = self:GetNextTimePoint()
	if timePoint ~= nil then
		self.visible___ = true
		self.timePoint = timePoint

		if animation then
			self:StarAction()
			self.can_get = true
		else
			self:StopAction()
			self.can_get = false
		end
		local awards = config_online[self.timePoint].rewards
		local reward_type,reward_key,reward_count = unpack(string.split(awards,":"))
		self.awards = {reward_type = reward_type,reward_key = reward_key,reward_count = reward_count}
	else
		self.visible___ = false 
	end
end

function WidgetAutoOrderAwardButton:IsTimePointRewarded(timepoint)
	local countInfo = User:GetCountInfo()
	for __,v in ipairs(countInfo.todayOnLineTimeRewards) do
		if v == timepoint then
			return true
		end
	end
	return false 
end
return WidgetAutoOrderAwardButton