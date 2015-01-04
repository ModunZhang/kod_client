local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local window = import("..utils.window")

local GameUIAlliancePosition = class("GameUIAlliancePosition",WidgetPopDialog)

function GameUIAlliancePosition:ctor()
    -- 根据是否处于联盟战状态构建不同UI
    local enemy_alliance = Alliance_Manager:GetEnemyAlliance()
    print("enemy_alliance:IsDefault()=",enemy_alliance:IsDefault())
    if enemy_alliance:IsDefault() then
        GameUIAlliancePosition.super.ctor(self,258,_("定位坐标"),window.top-200)
    end

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

    local go_shop_btn = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :align(display.CENTER,self.body:getContentSize().width/2,40)
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

return GameUIAlliancePosition