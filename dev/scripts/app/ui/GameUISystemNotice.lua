--
-- Author: Kenny Dai
-- Date: 2015-05-27 10:02:24
--
local GameUIBase = import('.GameUIBase')
local GameUISystemNotice = class("GameUISystemNotice", GameUIBase)

function GameUISystemNotice:ctor(notice_type,notice_content)
    GameUISystemNotice.super.ctor(self,{type = UIKit.UITYPE.WIDGET})
    self.notice_type = notice_type
    self.notice_content = notice_content
end
function GameUISystemNotice:onEnter()
    GameUISystemNotice.super.onEnter(self)
    local back = display.newSprite("back_ground_366x66.png"):addTo(self):pos(display.cx,display.top - 200)
    local back_width,back_height = back:getContentSize().width, back:getContentSize().height
    local clipNode = display.newClippingRegionNode(cc.rect(15,0,back_width-30,back_height)):addTo(back)
    local notice = UIKit:ttfLabel({
        text = self.notice_content,
        size = 24,
        color = self.notice_type == "warning" and 0xff5400 or 0xffedae
    }):align(display.LEFT_CENTER, back_width,back_height/2)
        :addTo(clipNode)

    back:opacity(0)
    transition.fadeTo(back, {opacity = 255, time = 2,
        onComplete = function()
            transition.moveTo(notice, {x = -notice:getContentSize().width, y = back_height/2, time = 8,
                onComplete = function()
                    transition.fadeTo(back, {opacity = 0, time = 2,onComplete = function (  )
                        self:LeftButtonClicked()
                    end})
                end
            })
        end
    })
end
return GameUISystemNotice