local Game = require("Game")
local BarracksUpgradeBuilding = import("app.entity.BarracksUpgradeBuilding")
local City = import("app.entity.City").new()


module( "test_barracks", lunit.testcase, package.seeall )
function setup()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    City:InitBuildings({
        BarracksUpgradeBuilding.new({ x = 9, y = 9, building_type = "barracks", level = 1, w = 9, h = 10 }),
    })
    City:InitDecorators({})
    City:ClearAllListener()
    City:GenerateWalls()
end
function test_barracks()
    local barracks = City:GetFirstBuildingByType("barracks")
    assert_table(barracks)
    assert_table(barracks:GetRecruitEvent())

    barracks:AddBarracksListener({
        OnBeginRecruit = function(lisenter, barracks, event)
            assert_equal(0, barracks:GetRecruitEvent():StartTime())
        end,
        OnRecruiting = function(lisenter, barracks, event, current_time)
            print(event:LeftTime(current_time))
        end,
        OnEndRecruit = function(lisenter, barracks, event, current_time)
            dump(event)
        end,
    })

    barracks:RecruitSoldiersWithFinishTime("swordsman", 1, barracks:GetRecruitingTimeByTypeWithCount("swordsman", 1))

    Game.new():OnUpdate(function(time)
        barracks:OnTimer(time)
        if time == 1 then
        elseif time == barracks:GetRecruitingTimeByTypeWithCount("swordsman", 1) then
            barracks:EndRecruitSoldiersWithCurrentTime(time)
        elseif time == barracks:GetRecruitingTimeByTypeWithCount("swordsman", 1) + 1 then
            return false
        end
        return true
    end)
end
