function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    local errDesc = tostring(errorMessage) .. "\n" .. debug.traceback("", 2)
    device.showAlert("☠错误☠",errDesc,"复制！",function()
    	ext.copyText(errDesc)
    end)
end

require("app.MyApp").new():run()
