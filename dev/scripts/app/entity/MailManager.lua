local Enum = import("..utils.Enum")
local MultiObserver = import("..entity.MultiObserver")
local Report = import("..entity.Report")

local MailManager = class("MailManager", MultiObserver)
MailManager.LISTEN_TYPE = Enum("MAILS_CHANGED","UNREAD_MAILS_CHANGED","REPORTS_CHANGED","FETCH_MAILS","FETCH_SAVED_MAILS","FETCH_SEND_MAILS"
    ,"FETCH_REPORTS","FETCH_SAVED_REPORTS")

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
    local delete_mail_server_index
    for k,v in pairs(self.savedMails) do
        if v.id == mail.id then
            delete_mail_server_index = v.index
            table.remove(self.savedMails,k)
        end
    end
    for k,v in pairs(self.savedMails) do
        if v.index > delete_mail_server_index then
            v.index = v.index - 1
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
            if v.isSaved then
                v.isSaved = false
                self:OnNewSavedMailsChanged(v)
            end
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
            for i,modify in ipairs(mail) do
                v[i] = modify
            end
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
        if k == "isRead" then
            self:OnNewSavedMailsChanged(mail,true)
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

function MailManager:AddMailsToEnd(mail)
    table.insert(self.mails, mail)
end
function MailManager:AddSavedMailsToEnd(mail)
    table.insert(self.savedMails, mail)
end
function MailManager:AddSendMailsToEnd(mail)
    table.insert(self.sendMails, mail)
end
function MailManager:AddReportsToEnd(report)
    table.insert(self.reports, Report:DecodeFromJsonData(report))
end
function MailManager:AddSavedReportsToEnd(report)
    table.insert(self.savedReports, Report:DecodeFromJsonData(report))
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
function MailManager:GetReportByServerIndex(serverIndex)
    local reports = self.reports
    for i,v in ipairs(reports) do
        print(".....v.index == index",v:Index(),serverIndex)
    end
    for i,v in ipairs(reports) do
        if v:Index() == serverIndex then
            return i
        end
    end
end
function MailManager:FetchMailsFromServer(fromIndex)
    NetManager:getFetchMailsPromise(fromIndex):done(function(response)
        if response.msg.mails then
            local user_data = DataManager:getUserData()
            local fetch_mails = {}
            for i,v in ipairs(response.msg.mails) do
                table.insert(user_data.mails, v)
                MailManager:AddMailsToEnd(v)
                table.insert(fetch_mails, v)
            end
            self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_MAILS,function(listener)
                listener:OnFetchMailsSuccess(fetch_mails)
            end)
        end
    end)
end
function MailManager:GetSavedMails(fromIndex)
    -- 首先检查本地MailManager是否缓存有之前获取到的邮件
    local fromIndex = fromIndex or 0

    local savedMails = {}
    if self.savedMails[fromIndex+1] then
        for i=fromIndex+1,fromIndex+10 do
            if self.savedMails[i] then
                table.insert(savedMails, self.savedMails[i])
            else
                break
            end
        end
    end
    return savedMails
end
function MailManager:FetchSavedMailsFromServer(fromIndex)
    NetManager:getFetchSavedMailsPromise(fromIndex):done(function (response)
        if response.msg.mails then
            local user_data = DataManager:getUserData()
            local fetch_mails = {}
            for i,v in ipairs(response.msg.mails) do
                table.insert(user_data.savedMails, v)
                MailManager:AddSavedMailsToEnd(v)
                table.insert(fetch_mails, v)
            end
            self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_SAVED_MAILS,function(listener)
                listener:OnFetchSavedMailsSuccess(fetch_mails)
            end)
        end
    end)
end
function MailManager:GetSendMails(fromIndex)
    local fromIndex = fromIndex or 0
    local sendMails = {}
    if self.sendMails[fromIndex+1] then
        for i=fromIndex+1,fromIndex+10 do
            if self.sendMails[i] then
                table.insert(sendMails, self.sendMails[i])
            end
        end
    end
    return sendMails
