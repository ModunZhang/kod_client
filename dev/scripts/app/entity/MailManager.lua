local Enum = import("..utils.Enum")
local MultiObserver = import("..entity.MultiObserver")

local MailManager = class("MailManager", MultiObserver)
MailManager.LISTEN_TYPE = Enum("MAILS_CHANGED","UNREAD_MAILS_CHANGED")

function MailManager:ctor()
    MailManager.super.ctor(self)
    self.mails = {}
    self.savedMails = {}
    self.sendMails = {}
end

function MailManager:IncreaseUnReadMailsAndReports(num)
    self.unread_num = self.unread_num + num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(self.unread_num)
    end)
end

function MailManager:DecreaseUnReadMailsAndReports(num)
    self.unread_num = self.unread_num - num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(self.unread_num)
    end)
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
function MailManager:ModifyMail(mail)
    for k,v in pairs(self.mails) do
        if v.id == mail.id then
            self.mails[k] = mail
        end
    end
end
function MailManager:DeleteSendMail(mail)
    for k,v in pairs(self.sendMails) do
        if v.id == mail.id then
            table.remove(self.sendMails,k)
        end
    end
end

function MailManager:dispatchMailServerData( eventName,msg )
    if eventName == "onGetMailsSuccess" then
        -- 获取邮件成功,加入MailManager缓存
        for _,mail in pairs(msg.mails) do
            table.insert(self.mails, mail)
        end
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
        for _,mail in pairs(msg.mail) do
            table.insert(self.sendMails, mail)
        end
    end

    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
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
        NetManager:getFetchMailsPromise(fromIndex):always(function ()
            cb()
        end):catch(function(err)
            dump(err:reason())
        end)
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
        NetManager:getFetchSavedMailsPromise(fromIndex):always(function ()
            cb()
        end):catch(function(err)
            dump(err:reason())
        end)
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
        NetManager:getFetchSendMailsPromise(fromIndex):always(function ()
            cb()
        end):catch(function(err)
            dump(err:reason())
        end)
    end
end
function MailManager:OnMailStatusChanged( mailStatus )
    self.unread_num = mailStatus.unreadMails
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(self.unread_num)
    end)
end
function MailManager:OnMailsChanged( mails )
    self.mails = mails
end
function MailManager:OnSavedMailsChanged( savedMails )
    self.savedMails = savedMails
end
function MailManager:OnSendMailsChanged( sendMails )
    self.sendMails =  sendMails
end

function MailManager:OnNewMailsChanged( mails )
    local add_mails = {}
    local remove_mails = {}
    local edit_mails = {}
    for _,mail in pairs(mails) do
        if mail.type == "add" then
            table.insert(add_mails, mail.data)
            table.insert(self.mails, mail.data)
            self:IncreaseUnReadMailsAndReports(1)
        elseif mail.type == "remove" then
            table.insert(remove_mails, mail.data)
            self:DeleteMail(mail.data)
        elseif mail.type == "edit" then
            table.insert(edit_mails, mail.data)
            self:ModifyMail(mail.data)
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
        listener:OnInboxMailsChanged({
            add_mails = add_mails,
            remove_mails = remove_mails,
            edit_mails = edit_mails,
        })
    end)
end
function MailManager:OnNewSavedMailsChanged( savedMails )
    local add_mails = {}
    local remove_mails = {}
    for _,mail in pairs(savedMails) do
        if mail.type == "add" then
            table.insert(add_mails, mail.data)
            table.insert(self.savedMails, mail.data)
        elseif mail.type == "remove" then
            table.insert(remove_mails, mail.data)
            self:DeleteSavedMail(mail.data)
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
        listener:OnSavedMailsChanged({
            add_mails = add_mails,
            remove_mails = remove_mails,
        })
    end)
end
function MailManager:OnNewSendMailsChanged( sendMails )
    local add_mails = {}
    local remove_mails = {}
    for _,mail in pairs(sendMails) do
        if mail.type == "add" then
            table.insert(add_mails, mail.data)
            table.insert(self.sendMails, mail.data)
        elseif mail.type == "remove" then
            table.insert(remove_mails, mail.data)
            self:DeleteSendMail(mail.data)
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
        listener:OnSendMailsChanged({
            add_mails = add_mails,
            remove_mails = remove_mails,
        })
    end)
end
function MailManager:OnUserDataChanged(userData,timer)
    -- 未读邮件和战报信息
    if userData.mailStatus then
        self:OnMailStatusChanged(userData.mailStatus)
    end
    if userData.mails then
        self:OnMailsChanged(userData.mails)
    end
    if userData.savedMails then
        self:OnSavedMailsChanged(userData.savedMails)
    end
    if userData.sendMails then
        self:OnSendMailsChanged(userData.sendMails)
    end
    if userData.__mails then
        self:OnNewMailsChanged(userData.__mails)
    end
    if userData.__savedMails then
        self:OnNewSavedMailsChanged(userData.__savedMails)
    end
    if userData.__sendMails then
        self:OnNewSendMailsChanged(userData.__sendMails)
    end
end


return MailManager




