DataManager = {}

function DataManager:setUserData( userData )
	self["user"] = userData
	print("DataManagerDataManagerDataManager 啊啊啊")
	City:OnUserDataChanged(userData, app.timer:GetServerTime())
end

function DataManager:getUserData(  )
	return self["user"]
end