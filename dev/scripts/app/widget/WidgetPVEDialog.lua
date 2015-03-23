local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local UILib = import("..ui.UILib")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPVEDialog = class("WidgetPVEDialog", WidgetPopDialog)


function WidgetPVEDialog:ctor(x, y, user)
    self.x = x
    self.y = y
    self.user = user
    self.pve_map = user:GetCurrentPVEMap()
    self.object = self.pve_map:GetObject(x, y)
    WidgetPVEDialog.super.ctor(self, 250, self:GetTitle(), display.cy + 150)
    self.dialog = display.newNode():addTo(self:GetBody())
    self.pve_map:AddObserver(self)
end
function WidgetPVEDialog:onEnter()
    WidgetPVEDialog.super.onEnter(self)
    self:Refresh()
end
function WidgetPVEDialog:onExit()
    WidgetPVEDialog.super.onExit(self)
    self.pve_map:RemoveObserver(self)
end
function WidgetPVEDialog:GetCurrentUser()
    return self.user
end
function WidgetPVEDialog:GetPVEMap()
    return self.pve_map
end
function WidgetPVEDialog:GetObject()
    return self.object
end
function WidgetPVEDialog:OnObjectChanged(object)
    local x, y = object:Position()
    if self.x == x and self.y == y then
        self:Refresh()
    end
end
function WidgetPVEDialog:Refresh()
    self.dialog:removeAllChildren()
    local size = self:GetBody():getContentSize()
    local w,h = size.width, size.height
    local dialog = self.dialog
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_frame_36x136.png"):align(display.LEFT_CENTER, 50, h*0.5 + 20)
        :addTo(dialog):flipX(true)
    cc.ui.UIImage.new("building_frame_36x136.png"):align(display.RIGHT_CENTER, 50 + 133, h*0.5 + 20)
        :addTo(dialog)
    local type_,image,s = self:GetIcon()
    if type_ == "image" then
        display.newSprite(image):addTo(dialog):pos(50 + 133 * 0.5, h*0.5 + 20):scale(s or 1)
    else
        ccs.Armature:create(image):addTo(dialog):pos(50 + 133 * 0.5, h*0.5 + 20):scale(s or 1):getAnimation():gotoAndPause(0)
    end

    --
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(dialog):pos(50 + 133 * 0.5, h*0.5 - 80)
    local size = level_bg:getContentSize()
    UIKit:ttfLabel({
        text = self:GetBrief(),
        size = 20,
        color = 0x514d3e,
    }):addTo(level_bg):align(display.CENTER, size.width/2 , size.height/2)

    --
    UIKit:ttfLabel({
        text = self:GetDesc(),
        size = 18,
        color = 0x797154,
        dimensions = cc.size(300,0)
    }):align(display.LEFT_TOP, 220, h*0.5 + 50):addTo(dialog)

    --
    local param = self:SetUpButtons()
    for i = #param, 1, -1 do
        cc.ui.UIPushButton.new({normal = "btn_138x110.png",pressed = "btn_pressed_138x110.png"})
            :addTo(dialog):pos(w - (#param - i + 0.5) * 138, - 110*0.5 + 10):setButtonLabel(UIKit:ttfLabel({
            text = param[i].label,
            size = 25,
            color = 0xffedae}))
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    if type(param[i].callback) == "function" then
                        cocos_promise.defer(function()
                            param[i].callback()
                        end)
                    else
                        self:removeFromParent()
                    end
                end
            end)
    end
end
function WidgetPVEDialog:GetIcon()
    return unpack(UILib.pve[self:GetObject():Type()])
end
function WidgetPVEDialog:GetTitle()
    return ""
end
function WidgetPVEDialog:GetBrief()
    if self:GetObject():IsUnSearched() then
        return _('未探索')
    elseif self:GetObject():IsSearched() then
        return _("已探索")
    else
        return string.format("%s%d%s", _("还剩"), self:GetObject():Left(), _("层"))
    end
end
function WidgetPVEDialog:GetDesc()
    return ""
end
function WidgetPVEDialog:SetUpButtons()
    return { { label = _("离开") } }
end
function WidgetPVEDialog:GotoNext()
    local cur_index = self.pve_map:GetIndex()
    local next_index = cur_index + 1
    local next_map = self.user:GetPVEDatabase():GetMapByIndex(next_index)
    if next_map then
        local point = next_map:GetStartPoint()
        self.user:GetPVEDatabase():SetCharPosition(point.x, point.y, next_index)
        NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData()):next(function(result)
            app:EnterPVEScene(next_index)
        end):catch(function(err)
            dump(err:reason())
        end)
    else
    end
end
function WidgetPVEDialog:HasGem(num)
    local gem = self:GetCurrentUser():GetGemResource():GetValue()
    if gem >= num then
        return true
    end
    return false
end
function WidgetPVEDialog:UseStrength(num)
    return self:GetCurrentUser():UseStrength(num)
end
function WidgetPVEDialog:AddStrength(num)
    local user = self:GetCurrentUser()
    user:GetStrengthResource():AddResourceByCurrentTime(app.timer:GetServerTime(), num)
    user:OnResourceChanged()
    return true
end
function WidgetPVEDialog:Search()
    local x, y = self:GetObject():Position()
    local searched = self:GetObject():Searched()
    self:GetPVEMap():ModifyObject(x, y, searched + 1)
end
function WidgetPVEDialog:GetRewardsFromServer(select)
    self.user:SetPveData(nil, self:GetObject():GetRewards(select))
    NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData())
end
function WidgetPVEDialog:Fight()
    local enemy = self:GetObject():GetNextEnemy()
    UIKit:newGameUI('GameUIPVESendTroop',
        enemy.soldiers,-- pve 怪数据
        function(dragonType, soldiers)
            local dargon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
            local attack_dragon = {
                dragonType = dragonType,
                currentHp = dargon:Hp(),
                hpMax = dargon:GetMaxHP(),
                totalHp = dargon:Hp(),
                strength = dargon:TotalStrength(),
                vitality = dargon:TotalVitality(),
                dragon = dragon,
            }
            local attack_soldier = LuaUtils:table_map(soldiers, function(k, v)
                return k, {name = v.name,
                    star = 1,
                    power = GameUtils:GetSoldiersConfig(v.name, 1),
                    morale = 100,
                    currentCount = v.count,
                    totalCount = v.count,
                    woundedCount = 0,
                    round = 0}
            end)


            dump(dargon:GetSkillByName("dragonBlood"))
            dump(dargon:GetAllEquipmentBuffEffect())

            local report = GameUtils:DoBattle(
                {dragon = attack_dragon, soldiers = attack_soldier}
                ,{dragon = enemy.dragon, soldiers = enemy.soldiers}
            )

            if report:IsAttackWin() then
                local rewards = self:GetObject():IsLast() and enemy.rewards + self:GetObject():GetRewards() or enemy.rewards
                self.user:SetPveData(report:GetAttackKDA(), rewards)
                NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData()):next(function()
                    self:Search()
                    UIKit:newGameUI("GameUIReplay", report, function()
                        if report:IsAttackWin() then
                            GameGlobalUI:showTips(_("获得奖励"), rewards)
                        end
                    end):addToCurrentScene(true)
                end):catch(function(err)
                    dump(err:reason())
                end)
            else
                self.user:SetPveData(report:GetAttackKDA())
                NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData()):next(function()
                    UIKit:newGameUI("GameUIReplay", report):addToCurrentScene(true)
                end):catch(function(err)
                    dump(err:reason())
                end)
            end
        end):addToCurrentScene(true)
end



return WidgetPVEDialog



















