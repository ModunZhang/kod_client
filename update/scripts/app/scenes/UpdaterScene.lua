--
-- Author: Danny He
-- Date: 2014-09-18 20:24:34
--
local UpdaterScene = class("UpdaterScene", function()
    return display.newScene("UpdaterScene")
end)

function UpdaterScene:ctor()
    self.ui = UIKit:newGameUI('GameUIUpdate')
end

function UpdaterScene:onEnter()
    self.ui:addToScene(self,false)
end

function UpdaterScene:onExit()
    self.ui = nil
end

return UpdaterScene