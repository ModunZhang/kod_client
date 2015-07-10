--
-- Author: Kenny Dai
-- Date: 2015-07-09 17:05:27
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local monsterConfig = GameDatas.AllianceInitData.monster

local GameUIAllianceMosterEnter = class("GameUIAllianceMosterEnter", WidgetPopDialog)

function GameUIAllianceMosterEnter:ctor(entity,isMyAlliance,alliance)
    local moster = entity:GetAllianceMonsterInfo()
    self.entity = entity
    print("self.entity = ",self.entity.id)
    self.moster_config = monsterConfig[moster.level]
    self.isMyAlliance = isMyAlliance
    self.alliance = alliance
    GameUIAllianceMosterEnter.super.ctor(self,286,_("野怪"),window.top - 200,"title_red_600x56.png")
end
function GameUIAllianceMosterEnter:onExit()
    scheduler.unscheduleGlobal(self.handle)
    GameUIAllianceMosterEnter.super.onExit(self)
end
function GameUIAllianceMosterEnter:onEnter()
    GameUIAllianceMosterEnter.super.onEnter(self)
    local alliance = self.alliance 
    local entity = self.entity 
    local moster_config = self.moster_config
    local rewards = string.split(moster_config.rewards,",")
    local icon = string.split(moster_config.icon,"_")
    local soldier_type = icon[1]
    local soldier_star = tonumber(icon[2])
    local level = moster_config.level

    local body = self:GetBody()
    local b_size = body:getContentSize()
    local b_width , b_height = b_size.width , b_size.height
    -- 下次刷新野怪时间
    local header_bg = UIKit:CreateBoxPanelWithBorder({height = 58}):align(display.TOP_CENTER, b_width/2, b_height - 30):addTo(body)
    self.time_label = UIKit:ttfLabel({
        text = string.format(_("即将消失:%s"),GameUtils:formatTimeStyle1(alliance:MonsterRefreshTime()/1000 - app.timer:GetServerTime())),
        color = 0x6a1f10,
        size = 22,
    }):addTo(header_bg):align(display.CENTER, header_bg:getContentSize().width/2, header_bg:getContentSize().height/2)
    -- 怪物士兵头像
    local soldier_ui_config = UILib.black_soldier_image[soldier_type][soldier_star]
    display.newSprite("red_bg_128x128.png"):addTo(body)
        :align(display.CENTER_TOP,100, b_height-100):scale(130/128)

    local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.CENTER_TOP,100, b_height-100)
    soldier_head_icon:scale(130/soldier_head_icon:getContentSize().height)
    display.newSprite("box_soldier_128x128.png"):addTo(soldier_head_icon):align(display.CENTER, soldier_head_icon:getContentSize().width/2, soldier_head_icon:getContentSize().height-64)
    body:addChild(soldier_head_icon)
    -- 等级
    local level_bg = WidgetUIBackGround.new({width = 130 , height = 36},WidgetUIBackGround.STYLE_TYPE.STYLE_3)
        :align(display.CENTER, soldier_head_icon:getPositionX(), soldier_head_icon:getPositionY() - 154):addTo(body)
    UIKit:ttfLabel({
        text = string.format(_("等级%d"),level),
        color = 0x514d3e,
        size = 22,
    }):addTo(level_bg):align(display.CENTER, level_bg:getContentSize().width/2, level_bg:getContentSize().height/2)

    -- 奖励背景框
    local reward_bg = display.newScale9Sprite("back_ground_258x90.png",0,0,cc.size(398,172),cc.rect(10,10,238,70))
        :align(display.RIGHT_BOTTOM, b_width - 25, 15)
        :addTo(body)
    self.reward_bg = reward_bg

    local title_bg = display.newScale9Sprite("back_ground_blue_254x42.png", 1, 172,cc.size(395,30),cc.rect(10,10,234,22)):align(display.LEFT_TOP):addTo(reward_bg)
    UIKit:ttfLabel({
        text = _("有几率获得"),
        color = 0xffedae,
        size = 20,
    }):addTo(title_bg):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)

    -- 奖励分为三个类别显示：资源道具，建筑建筑材料，银币道具和金龙币道具
    -- 资源道具框
    display.newSprite("box_118x118.png"):addTo(reward_bg):align(display.CENTER, 56, 90):scale(88/118)
    display.newSprite("box_118x118.png"):addTo(reward_bg):align(display.CENTER, 200, 90):scale(88/118)
    display.newSprite("box_118x118.png"):addTo(reward_bg):align(display.CENTER, 340, 90):scale(88/118)

    local items_rewards = {}
    local buildingMaterials_rewards = {}
    local gem_rewards = {}
    for i,v in ipairs(rewards) do
        local unit_reward = string.split(v,":")
        local reward_data = {name = unit_reward[2],count = unit_reward[3]}
        if string.find(v,"items") then
            if string.find(v,"coinClass") or string.find(v,"gemClass") then
                table.insert(gem_rewards, reward_data)
            else
                table.insert(items_rewards, reward_data)
            end
        else
            table.insert(buildingMaterials_rewards, reward_data)
        end
    end
    self.items_rewards = items_rewards
    self.buildingMaterials_rewards = buildingMaterials_rewards
    self.gem_rewards = gem_rewards

    self.item_index = 1
    local item_index = self.item_index
    local item_icon = display.newSprite(UILib.item[items_rewards[item_index].name])
        :align(display.CENTER, 56, 90)
        :addTo(reward_bg)
    item_icon:scale(74/math.max(item_icon:getContentSize().width,item_icon:getContentSize().height))
    self.item_icon = item_icon
    self.item_count_label = UIKit:ttfLabel({
        text = "X "..items_rewards[item_index].count,
        size = 20,
        color = 0x615b44
    }):addTo(reward_bg)
        :align(display.CENTER, 56, 30 )

    self.material_index = 1
    local material_index = self.material_index
    local material_icon = display.newSprite(UILib.materials[buildingMaterials_rewards[material_index].name])
        :align(display.CENTER, 200, 90)
        :addTo(reward_bg)
    material_icon:scale(74/math.max(material_icon:getContentSize().width,material_icon:getContentSize().height))
    self.material_icon = material_icon
    self.material_count_label = UIKit:ttfLabel({
        text = "X "..buildingMaterials_rewards[material_index].count,
        size = 20,
        color = 0x615b44
    }):addTo(reward_bg)
        :align(display.CENTER, 200, 30 )

    self.gem_index = 1
    local gem_index = self.gem_index
    local gem_icon = display.newSprite(UILib.item[gem_rewards[gem_index].name])
        :align(display.CENTER, 340, 90)
        :addTo(reward_bg)
    gem_icon:scale(74/math.max(gem_icon:getContentSize().width,gem_icon:getContentSize().height))
    self.gem_icon = gem_icon
    self.gem_count_label = UIKit:ttfLabel({
        text = "X "..gem_rewards[gem_index].count,
        size = 20,
        color = 0x615b44
    }):addTo(reward_bg)
        :align(display.CENTER, 340, 30 )
    -- 从第一栏开始变换
    self.change_index = 1
    self.handle = scheduler.scheduleGlobal(handler(self, self.ShowReward), 1, false)


    -- 进攻按钮
    local btn = WidgetPushButton.new({normal = "btn_138x110.png",pressed = "btn_pressed_138x110.png"},{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        }):onButtonClicked(function()
        	 UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers,total_march_time,gameuialliancesendtroops)
                    if alliance:GetSelf():IsProtected() then
                        UIKit:showMessageDialog(_("提示"),_("进攻改目标将失去保护状态，确定继续派兵?"),function()
                            NetManager:getAttackMonsterPromise(dragonType,soldiers,alliance:Id(),entity.id):done(function()
                                app:GetAudioManager():PlayeEffectSoundWithKey("TROOP_SENDOUT")
                            end)
                        end)
                    else
                        NetManager:getAttackMonsterPromise(dragonType,soldiers,alliance:Id(),entity.id):done(function()
                            app:GetAudioManager():PlayeEffectSoundWithKey("TROOP_SENDOUT")
                        end)
                    end
                end,{}):AddToCurrentScene(true)
                self:LeftButtonClicked()
        end):addTo(body):align(display.RIGHT_TOP, b_width, 10)
    local s = btn:getCascadeBoundingBox().size
    display.newSprite("attack_58x56.png"):align(display.CENTER, -s.width/2, -s.height/2+12):addTo(btn)
    UIKit:ttfLabel({
        text =  _("进攻"),
        size = 18,
        color = 0xffedae,
    }):align(display.CENTER, -s.width/2 , -s.height+25):addTo(btn)
