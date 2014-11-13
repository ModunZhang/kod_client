-- 需求列表控件
local UIListView = import("..ui.UIListView")
local WidgetRequirementListview = class("WidgetRequirementListview", function ()
    return display.newLayer()
end)

function WidgetRequirementListview:ctor(parms)
    self:setNodeEventEnabled(true)
    self.title = parms.title
    self.listview_height = parms.height
    self.listview_width = 520
    self.listParms = parms.listParms
    self.contents = parms.contents

    self.width = 548
    self:setContentSize(cc.size(self.width, self.listview_height+50))
    self:setAnchorPoint(cc.p(0.5,0))

    print("onEnter-> WidgetRequirementListview",display.height)
    local list_bg = display.newScale9Sprite("upgrade_requirement_background.png", 0, 0,cc.size(self.width, self.listview_height))
        :align(display.LEFT_BOTTOM):addTo(self)
    local title_bg = display.newSprite("upgrade_resources_title.png", x, y):align(display.CENTER_BOTTOM, self.width/2, self.listview_height):addTo(self)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = self.title ,
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,self.width/2, 25):addTo(title_bg)
    self.listview = UIListView.new({
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(0,0, self.listview_width, self.listview_height-20),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL})
        :addTo(list_bg,2):pos((self.width-self.listview_width)/2, 12)

    -- 缓存已经添加的升级条件项,供刷新时使用
    self.added_items = {}
    self:RefreshListView(self.contents)
end


function WidgetRequirementListview:RefreshListView(contents)
    --有两种背景色的达到要求的显示条，通过meeFlag来确定选取哪一个
    local meetFlag = true

    for k,v in pairs(contents ) do
        -- print(k,v)
        if v.isVisible then
            -- 需求已添加，则更新最新资源数据
            if self.added_items[v.resource_type] then
                -- print("需求已添加，则更新最新资源数据 ",v.resource_type)
                local added_resource = self.added_items[v.resource_type]
                local content = added_resource:getContent()
                if meetFlag then
                    content.bg:setTexture("upgrade_resources_background_3.png")
                else
                    content.bg:setTexture("upgrade_resources_background_2.png")
                end
                meetFlag =  not meetFlag
                if v.isSatisfy then
                    -- 符合条件，添加钩钩图标
                    content.mark:setTexture("upgrade_mark.png")
                else
                    -- content.bg:setTexture("upgrade_resources_background_red.png")
                    -- 不符合条提案，添加!图标
                    -- content.mark:setTexture("upgrade_prohibited.png")
                    content.mark:setTexture("upgrade_warning.png")
                end
                content.resource_value:setString(v.resource_type.." "..v.description)
            else
                -- 添加新条件
                print("添加新条件",v.resource_type)
                local item = self.listview:newItem()
                local item_width,item_height = self.listview_width,48
                item:setItemSize(item_width,item_height)
                local content = cc.ui.UIGroup.new()
                --  筛选不同背景颜色 bg
                if meetFlag then
                    content.bg = display.newSprite("upgrade_resources_background_3.png", 0, 0):addTo(content)
                else
                    content.bg = display.newSprite("upgrade_resources_background_2.png", 0, 0):addTo(content)
                end
                meetFlag =  not meetFlag
                if v.isSatisfy then
                    -- 符合条件，添加钩钩图标
                    content.mark = display.newSprite("upgrade_mark.png", item_width/2-25, 0):addTo(content)
                else
                    -- content.bg = display.newSprite("upgrade_resources_background_red.png", 0, 0):addTo(content)
                    -- 不符合条提案，添加X图标
                    content.mark = display.newSprite("upgrade_warning.png", item_width/2-25, 0):addTo(content)
                end
                -- 资源类型icon
                local resource_type_icon = display.newSprite(v.icon, -item_width/2+35, 0):addTo(content)
                resource_type_icon:setScale(40/resource_type_icon:getContentSize().width)
                content.resource_value = cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = v.resource_type.." "..v.description,
                    font = UIKit:getFontFilePath(),
                    size = 22,
                    color = UIKit:hex2c3b(0x403c2f)
                }):align(display.LEFT_CENTER,-180,0):addTo(content)
                item:addContent(content)
                self.listview:addItem(item)
                self.added_items[v.resource_type] = item
                self.listview:reload()
            end
        else
            -- 刷新时已经没有此项条件时，删除之前添加的项
            if self.added_items[v.resource_type] then
                -- print("刷新时已经没有此项条件时，删除之前添加的项",v.resource_type)
                self.listview:removeItem(self.added_items[v.resource_type])
                self.listview:reload()
            end
        end
    end
end

return WidgetRequirementListview


