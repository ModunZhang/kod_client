local UpdaterScene = class("UpdaterScene", function()
    return display.newScene("UpdaterScene")
end)

function UpdaterScene:ctor()
    self.ui = UIKitHelper:createGameUI('GameUISplash')
end

function UpdaterScene:onEnter()
    self.ui:addToScene(self,false)
end

function UpdaterScene:onExit()
    self.ui = nil
end

return UpdaterScene