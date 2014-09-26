DataManager = {}

function DataManager:setUserData( userData )
	self["user"] = userData
	City:OnUserDataChanged(userData, app.timer:GetServerTime())
end

function DataManager:getUserData(  )
	return self["user"]
end