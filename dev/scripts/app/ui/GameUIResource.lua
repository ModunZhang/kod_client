--
-- Author: Danny He
-- Date: 2014-09-13 10:30:04
--
local GameUIResource = UIKit:createUIClass("GameUIResource","GameUIUpgradeBuilding")
local ResourceManager = import("..entity.ResourceManager")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")
local City = City
local MAX_COUNT_DECORATOR = 5
local UIListView = import(".UIListView")
local window = import("..utils.window")
function GameUIResource:ctor(building)
    GameUIResource.super.ctor(self, City, self:GetTitleByType(building),building)
    self.building = building
    self.dataSource = self:GetDataSource()
end


function GameUIResource:onEnter()
    GameUIResource.super.onEnter(self)
    self:CreateUI()
end
function GameUIResource:CreateUI()
    self:CreateInfomation()
    self:createTabButtons()
end

function GameUIResource:createTabButtons()
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "infomation",
        }
    },
    function(tag)
        if tag == 'infomation' then
            self.infomationLayer:setVisible(true)
            self:RefreshListView()
        else
            self.infomationLayer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
end


function GameUIResource:CreateInfomation()
    local infomationLayer = display.newNode():addTo(self)
    self.infomationLayer = infomationLayer
    local iconBg = display.newSprite("resource_icon_background.png"):align(display.LEFT_TOP, window.left+60, window.top - 110):addTo(infomationLayer)
    display.newSprite("resource_icon.png"):align(display.CENTER, iconBg:getContentSize().width/2, iconBg:getContentSize().height/2):addTo(iconBg)
    local lvBg = display.newSprite("LV_background.png"):align(display.LEFT_TOP, window.left+60, iconBg:getPositionY()-iconBg:getContentSize().height-10):addTo(infomationLayer)
    local lvLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "OWN 998",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        -- dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
    }):addTo(lvBg):align(display.CENTER,lvBg:getContentSize().width/2,lvBg:getContentSize().height/2)

    local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("拆除这个建筑"),
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x29261c),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer):align(display.LEFT_TOP,iconBg:getPositionX()+iconBg:getContentSize().width+20,iconBg:getPositionY())

    local chaiButton = cc.ui.UIPushButton.new({normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"}, {scale9 = false})
        :addTo(infomationLayer)
        :align(display.TOP_RIGHT, window.right-60, iconBg:getPositionY())
        :setButtonLabel("normal",  cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("拆除"),
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0xffedae),
        }))
        :setButtonLabelOffset(0, 2)
        :onButtonClicked(function(event)
            self:ChaiButtonAction(event)
        end)
    local fistLine = display.newScale9Sprite("dividing_line.png")
        :align(display.BOTTOM_LEFT, titleLable:getPositionX(),lvBg:getPositionY()+lvBg:getContentSize().height-15)
        :addTo(infomationLayer)

    local firstLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("返还城民"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        -- dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
        :align(display.LEFT_BOTTOM,fistLine:getPositionX(),fistLine:getPositionY()+2)

    local firstValueLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "-100",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        -- dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
        :align(display.RIGHT_BOTTOM,chaiButton:getPositionX(),firstLable:getPositionY())
    self.firstValueLabel = firstValueLabel
    local secondLine = display.newScale9Sprite("dividing_line.png")
        :align(display.BOTTOM_LEFT, firstLable:getPositionX(),lvBg:getPositionY()-lvBg:getContentSize().height)
        :addTo(infomationLayer)

    local secondLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("城民增长"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        -- dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
        :align(display.LEFT_BOTTOM,secondLine:getPositionX(),secondLine:getPositionY()+2)
    self.secondLabel = secondLabel
    self.secondValueLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "-100/h",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        -- dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
        :align(display.RIGHT_BOTTOM,chaiButton:getPositionX(),secondLabel:getPositionY())

    -- local listHeader = display.newScale9Sprite("resources_background_header.png")
    --     :addTo(infomationLayer)
    --     :align(display.TOP_LEFT, window.left+45,secondLine:getPositionY()-30)

    -- cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = _("总计"),
    --     font = UIKit:getFontFilePath(),
    --     size = 24,
    --     align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
    --     -- dimensions = cc.size(listHeader:getContentSize().width, listHeader:getContentSize().height),
    --     color = UIKit:hex2c3b(0x403c2f),
    --     valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    -- })
    -- :addTo(listHeader,5)
    -- :pos(listHeader:getContentSize().width/2,listHeader:getContentSize().height/2)

    self.info = WidgetInfoWithTitle.new({
        title = _("总计"),
        h = 226
    }):addTo(self.infomationLayer)
        :align(display.TOP_CENTER, window.cx,secondLine:getPositionY()-30)

    self.listView = self.info:GetListView()
    self.infomationLayer:setVisible(false)
