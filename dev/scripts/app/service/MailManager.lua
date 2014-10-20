local Enum = import("..utils.Enum")
local Observer = import("..entity.Observer")

local MailManager = class("MailManager", Observer)
MailManager.LISTEN_TYPE = Enum("RECEIVED_MAILS","DELETE_MAILS","SAVE_MAILS","UNSAVE_MAILS","SEND_MAILS")

function MailManager:ctor()
    MailManager.super.ctor(self)
    self.mails = {}
    self.savedMails = {}
    self.sendMails = {}
end

-- function MailManager:GetMails()
--     return self.mails
-- end
-- function MailManager:GetSavedMails()
--     return self.savedMails
-- end
-- function MailManager:GetSendMails()
--     return self.sendMails
-- end

function MailManager:IncreaseUnReadMailsAndReports(num)
    self.unread_num = self.unread_num + num
end

function MailManager:DecreaseUnReadMailsAndReports(num)
    self.unread_num = self.unread_num - num
end

function MailManager:GetUnReadMailsAndReportsNum()
    return self.unread_num
end
function MailManager:AddSavedMail(mail)
    table.insert(self.savedMails,1, mail)
end
function MailManager:DeleteSavedMail(mail)
    for k,v in pairs(self.savedMails) do
        if v.id == mail.id then
            table.remove(self.savedMails,k)
        end
    end
end
function MailManager:DeleteMail(mail)
    for k,v in pairs(self.mails) do
        if v.id == mail.id then
            table.remove(self.mails,k)
        end
    end
end
function MailManager:AddSendMail(mail)
-- body
end
function MailManager:dispatchMailServerData( eventName,msg )
    if eventName == "onGetMailsSuccess" then
        -- 获取邮件成功,加入MailManager缓存
        for _,mail in pairs(msg.mails) do
            table.insert(self.mails, mail)
        end
    elseif eventName == "onNewMailReceived" then
        table.insert(self.mails,1, msg.mail)
    elseif eventName == "onGetSavedMailsSuccess" then
        -- 获取邮件成功,加入MailManager缓存
        for _,mail in pairs(msg.mails) do
            table.insert(self.savedMails, mail)
        end
    elseif eventName == "onGetSendMailsSuccess" then
        -- 获取邮件成功,加入MailManager缓存
        for _,mail in pairs(msg.mails) do
            table.insert(self.sendMails, mail)
        end
    elseif eventName == "onSendMailSuccess" then
        for _,mail in pairs(msg.mails) do
            table.insert(self.sendMails, mail)
        end
    end

    self:NotifyObservers(function(listener)
        listener:OnServerDataEvent({
            eventType = eventName,
            data = msg
        })
    end)
end

function MailManager:GetMails(cb,fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.mails[fromIndex+1] then
        local mails = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.mails[i] then
                table.insert(mails, self.mails[i])
            end
        end
        cb()
        return mails
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getMails(fromIndex,NOT_HANDLE)
    end
end

function MailManager:GetSavedMails(cb,fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.savedMails[fromIndex+1] then
        local savedMails = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.savedMails[i] then
                table.insert(savedMails, self.savedMails[i])
            end
        end
        cb()
        return savedMails
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getSavedMails(fromIndex,cb)
    end
end

function MailManager:GetSendMails(cb,fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.sendMails[fromIndex+1] then
        local sendMails = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.sendMails[i] then
                table.insert(sendMails, self.sendMails[i])
            end
        end
        cb()
        return sendMails
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getSendMails(fromIndex,NOT_HANDLE)
    end
end

function MailManager:OnUserDataChanged(userData,timer)
    -- 未读邮件和战报信息
    self.unread_num = userData.mailStatus.unreadMails + userData.mailStatus.unreadReports
    local mails = userData.mails
    -- inbox 改变，按收到时间最新排序
    table.sort(mails,function(mail_a,mail_b)
        if mail_a.sendTime==mail_b.sendTime then
            return mail_a.fromName<mail_b.fromName
        else
            return mail_a.sendTime>mail_b.sendTime
        end
    end)
    for k,v in pairs(mails) do
        table.insert(self.mails,v)
    end


    local savedMails = userData.savedMails
    -- table.sort(savedMails,function(mail_a,mail_b)
    --     if mail_a.sendTime==mail_b.sendTime then
    --         return mail_a.fromName<mail_b.fromName
    --     else
    --         return mail_a.sendTime>mail_b.sendTime
    --     end
    -- end)
    for k,v in pairs(savedMails) do
        table.insert(self.savedMails,v)
    end


    local sendMails = userData.sendMails
    table.sort(sendMails,function(mail_a,mail_b)
        if mail_a.sendTime==mail_b.sendTime then
            return mail_a.fromName<mail_b.fromName
        else
            return mail_a.sendTime<mail_b.sendTime
        end
    end)
    for k,v in pairs(sendMails) do
        table.insert(self.sendMails,v)
    end

end


return MailManager








