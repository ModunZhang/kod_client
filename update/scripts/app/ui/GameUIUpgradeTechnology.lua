--
-- Author: Danny He
-- Date: 2014-12-17 19:30:23
--
local GameUIUpgradeTechnology = UIKit:createUIClass("GameUIUpgradeTechnology")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetRequirementListview = import("..widget.WidgetRequirementListview")
local HEIGHT = 694
local window = import("..utils.window")

function GameUIUpgradeTechnology:onEnter()
	GameUIUpgradeTechnology.super.onEnter(self)
	self:BuildUI()
end

function GameUIUpgradeTechnology:BuildUI()
	UIKit:shadowLayer():addTo(self)
	local bg_node =  WidgetUIBackGround.new({height = HEIGHT,isFrame = "no"}):addTo(self):align(display.TOP_CENTER, window.cx, window.top_bottom)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png"):align(display.BOTTOM_CENTER,304,HEIGHT - 15):addTo(bg_node)
	UIKit:closeButton():align(display.RIGHT_BOTTOM,600, 0):addTo(title_bar):onButtonClicked(function()
		self:leftButtonClicked()
	end)
	UIKit:ttfLabel({text = _("科技研发"),
		size = 22,
        color = 0xffedae
    }):align(display.CENTER,300, 22):addTo(title_bar)
    local box = display.newSprite("alliance_item_flag_box_126X126.png"):align(display.LEFT_TOP, 20, title_bar:getPositionY() - 20):addTo(bg_node)
    display.newSprite("technology_bg_116x116.png", 63, 63):addTo(box):scale(0.95)
    local title = display.newSprite("technology_title_438x30.png")
    	:align(display.LEFT_TOP,box:getPositionX()+box:getContentSize().width + 10, box:getPositionY())
    	:addTo(bg_node)
    UIKit:ttfLabel({
    	text = "盾墙 LV 2",
    	size = 22,
    	color= 0xffedae
    }):align(display.LEFT_CENTER, 20, 15):addTo(title)
    local line_2 = display.newScale9Sprite("dividing_line_594x2.png"):size(422,1)
    	:align(display.LEFT_BOTTOM,box:getPositionX()+box:getContentSize().width + 10, box:getPositionY()-box:getContentSize().height)
    	:addTo(bg_node)
    local next_effect_desc = UIKit:ttfLabel({
    	text = _("下一级"),
    	size = 20,
    	color= 0x797154
    }):align(display.LEFT_BOTTOM,line_2:getPositionX(), line_2:getPositionY() + 5):addTo(bg_node)

    local next_effect_val = UIKit:ttfLabel({
    	text = "15%",
    	size = 22,
    	color= 0x403c2f
    }):align(display.RIGHT_BOTTOM,line_2:getPositionX()+line_2:getContentSize().width, next_effect_desc:getPositionY()):addTo(bg_node)

    local line_1 = display.newScale9Sprite("dividing_line_594x2.png"):size(422,1)
    	:align(display.LEFT_BOTTOM,line_2:getPositionX(), line_2:getPositionY() + 40)
    	:addTo(bg_node)

    local current_effect_desc = UIKit:ttfLabel({
    	text = _("提升木材生产效率"),
    	size = 20,
    	color= 0x797154
    }):align(display.LEFT_BOTTOM,line_1:getPositionX(), line_1:getPositionY() + 5):addTo(bg_node)

   	local current_effect_val = UIKit:ttfLabel({
    	text = "15%",
    	size = 22,
    	color= 0x403c2f
    }):align(display.RIGHT_BOTTOM,line_1:getPositionX()+line_1:getContentSize().width, current_effect_desc:getPositionY()):addTo(bg_node)

   local btn_now = UIKit:commonButtonWithBG(
    {
        w=250,
        h=65,
        style = UIKit.BTN_COLOR.GREEN,
        labelParams = {text = _("立即研发")},
        listener = function ()
        end,
    }):align(display.LEFT_TOP, 30, line_2:getPositionY() - 30)
    :addTo(bg_node)


    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams={text = _("研发")},
            listener = function ()
           
            end,
        }
    ):align(display.RIGHT_TOP, line_2:getPositionX()+line_2:getContentSize().width, line_2:getPositionY() - 30)
     :addTo(bg_node)
    local gem = display.newSprite("Topaz-icon.png")
    	:addTo(bg_node)
    	:scale(0.5)
    	:align(display.LEFT_TOP, btn_now:getPositionX(), btn_now:getPositionY() - 65 - 10)

    UIKit:ttfLabel({
    	text = "600",
    	size = 20,
    	color= 0x403c2f
    }):align(display.LEFT_TOP,gem:getPositionX() + gem:getCascadeBoundingBox().width + 10, gem:getPositionY()):addTo(bg_node)


    --升级所需时间
    local time_icon = display.newSprite("upgrade_hourglass.png")
    	:addTo(bg_node)
    	:scale(0.6)
    	:align(display.LEFT_TOP, btn_bg:getPositionX() - 185,btn_bg:getPositionY() - 65 - 10)
    UIKit:ttfLabel({
    	text = "20:10:10",
    	size = 18,
    	color= 0x403c2f
    }):align(display.LEFT_TOP, time_icon:getPositionX()+time_icon:getCascadeBoundingBox().width + 10, time_icon:getPositionY()):addTo(bg_node)

	UIKit:ttfLabel({
		text = "(-00:20:00)",
		size = 18,
		color= 0x068329
	}):align(display.LEFT_TOP,time_icon:getPositionX()+time_icon:getCascadeBoundingBox().width + 10,time_icon:getPositionY()-20):addTo(bg_node)
    local requirements = {
       {resource_type = _("木材"),isVisible = true,isSatisfy = true,icon="wood_icon.png",description="100/100"}
   }


   	self.listView = WidgetRequirementListview.new({
            title = _("研发需求"),
            height = 270,
            contents = requirements,
    }):addTo(bg_node):pos(30,40)
end

return GameUIUpgradeTechnology