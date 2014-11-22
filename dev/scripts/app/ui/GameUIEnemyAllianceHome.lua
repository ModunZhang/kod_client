--
-- Author: Danny He
-- Date: 2014-11-21 09:57:42
--
local GameUIEnemyAllianceHome = UIKit:createUIClass("GameUIEnemyAllianceHome", "GameUIAllianceHome")
local WidgetPushButton = import("..widget.WidgetPushButton")
local window = import("..utils.window")

function GameUIEnemyAllianceHome:OnMidButtonClicked(event)
	local tag = event.target:getTag()
    if not tag then return end
    if tag == 1 then
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
    else
    	GameUIEnemyAllianceHome.super.OnMidButtonClicked(self,event)
    end
end

function GameUIEnemyAllianceHome:CreateOperationButton()
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

return GameUIEnemyAllianceHome