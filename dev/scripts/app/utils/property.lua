local get_property_type_map = {
    only_read = true,
    all = true
}
local set_property_type_map = {
    only_wirte = true,
    all = true
}

return function(object, property_name, initial, property_type)
    assert(type(property_name) == "string")
    local head = string.upper(string.sub(property_name, 1, 1))
    local tail = string.sub(property_name, 2, #property_name)
    local get_name = string.format("%s%s", head, tail)
    local set_name = string.format("Set%s", get_name)
    assert(not object[get_name], "取值函数重复了!"..property_name)
    assert(not object[set_name], "设置函数重复了!"..property_name)
    -- 初始化
    object[property_name] = initial or nil

    property_type = property_type or "all"
    -- 生成取值函数
    if get_property_type_map[property_type] then
        object[get_name] = function(obj)
            return obj[property_name]
        end
    end
    -- 生成设置函数
    if set_property_type_map[property_type] then
        object[set_name] = function(obj, value)
            if obj[property_name] ~= value then
                local old_value = obj[property_name]
                obj[property_name] = value
                obj:OnPropertyChange(property_name, old_value, value)
            end
        end
    end
end









