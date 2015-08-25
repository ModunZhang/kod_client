function __G__TRACKBACK__(errorMessage)
    if CONFIG_LOG_DEBUG_FILE then
        print("----------------------------------------")
        print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
        print(debug.traceback("", 2))
        print("----------------------------------------")
        local errDesc = tostring(errorMessage) .. "\n" .. debug.traceback("", 2)
        device.showAlert("☠错误☠",errDesc,"复制！",function()
            ext.copyText(errDesc)
        end)
    else
        if checktable(ext.market_sdk) and ext.market_sdk.onPlayerEvent then
          local errDesc = tostring(errorMessage) .. "\n" .. debug.traceback("", 2)
          ext.market_sdk.onPlayerEvent("LUA_ERROR",errDesc)
        end
    end
	-- UIKit:showMessageDialog(_("提示"),_("游戏出现了bug,点击确定按钮发邮件给我们"),function()
 --        if device.platform == 'mac' then
 --            dump(errDesc)
 --        else
 --    		local subject,body = app:getSupportMailFormat(_("致命性Bug上报"),errDesc)
 --    		local canSendMail = ext.sysmail.sendMail('bugs@batcatstudio.com',subject,body,function()end)
 --    		if not canSendMail then
 --    			UIKit:showMessageDialog(_("错误"),_("您尚未设置邮件：请前往IOS系统“设置”-“邮件、通讯录、日历”-“添加账户”处设置"),function()end)
 --    		end
 --        end
	-- end,function()end)
end
function _(text)
    return text
end
require("app.MyApp").new():run()

