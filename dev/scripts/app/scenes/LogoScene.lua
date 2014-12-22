--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)

function LogoScene:ctor()
    self:PreLoadResource()
end

function LogoScene:onEnter()
    self.layer = display.newColorLayer(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newScale9Sprite("logos/batcat.png", display.cx, display.cy):addTo(self.layer)
    self:performWithDelay(function() self:beginAnimate() end,1)
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

function LogoScene:PreLoadResource()
    local soldier_anmations = {
        {"animations/Infantry_1_render0.plist","animations/Infantry_1_render0.png","animations/Infantry_1_render.ExportJson"},
        {"animations/Cavalry_1_render0.plist","animations/Cavalry_1_render0.png","animations/Cavalry_1_render.ExportJson"},
        {"animations/Archer_1_render0.plist","animations/Archer_1_render0.png","animations/Archer_1_render.ExportJson"},
        {"animations/Catapult_1_render0.plist","animations/Catapult_1_render0.png","animations/Catapult_1_render.ExportJson"},
        {"animations/Cloud_Animation0.plist","animations/Cloud_Animation0.png","animations/Cloud_Animation.ExportJson"},
    }
    for _,v in ipairs(soldier_anmations) do
        local plist,png,export_json = unpack(v)
        display.addSpriteFrames(plist,png,function(plistFilename, image)
            print("load resoures-->",plistFilename, image)
        end)
    end
end



function LogoScene:onExit()
end

return LogoScene

