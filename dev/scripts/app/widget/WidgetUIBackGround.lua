local Enum = import("..utils.Enum")
local WidgetUIBackGround = class("WidgetUIBackGround", function ()
    return display.newNode()
end)

-- WidgetUIBackGround.STYLE = Enum("STYLE_1","STYLE_2","STYLE_3")
-- local ST = WidgetUIBackGround.STYLE
-- local STYLES = {
--     ST.STYLE_1 = {
--         top_img = "back_ground_608x22.png",
--         bottom_img = "back_ground_608x22.png",
--         top_img = "back_ground_608x22.png",
--     }  
-- }

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
    display.newScale9Sprite(top_img,0, height,cc.size(width,u_height)):align(display.LEFT_TOP):addTo(self)
    local bottom = display.newScale9Sprite(bottom_img,0, 0,cc.size(width,b_height)):align(display.LEFT_BOTTOM):addTo(self)

    --bottom
    if params.b_flip then
        bottom:align(display.LEFT_TOP)
        bottom:setRotationSkewX(180)
    end
    --center
    local need_filled_height = height-(u_height+b_height) --中间部分需要填充的高度
    local center_y = b_height -- 中间部分起始 y 坐标
    local  next_y = b_height
    -- 需要填充的剩余高度大于中间部分图片原始高度时，直接复制即可
    while need_filled_height>=m_height do
        display.newScale9Sprite(mid_img, 0, next_y,cc.size(width,m_height)):align(display.LEFT_BOTTOM):addTo(self)
        need_filled_height = need_filled_height - m_height
        next_y = next_y+m_height
    end
    -- 最后一块小于中间部分图片原始高度时，缩放高度
    if need_filled_height>0 then
        display.newSprite(mid_img)
            :align(display.LEFT_BOTTOM,0, next_y)
            :addTo(self):setScaleY(need_filled_height/m_height)
    end

    -- 默认的style，并且宽度为608时添加边框
    if top_img == "back_ground_608x22.png" and  width==608 then
        display.newSprite("shrie_state_item_line_606_16.png"):addTo(self):align(display.LEFT_TOP,0, height-4)
        display.newSprite("shrie_state_item_line_606_16.png"):addTo(self):align(display.LEFT_BOTTOM,0, 4):flipY(true)
    end
end

return WidgetUIBackGround





