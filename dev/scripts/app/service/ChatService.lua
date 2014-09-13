--
-- Author: dannyhe
-- Date: 2014-08-16 15:06:14
--
local ChatService = {}

setmetatable(ChatService, {__index=NetManager})
--简单的将NetManager分为多个文件 继承自NetManager
ChatService.translateFunctionOpened = true -- 是否打开翻译功能

function ChatService:sendChat(data, cb)
	if checktable(data) and string.len(string.trim(data.text)) > 0 then
	    self.m_netService:request("chat.chatHandler.send",data, function(success)
	        cb(success)
	    end, false)
	else
		cb(false)
	end
end

function ChatService:getAllChat(cb)
    self.m_netService:request("chat.chatHandler.getAll", nil, function(success)
        cb(err)
    end, false)
end

return ChatService