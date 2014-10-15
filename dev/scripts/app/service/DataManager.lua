DataManager = {}

function DataManager:setUserData( userData )
    if not self.user then
        self.user = userData
    else
    	for k, v in pairs(userData) do
    		self.user[k] = v
    	end
    end
    City:OnUserDataChanged(userData, app.timer:GetServerTime())
end

function DataManager:getUserData(  )
    return self.user
end

