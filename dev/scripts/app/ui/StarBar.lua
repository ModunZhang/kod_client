-- 用于星级显示或者分页控件 支持横竖
local StarBar = class("StarBar",function()
		return display.newNode()
end)

StarBar.DIRECTION_VERTICAL		= 1
StarBar.DIRECTION_HORIZONTAL	= 2

function StarBar:ctor(params)
	assert(params)
	self.items_ = {}
	if not params.fillOffset then
		params.fillOffset = cc.p(0,0)
	end
	params.scale = params.scale or 1
	if not params.fillFunc then
		params.fillFunc = function(index,current,max)
			return index <= current
		end
	end
	self.direction_ = params.direction or StarBar.DIRECTION_HORIZONTAL
 	for i=1,params.max or 1 do
		local stars = display.newSprite(params.bg):addTo(self)
		stars:setScale(params.scale)
		if self.direction_ == StarBar.DIRECTION_HORIZONTAL then
			stars:align(display.LEFT_BOTTOM,(i-1)*((params.margin or 0)+stars:getContentSize().width * params.scale) , 0)
		else
			stars:align(display.LEFT_BOTTOM, 0, (i-1)*((params.margin or 0)+stars:getContentSize().height * params.scale))
		end
 		if params.fillFunc(i,params.num or 0,params.max) then
 			display.newSprite(params.fill):addTo(stars):pos(stars:getContentSize().width /2 +  params.fillOffset.x ,stars:getContentSize().height/2 + params.fillOffset.y)
 		end
		table.insert(self.items_,stars)
	end
end


function StarBar:onExit()
	self.fillFunc = nil
	self.items_ = nil
end
function StarBar:getContentSize()
	local lastItem = self.items_[#self.items_]
	if not lastItem then return {width = 0,height = 0} end
	if self.direction == StarBar.DIRECTION_HORIZONTAL then
		return {width = lastItem:getPositionX()+lastItem:getContentSize().width,height = lastItem:getContentSize().height}
	else
		return {width = lastItem:getContentSize().width,height = lastItem:getPositionY()+lastItem:getContentSize().height}
	end
end
return StarBar
