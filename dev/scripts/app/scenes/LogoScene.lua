--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
    local GameUIWarReport= import("..ui.GameUIWarReport")

local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)

function LogoScene:ctor()

end

function LogoScene:onEnter()
    self.layer = display.newColorLayer(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newScale9Sprite("logos/batcat.png", display.cx, display.cy):addTo(self.layer)
    
    self:performWithDelay(function() self:beginAnimate() end,1)
    -- GameUIWarReport.new():addTo(self)


    -- local rect = cc.rect(0,0,619,715)
    -- local clipnode = display.newClippingRegionNode(rect)
    -- local dragonAnimateNode = display.newSprite("dragon_node_619x715.png")
    --         :addTo(clipnode)
    --         :align(display.LEFT_BOTTOM,20,200)
    -- clipnode:addChild(sprite1)
    -- clipnode:addChild(sprite2)

    -- clipnode:addTo(self)
end

function LogoScene:beginAnimate()
    transition.execute(self.sprite, cc.ScaleTo:create(checknumber(3),1.5))
    transition.fadeTo(self.sprite, {opacity = 255/2, time = 1.5})
    transition.fadeOut(self.layer,{time = 1.5})
    local sequence = transition.sequence({
        cc.FadeOut:create(1.5),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                if CONFIG_IS_DEBUG then
                    app:enterScene("MainScene")
                else
                    app:enterScene("UpdaterScene")
                end
            end, 0.5)
        end),
    })
self.layer:runAction(sequence)
end


function LogoScene:onExit()
end

return LogoScene

