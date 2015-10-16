local BuildingRegister = import("..entity.BuildingRegister")
local City_ = import("..entity.City")
local AllianceManager_ = import("..entity.AllianceManager")
local User_ = import("..entity.User")
local MailManager_ = import("..entity.MailManager")
local check = import("..fte.check")
local initData = import("..fte.initData")

local app = app
local timer = app.timer
return function(userData)
    DataManager.user = userData
    timer:Clear()
    MailManager = MailManager_.new()
    Alliance_Manager = AllianceManager_.new()
    if GLOBAL_FTE or userData.basicInfo.terrain == "__NONE__" then
        DataManager:getFteData()._id                = userData._id
        DataManager:getFteData().serverId           = userData.serverId
        DataManager:getFteData().serverTime         = userData.serverTime
        DataManager:getFteData().logicServerId      = userData.logicServerId
        DataManager:getFteData().basicInfo.name     = userData.basicInfo.name
        DataManager:getFteData().basicInfo.terrain  = userData.basicInfo.terrain
        DataManager:getFteData().basicInfo.language = userData.basicInfo.language
        User = User_.new(initData._id)
        City = City_.new(User):InitWithJsonData(initData)
        DataManager:setFteUserDeltaData()
    else
        User = User_.new(userData._id)
        City = City_.new(User):InitWithJsonData(userData)
        DataManager:setUserData(userData)
    end

    timer:AddListener(City)
    timer:AddListener(Alliance_Manager)
    timer:Start()
end

























