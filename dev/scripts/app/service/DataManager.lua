DataManager = {}

function DataManager:setUserData( userData, deltaData )
    self.user = userData
    self:OnUserDataChanged(self.user, app.timer:GetServerTime(), deltaData)
end
function DataManager:setUserAllianceData(allianceData,deltaData)
	self.alliance = allianceData
	if allianceData == json.null then return end
	Alliance_Manager:OnAllianceDataChanged(allianceData,app.timer:GetServerTime(),deltaData)
end

function DataManager:getUserAllianceData()
	return self.alliance or {}
end

function DataManager:getUserData(  )
    return self.user
end

function DataManager:OnUserDataChanged(userData,timer, deltaData)
	dump(deltaData,"deltaData----->")
	User:OnUserDataChanged(userData, timer, deltaData)
	ItemManager:OnUserDataChanged(userData, timer, deltaData)
    City:OnUserDataChanged(userData, timer, deltaData)
    Alliance_Manager:OnUserDataChanged(userData, timer, deltaData)
    MailManager:OnUserDataChanged(userData, timer, deltaData)
end

