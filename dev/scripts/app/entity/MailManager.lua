local Enum = import("..utils.Enum")
local MultiObserver = import("..entity.MultiObserver")
local Report = import("..entity.Report")

local MailManager = class("MailManager", MultiObserver)
MailManager.LISTEN_TYPE = Enum("MAILS_CHANGED","UNREAD_MAILS_CHANGED","REPORTS_CHANGED","FETCH_MAILS")

function MailManager:ctor()
    MailManager.super.ctor(self)
    self.mails = {}
    self.savedMails = {}
    self.sendMails = {}
    self.reports = {}
    self.savedReports = {}
end

function MailManager:IncreaseUnReadMailsNum(num)
    self.unread_mail = self.unread_mail + num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged({mail=self.unread_mail})
    end)
end

function MailManager:IncreaseUnReadReportNum(num)
    self.unread_report = self.unread_report + num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged({report=self.unread_report})
    end)
end

function MailManager:DecreaseUnReadMailsNum(num)
    self.unread_mail = self.unread_mail - num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(
            {
                mail=self.unread_mail
            }
        )
    end)
end

function MailManager:DecreaseUnReadReportsNum(num)
    self.unread_report = self.unread_report - num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(
            {
                report=self.unread_report
            }
        )
    end)
end

function MailManager:DecreaseUnReadMailsNumByIds(ids)
    local mails = self.mails
    local num = 0
    for _,mail in pairs(mails) do
        for _,id in pairs(ids) do
            if id==mail.id and not mail.isRead then
                num = num + 1
            end
        end
    end
    self.unread_mail = self.unread_mail - num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(
            {
                mail=self.unread_mail
            }
        )
    end)
end

function MailManager:DecreaseUnReadReportsNumByIds(ids)
    local reports = self.reports
    local num = 0
    for _,report in pairs(reports) do
        for _,id in pairs(ids) do
            if id==report.id and not report.isRead then
                num = num + 1
            end
        end
    end
    self.unread_report = self.unread_report - num
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(
            {
                report=self.unread_report
            }
        )
    end)
end

function MailManager:GetUnReadMailsAndReportsNum()
    return self.unread_mail + self.unread_report
end
function MailManager:GetUnReadMailsNum()
    return self.unread_mail
end
function MailManager:GetUnReadReportsNum()
    return self.unread_report
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
    -- 由于服务器每次删除邮件后都回更改index，所以每次删除邮件后，对于客服端本地保存的邮件的服务器index大于当前删除邮件的都需要-1
    local delete_mail_server_index
    for k,v in pairs(self.mails) do
        if v.id == mail.id then
            table.remove(self.mails,k)
            delete_mail_server_index = v.index
        end
    end
    for k,v in pairs(self.mails) do
        if v.index > delete_mail_server_index then
            v.index = v.index - 1
        end
    end
end
function MailManager:ModifyMail(mail)
    for k,v in pairs(self.mails) do
        if v.id == mail.id then
            dump(v,"before ModifyMail")
            for i,modify in ipairs(mail) do
                v[i] = modify
            end
            dump(v,"after ModifyMail")
            return v
        end
    end
end
-- 更新某项属性
function MailManager:ModifyMailAttr(index,attr)
    local mail = self.mails[index]
    print("index==",index,#self.mails)
    assert(mail,"修改邮件属性，邮件不存在")
    for k,v in pairs(attr) do
        mail[k] = v
        if k == "isSaved" then
            self:OnNewSavedMailsChanged(mail)
        end
    end
    return mail
end
function MailManager:DeleteSendMail(mail)
    for k,v in pairs(self.sendMails) do
        if v.id == mail.id then
            table.remove(self.sendMails,k)
        end
    end
end

function MailManager:dispatchMailServerData( eventName,msg )
-- if eventName == "onGetMailsSuccess" then
--     -- 获取邮件成功,加入MailManager缓存
--     for _,mail in pairs(msg.mails) do
--         table.insert(self.mails, mail)
--     end
-- elseif eventName == "onGetSavedMailsSuccess" then
--     -- 获取邮件成功,加入MailManager缓存
--     for _,mail in pairs(msg.mails) do
--         table.insert(self.savedMails, mail)
--     end
-- elseif eventName == "onGetSendMailsSuccess" then
--     -- 获取邮件成功,加入MailManager缓存
--     for _,mail in pairs(msg.mails) do
--         table.insert(self.sendMails, mail)
--     end
-- elseif eventName == "onSendMailSuccess" then
--     for _,mail in pairs(msg.mail) do
--         table.insert(self.sendMails, mail)
--     end
-- elseif eventName == "onGetReportsSuccess" then
--     for _,report in pairs(msg.reports) do
--         table.insert(self.reports, Report:DecodeFromJsonData(report))
--     end
-- elseif eventName == "onGetSavedReportsSuccess" then
--     for _,report in pairs(msg.reports) do
--         table.insert(self.savedReports,Report:DecodeFromJsonData(report))
--     end
-- else
--     return
-- end
-- self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
--     listener:OnServerDataEvent({
--         eventType = eventName,
--         data = msg
--     })
-- end)
end
function MailManager:AddMailsToEnd(mail)
    table.insert(self.mails, mail)
