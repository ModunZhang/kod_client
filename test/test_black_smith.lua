local Game = require("Game")
local BlackSmithUpgradeBuilding = import("app.entity.BlackSmithUpgradeBuilding")

City = import("app.entity.City").new()
module( "test_blackSmith", lunit.testcase, package.seeall )
function setup()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        BlackSmithUpgradeBuilding.new({ x = 19, y = 19, building_type = "blackSmith", level = 1, w = 6, h = 6 }),
    })
    City:GenerateWalls()
end


function test_blackSmith()
    local blackSmith = City:GetFirstBuildingByType("blackSmith")
    assert_table(blackSmith)
    assert_table(blackSmith:GetMakeEquipmentEvent())

    blackSmith:AddBlackSmithListener({
        OnBeginMakeEquipmentWithEvent = function(lisenter, black_smith, event)
            assert_equal(0, black_smith:GetMakeEquipmentEvent():StartTime())
        end,
        OnMakingEquipmentWithEvent = function(lisenter, black_smith, event, current_time)
            -- print("OnMakingMaterialsWithEvent", current_time)
        end,
        OnEndMakeEquipmentWithEvent = function(lisenter, black_smith, event, equipment)
            assert_equal("redCrown_s1", equipment)
            assert_true(event:IsEmpty())
        end,
    })

    blackSmith:MakeEquipmentWithFinishTime("redCrown_s1", blackSmith:GetMakingTimeByEquipment("redCrown_s1"))

    Game.new():OnUpdate(function(time)
        blackSmith:OnTimer(time)
        if time == 1 then
            assert_true(blackSmith:IsMakingEquipment())
            assert_true(not blackSmith:IsEquipmentEventEmpty())
            assert_equal(1, blackSmith:GetMakeEquipmentEvent():ElapseTime(time))
            assert_equal(1600 - 1, blackSmith:GetMakeEquipmentEvent():LeftTime(time))
            assert_equal(1600, blackSmith:GetMakingTimeByEquipment("redCrown_s1"))
        elseif time == blackSmith:GetMakingTimeByEquipment("redCrown_s1") then
            blackSmith:EndMakeEquipmentWithCurrentTime(time)
        elseif time == blackSmith:GetMakingTimeByEquipment("redCrown_s1") + 1 then
            return false
        end
        return true
    end, 0.0001)
end







