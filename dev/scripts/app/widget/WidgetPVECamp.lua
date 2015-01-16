local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVECamp = class("WidgetPVECamp", WidgetPVEDialog)

function WidgetPVECamp:ctor(...)
    WidgetPVECamp.super.ctor(self, ...)
end
function WidgetPVECamp:GetIcon()
    return "camp_137x80.png"
end
function WidgetPVECamp:GetTitle()
    return string.format("%s %s%d", _('野外营地'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVECamp:GetDesc()
    if self:GetObject():IsSearched() then
        return _('你看到营地有火光, 走到近前却是空空荡荡。你感觉纳闷, 这里怎么如此眼熟。')
    elseif self:GetObject():Searched() == 1 then
        return _('你击败了部队的主力, 但部队剩下的士兵向你发起了冲锋。')
    end
    return _('你大胆地闯入了一支不明身份部队的营地, 一场战斗一触即发。')
end
function WidgetPVECamp:SetUpButtons()
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

return WidgetPVECamp















