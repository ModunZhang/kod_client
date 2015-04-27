--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
require("app.ui.GameGlobalUIUtils")
local UILib = import("app.ui.UILib")
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)
function LogoScene:ctor()
    self:loadSplashResources()
end

function LogoScene:onEnter()
    self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newScale9Sprite("batcat_logo_368x390.png", display.cx, display.cy):addTo(self.layer)
    self:performWithDelay(function() self:beginAnimate() end,0.5)

    -- UILib.loadSolidersAnimation()
    -- local ranger = ccs.Armature:create("gongjianshou_1"):addTo(self):pos(display.cx, display.cy):scale(4)

    -- local index = 78
    -- ranger:getAnimation():play("idle_90")
    -- ranger:getAnimation():gotoAndPause(index)

    -- self.button = cc.ui.UIPushButton.new(
    --     {normal = "yellow_btn_up_186x66.png",pressed = "yellow_btn_down_186x66.png"},
    --     {scale9 = false}
    -- ):setButtonLabel(cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = _("加速"),
    --     size = 24,
    --     color = UIKit:hex2c3b(0xfff3c7)}))
    --     :addTo(self):align(display.CENTER, 110, 50)
    --     :onButtonClicked(function()
    --         ranger:getAnimation():play("idle_90")
    --         ranger:getAnimation():gotoAndPause(index + 1)
    --         index = index + 1
    --         self.button:setButtonLabelString(index)
    --     end)

    -- UIKit:newGameUI("GameUIReplayNew"):AddToCurrentScene(true)
end

function LogoScene:beginAnimate()
    local action = cc.Spawn:create({cc.ScaleTo:create(checknumber(2),1.5),cca.fadeTo(1.5,255/2)})
    self.sprite:runAction(action)
    local sequence = transition.sequence({
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                app:enterScene("MainScene")
            end, 0.5)
        end),
    })
    self.layer:runAction(sequence)
end
--预先加载登录界面使用的大图
function LogoScene:loadSplashResources()
    --加载splash界面使用的图片
    display.addImageAsync("splash_beta_logo_515x119.png",function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end



function LogoScene:onExit()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("batcat_logo_368x390.png")
end

return LogoScene






