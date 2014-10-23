--
-- Author: Your Name
-- Date: 2014-10-23 20:46:22
--
local GameUIAllianTitle = UIKit:createUIClass("GameUIAllianTitle")

function GameUIAllianTitle:ctor(title)
	GameUIAllianTitle.super.ctor(self)
	self.title_ = title
end

return GameUIAllianTitle