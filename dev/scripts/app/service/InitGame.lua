local BuildingRegister = import("..entity.BuildingRegister")
local City_ = import("..entity.City")
local AllianceManager_ = import("..entity.AllianceManager")
local User_ = import("..entity.User")
local MailManager_ = import("..entity.MailManager")
local ChatCenter = import('..entity.ChatCenter')

local app = app
local timer = app.timer
return function(userData)
    User = User_.new(userData._id)
    Alliance_Manager = AllianceManager_.new()
    MailManager = MailManager_.new()
    City = City_.new(userData)

    DataManager:setUserData(userData)

    timer:AddListener(City)
    timer:AddListener(Alliance_Manager)
    timer:Start()

    ext.localpush.cancelAll()
    --read userdefaults about local push
    ext.localpush.switchNotification('BUILDING_PUSH_UPGRADE',true)

    local chatCenter = ChatCenter.new()
    chatCenter:requestAllMessage()
    app.chatCenter = chatCenter
    if CONFIG_IS_DEBUG then
        app:showDebugInfo()
    end
end

























