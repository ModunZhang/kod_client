--
-- Author: Danny He
-- Date: 2014-12-12 17:05:14
--
local LocalPushUtil = class("LocalPushUtil")
local localPush = ext.localpush

function LocalPushUtil:ctor()
	self.is_local_push_on = true
	self.category_map = {}
	self:CancelAll()
end

function LocalPushUtil:IsSupport()
	return device.platform == 'ios'
end

function LocalPushUtil:AddLocalPush(category,finishTime,msg,identity)
	if not self:IsSupport() or not self:NotificationIsOn() then return end
	self:CancelNotificationByIdentity(identity)
	ext.localpush.addNotification(category, finishTime,msg,identity)

end

function LocalPushUtil:CancelAll()
	if not self:IsSupport() then return end
	ext.localpush.cancelAll()
end

function LocalPushUtil:SwitchNotification(isOn,category)
	if not self:IsSupport() then return end
	isOn = checkbool(isOn)
	if LuaUtils:isString(category) then
		self:CancelNotificationByCategory(category)
		ext.localpush.switchNotification(category,isOn)
	end
end

function LocalPushUtil:NotificationIsOn()
	return self.is_local_push_on
end

function LocalPushUtil:CancelNotificationByIdentity(identity)
	ext.localpush.cancelNotification(identity)
end

function LocalPushUtil:CancelNotificationByCategory(category)
	self:iteratorCategoryIdentity(category,function(identity)
		self:CancelNotificationByIdentity(identity)
	end)
end

function LocalPushUtil:addPushForCategory_(category,identity)
	
	table.insert(self:getPushIdentityForCategory_(category),identity)
end

function LocalPushUtil:getPushIdentityForCategory_(category)
	if not self.category_map[category] then
		self.category_map[category] = {}
	end
	return self.category_map[category]
end

function LocalPushUtil:iteratorCategoryIdentity(category,func)
	table.foreachi(self:getPushIdentityForCategory_(category),function(_,identity)
		func(identity)
	end)
end
return LocalPushUtil