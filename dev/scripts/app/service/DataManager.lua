DataManager = {}

function DataManager:setUserData( userData )
    if not self.user then
        self.user = userData
    else
    	for k, v in pairs(userData) do
    		self.user[k] = v
    	end
    end
    self:OnUserDataChanged(userData, app.timer:GetServerTime())
end
function DataManager:setUserAllianceData(allianceData)
	Alliance_Manager:OnAllianceDataChanged(allianceData)
end


function DataManager:getUserData(  )
    return self.user
end

function DataManager:OnUserDataChanged(userData,timer)
	User:OnUserDataChanged(userData, timer)
	ItemManager:OnUserDataChanged(userData, timer)
    City:OnUserDataChanged(userData, timer)
    Alliance_Manager:OnUserDataChanged(userData, timer)
    MailManager:OnUserDataChanged(userData, timer)
end

