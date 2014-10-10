--
-- Author: Danny He
-- Date: 2014-10-10 12:07:04
--
local AllianceManager = class("AllianceManager")
local Enum = import("..utils.Enum")
AllianceManager.ALLIANCETITLE = {
		Archon = "archon",
		General = "general",
		Diplomat ="diplomat",
		Quartermaster = "quartermaster",
		Supervisor = "supervisor",
		Elite = "elite",
		Member = "member"
	}

AllianceManager.ONUSERDATACHANGED = "AllianceManager.OnUserDataChanged"
AllianceManager.ALLIANCE_EVENT_TYPE = Enum(
	"NORMAL",
	"CREATE_OR_JOIN",
	"QUIT"
)
function AllianceManager:ctor()
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.alliance_ = nil
	self.isInit_ = true
	print("AllianceManager:ctor----->",self.ALLIANCE_EVENT_TYPE.NORMAL)
end

function AllianceManager:OnUserDataChanged(userData,timer)
	local eventType = self.ALLIANCE_EVENT_TYPE.NORMAL
	if not self.isInit_ then
		if (self.alliance_ == nil and  userData.alliance ~= nil) then
			eventType = self.ALLIANCE_EVENT_TYPE.CREATE_OR_JOIN
		end
		if (self.alliance_ ~= nil and  userData.alliance == nil) then
			eventType = self.ALLIANCE_EVENT_TYPE.QUIT
		end
	end
	print("AllianceManager:OnUserDataChanged----->",eventType)
	self.alliance_ = userData.alliance 
	self:dispatchEvent({name = AllianceManager.ONUSERDATACHANGED,
        allianceEvent = eventType
    })
    self.isInit_  = false
end


function AllianceManager:onAllianceDataChanged(callback)
	return self:addUserDataChangedListener("_",callback)
end

function AllianceManager:cancelAllianceDataChanged()
	return self:removeUserDataChangedListener("_")
end

function AllianceManager:addUserDataChangedListener(tag,callback)
    return self:addEventListener(AllianceManager.ONUSERDATACHANGED, callback,tag)
end

function AllianceManager:removeUserDataChangedListener( tag )
	return self:removeEventListenersByTag(tag)
end

--logic methods

function AllianceManager:getAlliance()
	return self.alliance_
end

function AllianceManager:haveAlliance()
	return self:getAlliance() ~= nil
end

-- flag
return AllianceManager