DataManager = {}

function DataManager:setUserData( userData )
	self["user"] = userData
	City:OnUserDataChanged(app.timer:GetServerTime(), userData)
end

function DataManager:getUserData(  )
	return self["user"]
end