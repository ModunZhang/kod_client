return function(object, property_name, initial)
    assert(type(property_name) == "string")
    local h = string.upper(string.sub(property_name, 1, 1))
    local t = string.sub(property_name, 2, #property_name)
    local get_name = string.format("%s%s", h, t)
    local set_name = string.format("Set%s", get_name)
    assert(not object[get_name], "属性重复了!"..property_name)
    assert(not object[set_name], "属性重复了!"..property_name)
    object[property_name] = initial or nil
    object[get_name] = function(obj)
        return obj[property_name]
    end
    object[set_name] = function(obj, value)
        if obj[property_name] ~= value then
            local old_value = obj[property_name]
            obj[property_name] = value
            if type(obj.OnPropertyChange) == "function" then
                obj:OnPropertyChange(property_name, old_value, value)
            end
        end
    end
end


