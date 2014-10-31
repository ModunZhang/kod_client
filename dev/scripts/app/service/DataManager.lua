DataManager = {}

local CURRENT_MODULE_NAME = ...

DataManager.managers_ = {}

function DataManager:setUserData( userData )
	self:registerManager_("AllianceManager")
	self:registerManager_("MailManager")
    if not self.user then
        self.user = userData
    else
    	for k, v in pairs(userData) do
    		self.user[k] = v
    	end
    end
    self:OnUserDataChanged(userData, app.timer:GetServerTime())
end


function DataManager:getUserData(  )
    return self.user
end

function DataManager:registerManager_(name,...)
	if not self.managers_[name] then
		local manager_ = import('.' .. name,CURRENT_MODULE_NAME).new(...)
		self.managers_[name] = manager_
	end
	return self
end

function DataManager:OnUserDataChanged(userData,timer)
	User:OnUserDataChanged(userData)
	City:OnUserDataChanged(userData, timer)
	Alliance_Manager:OnUserDataChanged(userData, timer)
	self:callManagers_(userData,timer)
end


function DataManager:callManagers_(userData,timer)
	table.foreach(self.managers_,function(name,obj)
		if obj.OnUserDataChanged then
			obj.OnUserDataChanged(obj,userData,timer)
		end
	end)
end

function DataManager:GetManager(name)
	assert(self.managers_[name])
	return self.managers_[name]
end
