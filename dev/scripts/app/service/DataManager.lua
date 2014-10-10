DataManager = {}

local CURRENT_MODULE_NAME = ...

DataManager.managers_ = {}

function DataManager:setUserData( userData )
	self:registerDataChangedManager_("AllianceManager")
	self["user"] = userData
	self:OnUserDataChanged(userData, app.timer:GetServerTime())
end

function DataManager:getUserData(  )
	return self["user"]
end

function DataManager:registerDataChangedManager_(name,...)
	if not self.managers_[name] then
		local manager_ = import('.' .. name,CURRENT_MODULE_NAME).new(...)
		self.managers_[name] = manager_
	end
	return self
end

function DataManager:OnUserDataChanged(userData,timer)
	City:OnUserDataChanged(userData, timer)
	self:callDataChangedManagers_(userData,timer)
end


function DataManager:callDataChangedManagers_(userData,timer)
	table.foreach(self.managers_,function(name,obj)
		if obj.OnUserDataChanged then
			obj.OnUserDataChanged(obj,userData,timer)
		end
	end)
end

function DataManager:GetDataChangedManager(name)
	return self.managers_[name]
end
