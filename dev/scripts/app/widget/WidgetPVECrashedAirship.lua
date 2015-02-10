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
    if self:GetObject():IsSearched() then
        return _('一艘飞艇的残骸, 可惜里面的物资早已被人洗劫一空。')
    elseif self:GetObject():Searched() == 1 then
        return _('强盗眼看不是你的对手, 想要烧毁这里的物资, 如果不阻拦他们那就得不到任何东西。')
    end
    return _('你发现了一艘坠毁的飞艇, 其中的有大量的物资, 但当你走近时却发现那里已经被强盗占领。')
end
function WidgetPVECrashedAirship:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("离开") } } or
        { { label = _("进攻"), callback = function()
            UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType, soldiers)
                local dargon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                local attack_dragon = {
                    dragonType = dragonType,
                    currentHp = dargon:Hp(),
                    hpMax = dargon:GetMaxHP(),
                    totalHp = dargon:Hp(),
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
                    dragonType = "redDragon",
                    currentHp = 100,
                    totalHp = 100,
                    hpMax = 100,
                    strength = 100,
                    vitality = 100,
                }
                local defence_soldier = {
                    {
                        name = "ranger",
                        star = 1,
                        morale = 100,
                        currentCount = 20,
                        totalCount = 20,
                        woundedCount = 0,
                        round = 0
                    }
                }

                local report = GameUtils:DoBattle(
                    {dragon = attack_dragon, soldiers = attack_soldier}
                    ,{dragon = defence_dragon, soldiers = defence_soldier}
                )

                self.user:SetPveData(report:GetAttackKDA(), {{type = "resources", name = "wood", count = 1000}})
                if report:IsAttackWin() then
                    self:Search()
                else
                    NetManager:getSetPveDataPromise(self.user:EncodePveData()):next(function(result)
                        dump(result)
                    end):catch(function(err)
                        dump(err:reason())
                    end)
                end

                UIKit:newGameUI("GameUIReplay",report):addToCurrentScene(true)
            end,{isPVE = true}):addToCurrentScene(true)
        end }, { label = _("离开") } }
end

return WidgetPVECrashedAirship















