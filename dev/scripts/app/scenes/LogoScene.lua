--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
require("app.ui.GameGlobalUIUtils")
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)
--提前加载splash需要的资源
function LogoScene:ctor()
    self:PreLoadResource()
end

function LogoScene:onEnter()
    self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newScale9Sprite("batcat_logo_368x390.png", display.cx, display.cy):addTo(self.layer)
    self:performWithDelay(function() self:beginAnimate() end,0.5)
end

function LogoScene:beginAnimate()
    -- transition.execute(self.sprite, cc.ScaleTo:create(checknumber(2),1.5))
    -- transition.fadeTo(self.sprite, {opacity = 255/2, time = 1.5})
    local action = cc.Spawn:create({cc.ScaleTo:create(checknumber(2),1.5),cca.fadeTo(1.5,255/2)})
    self.sprite:runAction(action)
    -- transition.fadeOut(self.layer,{time = 2})
    local sequence = transition.sequence({
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                if CONFIG_IS_DEBUG then
                    app:enterScene("MainScene")
                else
                    -- app:enterScene("UpdaterScene")
                end
            end, 0.5)
        end),
    })
    self.layer:runAction(sequence)
end
--TODO:预先加载登录界面使用的大图 
function LogoScene:PreLoadResource()
    --加载splash界面使用的图片
    display.addImageAsync("splash_beta_logo_515x119.png",function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end



function LogoScene:onExit()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("batcat_logo_368x390.png")
end

return LogoScene




