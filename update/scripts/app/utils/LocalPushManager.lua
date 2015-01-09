--
-- Author: Danny He
-- Date: 2014-12-12 17:05:14
--
local LocalPushManager = class("LocalPushManager")
local localPush = ext.localpush
local LOCAL_PUSH_KEY = "LOCAL_PUSH_KEY"

function LocalPushManager:ctor(game_default)
	self:CancelAll()
	self.game_default = game_default
	self.is_local_push_on = self:GetGameDefault():getBasicInfoValueForKey(LOCAL_PUSH_KEY,true)
	if self:IsSupport() then
		localPush.switchNotification(LOCAL_PUSH_KEY,self.is_local_push_on)
	end
end

function LocalPushManager:GetGameDefault()
	return self.game_default
end

function LocalPushManager:IsSupport()
	return device.platform == 'ios'
end
-- identity 为push的唯一不变id
function LocalPushManager:AddLocalPush(finishTime,msg,identity)
	if not self:IsSupport() or not self:IsNotificationIsOn() then return end
	self:CancelNotificationByIdentity(identity)
	localPush.addNotification(LOCAL_PUSH_KEY, finishTime,msg,identity)
end

function LocalPushManager:CancelAll()
	if not self:IsSupport() then return end
	localPush.cancelAll()
end

function LocalPushManager:SwitchNotification(isOn)
	if not self:IsSupport() or self.is_local_push_on == isOn then return end
	isOn = checkbool(isOn)
	self.is_local_push_on = isOn
	localPush.switchNotification(LOCAL_PUSH_KEY,self.is_local_push_on)
	if not isOn then
		self:CancelAll()
	end
	self:GetGameDefault():setBasicInfoBoolValueForKey(LOCAL_PUSH_KEY,isOn)
	self:GetGameDefault():flush()
end

function LocalPushManager:IsNotificationIsOn()
	if not self:IsSupport() then return self:IsSupport() end
	return self.is_local_push_on
end

function LocalPushManager:CancelNotificationByIdentity(identity)
	if not self:IsSupport() then return end
	localPush.cancelNotification(identity)
end

return LocalPushManager