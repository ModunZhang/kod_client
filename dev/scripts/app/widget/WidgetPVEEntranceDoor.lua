local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEEntranceDoor = class("WidgetPVEEntranceDoor", WidgetPVEDialog)

function WidgetPVEEntranceDoor:ctor(...)
    WidgetPVEEntranceDoor.super.ctor(self, ...)
end
function WidgetPVEEntranceDoor:GetIcon()
    return "entrance_door.png"
end
function WidgetPVEEntranceDoor:GetTitle()
    return string.format("%s %s%d", _('异界之门'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVEEntranceDoor:GetDesc()
    return self:GetObject():IsSearched() 
    and _('在没有什么能阻挡你前进了, 你可以直接前往下一个关卡')
    or _('你能感觉到一个一场强大的生物驻守在这里, 阻挡着你继续前进, 但想要前往下一关卡必须击败它。')
end
function WidgetPVEEntranceDoor:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("传送") }, { label = _("离开") } } or
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

return WidgetPVEEntranceDoor















