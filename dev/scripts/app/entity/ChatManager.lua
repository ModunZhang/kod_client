--
-- Author: Danny He
-- Date: 2015-01-21 16:14:47
--
local MultiObserver = import(".MultiObserver")
local ChatManager = class("ChatManager",MultiObserver)
local Enum = import("..utils.Enum")
local MAX_COUNT_OF_MESSAGE = 50 -- 缓存容量
local MAX_COUNT_OF_BUFF_CHANNEL = 2 -- 最新聊天的缓存数量

ChatManager.LISTEN_TYPE = Enum("OnPush")
ChatManager.CHANNNEL_TYPE = {GLOBAL = 1 ,ALLIANCE = 2}


function ChatManager:ctor(gameDefault)
	ChatManager.super.ctor(self)
	self.gameDefault = gameDefault

	self.global_channel = {}
	self.alliance_channel = {}
end

function ChatManager:GetGameDefault()
	return self.gameDefault
end

function ChatManager:__sortMessage(t)
	return t
end

function ChatManager:__checkIsBlocked(msg)
	return false
end

function ChatManager:__checkChannelNeedRemoveIf(channel,limit)
	local itme_to_del = {}
	for index = limit + 1,#channel do
		if not channel[index] then
			return itme_to_del
		end
		table.insert(itme_to_del,index)
	end
	return itme_to_del
end

function ChatManager:__insertNormalMessage(msg)
	if not msg.fromType then return end
	local msg_type = string.lower(msg.fromType)
	if msg_type =='global' or msg_type == 'system' then
		if not self:__checkIsBlocked(msg) then
			table.insert(self.global_channel,1,msg)
			return self:__checkChannelNeedRemoveIf(self.global_channel,MAX_COUNT_OF_MESSAGE)
		end
	elseif msg_type == 'alliance' then
		if not self:__checkIsBlocked(msg) then
			table.insert(self.alliance_channel,1,msg)
			return self:__checkChannelNeedRemoveIf(self.alliance_channel,MAX_COUNT_OF_MESSAGE)
		end
	end
	dump(msg,"msg")
	assert(false,"插入聊天失败!")
end


function ChatManager:__callEventsChangedListeners(LISTEN_TYPE,tabel_param)
	tabel_param = tabel_param or {}
    self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
        listener[self.LISTEN_TYPE[LISTEN_TYPE]](listener,unpack(tabel_param))
    end)
end

function ChatManager:PushMessage(msg)
	local indexs_to_del = self:__insertNormalMessage(msg) 
	if indexs_to_del then
		self:__notifyMessagePush({
			added = {1},
			removed = indexs_to_del,
		})
	end
end

function ChatManager:__notifyMessagePush(index_to_add_and_del)
	if index_to_add_and_del then
		self:__callEventsChangedListeners(self.LISTEN_TYPE.OnPush,{index_to_add_and_del})
	end
end


-- api
function ChatManager:HandleNetMessage(eventName,msg)

end
function ChatManager:GetChannelMessage(channel)
	if channel == self.CHANNNEL_TYPE.GLOBAL then
		return self.global_channel
	elseif channel == self.CHANNNEL_TYPE.ALLIANCE then
		return self.alliance_channel
	end
end




return ChatManager