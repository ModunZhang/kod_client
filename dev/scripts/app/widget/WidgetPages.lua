local WidgetPushButton = import(".WidgetPushButton")

local WidgetPages = class("WidgetPages", function ()
    return display.newSprite("shire_stage_title_564x58.png")
end)

function WidgetPages:ctor(params)
    self.page = params.page -- 页数
    self.titles = params.titles -- 标题 type -> table
    self.cb = params.cb or function ()end -- 回调
    self.current_page = params.current_page or 1
    local icon_image = params.icon

    -- 标题icon
    local icon
    if icon_image then
        icon = cc.ui.UIImage.new(icon_image):addTo(self)
            :align(display.LEFT_CENTER, 70, 28)
    end
    self.title_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x5d563f
    })
        :align(display.LEFT_BOTTOM,icon and icon:getContentSize().width + 80 or 70,15)
        :addTo(self)
    local page_label = UIKit:ttfLabel({
        text = "/"..self.page,
        size = 20,
        color = 0x5d563f
    })
        :align(display.RIGHT_BOTTOM,480,15)
        :addTo(self)
    self.current_page_label = UIKit:ttfLabel({
        text = self.current_page,
        size = 20,
        color = 0x5d563f
    })
        :align(display.RIGHT_BOTTOM,page_label:getPositionX() - page_label:getContentSize().width,15)
        :addTo(self)

    self.left_button = WidgetPushButton.new(
        {normal = "shrine_page_btn_normal_52x44.png",pressed = "shrine_page_btn_light_52x44.png"},
        {scale9 = false},
        {disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}}
    ):addTo(self):align(display.LEFT_CENTER,7,29)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:ChangePage_(-1)
            end
        end)
    local icon = display.newSprite("shrine_page_control_26x34.png")
    icon:setFlippedX(true)
    icon:addTo(self.left_button):pos(26,0)

    self.right_button = WidgetPushButton.new(
        {normal = "shrine_page_btn_normal_52x44.png",pressed = "shrine_page_btn_light_52x44.png"},
        {scale9 = false},
        {disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}}
    ):addTo(self):align(display.RIGHT_CENTER,557,29)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:ChangePage_(1)
            end
        end)
    display.newSprite("shrine_page_control_26x34.png")
        :addTo(self.right_button)
        :pos(-26,0)
    self:SelectPage_(self.current_page)
end
--翻页 false ->left true->right
function WidgetPages:ChangePage_(page_change)
    local to_page = 1
    local change = self.current_page + page_change
    if page_change>0 then
        to_page = change >= self.page and self.page or change
    else
        to_page = change <= 1 and 1 or change
    end
    self.left_button:setButtonEnabled(to_page ~= 1)
    self.right_button:setButtonEnabled(to_page ~= self.page)

    self.title_label:setString(self.titles[to_page])
    self.current_page = to_page
    self.current_page_label:setString(to_page)
    self.cb(to_page)
end
function WidgetPages:SelectPage_(page)
    self.title_label:setString(self.titles[page])
    self.left_button:setButtonEnabled(page ~= 1)
    self.right_button:setButtonEnabled(page ~= self.page)
    self.current_page = page
end
return WidgetPages





