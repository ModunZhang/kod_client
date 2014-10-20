local WidgetUIBackGround = class("WidgetUIBackGround", function ()
    return display.newNode()
end)

function WidgetUIBackGround:ctor(height)
    self:setContentSize(cc.size(608,height))
    -- 上中下三段的图片高度
    local u_height,m_height,b_height = 22 , 98 , 62
    --top
    display.newSprite("back_ground_608x22.png"):align(display.LEFT_TOP, 0, height):addTo(self)
    --bottom
    display.newSprite("back_ground_608x62.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(self)

    --center
    local need_filled_height = height-(u_height+b_height) --中间部分需要填充的高度
    local center_y = b_height -- 中间部分起始 y 坐标
    local  next_y = b_height
    -- 需要填充的剩余高度大于中间部分图片原始高度时，直接复制即可
    while need_filled_height>=m_height do
        display.newSprite("back_ground_608X98.png"):align(display.LEFT_BOTTOM, 0, next_y):addTo(self)
        need_filled_height = need_filled_height - m_height
        -- copy_count = copy_count + 1
        next_y = next_y+m_height
    end
    -- 最后一块小于中间部分图片原始高度时，缩放高度
    -- print("最后一块小于中间部分图片原始高度时，需要 填充高度 need_filled_height",need_filled_height,"copy_count=",copy_count)
    display.newSprite("back_ground_608X98.png", 0, next_y):align(display.LEFT_BOTTOM):addTo(self):setScaleY(need_filled_height/m_height)

end

return WidgetUIBackGround


