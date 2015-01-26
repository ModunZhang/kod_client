local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEResource = class("WidgetPVEResource", WidgetPVEDialog)

function WidgetPVEResource:ctor(...)
    WidgetPVEResource.super.ctor(self, ...)
end
function WidgetPVEResource:GetDesc()
    if self:GetObject():IsSearched() then
        return _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!')
    elseif self:GetObject():Searched() == 1 then
        return _('你已经突破了叛军第一层的防御, 你感觉到前方有更强大的敌人...')
    elseif self:GetObject():Searched() == 2 then
        return _('胜利就在眼前, 前方就是叛军的将领, 将击败你便能永久占领此地!')
    elseif self:GetObject():Searched() == 3 then
        return _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
    end
    return _("这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。")
end
function WidgetPVEResource:SetUpButtons()
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

                self.user:SetPveData(report:GetAttackKDA())
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
            end):addToCurrentScene(true)
        end }, { label = _("离开") } }
end

return WidgetPVEResource
















