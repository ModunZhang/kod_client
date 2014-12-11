local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.ui = UIKit:newGameUI('GameUILogin')
end

function MainScene:onEnter()
    self.ui:addToScene(self,false)
end

function MainScene:onExit()
    self.ui:removeFromParent()
end

return MainScene
