--
-- Author: Kenny Dai
-- Date: 2015-01-16 11:14:47
--
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")

local WidgetInput = class("WidgetInput", WidgetPopDialog)

function WidgetInput:ctor(params)
    WidgetInput.super.ctor(self,200,"调整数量",display.top-400)
    self:DisableCloseBtn()
    local body = self.body
    local max = params.max
    local current = params.current
    local min = params.min or 0
    local unit = params.unit or ""
    local callback = params.callback or NOT_HANDLE

    local function edit(event, editbox)
        local text = tonumber(editbox:getText()) or min
        if event == "began" then
            if min==text then
                editbox:setText("")
            end
        elseif event == "changed" then
            if text then
                if text > max then
                    editbox:setText(max)
                end
            end
        elseif event == "ended" then
            if editbox:getText()=="" or min>text then
                editbox:setText(min)
            end
            local edit_value = tonumber(editbox:getText())
            editbox:setText(edit_value)
            callback(edit_value)
        end
    end

    -- soldier current
    self.editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "back_ground_83x32.png",
        size = cc.size(100,32),
        font = UIKit:getFontFilePath(),
        listener = edit
    })
    local editbox = self.editbox
    editbox:setMaxLength(10)
    editbox:setText(current)
    editbox:setFont(UIKit:getFontFilePath(),20)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.CENTER, body:getContentSize().width/2,body:getContentSize().height/2+20):addTo(body)

    UIKit:ttfLabel({
        text = string.format(unit.."/ %d"..unit, max),
        size = 20,
        color = 0x403c2f
    }):addTo(body)
        :align(display.LEFT_CENTER, editbox:getPositionX()+70,editbox:getPositionY())
    -- 升级按钮
    WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("确定"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:leftButtonClicked()
            end
        end):align(display.CENTER, editbox:getPositionX(),editbox:getPositionY()-50):addTo(body)
end

return WidgetInput

