DataManager = {}

function DataManager:setUserData( userData )
	self["user"] = userData
end

function DataManager:getUserData(  )
	return self["user"]
end