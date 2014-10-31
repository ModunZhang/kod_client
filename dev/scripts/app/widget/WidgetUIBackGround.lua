local WidgetUIBackGround = class("WidgetUIBackGround", function ()
    return display.newNode()
end)

function WidgetUIBackGround:ctor(params)
    local width = params.width or 608
    local height = params.height or 100
    local top_img = params.top_img or "back_ground_608x22.png"
    local bottom_img = params.bottom_img or "back_ground_608x62.png"
    local mid_img = params.mid_img or "back_ground_608X98.png"
    -- 上中下三段的图片高度
    local u_height = params.u_height or 22
    local m_height = params.m_height or 98
    local b_height = params.b_height or 62

    self:setContentSize(cc.size(width,height))
    --top
    display.newSprite(top_img):align(display.LEFT_TOP, 0, height):addTo(self)
    --bottom
    display.newSprite(bottom_img):align(display.LEFT_BOTTOM, 0, 0):addTo(self)

    --center
    local need_filled_height = height-(u_height+b_height) --中间部分需要填充的高度
    local center_y = b_height -- 中间部分起始 y 坐标
    local  next_y = b_height
    -- 需要填充的剩余高度大于中间部分图片原始高度时，直接复制即可
    while need_filled_height>=m_height do
        display.newSprite(mid_img):align(display.LEFT_BOTTOM, 0, next_y):addTo(self)
        need_filled_height = need_filled_height - m_height
        next_y = next_y+m_height
    end
    -- 最后一块小于中间部分图片原始高度时，缩放高度
    if need_filled_height>0 then
        display.newSprite(mid_img, 0, next_y):align(display.LEFT_BOTTOM):addTo(self):setScaleY(need_filled_height/m_height)
    end
end

return WidgetUIBackGround