end
function MailManager:FetchSendMailsFromServer(fromIndex)
    NetManager:getFetchSendMailsPromise(fromIndex):done(function(response)
        if response.msg.mails then
            local user_data = DataManager:getUserData()
            local fetch_mails = {}
            for i,v in ipairs(response.msg.mails) do
                table.insert(user_data.sendMails, v)
                MailManager:AddSendMailsToEnd(v)
                table.insert(fetch_mails, v)
            end
            self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_SEND_MAILS,function(listener)
                listener:OnFetchSendMailsSuccess(fetch_mails)
            end)
        end
    end)
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
                    data.index = self.mails[1] and (self.mails[1].index + 1) or 0
                end
                table.insert(add_mails, data)
                table.insert(self.mails, 1, data)
                self:IncreaseUnReadMailsNum(1)


                local u_mails = DataManager:getUserData().mails
                local max_index = 0
                for k,v in pairs(u_mails) do
                    max_index = math.max(k,max_index)
                end
                local temp_mail = table.remove(u_mails,max_index)
                table.insert(u_mails, 1 ,temp_mail)
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
function MailManager:OnNewSavedMailsChanged( savedMails,isRead )
    local add_mails = {}
    local remove_mails = {}
    local edit_mails = {}
    if isRead then
        table.insert(edit_mails, savedMails)
    else
        if savedMails.isSaved then
            table.insert(add_mails, savedMails)
            table.insert(self.savedMails, savedMails)
        else
            table.insert(remove_mails, savedMails)
            self:DeleteSavedMail(savedMails)
        end
    end
    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.MAILS_CHANGED,function(listener)
        listener:OnSavedMailsChanged({
            add_mails = add_mails,
            remove_mails = remove_mails,
            edit_mails = edit_mails,
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
    is_delta_update = not is_fully_update and deltaData.mails ~= nil
    if is_delta_update then
        self:OnNewMailsChanged(deltaData.mails)
    end
    is_delta_update = not is_fully_update and deltaData.sendMails ~= nil
    if is_delta_update then
        self:OnNewSendMailsChanged(deltaData.sendMails)
    end

    -- 战报部分
    if is_fully_update then
        self:OnReportsChanged(userData.reports)
        self:OnSavedReportsChanged(userData.savedReports)
    end
    local is_delta_update = not is_fully_update and deltaData.reports ~= nil
    if is_delta_update then
        self:OnNewReportsChanged(deltaData.reports)
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
    LuaUtils:outputTable("OnNewReportsChanged :__reports", __reports)
    for type,rp in pairs(__reports) do
        if type == "add" then
            for k,data in pairs(rp) do
                if not data.index then
                    data.index = self.reports[1] and (self.reports[1]:Index() + 1) or 0
                end
                local c_report = Report:DecodeFromJsonData(data)
                table.insert(add_reports, c_report)
                table.insert(self.reports,1, c_report)
                self:IncreaseUnReadReportNum(1)

                -- 由于当前 DataManager中的reports 最新这条是服务器的index,需要修正为客户端index

                local u_reports = DataManager:getUserData().reports
                local max_index = 0
                for k,v in pairs(u_reports) do
                    max_index = math.max(k,max_index)
                end
                local temp_report = table.remove(u_reports,max_index)
                table.insert(u_reports, 1 ,temp_report)
            end
        elseif type == "remove" then
            for k,data in pairs(rp) do
                table.insert(remove_reports, Report:DecodeFromJsonData(data))
                self:DeleteReport(data)
            end
        elseif type == "edit" then
            for k,data in pairs(rp) do
                table.insert(edit_reports,self:ModifyReport(data))
            end
        elseif tolua.type(type) == "number" then
            table.insert(edit_reports, self:ModifyReportByIndex(tonumber(type),rp))
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
    if __savedReports.isSaved then
        table.insert(add_reports, __savedReports)
        table.insert(self.savedReports, __savedReports)
    else
        table.insert(remove_reports, __savedReports)
        self:DeleteSavedReport(__savedReports)
    end


    self:NotifyListeneOnType(MailManager.LISTEN_TYPE.REPORTS_CHANGED,function(listener)
        listener:OnSavedReportsChanged({
            add = add_reports,
            remove = remove_reports,
        })
    end)

end
function MailManager:DeleteReport( report )
    local delete_report_server_index
    for k,v in pairs(self.reports) do
        if v:Id() == report.id then
            delete_report_server_index = v:Index()
            table.remove(self.reports,k)
            -- 收藏的战报需要在收藏夹中删除
            if v:IsSaved() then
                v:SetIsSaved(false)
                self:OnNewSavedReportsChanged(v)
            end
        end
    end
    for k,v in pairs(self.reports) do
        if v:Index() > delete_report_server_index then
            v:SetIndex(v:Index() - 1)
        end
    end
end
function MailManager:ModifyReport( report )
    for k,v in pairs(self.reports) do
        if v:Id() == report.id then
            self.reports[k]:Update(report)
            return self.reports[k]
        end
    end
end
function MailManager:ModifyReportByIndex( index,attr )
    local report = self.reports[index]
    print("index==",index,#self.reports)
    assert(report,"修改战报属性，战报不存在")
    for k,v in pairs(attr) do
        report[k] = v
        print("ModifyReportByIndex",k,v)
        if k == "isSaved" then
            self:OnNewSavedReportsChanged(report)
        end
    end
    return report
end
function MailManager:DeleteSavedReport( report )
    local delete_index
    for k,v in pairs(self.savedReports) do
        if v:Id() == report:Id() then
            delete_index = v:Index()
            table.remove(self.savedReports,k)
        end
    end
    for k,v in pairs(self.savedReports) do
        if v:Index() > delete_index then
            v:SetIndex(v:Index()-1)
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
    local reports = {}
    if self.reports[fromIndex+1] then
        for i=fromIndex+1,fromIndex+10 do
            if self.reports[i] then
                table.insert(reports, self.reports[i])
            else
                break
            end
        end
    end
    return reports
end
function MailManager:FetchReportsFromServer(fromIndex)
    NetManager:getReportsPromise(fromIndex)
        :done(function (response)
            if response.msg.reports then
                local user_data = DataManager:getUserData()
                local fetch_reports = {}
                for i,v in ipairs(response.msg.reports) do
                    table.insert(user_data.reports, v)
                    MailManager:AddReportsToEnd(v)
                    table.insert(fetch_reports, v)
                end
                self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_REPORTS,function(listener)
                    listener:OnFetchReportsSuccess(fetch_reports)
                end)
            end
        end)
end
function MailManager:GetSavedReports(fromIndex)
    local fromIndex = fromIndex or 0
    local reports = {}
    if self.savedReports[fromIndex+1] then
        for i=fromIndex+1,fromIndex+10 do
            if self.savedReports[i] then
                table.insert(reports, self.savedReports[i])
            else
                break
            end
        end
    end
    return reports
end
function MailManager:FetchSavedReportsFromServer(fromIndex)
    NetManager:getSavedReportsPromise(fromIndex):done(function (response)
        if response.msg.reports then
            local user_data = DataManager:getUserData()
            local fetch_reports = {}
            for i,v in ipairs(response.msg.reports) do
                table.insert(user_data.reports, v)
                MailManager:AddSavedReportsToEnd(v)
                table.insert(fetch_reports, v)
            end
            self:NotifyListeneOnType(MailManager.LISTEN_TYPE.FETCH_SAVED_REPORTS,function(listener)
                listener:OnFetchSavedReportsSuccess(fetch_reports)
            end)
        end
    end)
end
return MailManager




































