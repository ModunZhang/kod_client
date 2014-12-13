--
-- Author: dannyhe
-- Date: 2014-08-14 17:34:50
--

local Observer = import('.Observer')
local ChatCenter = class('ChatCenter',Observer)
local MAX_MESSAGE_PER_PAGE = 100


function ChatCenter:ctor()
	ChatCenter.super.ctor(self)
	self._messageQueue_ = {}
	self._blockedIdList_ = self:initBlockList()
end


function ChatCenter:pushMessage(msg)
	if self:_insertMessage(msg) then
		self:_notifyObservers('onPush',msg)
		self:_notifyObservers('onLastMessage',msg)
	end
end

function ChatCenter:shiftMessage()
	local r = #self._messageQueue_ == 0 and nil or table.remove(self._messageQueue_,1)
	self:_notifyObservers('onShift',r)
end

function ChatCenter:getMessage(index,page,type)
	if not self._messageQueue_[type] then return {} end
	-- local currentCount = MAX_MESSAGE_PER_PAGE*page
	-- if currentCount > #self._messageQueue_[type] then
		-- currentCount = #self._messageQueue_[type]
	-- end
	-- local finalIndex = currentCount - (index + 1) + 1
	return tonumber(index) and self._messageQueue_[type][tonumber(index+1)] or {}
end

function ChatCenter:popMessage()
	local r =  #self._messageQueue_ == 0 and nil or table.remove(self._messageQueue_)
	self:_notifyObservers('onPop',r)
end

function ChatCenter:getAllMessages(type,page)
	page = page or 1 -- default read page 1
	if not self._messageQueue_[type] then return {} end 
	local pageMax = math.ceil(#self._messageQueue_[type] / MAX_MESSAGE_PER_PAGE)
	if page > pageMax then return {} end
	if page <= 0 then page = 1 end
	local data = self._messageQueue_[type] or  {}

	local s,e = self:getSAndEWithPage(page)
	return self:limitDataSource(data,s,e)
end

function ChatCenter:getAll(type)
	return self._messageQueue_[type] or  {}
end

function ChatCenter:getSAndEWithPage(page)
	return 1 + (page - 1) * MAX_MESSAGE_PER_PAGE,MAX_MESSAGE_PER_PAGE * page
end


function ChatCenter:limitDataSource(source,s,e)
	if not checktable(source) then return end
	local r = {}
	for i=s,e do
		local chat = source[i]
		if chat then
			if not self:_isBlockedChat(chat) then
				table.insert(r,chat)
			end
		end
	end
	return r
end

function ChatCenter:requestAllMessage()
	NetManager:getFetchChatPromise()
end

-- Private

-- handler for net request,call my listeners
function ChatCenter:handleNetMessage(eventName,msg )
	if eventName == 'onAllChat' then
		self._messageQueue_ = {}
		for _,v in ipairs(msg) do
			self:_insertMessage(v)
		end
		-- dump(self._messageQueue_)
		self:_notifyObservers('onRefresh', self._messageQueue_)
		self:_notifyObservers('onLastMessage', msg[#msg])
	elseif eventName == 'onChat' then
		self:pushMessage(msg)
	end
end

function ChatCenter:_notifyObservers( event,data)
	self:NotifyObservers(function(listener)
		if listener.messageEvent then
			listener.messageEvent(listener,event,data)
		end
	end)
end

function ChatCenter:_insertMessage(v )
	if not v.fromType then return end
	if string.lower(v.fromType) ~='system' then
		if not self._messageQueue_[string.lower(v.fromType)] then
			self._messageQueue_[string.lower(v.fromType)] = {}
		end
		if not self:_isBlockedChat(v) then
			table.insert(self._messageQueue_[string.lower(v.fromType)],v)
			return true
		end
	else
		print("插入系统消息")
		--系统邮件默认放入世界聊天频道
		if not self._messageQueue_[string.lower('global')] then self._messageQueue_[string.lower('global')] = {} end
		table.insert(self._messageQueue_[string.lower('global')],v)
		return true
	end
	return false
end

--是否被列入了黑名单
function ChatCenter:_isBlockedChat( chat )
	local isBlocked = false
	for _,v in ipairs(self._blockedIdList_) do
		if chat.fromId == v.fromId then
			isBlocked = true
			break
		end
	end
	return isBlocked
end

function ChatCenter:add2BlockedList(chat)
	local isIn = false
	for _,v in ipairs(self._blockedIdList_) do
		if v.fromId == chat.fromId then
			isIn = true
			break
		end
	end
	if isIn then return end
	table.insert(self._blockedIdList_,chat)
	for i,v in ipairs(self._messageQueue_[chat.fromType]) do
		if v.fromId == chat.fromId then 
			table.remove(self._messageQueue_[chat.fromType],i)
		end
	end
	LuaUtils:outputTable("self._blockedIdList_", self._blockedIdList_)
end


function ChatCenter:getBlockedList()
	return self._blockedIdList_ or {}
end


function ChatCenter:removeItemFromBlockList(fromId)
	local flag  = false
	local index = -1
	for i,v in ipairs(self._blockedIdList_) do
		if v.fromId == fromId then
			flag = true
			index = i
			table.remove(self._blockedIdList_,i)
			break
		end
	end
	return flag,index
end

function ChatCenter:initBlockList()
	local jsonString = cc.UserDefault:getInstance():getStringForKey('ChatCenter')
	if jsonString and string.len(jsonString) > 0 then
		local t = json.decode(jsonString)
		if type(t) == 'table' then
			return t
		end
	end
	return {}
end

function ChatCenter:flush()  
	local jsonString = json.encode(self._blockedIdList_)
	cc.UserDefault:getInstance():setStringForKey('ChatCenter', jsonString)
	cc.UserDefault:getInstance():flush()
end

return ChatCenter