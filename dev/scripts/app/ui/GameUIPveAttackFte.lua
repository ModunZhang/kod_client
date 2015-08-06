local GameUIPveAttack = import(".GameUIPveAttack")
local GameUIPveAttackFte = class("GameUIPveAttackFte", GameUIPveAttack)
local mockData = import("..fte.mockData")
local WidgetFteArrow = import("..widget.WidgetFteArrow")
local sections = GameDatas.PvE.sections
function GameUIPveAttackFte:ctor(...)
    GameUIPveAttackFte.super.ctor(self, ...)
    self:DisableAutoClose()
end

local fightReport1 = {
    playerDragonFightData = {
        type = "greenDragon",
        hpMax = 116,
        hp = 116,
        isWin = true,
        hpDecreased = 15
    },
    sectionDragonFightData = {
        type = "blueDragon",
        hpMax = 116,
        hp = 116,
        isWin = false,
        hpDecreased = 22
    },
    playerSoldierRoundDatas = {{
        soldierName = "swordsman",
        morale = 100,
        soldierCount = 100,
        soldierWoundedCount = 2,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 2,
        moraleDecreased = 2
    }, {
        soldierName = "swordsman",
        morale = 98,
        soldierCount = 98,
        soldierWoundedCount = 2,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 2,
        moraleDecreased = 4
    }, {
        soldierName = "swordsman",
        morale = 94,
        soldierCount = 96,
        soldierWoundedCount = 1,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 1,
        moraleDecreased = 4
    }, {
        soldierName = "swordsman",
        morale = 90,
        soldierCount = 95,
        soldierWoundedCount = 1,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 1,
        moraleDecreased = 8
    }},
    sectionSoldierRoundDatas = {{
        soldierName = "lancer",
        morale = 100,
        soldierCount = 8,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 3,
        moraleDecreased = 19
    }, {
        soldierName = "ranger",
        morale = 100,
        soldierCount = 12,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 3,
        moraleDecreased = 13
    }, {
        soldierName = "catapult",
        morale = 100,
        soldierCount = 2,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 1,
        moraleDecreased = 25
    }, {
        soldierName = "swordsman",
        morale = 100,
        soldierCount = 4,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 3,
        moraleDecreased = 38
    }}
}


local fightReport2 = {
    playerDragonFightData = {
        type = "greenDragon",
        hpMax = 116,
        hp = 116,
        isWin = true,
        hpDecreased = 15
    },
    sectionDragonFightData = {
        type = "blueDragon",
        hpMax = 116,
        hp = 116,
        isWin = false,
        hpDecreased = 22
    },
    playerSoldierRoundDatas = {{
        soldierName = "swordsman",
        morale = 100,
        soldierCount = 100,
        soldierWoundedCount = 3,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 3,
        moraleDecreased = 3
    }, {
        soldierName = "swordsman",
        morale = 97,
        soldierCount = 97,
        soldierWoundedCount = 3,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 3,
        moraleDecreased = 6
    }, {
        soldierName = "swordsman",
        morale = 91,
        soldierCount = 94,
        soldierWoundedCount = 2,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 2,
        moraleDecreased = 8
    }, {
        soldierName = "swordsman",
        morale = 83,
        soldierCount = 92,
        soldierWoundedCount = 1,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 1,
        moraleDecreased = 8
    }},
    sectionSoldierRoundDatas = {{
        soldierName = "catapult",
        morale = 100,
        soldierCount = 6,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 2,
        moraleDecreased = 17
    }, {
        soldierName = "swordsman",
        morale = 100,
        soldierCount = 18,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 5,
        moraleDecreased = 14
    }, {
        soldierName = "lancer",
        morale = 100,
        soldierCount = 6,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 2,
        moraleDecreased = 17
    }, {
        soldierName = "ranger",
        morale = 100,
        soldierCount = 6,
        soldierWoundedCount = 0,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 3,
        moraleDecreased = 25
    }}
}


