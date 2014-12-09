--
-- Author: Danny He
-- Date: 2014-12-01 18:13:01
--
--TODO:将月门的行军事件适配到队列中
local Observer = import(".Observer")
local QueueManager = class("QueueManager",Observer)
local AllianceShrine = import(".AllianceShrine")
local Enum = import("..utils.Enum")

QueueManager.QUEUE_TYPE = Enum("MARCH_EVENT")
QueueManager.EVENT_NAME = Enum("SHIRE_MARCH_EVENT","SHIRE_MARCH_RETURNEVENT","HELP_DEFENCE_MARCHEVENT","HELP_DEFENCE_MARCHRETURNEVENT")
QueueManager.NOTIFIY_TYPE = Enum("")

function QueueManager:ctor(alliacne)
	QueueManager.super.ctor(self)
	self._numberOfEvents = {}
	self._limitOfQueue_ = {}
	--init the count
	for k,v in pairs(self.QUEUE_TYPE) do
		if type(k) == 'string' then
			self._limitOfQueue_[v] = 3 
		end
	end

	for k,v in pairs(self.EVENT_NAME) do
		if type(k) == 'string' then
			self._numberOfEvents[v] = 0 
		end
	end
	self:InitWithAlliance_(alliacne)
end

function QueueManager:UpdateQueueLimit(queue_type,count)
	assert(self.QUEUE_TYPE[queue_type])
	self._limitOfQueue_[self.QUEUE_TYPE[queue_type]] = checknumber(count)
end

function QueueManager:UpdateEvnetCount(event_name,count)
	assert(self.EVENT_NAME[event_name])
	self._numberOfEvents[event_name] = checknumber(count)
end

function QueueManager:UpdateEvnetCountOffset_(event_name,offset)
	assert(self.EVENT_NAME[event_name])
	self._numberOfEvents[event_name] = checknumber(offset) + self:GetEventCount(event_name)
end

function QueueManager:GetEventCount(event_name)
	assert(self.EVENT_NAME[event_name])
	return self._numberOfEvents[event_name]
end


function QueueManager:GetQueueLimit(queue_type)
	return self._limitOfQueue_[queue_type]
end

function QueueManager:IsReachLimit(queue_type)
	if queue_type == self.QUEUE_TYPE.MARCH_EVENT then
		return self:GetEventCount(self.EVENT_NAME.SHIRE_MARCH_EVENT) + self:GetEventCount(self.EVENT_NAME.SHIRE_MARCH_RETURNEVENT) + self:GetEventCount(self.EVENT_NAME.HELP_DEFENCE_MARCHEVENT) + self:GetEventCount(self.EVENT_NAME.HELP_DEFENCE_MARCHRETURNEVENT)
			>= self:GetQueueLimit(self.QUEUE_TYPE.MARCH_EVENT)
	end
end

function QueueManager:InitWithAlliance_(alliacne)
  	self.alliacne_ = alliacne
  	self:GetAlliance_():GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchEventsChanged)
  	self:GetAlliance_():GetAllianceShrine():AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchReturnEventsChanged)
  	self:GetAlliance_():AddListenOnType(self,self:GetAlliance_().LISTEN_TYPE.OnHelpDefenceMarchEventsChanged)
  	self:GetAlliance_():AddListenOnType(self,self:GetAlliance_().LISTEN_TYPE.OnHelpDefenceMarchReturnEventsChanged)
end

function QueueManager:ResetAllianceQueue()
	  self:GetAlliance_():GetAllianceShrine():RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchEventsChanged)
	  self:GetAlliance_():GetAllianceShrine():RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchReturnEventsChanged)
	  self:GetAlliance_():RemoveListenerOnType(self,self:GetAlliance_().LISTEN_TYPE.OnHelpDefenceMarchEventsChanged)
    self:GetAlliance_():RemoveListenerOnType(self,self:GetAlliance_().LISTEN_TYPE.OnHelpDefenceMarchReturnEventsChanged)
end

function QueueManager:GetAlliance_()
	return self.alliacne_
end

function QueueManager:OnMarchReturnEventsChanged(changed_map)
	local add,sub = 0,0
	if changed_map.removed then
      	table.foreachi(changed_map.removed,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			sub = sub - 1
      		end
      	end)
    elseif changed_map.added then
       table.foreachi(changed_map.added,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			add = add + 1
      		end
      	end)
    end
    self:UpdateEvnetCountOffset_(self.EVENT_NAME.SHIRE_MARCH_RETURNEVENT,add+sub)
end

function QueueManager:OnMarchEventsChanged(changed_map)
	local add,sub = 0,0
	if changed_map.removed then
      	table.foreachi(changed_map.removed,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			sub = sub - 1
      		end
      	end)
    elseif changed_map.added then
       table.foreachi(changed_map.added,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			add = add + 1

      		end
      	end)
    end
    self:UpdateEvnetCountOffset_(self.EVENT_NAME.SHIRE_MARCH_EVENT,add+sub)
    dump(self:IsReachLimit(self.QUEUE_TYPE.MARCH_EVENT),"QueueManager:OnMarchEventsChanged---xxxx-->")
end

function QueueManager:OnHelpDefenceMarchReturnEventsChanged(changed_map)
	local add,sub = 0,0
	if changed_map.removed then
      	table.foreachi(changed_map.removed,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.RECEIVER then
      			sub = sub - 1
      		end
      	end)
    elseif changed_map.added then
       table.foreachi(changed_map.added,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.RECEIVER then
      			add = add + 1
      		end
      	end)
    end
    self:UpdateEvnetCountOffset_(self.EVENT_NAME.HELP_DEFENCE_MARCHRETURNEVENT,add+sub)
end

function QueueManager:OnHelpDefenceMarchEventsChanged(changed_map)
	local add,sub = 0,0
	if changed_map.removed then
      	table.foreachi(changed_map.removed,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			 sub = sub - 1
      		end
      	end)
    elseif changed_map.added then
       table.foreachi(changed_map.added,function(key,event)
      		if event:GetMarchPlayerInfo(DataManager:getUserData()._id) == event.MARCH_EVENT_WITH_PLAYER.SENDER then
      			add = add + 1
      		end
      	end)
    end
    self:UpdateEvnetCountOffset_(self.EVENT_NAME.HELP_DEFENCE_MARCHEVENT,add+sub)
end
-- TODO:获取瞭望塔的数据结构
function QueueManager:GetMarchEventData()

end

return QueueManager