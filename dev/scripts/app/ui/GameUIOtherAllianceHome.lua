--
-- Author: Danny He
-- Date: 2014-11-21 09:57:42
--
local GameUIOtherAllianceHome = UIKit:createUIClass("GameUIOtherAllianceHome", "GameUIAllianceHome")
local WidgetPushButton = import("..widget.WidgetPushButton")
local window = import("..utils.window")
local Alliance = import("..entity.Alliance")
local Flag = import("..entity.Flag")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")



function GameUIOtherAllianceHome:onEnter()
    GameUIOtherAllianceHome.super.onEnter(self)
   
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
end

function GameUIOtherAllianceHome:onExit()
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)

    GameUIOtherAllianceHome.super.onExit(self)
end

function GameUIEnemyAllianceHome:TopBg()
    -- 顶部背景,为按钮
    local top_self_bg = WidgetPushButton.new({normal = "allianceHome/button_blue_normal_320X94.png",
        pressed = "allianceHome/button_blue_normal_320X94.png"})
        :align(display.TOP_CENTER, window.cx-160, window.top)
        :addTo(self)
    top_self_bg:setTouchEnabled(true)
    top_self_bg:setTouchSwallowEnabled(true)
    local top_enemy_bg = WidgetPushButton.new({normal = "allianceHome/button_red_normal_320X94.png",
        pressed = "allianceHome/button_blue_normal_320X94.png"})
        :align(display.TOP_CENTER, window.cx+160, window.top)
        :addTo(self)
    top_enemy_bg:setTouchEnabled(true)
    top_enemy_bg:setTouchSwallowEnabled(true)

    return top_self_bg,top_enemy_bg
end

function GameUIOtherAllianceHome:TopTabButtons()

    -- 荣誉,忠诚,坐标,世界按钮背景框
    local btn_bg = display.newSprite("allianceHome/back_ground_637x55.png")
        :align(display.TOP_CENTER, window.cx,window.top-94)
        :addTo(self)
    btn_bg:setTouchEnabled(true)

    -- 坐标按钮
    local coordinate_btn = WidgetPushButton.new({normal = "allianceHome/btn_138X42.png",
        pressed = "allianceHome/btn_138X42_light.png"})
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAlliancePosition'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 392, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    -- 坐标
    display.newSprite("allianceHome/coordinate.png")
        :align(display.CENTER, -40,coordinate_btn:getContentSize().height/2-4)
        :addTo(coordinate_btn)
    UIKit:ttfLabel(
        {
            text = _("坐标"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, -15, coordinate_btn:getContentSize().height/2+10)
        :addTo(coordinate_btn)
    self.coordinate_label = UIKit:ttfLabel(
        {
            text = "23,21",
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, -15, coordinate_btn:getContentSize().height/2-10)
        :addTo(coordinate_btn)

end

function GameUIOtherAllianceHome:CreateTop()
    local alliance = self.alliance
    local moonGate = alliance:GetAllianceMoonGate()
    local enemyAlliance = moonGate:GetEnemyAlliance()
    local top_self_bg,top_enemy_bg = self:TopBg()
    local t_self_width,t_self_height = top_self_bg:getCascadeBoundingBox().size.width,top_self_bg:getCascadeBoundingBox().size.height
    local t_enemy_width,t_enemy_height = top_enemy_bg:getCascadeBoundingBox().size.width,top_enemy_bg:getCascadeBoundingBox().size.height

    -- 己方联盟名字
    local self_name_bg = display.newSprite("allianceHome/title_green_292X32.png")
        :align(display.LEFT_CENTER, -t_self_width/2+10,-26)
        :addTo(top_self_bg):flipX(true)
    local self_name_label = UIKit:ttfLabel(
        {
            text = "["..enemyAlliance.tag.."] "..enemyAlliance.name,
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, 30, 20)
        :addTo(self_name_bg)
    -- 己方联盟旗帜
    local ui_helper = WidgetAllianceUIHelper.new()
    local self_flag = ui_helper:CreateFlagContentSprite(Flag.new():DecodeFromJson(enemyAlliance.flag)):scale(0.5)
    self_flag:align(display.CENTER, self_name_bg:getContentSize().width-100, -30):addTo(self_name_bg)

    -- 敌方联盟名字
    local enemy_name_bg = display.newSprite("allianceHome/title_red_292X32.png")
        :align(display.RIGHT_CENTER, t_enemy_width/2-10,-26)
        :addTo(top_enemy_bg)
    local enemy_name_label = UIKit:ttfLabel(
        {
            text = "["..alliance:AliasName().."] "..alliance:Name(),
            size = 18,
            color = 0xffedae
        }):align(display.RIGHT_CENTER, enemy_name_bg:getContentSize().width-30, 20)
        :addTo(enemy_name_bg)

    local enemy_flag = ui_helper:CreateFlagContentSprite(alliance:Flag()):scale(0.5)
    enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
        :addTo(enemy_name_bg)

    -- 和平期,战争期,准备期背景
    local period_bg = display.newSprite("allianceHome/back_ground_123x102.png")
        :align(display.TOP_CENTER, window.cx,window.top)
        :addTo(self)
    local vs = display.newSprite("allianceHome/VS_.png")
        :align(display.TOP_CENTER, period_bg:getContentSize().width/2,period_bg:getContentSize().height)
        :addTo(period_bg)
    local time_bg = display.newSprite("allianceHome/back_ground_109x46.png")
        :align(display.BOTTOM_CENTER, period_bg:getContentSize().width/2,12)
        :addTo(period_bg)
    local period_label = UIKit:ttfLabel(
        {
            text = _("战争期"),
            size = 16,
            color = 0xbdb582
        }):align(display.TOP_CENTER, time_bg:getContentSize().width/2, time_bg:getContentSize().height)
        :addTo(time_bg)
    self.time_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae
        }):align(display.BOTTOM_CENTER, time_bg:getContentSize().width/2, 0)
        :addTo(time_bg)
    -- 己方击杀
    local our_num_icon = cc.ui.UIImage.new("battle_39x38.png"):align(display.CENTER, -t_self_width/2+50, -65):addTo(top_self_bg)
    local self_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, -t_self_width/2+50, -65):addTo(top_self_bg)
    local self_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(moonGate:GetCountData().our.kill),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
        :addTo(self_power_bg)
    -- 敌方击杀
    local enemy_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
    local enemy_num_icon = cc.ui.UIImage.new("battle_39x38.png")
        :align(display.CENTER, 0, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)
    local enemy_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(moonGate:GetCountData().enemy.kill),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)

    self:TopTabButtons()
