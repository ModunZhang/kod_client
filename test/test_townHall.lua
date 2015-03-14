local Game = require("Game")
local TownHallUpgradeBuilding = import("app.entity.TownHallUpgradeBuilding")

City = import("app.entity.City").new()
module( "test_toolShop", lunit.testcase, package.seeall )
function setup()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        TownHallUpgradeBuilding.new({ x = 19, y = 19, building_type = "townHall", level = 1, w = 6, h = 6 }),
    })
    City:GenerateWalls()
end


function test_toolShop()
    local townHall = City:GetFirstBuildingByType("townHall")
    assert_table(townHall)
    -- assert_table(townHall:GetTaxEvent())

    -- townHall:AddTownHallListener({
    --     OnBeginImposeWithEvent = function(lisenter, townhall, event)
    --         assert_equal(0, townhall:GetTaxEvent():StartTime())
    --     end,
    --     OnImposingWithEvent = function(lisenter, townhall, event, current_time)

    --     end,
    --     OnEndImposeWithEvent = function(lisenter, townhall, event, current_time)
    --     end,
    --     OnGetTaxWithEvent = function(lisenter, townhall, event)
    --         assert_true(townhall:IsEmpty())
    --     end,
    -- })

    -- townHall:ImposeWithFinishedTime(800, townHall:GetImposeTime())

    -- Game.new():OnUpdate(function(time)
    --     townHall:OnTimer(time)
    --     if time == 1 then
    --         assert_true(townHall:IsInImposing())
    --         assert_true(not townHall:IsEmpty())
    --         assert_equal(1, townHall:GetTaxEvent():ElapseTime(time))
    --         assert_equal(8639, townHall:GetTaxEvent():LeftTime(time))
    --         assert_equal(8640, townHall:GetImposeTime())
    --     elseif time == townHall:GetImposeTime() then
    --         townHall:EndImposeWithCurrentTime(800, time)
    --     elseif time == townHall:GetImposeTime() + 1 then
    --         return false
    --     end
    --     return true
    -- end, 0.000001)
end







