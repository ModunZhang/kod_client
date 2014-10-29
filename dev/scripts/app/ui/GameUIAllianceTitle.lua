--
-- Author: Danny He
-- Date: 2014-10-23 20:46:22
--
local GameUIAllianceTitle = UIKit:createUIClass("GameUIAllianceTitle")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameUIAllianceTitle:ctor(title)
	GameUIAllianceTitle.super.ctor(self)
	self.title_ = title
end

function GameUIAllianceTitle:onMoveInStage()
	GameUIAllianceTitle.super.onMoveInStage(self)
	self:BuildUI()
end


function GameUIAllianceTitle:GetAllianceTitleAndLevelPng(title)
	local levelImages = {
		general = "5_23x24.png",
		quartermaster = "4_32x24.png",
		supervisor = "3_35x24.png",
		elite = "2_23x24.png",
		member = "1_11x24.png",
		archon = "alliance_item_leader_39x39.png"
	}
	local alliance = Alliance_Manager:GetMyAlliance()
	return alliance:GetTitles()[title],levelImages[title]
end

function GameUIAllianceTitle:BuildUI()
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=634}):addTo(shadowLayer):pos(window.left+20,window.bottom+150)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 0, 619)
	local closeButton = WidgetPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	self.title_label = UIKit:ttfLabel({
		text = _("联盟权限"),
		size = 24,
		color = 0xffedae,
	}):align(display.CENTER,title_bar:getContentSize().width/2, title_bar:getContentSize().height/2)
		:addTo(title_bar)
	local prePageButton = WidgetPushButton.new({normal="alliance_page_button_normal_48x90.png",pressed = "alliance_page_button_highlight_48x90.png"})
	:align(display.LEFT_TOP,0,title_bar:getPositionY()-10):addTo(bg)

	local nextPageButton = WidgetPushButton.new({normal="alliance_page_button_normal_48x90.png",pressed = "alliance_page_button_highlight_48x90.png"})
	nextPageButton:setRotation(180)
	nextPageButton:align(display.LEFT_BOTTOM,608,title_bar:getPositionY()-10):addTo(bg)

	local display_title,levelImage = self:GetAllianceTitleAndLevelPng(self.title_)
	local icon = display.newSprite(levelImage):addTo(bg):align(display.LEFT_CENTER,60,title_bar:getPositionY()-52)

	local function onEdit(event, editbox)
        if event == "return" then
           	self:OnEditAllianceTitle(editbox:getText())
        end
    end
	local editbox = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "input_box.png",
        size = cc.size(427,51),
        listener = onEdit,
    })
    editbox:setText(display_title)
    editbox:setMaxLength(140)
    editbox:setFont(UIKit:getFontFilePath(),18)
    editbox:setFontColor(UIKit:hex2c3b(0xccc49e))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.LEFT_TOP,icon:getPositionX()+50,icon:getPositionY()+20):addTo(bg)
    local pageLabel = UIKit:ttfLabel({
		text = "1/6",
		size = 18,
		color = 0x797154,
	}):addTo(bg):align(display.CENTER,editbox:getPositionX()+213,editbox:getPositionY() - 51 - 20)
    local line = display.newSprite("dividing_line_594x2.png")
    	:addTo(bg)
    	:align(display.LEFT_TOP,7,pageLabel:getPositionY() - pageLabel:getContentSize().height/2 - 5)
    local listBg = display.newSprite("alliance_title_list_572x436.png")
		:addTo(bg)
		:align(display.CENTER_TOP,304,line:getPositionY()-20)
	self.authority_list = UIListView.new {
    	viewRect = cc.rect(4, 12, 564,325),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(listBg)

    for i=1,10 do
    	local item = self.authority_list:newItem()
    	local bg = display.newSprite(string.format("resource_item_bg%d.png",i%2))
    	UIKit:ttfLabel({
			text = _("发起联盟邀请"),
			size = 20,
			color = 0x797154,
		}):addTo(bg):align(display.LEFT_CENTER, 30, 23)

		display.newSprite("upgrade_prohibited.png"):align(display.RIGHT_CENTER,517,23):addTo(bg)
    	item:addContent(bg)
    	item:setItemSize(547, 46)
    	self.authority_list:addItem(item)
    end
    self.authority_list:reload()


    local button = WidgetPushButton.new({normal = "yellow_btn_up.png",pressed = "yellow_btn_down.png"})
    :addTo(bg):pos(304,listBg:getPositionY() - listBg:getContentSize().height - 40)
    :setButtonLabel("normal",
    	UIKit:ttfLabel({
			text = _("竞选盟主"),
			size = 18,
			color = 0xfff3c7,
			shadow = true,
		})
    )
    :setButtonLabelOffset(0, 15)
    local gem_bg = display.newSprite("alliance_title_gem_bg_154x20.png"):addTo(button):align(display.TOP_CENTER,0,0)
    local gem_icon = display.newSprite("gem_66x56.png"):scale(0.4):align(display.LEFT_BOTTOM, 10, 0):addTo(gem_bg)
    UIKit:ttfLabel({
			text = "2000",
			size = 20,
			color = 0xfff3c7,
	}):align(display.LEFT_BOTTOM, gem_icon:getPositionX()+gem_icon:getContentSize().width*0.4+20, -3):addTo(gem_bg)

	 UIKit:ttfLabel({
			text = _("盟主离线超过7D可以使用竞选盟主和盟主职位兑换"),
			size = 18,
			color = 0x7e0000,
	}):align(display.TOP_CENTER, 304, button:getPositionY() - 50):addTo(bg)
end

function GameUIAllianceTitle:OnEditAllianceTitle(newTitle)
	 NetManager:getEditTitleNamePromise(self.title_,newTitle):next(function()
	 	local alliance = Alliance_Manager:GetMyAlliance()
		print(alliance:GetTitles()[self.title_])
	 end)
end

return GameUIAllianceTitle