end
function MailManager:GetMails(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    local mails = {}
    if self.mails[fromIndex+1] then
        for i=fromIndex+1,fromIndex+10 do
            if self.mails[i] then
                table.insert(mails, self.mails[i])
            else
                break
            end
        end
    end
    return mails
end
function MailManager:GetMailByServerIndex(serverIndex)
    local mails = self.mails
    for i,v in ipairs(mails) do
        print(".....v.index == index",v.title,v.index,serverIndex,v.index == serverIndex)
    end
    for i,v in ipairs(mails) do
        print("v.index == index",v.title,v.index,serverIndex,v.index == serverIndex)
        if v.index == serverIndex then
            return i
        end
    end
end
function MailManager:FetchMailsFromServer(fromIndex)
    NetManager:getFetchMailsPromise(fromIndex):next(function ( fetch_mails )
        self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_MAILS,function(listener)
            listener:OnFetchMailsSuccess(fetch_mails)
        end)
    end)
end
function MailManager:GetSavedMails(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0

    if self.savedMails[fromIndex+1] then
        local savedMails = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.savedMails[i] then
                table.insert(savedMails, self.savedMails[i])
            else
                break
            end
        end
        return savedMails
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getFetchSavedMailsPromise(fromIndex)
    end
end
function MailManager:FetchSavedMailsFromServer(fromIndex)
    NetManager:getFetchSavedMailsPromise(fromIndex):next(function ( fetch_mails )
        self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_MAILS,function(listener)
            listener:OnFetchMailsSuccess(fetch_mails)
        end)
    end)
end
function MailManager:GetSendMails(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.sendMails[fromIndex+1] then
        local sendMails = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.sendMails[i] then
                table.insert(sendMails, self.sendMails[i])
            end
        end
        return sendMails
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getFetchSendMailsPromise(fromIndex):catch(function(err)
            dump(err:reason())
        end)
    end
end
function MailManager:OnMailStatusChanged( mailStatus )
    if mailStatus.unreadMails then
        self.unread_mail = mailStatus.unreadMails
    end
    if mailStatus.unreadReports then
        self.unread_report = mailStatus.unreadReports
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED,function(listener)
        listener:MailUnreadChanged(
            {
                mail=self.unread_mail,
                report=self.unread_report
            }
        )
    end)
end
function MailManager:OnMailsChanged( mails )
    self.mails = clone(mails)
end
function MailManager:OnSavedMailsChanged( savedMails )
    self.savedMails = clone(savedMails)
end
function MailManager:OnSendMailsChanged( sendMails )
    self.sendMails = clone(sendMails)
end

function MailManager:OnNewMailsChanged( mails )
    local add_mails = {}
    local remove_mails = {}
    local edit_mails = {}
    for type,mail in pairs(mails) do
        if type == "add" then
            for i,data in ipairs(mail) do
                -- 收到
                if not data.index then
                    data.index = self.mails[1].index + 1
                    print("收到新邮件，计算服务器下标,客服端最新邮件下标",self.mails[1].index)
                end
                table.insert(add_mails, data)
                table.insert(self.mails, 1, data)
                self:IncreaseUnReadMailsNum(1)

                -- 由于当前 DataManager中的mails 最新这条是服务器的index,需要修正为客户端index
                LuaUtils:outputTable("DataManager:需要修正为客户端index().mails", DataManager:getUserData().mails)

                local u_mails = DataManager:getUserData().mails
                local max_index = 0
                for k,v in pairs(u_mails) do
                    max_index = math.max(k,max_index)
                end
                local max_mail = u_mails[max_index]
                local temp_mail = table.remove(u_mails,max_index)
                table.insert(u_mails, 1 ,temp_mail)
                LuaUtils:outputTable("DataManager:getUserData().mails", DataManager:getUserData().mails)
                print("ta")
            end
        elseif type == "remove" then
            for i,data in ipairs(mail) do
                table.insert(remove_mails, data)
                self:DeleteMail(data)
            end
        elseif type == "edit" then
            for i,data in ipairs(mail) do
                table.insert(edit_mails, self:ModifyMail(data))
            end
        elseif tolua.type(type) == "number" then
            table.insert(edit_mails, self:ModifyMailAttr(tonumber(type),mail))
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
    if savedMails.isSaved then
        table.insert(add_mails, savedMails)
        table.insert(self.savedMails, savedMails)
    else
        table.insert(remove_mails, savedMails)
                self:DeleteSavedMail(savedMails)
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
    for type,mail in pairs(sendMails) do
        if type == "add" then
            for i,data in ipairs(mail) do
                table.insert(add_mails, data)
                table.insert(self.sendMails, data)
            end
        elseif type == "remove" then
            for i,data in ipairs(mail) do
                table.insert(remove_mails, data)
                self:DeleteSendMail(data)
            end
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
        listener:OnSendMailsChanged({
            add_mails = add_mails,
            remove_mails = remove_mails,
        })
    end)
