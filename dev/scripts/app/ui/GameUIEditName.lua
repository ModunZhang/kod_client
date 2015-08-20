local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local GameUIEditName = class("GameUIEditName", WidgetPopDialog)


function GameUIEditName:ctor(callback)
    GameUIEditName.super.ctor(self, 282, _("玩家姓名"), window.top - 300)
    self:DisableCloseBtn()
    self:DisableAutoClose(true)
    self.__type  = UIKit.UITYPE.BACKGROUND
    self.callback = callback


    UIKit:ttfLabel({
        text = _("请问领主尊姓大名?"),
        color= 0x403c2f,
        size = 22,
    }):align(display.CENTER, 400, 220):addTo(self:GetBody())



    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(350,48),
        font = UIKit:getFontFilePath(),
    })
    editbox:setPlaceHolder(_("输入新的名字"))
    editbox:setMaxLength(12)
    editbox:setFont(UIKit:getEditBoxFont(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:addTo(self:GetBody()):pos(400, 160)

    UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("确认")},
            listener = function ()
                NetManager:getUseItemPromise("changePlayerName", {
                    changePlayerName = { playerName = string.trim(editbox:getText()) }
                }):always(function()
                    NetManager:getFinishFTE()
                    self:LeftButtonClicked()
                end)
            end,
        }
    ):addTo(self:GetBody()):pos(400, 75)


    display.newSprite("Npc.png"):addTo(self:GetBody()):pos(95, 198)
end

function GameUIEditName:onExit()
	GameUIEditName.super.onExit(self)
	if type(self.callback) == "function" then
		self.callback()
	end
end


return GameUIEditName

