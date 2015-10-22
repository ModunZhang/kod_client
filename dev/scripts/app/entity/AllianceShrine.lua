--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceInitData.shrineStage
local config_shrine = GameDatas.AllianceBuilding.shrine
local AllianceShrineStage = import(".AllianceShrineStage")
local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceShrine = class("AllianceShrine",MultiObserver)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local Enum = import("..utils.Enum")
local ShrineFightEvent = import(".ShrineFightEvent")
local ShrineReport = import(".ShrineReport")
local GameUtils = GameUtils
local Localize = import("..utils.Localize")

AllianceShrine.LISTEN_TYPE = Enum()

function AllianceShrine:ctor(alliance)
    AllianceShrine.super.ctor(self)
    self.alliance = alliance
    self:loadStages()
end

function AllianceShrine:GetAlliance()
    return self.alliance
end

--配置表加载所有的关卡
function AllianceShrine:loadStages()
    if self.stages then return end
    local stages_ = {}
    local large_key = "1_1"
    table.foreach(config_shrineStage,function(key,config)
        local stage = AllianceShrineStage.new(config)
        stages_[key] = stage
        if key > large_key then
            large_key = key
        end
    end)
    property(self,"stages",stages_)
end

function AllianceShrine:Reset()
end

function AllianceShrine:OnPropertyChange(property_name, old_value, value)
end

-- api
--------------------------------------------------------------------------------------
--联盟危机


function AllianceShrine:GetStageByIndex(index)
    for _,v in pairs(self:Stages()) do
        if v:Index() == index then
            return v
        end
    end
    return nil
end

function AllianceShrine:GetStatgeByName(state_name)
    return self:Stages()[state_name]
end


function AllianceShrine:GetStarInfoByMainStage(statge_index)
    local current_star,total_star = 0,0
    for key,stage in pairs(self:Stages()) do
        if tonumber(string.sub(key,1,1)) == statge_index then
            current_star = current_star + stage:Star()
            total_star = total_star + stage:MaxStar()
        end
    end
    return current_star,total_star
end

-- state is number 1~6
function AllianceShrine:GetSubStagesByMainStage(statge_index)
    local tempStages = {}
    for key,stage in pairs(self:Stages()) do
        if tonumber(string.sub(key,1,1)) == statge_index then
            table.insert(tempStages,stage)
        end
    end
    table.sort(tempStages,function(a,b) return a:StageName() < b:StageName() end)
    return tempStages
end

function AllianceShrine:GetMainStageDescName(statge_index)
    return Localize.shrine_desc[string.format("main_stage_%s",statge_index)]
end


return AllianceShrine

