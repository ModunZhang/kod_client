local GameUIWatiForNetWork = UIKit:createUIClass("GameUIWatiForNetWork")

function GameUIWatiForNetWork:ctor()
    GameUIWatiForNetWork.super.ctor(self)
end
function GameUIWatiForNetWork:onEnter()
    GameUIWatiForNetWork.super.onEnter(self)

    self:performWithDelay(function()
        self:show()
    end, 0.5)

    self.sprite = display.newSprite("batcat_logo_368x390.png", display.cx, display.cy, {class=cc.FilteredSpriteWithOne}):addTo(self)
    local size = self.sprite:getContentSize()
    self.sprite:setScaleX(display.width / size.width)
    self.sprite:setScaleY(display.height / size.height)
    local filter = filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/mask_layer.fs",
            shaderName = "mask_layer",
            iResolution = {display.widthInPixels, display.heightInPixels}
        })
    )
    self.sprite:setFilter(filter)
    local loading = display.newSprite("loading_88x86.png"):addTo(self):pos(display.cx, display.cy)
    loading:runAction(cc.RepeatForever:create(cc.RotateBy:create(7, 360)))

    self:hide()
end



return GameUIWatiForNetWork