end


function GameUIResource:GetListItem(index,title,val)
    local bgImage = string.format("resource_item_bg%d.png",tonumber(index-1)%2)
    local item = self.listView:newItem()
    local bg = display.newSprite(bgImage)
    local titleLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = title,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
        :addTo(bg)
        :pos(10,20)
    local valLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = val,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
        :addTo(bg)
    valLabel:pos(bg:getContentSize().width - valLabel:getContentSize().width - 10 , 20)
    item:addContent(bg)
    item:setItemSize(bg:getContentSize().width,bg:getContentSize().height)
    return item
end

function GameUIResource:RefreshListView()
    -- self.listView:removeAllItems()
    -- for i,v in ipairs(self.dataSource) do
    --     local newItem = self:GetListItem(i,v[1],v[2])
    --     self.listView:addItem(newItem)
    -- end
    -- self.listView:reload()
    self.info:CreateInfoItems(self.dataSource)
end

function GameUIResource:GetDataSource()
    local dataSource = {{_('待建地基'),'x' .. #City:GetRuinsNotBeenOccupied()}}
    local decorators = City:GetDecoratorsByType(self.building:GetType())
    table.insert(dataSource,{_('可建造数量'),#decorators .. '/' .. MAX_COUNT_DECORATOR})

    local number = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType()):GetResourceValueByCurrentTime(app.timer:GetServerTime())
    table.insert(dataSource,{_('当前产出'),string.format('%d',number)})
    local levelTable = {}
    for _,v in ipairs(decorators) do
        if levelTable[tostring(v:GetLevel())] then
            table.insert(levelTable[tostring(v:GetLevel())],v)
        else
            levelTable[tostring(v:GetLevel())] = {v}
        end
    end
    local title = self:GetTitleByType(self.building)
    for k,v in pairs(levelTable) do
        table.insert(dataSource,{title .. ' LV ' .. k ,'x' .. #v})
    end
    return dataSource
end


function GameUIResource:GetTitleByType(building)
    local type = building:GetUpdateResourceType()
    if type == ResourceManager.RESOURCE_TYPE.WOOD then
        return _('木工小屋'),_('木材产量')
    elseif type == ResourceManager.RESOURCE_TYPE.IRON then
        return _('矿工小屋'),_('铁矿产量')
    elseif type == ResourceManager.RESOURCE_TYPE.STONE then
        return _('石匠小屋'),_('石料产量')
    elseif type == ResourceManager.RESOURCE_TYPE.FOOD then
        return _('农夫小屋'),_('粮食产量')
    elseif type == ResourceManager.RESOURCE_TYPE.POPULATION then
        return _('住宅'),_('城民产量')
    else
        assert(false)
    end
end

function GameUIResource:onMoveInStage()
    GameUIResource.super.onMoveInStage(self)
    local resource = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType())
    local citizen = self.building:GetCitizen()
    self.firstValueLabel:setString(string.format('%d',citizen))
    local _,resource_title = self:GetTitleByType(self.building)
    self.secondLabel:setString(resource_title)
    self.secondValueLabel:setString(string.format("%d/h",resource:GetProductionPerHour()))
end

function GameUIResource:ChaiButtonAction( event )
    if self.building:IsUpgrading() or self.building:IsBuilding() then
        UIKit:showMessageDialog(_("提示"), _("正在建造或者升级小屋,不能拆除!"), function()end)
        return
    end
    -- if tonumber(City:GetUser():GetGemResource():GetValue()) < 100 then
    --     UIKit:showMessageDialog(_("提示"), _("宝石不足"), function()end)
    --     return
    -- end
    local tile = self.city:GetTileWhichBuildingBelongs(self.building)
    local house_location = tile:GetBuildingLocation(self.building)

    NetManager:getDestroyHouseByLocationPromise(tile.location_id, house_location)
        :catch(function(err)
            dump(err:reason())
        end)
    self:leftButtonClicked(nil)
end

function GameUIResource:onMoveOutStage()
    self.dataSource = nil
    self.building = nil
    GameUIResource.super.onMoveOutStage(self)
end

function GameUIResource:OnResourceChanged(resource_manager)
    GameUIResource.super.OnResourceChanged(self,resource_manager)
    -- if self.listView:getItems():count() < 2 then return end
    local number = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType()):GetResourceValueByCurrentTime(app.timer:GetServerTime())
    -- print("update cout:",number)
end

return GameUIResource


