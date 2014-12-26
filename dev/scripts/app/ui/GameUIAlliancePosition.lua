local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local window = import("..utils.window")

local GameUIAlliancePosition = class("GameUIAlliancePosition", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function GameUIAlliancePosition:ctor()
    self:setNodeEventEnabled(true)
    self.body = self:CreateBackGroundWithTitle()
        :align(display.CENTER, window.cx, window.top -400)
        :addTo(self)

    -- 联盟名字
    UIKit:ttfLabel({
        text = _("[KOD] 中华全国妇女联合会"),
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, 304, 225):addTo(self.body)
    local bg1 = WidgetUIBackGround.new({
        width = 558,
        height = 118,
        top_img = "back_ground_580x12_top.png",
        bottom_img = "back_ground_580X12_bottom.png",
        mid_img = "back_ground_580X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    }):align(display.CENTER,304, 140):addTo(self.body)
    -- x 坐标
    UIKit:ttfLabel({
        text = "X:",
        size = 26,
        color = 0x514d3e,
    }):align(display.CENTER, 100, 140):addTo(self.body)
    local editbox_x = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box_174X40.png",
        size = cc.size(174,40),
        font = UIKit:getFontFilePath(),
    })
    editbox_x:setMaxLength(2)
    editbox_x:setFont(UIKit:getFontFilePath(),22)
    editbox_x:setFontColor(cc.c3b(0,0,0))
    editbox_x:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox_x:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox_x:align(display.LEFT_CENTER,110, 140)
    editbox_x:addTo(self.body)
    -- y 坐标
    UIKit:ttfLabel({
        text = "Y:",
        size = 26,
        color = 0x514d3e,
    }):align(display.CENTER, 320, 140):addTo(self.body)
    local editbox_y = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box_174X40.png",
        size = cc.size(174,40),
        font = UIKit:getFontFilePath(),
    })
    editbox_y:setMaxLength(2)
    editbox_y:setFont(UIKit:getFontFilePath(),22)
    editbox_y:setFontColor(cc.c3b(0,0,0))
    editbox_y:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox_y:align(display.LEFT_CENTER,330, 140)
    editbox_y:addTo(self.body)

    local go_shop_btn = WidgetPushButton.new({normal = "yellow_btn_up_149x47.png",pressed = "yellow_btn_down_149x47.png"})
        :align(display.CENTER,self.body:getContentSize().width-90,40)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
            	local x = string.trim(editbox_x:getText())
            	local y = string.trim(editbox_y:getText())
                if string.len(x) == 0 or string.len(y) == 0 then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("请输入坐标"))
                        :CreateOKButton({
                            listener =  function()end
                        })
                        :AddToCurrentScene()
                    return
                end
                local map_layer = display.getRunningScene():GetSceneLayer()
                local point = map_layer:ConvertLogicPositionToMapPosition(editbox_x:getText(),editbox_y:getText())
                map_layer:GotoMapPositionInMiddle(point.x,point.y)
                self:removeFromParent(true)
            end
        end)
        :setButtonLabel("normal", UIKit:ttfLabel({
            text = _("定位"),
            size = 20,
            color = 0xfff3c7,
            shadow = true
        }))
        :addTo(self.body)
end


function GameUIAlliancePosition:onEnter()
end

function GameUIAlliancePosition:onExit()
    UIKit:getRegistry().removeObject(self.__cname)
end

function GameUIAlliancePosition:CreateBackGroundWithTitle(  )
    local body = WidgetUIBackGround.new({height=258}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = _("定位坐标"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    return body
end

function GameUIAlliancePosition:addToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end

return GameUIAlliancePosition