local fightReport3 = {
    playerDragonFightData = {
        type = "greenDragon",
        hpMax = 276,
        hp = 213,
        isWin = true,
        hpDecreased = 15
    },
    sectionDragonFightData = {
        type = "blueDragon",
        hpMax = 116,
        hp = 116,
        isWin = false,
        hpDecreased = 22
    },
    playerSoldierRoundDatas = {{
        soldierName = "swordsman",
        morale = 100,
        soldierCount = 100,
        soldierWoundedCount = 7,
        soldierStar = 1,
        isWin = false,
        soldierDamagedCount = 7,
        moraleDecreased = 8
    }, {
        soldierName = "ranger",
        morale = 100,
        soldierCount = 100,
        soldierWoundedCount = 5,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 5,
        moraleDecreased = 5
    }, {
        soldierName = "ranger",
        morale = 95,
        soldierCount = 95,
        soldierWoundedCount = 5,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 5,
        moraleDecreased = 10
    }, {
        soldierName = "ranger",
        morale = 85,
        soldierCount = 90,
        soldierWoundedCount = 2,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 2,
        moraleDecreased = 8
    }, {
        soldierName = "ranger",
        morale = 77,
        soldierCount = 88,
        soldierWoundedCount = 2,
        soldierStar = 1,
        isWin = true,
        soldierDamagedCount = 2,
        moraleDecreased = 16
    }},
    sectionSoldierRoundDatas = {{
        soldierName = "skeletonArcher",
        morale = 100,
        soldierCount = 16,
        soldierWoundedCount = 0,
        soldierStar = 2,
        isWin = true,
        soldierDamagedCount = 3,
        moraleDecreased = 10
    }, {
        soldierName = "skeletonArcher",
        morale = 90,
        soldierCount = 13,
        soldierWoundedCount = 0,
        soldierStar = 2,
        isWin = false,
        soldierDamagedCount = 4,
        moraleDecreased = 25
    }, {
        soldierName = "meatWagon",
        morale = 100,
        soldierCount = 3,
        soldierWoundedCount = 0,
        soldierStar = 2,
        isWin = false,
        soldierDamagedCount = 1,
        moraleDecreased = 17
    }, {
        soldierName = "skeletonWarrior",
        morale = 100,
        soldierCount = 8,
        soldierWoundedCount = 0,
        soldierStar = 2,
        isWin = false,
        soldierDamagedCount = 2,
        moraleDecreased = 13
    }, {
        soldierName = "deathKnight",
        morale = 100,
        soldierCount = 2,
        soldierWoundedCount = 0,
        soldierStar = 2,
        isWin = false,
        soldierDamagedCount = 1,
        moraleDecreased = 25
    }}
}

--
function GameUIPveAttackFte:Find()
    return self.attack
end
function GameUIPveAttackFte:PormiseOfFte()
    local r = self:Find():getCascadeBoundingBox()
    self:GetFteLayer():SetTouchObject(self:Find())

    WidgetFteArrow.new(_("点击进攻")):addTo(self:GetFteLayer())
        :TurnUp():align(display.TOP_CENTER, r.x + r.width/2, r.y - 10)

    self:Find():removeEventListenersByEvent("CLICKED_EVENT")
    self:Find():onButtonClicked(function()
        local soldiers = string.split(sections[self.pve_name].troops, ",")
        table.remove(soldiers, 1)
        UIKit:newGameUI('GameUIPVEFteSendTroop',
            LuaUtils:table_map(soldiers, function(k,v)
                local name,star = unpack(string.split(v, "_"))
                return k, {name = name, star = tonumber(star)}
            end),
            function(dragonType, soldiers)
                local dragon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                local report
                if self.pve_name == "1_1" then
                    report = fightReport1
                elseif self.pve_name == "1_2" then
                    report = fightReport2
                elseif self.pve_name == "1_3" then
                    report = fightReport3
                end
                mockData.FightWithNpc(self.pve_name)
                display.getRunningScene():GetSceneLayer():RefreshPve()
                report.playerDragonFightData.type = dragonType
                UIKit:newGameUI("GameUIReplayNew", self:DecodeReport(report, dragon, soldiers), function()
                    self:performWithDelay(function()
                        self:LeftButtonClicked()
                        display.getRunningScene():GetSceneLayer():MoveAirship(true)
                    end, 0)
                end):AddToCurrentScene(true)
            end):AddToCurrentScene(true)
    end)

    return UIKit:PromiseOfOpen("GameUIPVEFteSendTroop")
        :next(function(ui)
            self:GetFteLayer():removeFromParent()
            return ui:PormiseOfFte()
        end):next(function()
        return UIKit:PromiseOfClose("GameUIPveAttackFte")
        end)
end
return GameUIPveAttackFte








