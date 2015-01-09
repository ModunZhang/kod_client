--
-- Author: Danny He
-- Date: 2014-12-30 10:02:49
--
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local GameUITest = UIKit:createUIClass("GameUITest")
local UICheckBoxButton = import("..ui.UICheckBoxButton")
local UICanCanelCheckBoxButtonGroup = import("..ui.UICanCanelCheckBoxButtonGroup")
function GameUITest:onEnter()
	local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    self.joinTypeButton = UICanCanelCheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addButton(UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("允许玩家立即加入联盟"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            -- :setButtonSelected(true)
            )
        :addButton(UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("玩家仅能通过申请或者邀请的方式加入"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            -- :setButtonSelected(true)
            )
        :onButtonSelectChanged(handler(self, self.OnAllianceJoinTypeButtonClicked))
        :addTo(self)
        :setButtonsLayoutMargin(26,0,0,0)
        :setLayoutSize(557, 54)
        :pos(display.left,display.cy)
        :setCheckButtonStateChangeFunction(function(group,currentSelectedIndex,oldIndex)
        	if currentSelectedIndex ~= oldIndex then
	        	FullScreenPopDialogUI.new():SetTitle(_("提示"))
	        	:SetPopMessage(_("你将设置联盟加入方式为") .. currentSelectedIndex)
		        :CreateOKButton(
		            {
		                listener =  function ()
		                  	self.joinTypeButton:sureSelectedButtonIndex(currentSelectedIndex)
		                end
		            }
			        )
		        :CreateCancelButton({listener = function ()
		        end,btn_name = _("取消")})
		        :AddToCurrentScene()
		     end
	        	return false
	        end)
        self.joinTypeButton:sureSelectedButtonIndex(2,true)
end

function GameUITest:OnAllianceJoinTypeButtonClicked(event)
	print("OnAllianceJoinTypeButtonClicked--->")
end

return GameUITest