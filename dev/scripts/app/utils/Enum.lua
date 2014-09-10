return function(...)
    local enum = {}
    for i, v in pairs({...}) do
        enum[v] = i
    end
    return enum
end



