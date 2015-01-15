local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEFarmer = class("WidgetPVEFarmer", WidgetPVEDialog)

function WidgetPVEFarmer:ctor(...)
    WidgetPVEFarmer.super.ctor(self, ...)
end
function WidgetPVEFarmer:GetIcon()
    return SpriteConfig["farmer"]:GetConfigByLevel(1).png
end
function WidgetPVEFarmer:GetTitle()
    return string.format("%s %s%d", _('废弃的农夫小屋'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVEFarmer:GetDesc()
    return self:GetObject():IsSearched() 
    and _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!') 
    or _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
end
function WidgetPVEFarmer:SetUpButtons()
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

return WidgetPVEFarmer















