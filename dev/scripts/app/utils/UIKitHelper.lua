--
-- Author: dannyhe
-- Date: 2014-08-01 08:46:35
--
-- 封装常用ui工具

UIKitHelper = 
{
	GameUIBase = import('..ui.GameUIBase'),
}

function UIKitHelper:inheritUIBase(className)
	return class(className, self.GameUIBase)
end

-- TODO:
function UIKitHelper:initLocaledLabel(label,needAnim)

end

function UIKitHelper:createGameUI(gameUIName,... )
	local viewPackageName = app.packageRoot .. ".ui." .. gameUIName
    local viewClass = require(viewPackageName)
    return viewClass.new(...)
end