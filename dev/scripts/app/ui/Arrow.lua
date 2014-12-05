local SpriteUINode = import("..ui.SpriteUINode")
local Arrow = class("Arrow", SpriteUINode)
function Arrow:InitWidget()
    display.newSprite("arrow.png"):addTo(self):align(display.BOTTOM_CENTER)
end


return Arrow