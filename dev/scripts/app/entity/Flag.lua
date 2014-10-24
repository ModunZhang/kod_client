local Flag = class("Flag")
Flag.FLAG_COLOR_MAP = {
    "red",
    "yellow",
    "green",
    "babyBlue",
    "darkBlue",
    "purple",
    "orange",
    "white",
    "black",
    "charmRed",
    "blue",
    "orangeRed",
}
local flag_color_map = Flag.FLAG_COLOR_MAP
function Flag:ctor()
    self.flag = {}
end
function Flag:SetBackColors(color1, color2)
    self.flag.flagColor = {color1, color2}
end
function Flag:SetBackStyle(back_style)
    self.flag.flag = back_style
end
function Flag:SetFrontStyle(front_style)
    self.flag.graphic = front_style
end
function Flag:SetFrontImagesStyle(style1, style2)
    self.flag.graphicContent = {style1, style2}
end
function Flag:SetFrontImageColors(color1, color2)
    self.flag.graphicColor = {color1, color2}
end
function Flag:IsSameWithFlag(flag)
    local this_flag = self.flag
    local flag_ = flag.flag
    return this_flag.flagColor[1] == flag_.flagColor[1]
        and this_flag.flagColor[2] == flag_.flagColor[2]
        and this_flag.flag == flag_.flag
        and this_flag.graphic == flag_.graphic
        and this_flag.graphicContent[1] == flag_.graphicContent[1]
        and this_flag.graphicContent[2] == flag_.graphicContent[2]
        and this_flag.graphicColor[1] == flag_.graphicColor[1]
        and this_flag.graphicColor[2] == flag_.graphicColor[2]
end
-- 随机不会替换以前的旗帜
function Flag:RandomFlag()
    local flag = Flag.new()
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    flag:SetBackStyle(math.random(4))
    flag:SetBackColors(flag_color_map[math.random(#flag_color_map)], flag_color_map[math.random(#flag_color_map)])
    flag:SetFrontStyle(math.random(4))
    flag:SetFrontImagesStyle(math.random(17), math.random(17))
    flag:SetFrontImageColors(flag_color_map[math.random(#flag_color_map)], flag_color_map[math.random(#flag_color_map)])
    return flag
end
function Flag:EncodeToJson()
    assert(self.flag.flag)
    assert(self.flag.graphic)
    assert(self.flag.flagColor)
    assert(self.flag.graphicColor)
    assert(self.flag.graphicContent)
    return json.encode(self.flag)
end
function Flag:DecodeFromJson(json_data)
    local flag = Flag.new()
    flag.flag = json.decode(json_data)
    return flag
end


return Flag


