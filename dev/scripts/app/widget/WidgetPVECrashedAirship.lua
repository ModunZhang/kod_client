local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVECrashedAirship = class("WidgetPVECrashedAirship", WidgetPVEDialog)

function WidgetPVECrashedAirship:ctor(...)
    WidgetPVECrashedAirship.super.ctor(self, ...)
end
function WidgetPVECrashedAirship:GetIcon()
    return "crashed_airship_94x80.png"
end
function WidgetPVECrashedAirship:GetTitle()
    return string.format("%s %s%d", _('坠毁的飞艇'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVECrashedAirship:GetDesc()
    return self:GetObject():IsSearched() 
    and _('一艘飞艇的残骸, 可惜里面的物资早已被人洗劫一空')
    or _('你发现了一艘坠毁的飞艇, 其中的有大量的物资, 但当你走近时却发现那里已经被强盗占领。')
end
function WidgetPVECrashedAirship:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("离开") } } or
        { { label = _("进攻"), callback = function()
            UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType, soldiers)
                local dargon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                local attack_dragon = {
                    currentHp = dargon:Hp(),
                    hpMax = dargon:GetMaxHP(),
                    strength = dargon:TotalStrength(),
                    vitality = dargon:TotalVitality(),
                }
                local attack_soldier = LuaUtils:table_map(soldiers, function(k, v)
                    return k, {name = v.name,
                        star = 1,
                        morale = 100,
                        currentCount = v.count,
                        totalCount = v.count,
                        woundedCount = 0,
                        round = 0}
                end)

                local defence_dragon = {
                    currentHp = 1000,
                    hpMax = 1000,
                    strength = 700,
                    vitality = 200,
                }
                local defence_soldier = {
                    {
                        name = "ranger",
                        star = 1,
                        morale = 100,
                        currentCount = 50,
                        totalCount = 50,
                        woundedCount = 0,
                        round = 0
                    }
                }

                local report = GameUtils:DoBattle(
                    {dragon = attack_dragon, soldiers = attack_soldier}
                    ,{dragon = defence_dragon, soldiers = defence_soldier}
                )

                if report:IsAttackWin() then
                    self:Search()
                end

                UIKit:newGameUI("GameUIReplay",report):addToCurrentScene(true)
            end):addToCurrentScene(true)
        end }, { label = _("离开") } }
end

return WidgetPVECrashedAirship















