--
-- Author: Danny He
-- Date: 2015-01-21 16:14:47
--
--Emoji
--------------------------------------------------------------------------------------------------
local EmojiUtil = class("EmojiUtil")

--将表情化标签转换成富文本语法
function EmojiUtil:ConvertEmojiToRichText(str)

end

--end
--------------------------------------------------------------------------------------------------
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local MultiObserver = import(".MultiObserver")
local ChatManager = class("ChatManager",MultiObserver)
local Enum = import("..utils.Enum")
local PUSH_INTVAL = 10 -- 推送的时间间隔
local SIZE_MUST_PUSH = 10 -- 如果队列中数量达到指定条数立即推送
ChatManager.LISTEN_TYPE = Enum("TO_TOP","TO_REFRESH")
ChatManager.CHANNNEL_TYPE = {GLOBAL = 1 ,ALLIANCE = 2}


function ChatManager:ctor(gameDefault)
	ChatManager.super.ctor(self)
	self.gameDefault = gameDefault
	self.emojiUtil = EmojiUtil.new()
	self.global_channel = {}
	self.alliance_channel = {}
	self.push_buff_queue = {}
	self.___handle___ = scheduler.scheduleGlobal(handler(self, self.__checkNotifyIf),PUSH_INTVAL)
end

function ChatManager:GetEmojiUtil()
	return self.emojiUtil
end

function ChatManager:GetGameDefault()
	return self.gameDefault
end

function ChatManager:sortMessage_(t)
	return t
end

function ChatManager:__checkIsBlocked(msg)
	return false
end

function ChatManager:insertNormalMessage_(msg)
	if not msg.fromChannel then return end
	local msg_type = string.lower(msg.fromChannel)
	if msg_type =='global' or msg_type == 'system' then
		if not self:__checkIsBlocked(msg) then
			table.insert(self.global_channel,1,msg)
			return true
		end
	elseif msg_type == 'alliance' then
		if not self:__checkIsBlocked(msg) then
			table.insert(self.alliance_channel,1,msg)
			return true
		end
	end
	dump(msg,"插入聊天信息失败")
	return false
end


function ChatManager:callEventsChangedListeners_(LISTEN_TYPE,tabel_param)
	tabel_param = tabel_param or {}
	dump(tabel_param)
    self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
        listener[self.LISTEN_TYPE[LISTEN_TYPE]](listener,unpack(tabel_param))
    end)
end

function ChatManager:__checkNotifyIf()
	print("__checkNotifyIf---->",#self.push_buff_queue ~= 0)
	if #self.push_buff_queue ~= 0 then
		self:callEventsChangedListeners_(self.LISTEN_TYPE.TO_TOP,{self.push_buff_queue})
		self:emptyPushQueue_()
	end
end


function ChatManager:pushMsgToQueue_(msg)
	table.insert(self.push_buff_queue,1,msg)
	if #self.push_buff_queue >= SIZE_MUST_PUSH then
		self:__checkNotifyIf()
	end
end


function ChatManager:emptyChannel_()
	self.global_channel = {}
	self.alliance_channel = {}
end

function ChatManager:emptyPushQueue_()
	self.push_buff_queue = {}
end

-- api
function ChatManager:HandleNetMessage(eventName,msg)
	if eventName == 'onChat' then
		if self:insertNormalMessage_(msg) then
			self:pushMsgToQueue_(msg)
		end
	elseif eventName == 'onAllChat' then
		self:emptyPushQueue_()
		self:emptyChannel_()
		for _,v in ipairs(msg) do
			self:insertNormalMessage_(v)
		end
		self:callEventsChangedListeners_(self.LISTEN_TYPE.TO_REFRESH,{})
	end
end

function ChatManager:FetchChannelMessage(channel)
	if channel == self.CHANNNEL_TYPE.GLOBAL then
		return self.global_channel
	elseif channel == self.CHANNNEL_TYPE.ALLIANCE then
		return self.alliance_channel
	end
end

function ChatManager:FetchAllChatMessage()
	NetManager:getFetchChatPromise():next(function(messages)
		self:HandleNetMessage('onAllChat',messages)
	end)
end

function ChatManager:SendChat(channel,msg)
	local channel_in_server = channel == self.CHANNNEL_TYPE.GLOBAL and 'global' or 'alliance'
	NetManager:getSendChatPromise(channel_in_server,msg):next(function()
		self:__checkNotifyIf()
	end)
end

function ChatManager:Reset()
	self:emptyChannel_()
	self:emptyPushQueue_()
	if self.___handle___ then
		scheduler.unscheduleGlobal(self.___handle___)
	end
end

return ChatManager