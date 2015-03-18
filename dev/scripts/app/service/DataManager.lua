DataManager = {}

function DataManager:setUserData( userData, deltaData )
    self.user = userData
    self:OnUserDataChanged(self.user, app.timer:GetServerTime(), deltaData)
end
function DataManager:setUserAllianceData(allianceData)
	Alliance_Manager:OnAllianceDataChanged(allianceData)
end


function DataManager:getUserData(  )
    return self.user
end

function DataManager:OnUserDataChanged(userData,timer, deltaData)
	User:OnUserDataChanged(userData, timer, deltaData)
	ItemManager:OnUserDataChanged(userData, timer, deltaData)
    City:OnUserDataChanged(userData, timer, deltaData)
    Alliance_Manager:OnUserDataChanged(userData, timer, deltaData)
    MailManager:OnUserDataChanged(userData, timer, deltaData)
end

