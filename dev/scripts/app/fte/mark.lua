return function(key)
    local user_default = cc.UserDefault:getInstance()
    user_default:setStringForKey(key, 1)
    user_default:flush()
end





