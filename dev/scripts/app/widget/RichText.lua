local utf8 = import("..utils.utf8")
local RichText = class("RichText", function()
    return display.newNode()
end)
local GameUtils = GameUtils
local LuaUtils = LuaUtils

local function get_first_line(label, width)
    label:setLineBreakWithoutSpace(true)
    label:setMaxLineWidth(width)

    local origin_str = label:getString()
    local len = utf8.len(origin_str)
    local char_index = 0
    while char_index < len do
        local next_index = char_index + 1
        if utf8.index(origin_str, next_index) == "\n" then
            return utf8.substr(origin_str, 1, char_index), utf8.sub(origin_str, char_index + 2), next_index == len
        end
        char_index = next_index
        if not label:getLetter(char_index) then
            break
        end
    end
    local next_index = char_index + 1
    if utf8.index(origin_str, char_index + 1) == "\n" then
        return utf8.substr(origin_str, 1, char_index), utf8.sub(origin_str, char_index + 2), next_index == len
    end
    return utf8.substr(origin_str, 1, char_index), utf8.sub(origin_str, char_index + 1)
end
function RichText:ctor(params)
    assert(params.width)
    self.width = params.width
    self.size = params.size or 30
    self.color = params.color or 0xffffff
    self.lineHeight = params.lineHeight or self.size
end

function RichText:Text(str)
    assert(not self.lines, "富文本不可变!")
    local items = LuaUtils:table_map(GameUtils:parseRichText(str), function(k, v)
        local type_ = type(v)
        if type_ == "string" then
            return k, {type = "text", value = v, size = 20}
        end
        return k, v
    end)
    local width = self.width
    local cur_x = 0
    local cur_y = 0
    local lines = {}
    local function getLine(line_number)
        if not lines[line_number] then
            lines[line_number] = display.newNode():addTo(self)
        end
        return lines[line_number]
    end
    local function curLine()
        return getLine(cur_y)
    end
    local function newLine()
        cur_x = 0
        cur_y = cur_y + 1
        curLine()
    end
    newLine()
    for i, v in ipairs(items) do
        if v.type == "image" then
            local img = display.newSprite(v.value)

            local size = img:getContentSize()
            
            if size.width > 5 + width - cur_x then newLine() end

            img:align(display.CENTER, cur_x + size.width * 0.5, 0):addTo(curLine())

            cur_x = cur_x + size.width

            if cur_x > width then newLine() end
        elseif v.type == "text" then
            local head, tail, is_newline = v.value, ""
            local size = v.size or self.size
            local color = v.color or self.color
            
            repeat
                if width - cur_x < size then newLine() end
                local label = UIKit:ttfLabel({
                    text = head,
                    size = size,
                    color = color,
                    align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
                }):align(display.LEFT_CENTER)
                head, tail, is_newline = get_first_line(label, width - cur_x)
                label:removeFromParent()

                local label = UIKit:ttfLabel({
                    text = head,
                    size = size,
                    color = color,
                    align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
                }):align(display.LEFT_CENTER, 0 + cur_x, 0)
                local size = label:getContentSize()
                if size.width == 0 or size.height == 0 then
                    label:removeFromParent()
                else
                    label:addTo(curLine())
                end

                cur_x = cur_x + size.width
                head, tail = tail, ""

                if #head > 0 or cur_x > width or is_newline then newLine() end
            until #head == 0
        end
    end
    self.lines = lines
    return self
end
-- function RichText:HandleElement(item)
--     if item.type == "image" then
--         return self:HandleImage(item)
--     end
-- end
-- function RichText:HandleImage(item)
--     return display.newSprite(item.value)
-- end

function RichText:align(anchorPoint, x, y)
    assert(self.lines, "必须先生成富文本!")
    local ANCHOR_POINTSint = display.ANCHOR_POINTS[anchorPoint]
    local size = self:getCascadeBoundingBox()
    local offset_x = ANCHOR_POINTSint.x * size.width
    local offset_y = (1-ANCHOR_POINTSint.y) * size.height
    local cur_height = 0
    local line_height = self.lineHeight
    for i, v in ipairs(self.lines) do
        v:pos(- offset_x, - cur_height + offset_y)
        local h = v:getCascadeBoundingBox().height
        h = h == 0 and 10 or h
        cur_height = cur_height + h
    end
    return self:pos(x, y)
end



return RichText