end

function GameUIOtherAllianceHome:OnMidButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 1 then
        self:ComeBackToOurAlliance()
    else
        GameUIOtherAllianceHome.super.OnMidButtonClicked(self,event)
    end
end

function GameUIOtherAllianceHome:CreateOperationButton()
    local first_row = 220
    local first_col = 177
    local label_padding = 100
    for i, v in ipairs({
        {"allianceHome/enemy.png", _("我方")},
        {"allianceHome/help.png", _("帮助")},
        {"allianceHome/war.png", _("战斗")},
    }) do
        local col = i - 1
        local y =  first_row + col*label_padding
        local button = WidgetPushButton.new({normal = v[1]})
            :onButtonClicked(handler(self, self.OnMidButtonClicked))
            :setButtonLabel("normal",cc.ui.UILabel.new({text = v[2],
                size = 16,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xf5e8c4)}
            )
            )
            :setButtonLabelOffset(0, -40)
            :addTo(self):pos(window.right-50, y)
        button:setTag(i)
        button:setTouchSwallowEnabled(true)
    end
end

function GameUIOtherAllianceHome:ComeBackToOurAlliance()
    app:lockInput(false)
    app:enterScene("AllianceScene", nil, "custom", -1, function(scene, status)
        local manager = ccs.ArmatureDataManager:getInstance()
        if status == "onEnter" then
            manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
            display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
                transition.sequence{
                    cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
                    cc.FadeIn:create(0.75),
                    cc.CallFunc:create(function() scene:hideOutShowIn() end),
                    cc.DelayTime:create(0.5),
                    cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
                    cc.FadeOut:create(0.75),
                    cc.CallFunc:create(function() scene:finish() end),
                }
            )
        elseif status == "onExit" then
            manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
        end
    end)
end

function GameUIOtherAllianceHome:OnBasicChanged(alliance,changed_map)
    if changed_map.status then
        if changed_map.status.new ~="fight" then
            FullScreenPopDialogUI.new():SetTitle(_("提示"))
                :SetPopMessage(_("联盟会战已经结束,请返回我方联盟"))
                :CreateOKButton(function ()
                    self:ComeBackToOurAlliance()
                end,_("确定"))
                :AddToCurrentScene()
        end
    end
end

function GameUIOtherAllianceHome:AddMapChangeButton()
    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.ENEMY_ALLIANCE):addTo(self)
end

return GameUIOtherAllianceHome