end
function GameUIAllianceMosterEnter:ShowReward()
    local items_rewards = self.items_rewards
    if self.change_index == 1 then
        local item_index = self.item_index
        self.item_index = (item_index + 1) > #items_rewards and 1 or (item_index + 1)
        self.item_icon:setTexture(UILib.item[items_rewards[self.item_index].name])
        self.item_count_label:setString("X "..items_rewards[self.item_index].count)
    elseif self.change_index == 2 then
        local buildingMaterials_rewards = self.buildingMaterials_rewards
        local material_index = self.material_index
        self.material_index = (material_index + 1) > #buildingMaterials_rewards and 1 or (material_index + 1)
        self.material_icon:setTexture(UILib.materials[buildingMaterials_rewards[self.material_index].name])
        self.material_count_label:setString("X "..items_rewards[self.material_index].count)
    else
        local gem_rewards = self.gem_rewards
        local gem_index = self.gem_index
        self.gem_index = (gem_index + 1) > #gem_rewards and 1 or (gem_index + 1)
        self.gem_icon:setTexture(UILib.item[gem_rewards[self.gem_index].name])
        self.gem_count_label:setString("X "..items_rewards[self.gem_index].count)
    end
    self.change_index = (self.change_index + 1) > 3 and 1 or (self.change_index + 1)

    self.time_label:setString(string.format(_("即将消失:%s"),GameUtils:formatTimeStyle1(self.alliance:MonsterRefreshTime()/1000 - app.timer:GetServerTime())))
end
return GameUIAllianceMosterEnter







