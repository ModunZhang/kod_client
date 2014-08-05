local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)


function MainScene:ctor()
    self.m_currentLabel = nil
end

function MainScene:onEnter()
    print("MainScene:onEnter")
    self:createBgLayer()
    self:checkLogin()
end

function MainScene:onExit()
end

function MainScene:createBgLayer()
    display.newSprite("images/spalshbg.png", display.cx, display.cy):addTo(self)
end

function MainScene:checkLogin()
    self:showText(_("连接网关服务器...."))
    NetManager:connectGateServer(function(success)
        if not success then
            self:showText(_("连接网关服务器失败!"))
            return
        end

        self:showText(_("获取游戏服务器信息...."))
        NetManager:getLogicServerInfo(function(success)
            if not success then
                self:showText(_("获取游戏服务器信息失败!"))
                return
            end

            self:showText(_("连接游戏服务器...."))
            NetManager:connectLogicServer(function(success)
                if not success then
                    self:showText(_("连接游戏服务器失败!"))
                    return
                end

                NetManager:login(function ( success, msg )
                    if not success then
                        self:showText(_("登录游戏失败!"))
                        return
                    else
                        self:showText(_("登录游戏成功!"))
                        LuaUtils:outputTable("userMessage", msg)
                    end
                end)
            end)
        end)
    end)
end


function MainScene:showText(text)
    self:removeText()

    local label = ui.newTTFLabel({
        text = text,
        font = "fonts/Arial.ttf",
        size = 35,
        aligh = ui.TEXT_ALIGN_CENTER,
        valigh = ui.TEXT_VALIGN_CENTER,
        color = ccc3(255, 255, 255)
    })
    label:setPosition(display.cx, display.cy)
    label:addTo(self)

    self.m_currentLabel = label
end

function MainScene:removeText()
    if self.m_currentLabel then
        self.m_currentLabel:removeSelf()
        self.m_currentLabel = nil
    end
end

return MainScene