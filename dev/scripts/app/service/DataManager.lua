DataManager = {}
local initData = import("..fte.initData")
function DataManager:setUserData( userData, deltaData )
    self.user = userData
    if not GLOBAL_FTE then
        LuaUtils:TimeCollect(function()
            self:OnUserDataChanged(self.user, app.timer:GetServerTime(), deltaData)
        end, "DataManager:setUserData")
    end
end
function DataManager:setUserAllianceData(allianceData,deltaData)
    self.allianceData = allianceData
    if GLOBAL_FTE then return end
    if allianceData == json.null then return end
    if not Alliance_Manager then
        print(debug.traceback("", 2))
        assert(false)
    end
    LuaUtils:TimeCollect(function()
        Alliance_Manager:OnAllianceDataChanged(allianceData,app.timer:GetServerTime(),deltaData)
    end, "DataManager:setUserAllianceData")
end
function DataManager:getUserAllianceData()
    return self.allianceData
end

function DataManager:getUserData()
    return self.user
end
function DataManager:hasUserData()
    return type(self.user) == "table"
end

function DataManager:setFteUserDeltaData(deltaData)
    if GLOBAL_FTE then
        LuaUtils:TimeCollect(function()
            self:OnUserDataChanged(self:getFteData(), app.timer:GetServerTime(), deltaData)
        end, "DataManager:setFteUserDeltaData")
    end
end
function DataManager:getFteData()
    return initData
end

function DataManager:setEnemyAllianceData(enemyAllianceData,deltaData)
    self.enemyAllianceData = enemyAllianceData
    if GLOBAL_FTE then return end
    if not Alliance_Manager then
        print(debug.traceback("", 2))
        assert(false)
    end
    LuaUtils:TimeCollect(function()
        Alliance_Manager:OnEnemyAllianceDataChanged(enemyAllianceData,app.timer:GetServerTime(),deltaData)
    end, "DataManager:setEnemyAllianceData")
end

function DataManager:getEnemyAllianceData()
    return self.enemyAllianceData
end

function DataManager:OnUserDataChanged(userData,timer, deltaData)
    if not User or not ItemManager or not City or not Alliance_Manager or not MailManager then
        print(debug.traceback("", 2))
        assert(false)
    end
    User:OnUserDataChanged(userData, timer, deltaData)
    ItemManager:OnUserDataChanged(userData, timer, deltaData)
    City:OnUserDataChanged(userData, timer, deltaData)
    Alliance_Manager:OnUserDataChanged(userData, timer, deltaData)
    MailManager:OnUserDataChanged(userData, timer, deltaData)
end