end
function MailManager:OnUserDataChanged(userData,timer,deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.mailStatus ~= nil
    -- 邮件
    if is_fully_update or is_delta_update then
        self:OnMailStatusChanged(userData.mailStatus)
    end
    if is_fully_update then
        self:OnMailsChanged(userData.mails)
        self:OnSavedMailsChanged(userData.savedMails)
        self:OnSendMailsChanged(userData.sendMails)
    end
    LuaUtils:outputTable("MailManager deltaData", deltaData)
    print("ta")
    is_delta_update = not is_fully_update and deltaData.mails ~= nil
    if is_delta_update then
        self:OnNewMailsChanged(deltaData.mails)
    end
    is_delta_update = not is_fully_update and deltaData.sendMails ~= nil
    if is_delta_update then
        self:OnNewSendMailsChanged(deltaData.sendMails)
    end

    -- 战报部分
    if userData.reports then
        self:OnReportsChanged(userData.reports)
    end
    if userData.savedReports then
        self:OnSavedReportsChanged(userData.savedReports)
    end
    if userData.__reports then
        self:OnNewReportsChanged(userData.__reports)
    end
    if userData.__savedReports then
        self:OnNewSavedReportsChanged(userData.__savedReports)
    end
end

function MailManager:OnReportsChanged( reports )
    for k,v in pairs(reports) do
        table.insert(self.reports, Report:DecodeFromJsonData(v))
    end
end
function MailManager:OnSavedReportsChanged( savedReports )
    for k,v in pairs(savedReports) do
        table.insert(self.savedReports, Report:DecodeFromJsonData(v))
    end
end
function MailManager:OnNewReportsChanged( __reports )
    local add_reports = {}
    local remove_reports = {}
    local edit_reports = {}
    for _,rp in pairs(__reports) do
        if rp.type == "add" then
            local c_report = Report:DecodeFromJsonData(rp.data)
            table.insert(add_reports, c_report)
            table.insert(self.reports,1, c_report)
            self:IncreaseUnReadReportNum(1)
        elseif rp.type == "remove" then
            table.insert(remove_reports, Report:DecodeFromJsonData(rp.data))
            self:DeleteReport(rp.data)
        elseif rp.type == "edit" then
            table.insert(edit_reports, Report:DecodeFromJsonData(rp.data))
            self:ModifyReport(rp.data)
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.REPORTS_CHANGED,function(listener)
        listener:OnReportsChanged({
            add = add_reports,
            remove = remove_reports,
            edit = edit_reports,
        })
    end)
end
function MailManager:OnNewSavedReportsChanged( __savedReports )
    local add_reports = {}
    local remove_reports = {}
    local edit_reports = {}
    for _,rp in pairs(__savedReports) do
        if rp.type == "add" then
            table.insert(add_reports, Report:DecodeFromJsonData(rp.data))
            table.insert(self.savedReports, Report:DecodeFromJsonData(rp.data))
        elseif rp.type == "remove" then
            table.insert(remove_reports, Report:DecodeFromJsonData(rp.data))
            self:DeleteSavedReport(rp.data)
        elseif rp.type == "edit" then
            table.insert(edit_reports, Report:DecodeFromJsonData(rp.data))
            self:ModifySavedReport(rp.data)
        end
    end

    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.REPORTS_CHANGED,function(listener)
        listener:OnSavedReportsChanged({
            add = add_reports,
            remove = remove_reports,
            edit = edit_reports,
        })
    end)
end
function MailManager:DeleteReport( report )
    for k,v in pairs(self.reports) do
        if v:Id() == report.id then
            table.remove(self.reports,k)
        end
    end
end
function MailManager:ModifyReport( report )
    for k,v in pairs(self.reports) do
        if v:Id() == report.id then
            self.reports[k] = Report:DecodeFromJsonData(report)
        end
    end
end
function MailManager:DeleteSavedReport( report )
    for k,v in pairs(self.savedReports) do
        if v:Id() == report.id then
            table.remove(self.savedReports,k)
        end
    end
end
function MailManager:ModifySavedReport( report )
    for k,v in pairs(self.savedReports) do
        if v:Id() == report.id then
            self.savedReports[k] = Report:DecodeFromJsonData(report)
        end
    end
end
function MailManager:GetReports(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.reports[fromIndex+1] then
        local reports = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.reports[i] then
                table.insert(reports, self.reports[i])
            else
                break
            end
        end
        return reports
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getReportsPromise(fromIndex)
    end
end
function MailManager:GetSavedReports(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0
    if self.savedReports[fromIndex+1] then
        local reports = {}
        for i=fromIndex+1,fromIndex+10 do
            if self.savedReports[i] then
                table.insert(reports, self.savedReports[i])
            else
                break
            end
        end
        return reports
    else
        -- 本地没有缓存，则从服务器获取
        NetManager:getSavedReportsPromise(fromIndex)
    end
end
return MailManager



















